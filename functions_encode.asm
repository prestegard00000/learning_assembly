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

%ifndef headers
	%define headers
push_index_parameter_onStack_create:
	; encode index on rax
	mov	rax,	rax
	; call	get_indexSize_bytes_decoded
	; create index space on stack
	sub	rsp,	16
	call	push_index_parameter_onStack
	ret

push_index_parameter_onStack:
	mov	qword	[rsp + 16],	rax
	ret

pop_index_parameter_offStack:
	mov	rax,	qword	[rsp - 16]
	
	; get first byte
	; calcuate size
	; get the rest of the bytes
	; move encoded index into rax
	; clear size
	ret

pop_index_parameter_offStack_clear:
	call	pop_index_parameter_offStack
	add	rsp,	16
	ret

push_memory_parameter_onStack_create:
	sub	rsp,	16
	mov	qword	[rsp+16],	rax
	ret

push_memory_parameter_onStack:
	mov	qword	[rsp+16],	rax

	ret

pop_memory_parameter_offStack:
	mov	rax,	qword	[rsp+16]
	ret

pop_memory_parameter_offStack_clear:
	call	pop_memory_parameter_offStack
	add	rsp,	16
	ret



%endif
