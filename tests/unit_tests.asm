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

%ifndef tests
	%define tests
; **!** could use some push and pop to make it safer
; **!** could use a throw error mechanism
convert_number_to_string_onStackTEST:
	;push	100000000010100001000000b
	;push	12345
	call	convert_number_to_string_onStack
	;pop	rdx
	;call	print_rdx_decimal
	ret


conversion_binaryTObaseTEST:
	push	rdx
	push	rax
	push	rcx
	mov	rax, 10
	mov	rdx, 15894
	call convertBinaryToBase_String
	mov	rcx,	rax
	call	print_rcx
	pop	rcx
	pop	rax
	pop	rdx
	ret

index__set_get_test_all:
	call	index__set_get_test1
	call	index__set_get_test2
	call	index__set_get_test3
	call	index__set_get_test4
	ret

index__set_get_test1:
	push	rdx
	mov	rdx,	0
	call	index__set_get_test_rdx
	pop	rdx
	ret

index__set_get_test2:
	push	rdx
	mov	rdx,	1
	call	index__set_get_test_rdx
	pop	rdx
	ret

index__set_get_test3:
	push	rdx
	mov	rdx,	36546848
	call	index__set_get_test_rdx
	pop	rdx
	ret

index__set_get_test4:
	push	rdx
	mov	rdx,	6648634333
	call	index__set_get_test_rdx
	pop	rdx
	ret

index__set_get_test_rdx:
	mov	rax,	3	; print the binary of rdx
	call	print_binary_register
	call	set_indexValue_encoded
	call	get_indexValue_decoded
	mov	rax,	2	; print the binary of rcx
	call	print_binary_register
	cmp	rbx,	0
	jmp	.passed
	mov	rcx,	msg_failed
	call	print_rcx
	jmp	.end_test
.passed:
	mov	rcx,	msg_passed
	call	print_rcx
	call	print_rcx
.end_test:
	ret
	

%endif	
