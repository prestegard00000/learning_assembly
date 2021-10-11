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
; quit program
QUIT:
   mov rax, 60
   syscall
   ret

;section .data ;section .data in an include file throws a segmentation fault
;   msg2 db "hello mars!", 0Ah, 0h

; section .bss ;section .bss in an include file did throw an error
; functionVariable: RESB 1 ; reserve 1 byte for the variable functionVariable
