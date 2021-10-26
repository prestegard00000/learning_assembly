; MIT License

; Copyright (c) 2021 Aaron Prestegard (prestegard00000@gmail.com)

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
%ifndef functions
	%define functions
section .text ;section .text in an include file did not throw an error

;---------------------------------------------------------------------------------
; returns rbx as memory location of file pointer
; fileCreate( filename rdi, fileDiscriptorAddress rbx)
;
fileCreate:
	mov	rcx,	rdi
	call	slen
	mov	rax,	rdx
	mov	rsi,	0102o	; O_Create, man open
	mov	rdx,	0666o	; umode_t
	mov	rax,	2	; syscall: open
	syscall
	mov [rbx], rax
	ret

;---------------------------------------------------------------------------------
; void fileWrite(msg rsi, filediscriptoraddress rbx)
fileWrite:
	push	rax		; save rax
	push	rcx		; save rcx
	push	rdx		; save rdx
	mov	rsi,	rcx	; copy message to rcx for slen
	call	slen		; get string length
	mov	rdx,	rax	; move string length to rdx for syscall
	mov	rdi,	[rbx]	; move file discriptor to rdi for syscall
	mov	rax,	1	; move 1 to rax for syscall
	syscall
	pop	rdx
	pop	rcx
	pop	rax
	ret



;---------------------------------------------------------------------------------
; void fileClose(fileDiscriptorAddress rbx)
fileClose:
   mov   rdi, [rbx]
   mov   rax, 3		; sys_close for syscall
   syscall
   ret
   


;---------------------------------------------------------------------------------
; rcx contains value(string) to print
print_rcx:
   push  rdx
   push  rcx
   push  rbx
   push  rax
   call slen

   mov  rdx, rax
   mov  rbx, 1
   mov  rax, 4
   int  80h
   syscall
   pop  rax
   pop  rbx
   pop  rcx
   pop  rdx

   ret


;---------------------------------------------------------------------------------
; get register id via rax
; **!** this picker needs to be outside rax, so rax can be printed too
; push register values
; convert register into n bit array
; call print function
; pop registers
; const function
print_binary_register:
	; push values
	; find register
	; get register size
	; those two can be pushed together
	push	rdx

	cmp	rax,	1
	je	.register_rbx
	cmp	rax,	2
	je	.register_rcx
	cmp	rax,	3
	je	.register_rdx
	cmp	rax,	4
	je	.register_rsp
	cmp	rax,	5
	je	.register_rbp
	cmp	rax,	6
	je	.register_rsi
	cmp	rax,	7
	je	.register_rdi
	cmp	rax,	8
	je	.register_r8
	cmp	rax,	9
	je	.register_r9
	cmp	rax,	10
	je	.register_r10
	cmp	rax,	11
	je	.register_r11
	cmp	rax,	12
	je	.register_r12
	cmp	rax,	13
	je	.register_r13
	cmp	rax,	14
	je	.register_r14
	cmp	rax,	15
	je	.register_r15
.register_rbx:
	mov	rdx,	rbx
	jmp	.register64_loaded
.register_rcx:
	mov	rdx,	rbx
	jmp	.register64_loaded
	cmp	rax,	3	; **!** this never gets run ?
.register_rdx:
	jmp	.register64_loaded
.register_rsp:
	mov	rdx,	rsp
	jmp	.register64_loaded
.register_rbp:
	mov	rdx,	rbp
	jmp	.register64_loaded
.register_rsi:
	mov	rdx,	rsi
	jmp	.register64_loaded
.register_rdi:
	mov	rdx,	rdi
	jmp	.register64_loaded
.register_r8:
	mov	rdx,	r8
	jmp	.register64_loaded
.register_r9:
	mov	rdx,	r9
	jmp	.register64_loaded
.register_r10:
	mov	rdx,	r10
	jmp	.register64_loaded
.register_r11:
	mov	rdx,	r11
	jmp	.register64_loaded
.register_r12:
	mov	rdx,	r12
	jmp	.register64_loaded
.register_r13:
	mov	rdx,	r13
	jmp	.register64_loaded
.register_r14:
	mov	rdx,	r14
	jmp	.register64_loaded
.register_r15:
	mov	rdx,	r15

.register64_loaded:
	push	rcx
	mov	rcx,	64
	push	r9	; inverted counter
	mov	r9,	0
	push	r8	; load string array for binary	
	mov	r8,	bin_array_64Bit
.register64_loop: ; this loop could be for all the register sizes
	shl	rdx,	1
	; cmp overflow
	jc	.register64_one	;if there is overflow, then jump
	mov	byte	[r8],	'0'
	jmp	.register64_found
.register64_one:
	mov	byte	[r8],	'1'
.register64_found:
	
	inc	r8
	dec	rcx
	jnz	.register64_loop
	; does this array need a zero terminal?
	mov	byte	[r8],	'b'
	inc	r8
	mov	byte	[r8],	0Ah
	inc	r8
	mov	byte	[r8],	0h
	mov	rcx,	bin_array_64Bit	;r8 is now pointing at the end of bin_array_64Bit	
	call	print_rcx

	pop	r8
	pop	r9
	pop	rcx
	pop	rdx

	; clear rcx register
	; mov	register into rcx
	; shift bits and add to printing array (up to register size)
	; call print_rcx
	; pop registers
	ret
	


;---------------------------------------------------------------------------------
; get string length of string in rcx
; return in rax
; *!* does it need to be rcx->rbx and rcx->rax?
slen:
   push rcx
   push rbx
   mov  rbx, rcx
   mov  rax, rcx

.nextchar:
   cmp  byte [rax], 0
   jz   .finished
   inc  rax
   jmp  .nextchar

.finished:
   sub  rax, rbx
   pop  rbx
   pop  rcx

   ret

;---------------------------------------------------------------------------------
; returns the number of bits in the rax register
getSysMaxBits:
	mov	rax, 64
	ret

;---------------------------------------------------------------------------------
; quit program
QUIT:
   mov rax, 60
   syscall
   ret

;section .data ;section .data in an include file throws a segmentation fault
;   msg2 db "hello mars!", 0Ah, 0h

; section .bss ;section .bss in an include file did throw an error
; functionVariable: RESB 1 ; reserve 1 byte for the variable functionVariable

%endif
