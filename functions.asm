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
	mov	r8,	register_array_64BitMax
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
	mov	rcx,	register_array_64BitMax	;r8 is now pointing at the end of register_array_64BitMax	
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
; take the rdx and return a decimal
print_rdx_decimal:

	push	rax
	push	rbx
	push	rcx
	mov	rcx,	64
	mov	rbx,	rdx
	mov	rax,	rdx
.leadingZerosloop:
	;	mul	rbx,	10	; mul bx -> ax = ax*bx with overflow into dx
	jc	.valueLoop
	mov	rax,	rbx
	dec	rcx
	jnz	.leadingZerosloop
	mov	rcx,	register_array_64BitMax
	mov	byte	[rcx],	'0'
	jmp	.done

.valueLoop:
	;div	rbx,	10
	sub	rax,	rbx
	
	
	dec	rcx
	jnz	.valueLoop


.done:
	inc	rcx
	mov	byte	[rcx],	0h
	mov	rcx,	register_array_64BitMax
	call	print_rcx

	pop	rcx
	pop	rbx
	pop	rax
	ret

;---------------------------------------------------------------------------------
; convert the binary number in rdx into a string of digits with base in rax
; return string in rax
convertBinaryToBase_String:
	;do a zero comparison and exit early
	push	rbx	; base
	push	rcx	; counter (max power of the base that is > value)
	push	rdx	; back up of the value
	push	r8	; temporary storage of the output string memory address
	push	r9	; temporary storage of the value
	push	r10	; temporary storage of the base^power
	push	r11	; amount to subtract from temp value
	
	mov	r9,	rdx
	mov	rbx,	rax
	mov	r8,	register_array_64BitMax
	mov	rdx,	0
	mov	rcx,	0	; counter
	; pop number
	; pop register size (10 bits) [1-1024]
	; pop base (12 bits) [1-4096]
	; pop leading zeros (1 bit)
	; pop append base (1 bit)
	; add the last three together and mask
	; return stack pointer array
	; **!** need a way to specify displaying leading zeros and base notation
	; do a base two conversion and exit early
	; turn base into string (using base ten)
	; append base to current string
.morePower:
	cmp	r9,	rax	; is the value (rax) less than or equal to the base to a power
	jle	.loop2		; if it is, then start decoding
	inc	rcx		; count the power of the base
	mul	rbx	; unsigned multiplication, rax = rax * rbx, with overflow into rdx
			; rbx = base, rax = base ^ rcx
	;	rdx should be zerod, so if it isn't then .tooBig
	cmp	rdx,	0
	jnz	.tooBig
	; jc	.tooBig
	jmp	.morePower
.tooBig:
	nop
	; **!** need a way to handle r9^n < rbx ^ rcx [base^power] <r9^n+1
	; subtract rbx^rcx - r9^n
	; divide by rbx^rcx
	; send new number in recursively, with same base.
	; remove base from the returned string, push in front of rest of string

.loop2:
	push	rcx
	mov	rcx,	msg1
	call	print_rcx
	pop	rcx
	; rdx should be zero'd so move rdx to r10
	div	rbx
	mov	r10,	rax
	mov	rax,	r9
	div	r10

; **!** conditional move CMOVcc	reg32/m32	; o32 of 40+cc/r
	; convert rcx to a char
	cmp	rax,	0
	je	.C00
	cmp	rax,	1
	je	.C01
	cmp	rax,	2
	je	.C02
	cmp	rax,	3
	je	.C03
	cmp	rax,	4
	je	.C04
	cmp	rax,	5
	je	.C05
	cmp	rax,	6
	je	.C06
	cmp	rax,	7
	je	.C07
	cmp	rax,	8
	je	.C08
	cmp	rax,	9
	je	.C09
	cmp	rax,	10
	je	.C10
	cmp	rax,	11
	je	.C11
	cmp	rax,	12
	je	.C12
	cmp	rax,	13
	je	.C13
	cmp	rax,	14
	je	.C14
	cmp	rax,	15
	je	.C15
	jmp	.COTHER

