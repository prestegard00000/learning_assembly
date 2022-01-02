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

section .text
; other library.asm files can be included using %include 'fileName.asm'
; not sure if %include is required to be in the .text section
; code goes in the .text section
%include 'functions.asm'

%include 'index.asm'		; how to handel index data types

%include 'tests/unit_tests.asm'	; **!** needs a mechanism to exclude tests

%include 'functions_encode.asm' ; move values to and from stack

global _start ; _start must be declared as a global for the linker

;start the actual program
_start:
; run some code here
; test print function
; **!** need to move these tests to the testing framework
	mov	rcx,	msg1
	call	print_rcx

; test file function
	mov	rcx,	filename_test
	call	print_rcx

; create file
	mov	rdi,	filename_test
	mov	rbx,	fd_test
	call	fileCreate

; test file function
	mov	rcx,	filename_test
	call	print_rcx

; print message to file
	mov	rcx, msg1
	call	fileWrite

; close file
	mov	rbx,	fd_test
	call	fileClose

; test file function
	mov	rcx,	filename_test
	call	print_rcx


; testing framework for index.asm
	mov	rcx,	LF
	call	print_rcx
	mov	rcx,	msg_testBegin
	call	print_rcx
	mov	rcx,	LF
	call	print_rcx
	call	index__set_get_test_all

	push	rax
	xor	rax,	rax
	mov	rax,	msg2
	sub	rsp,	16
	mov	qword	[rsp],	rax
	call	convert_number_to_string_onStackTEST
	mov	rcx,	qword	[rsp]
	add	rsp,	16
	call	print_rcx
	;pop	rax

; testing framework for pushing an index on and off the stack
	push	rax
	mov	rax,	5555
	call	index__on_and_off_stackTEST
	pop	rax
	

	call	conversion_binaryTObaseTEST

	call	QUIT


;---------------------------------------------------------------------------------
;---------------------------------------------------------------------------------
;---------------------------------------------------------------------------------


; .data contains constant variables ?
section .data

    filename_test db "test.txt", 0
    fd_test dq 0

	msg_testBegin	db	"tests begin: ",	0Ah,	0h
	msg_passed	db	".",	0Ah,	0h
	msg_failed	db	"x",	0Ah,	0h
    msg1  db "Hello world!", 0Ah, 0h
    msg2  db "Hello space!", 0Ah, 0h
    LF    db 0AH, 0h   ; 'line feed'
    zero  db 30H, 0h   ; '0'
    one   db 31H, 0h   ; '1'

; .bss contains variable variables ?
section .bss
variable: RESB 1 ; reserve 1 byte for the variable variable
register_array_64BitMax: RESB	67 ;	db	"0000000000000000000000000000000000000000000000000000000000000000b",	0Ah,	0h