.C00:
	mov	byte	[r8],	'0'
	jmp	.found
.C01:
	mov	byte	[r8],	'1'
	mov	r11,	1
	jmp	.found
.C02:
	mov	byte	[r8],	'2'
	sub	rax,	2
	jmp	.found
.C03:
	mov	byte	[r8],	'3'
	jmp	.found
.C04:
	mov	byte	[r8],	'4'
	jmp	.found
.C05:
	mov	byte	[r8],	'5'
	jmp	.found
.C06:
	mov	byte	[r8],	'6'
	jmp	.found
.C07:
	mov	byte	[r8],	'7'
	jmp	.found
.C08:
	mov	byte	[r8],	'8'
	jmp	.found
.C09:
	mov	byte	[r8],	'9'
	jmp	.found
.C10:
	mov	byte	[r8],	'A'
	jmp	.found
.C11:
	mov	byte	[r8],	'B'
	jmp	.found
.C12:
	mov	byte	[r8],	'C'
	jmp	.found
.C13:
	mov	byte	[r8],	'D'
	jmp	.found
.C14:
	mov	byte	[r8],	'E'
	jmp	.found
.C15:
	mov	byte	[r8],	'F'
	jmp	.found
.COTHER:
	mov	byte	[r8],	'i'
	jmp	.found
.found:
;	pop	rdx
;	pop	rax
	inc	r8
	dec	rcx
	cmp	r10,	1
	je	.done

	;mov	rax,	rdx
	
	mul	r10
	sub	r9,	rax
	;mov	r9,	rax
	;mov	rax,	r11
	;mul	r10
	;sub	r9,	rax
	mov	rax,	r10
	
	
	;cmp	rcx,	0
	;	mov	rax,	rcx
	jmp	.loop2
.done:
	;	add the b{base number}
	mov	byte	[r8],	'b'
	inc	r8
	mov	byte	[r8],	0Ah
	inc	r8
	mov	byte	[r8],	0h
	
	mov	rax,	register_array_64BitMax

	pop	r11
	pop	r10
	pop	r9
	pop	r8
	pop	rdx
	pop	rcx
	pop	rbx

	push	rcx
	mov	rcx,	msg1
	call	print_rcx
	pop	rcx
	
	ret

;---------------------------------------------------------------------------------
; attempting to pass 64 bits and 24 bits from stack
; returning some number of bytes on stack
convert_number_to_string_onStack:
	xor	rcx,	rcx
	mov	rcx,	qword	[rsp+16]
	call	print_rcx
	mov	rcx,	msg1
	call	print_rcx
	xor	rcx,	rcx
	mov	qword	[rsp - 16],	msg2
;	pop	r9	; value (64 bits)
;	pop	r10	; metaData (24 bits)
;	push	rbx	; save for later - now the total base^power
;	push	rcx	; save for later - now the power count
;	push	rdi	; save for later?
;	push	r13	; string pointer
	
;	mov	rax,	r10	; extrack register size, via masking
;	and	rax,	1111111111b	; register size
;	mov	r11,	r10
;	shr	r11,	10
;	and	r11,	00111111111111b ; base amount
;	mov	r12,	r10	; meta data
;	shr	r12,	22	; 1- include base number in string, -1 include leading zeros
;	push	r12
;	shr	r12,	1
;	cmp	r12,	1
;	jne	.skip_base
;	push	000000000011000000001010b
;	push	r11
;	call	convert_number_to_string_onStack
;	pop	r13	;	(pointer to string Array)
;	
;.skip_base:
;	pop	r12
	; pop	r13	; pointer to string of decimal of base number (zero terminated)
	
	;	stick	r13 pointer onto the stack
;	push	r13
;	pop	r13
;	pop	rdi
;	pop	rcx
;	pop	rbx
	
	; push	r13
	
	; push	
	
	 
	; push	
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
