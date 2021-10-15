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

; %include 'functions.asm' need to pragma each asm file

; non-negative lookup numbers
; first two bits are size
; 00 - four bits total, two for the size, two for the index
; 01 - eight bits total, two for the size, six for the index
; 10 - half of the system max bits, two for the size, ((system max)/2 -2) for the index
; 11 - full system max bits, two for the size, ((system max)-2) for the index

; for index in rdx
; move to rbx
; left shift twice
; right shift twice
; take the difference
; return lookup table value
get_indexSize:
	push	rbx
	push	rcx
	mov	rcx,	1100000000000000000000000000000000000000000000000000000000000b	; apparently nasm doesn't like using 64 binary immediate with "and"
	mov	rbx,	rdx	; copy rdx into rbx
	and	rbx,	rcx	; bit mask the top two
	mov	rax,	4
	cmp	rbx,	0
	jmp	.indexFoundSize
	shl	rbx,	2
	mov	rcx,	0100000000000000000000000000000000000000000000000000000000000b 	; apparently nasm doesn't like using 64 binary immediate with "cmp"
	cmp	rbx,	rcx
	jmp	.indexFoundSize
	call	getSysMaxBits
	mov	rcx,	1100000000000000000000000000000000000000000000000000000000000b	; apparently nasm doesn't like using 64 binary immediate with "cmp"
	cmp	rbx,	rcx
	jmp	.indexFoundSize
	shr	rax,	1
	;cmp	rbx,	1100000 00000000 00000000 00000000 00000000 00000000 00000000 00000000b
.indexFoundSize:
	pop	rcx
	pop	rbx
	;*!* should the registers be zero'd out?

	ret

set_indexSize:
    ; compute the number of bits needed to store the index
    ; convert the index to a sized index
    ret

get_indexValue:
    ; get the indexSize
    ; set register to zero
    ; place index value in register
    ret

compute_indexSize:
	; return four bits depending on value in rdx
	push	rcx
	mov	rcx,	rdx
	shl	rcx,	2
	cmp	rcx,	0
	jmp	.indexSize2
	shl	rcx,	4
	cmp	rcx,	0
	jmp	.indexSize6
	call	getSysMaxBits
	shl	rbx,	1
	shl	rcx,	rbx
	cmp	rcx,	0
	jmp	.indexSizeHalfMax
	; otherwise indexSize is max
	mov	rax,	11b
	jmp	.indexFoundSize
.indexSize2:
	mov	rax,	00b
	jmp	.indexFoundSize
.indexSize4:
	mov	rax,	01b
	jmp	.indexFoundSize
.indexSizeHalfMax:
	mov	rax,	10b
.indexFoundSize:
	pop	rcx
	ret
; compare two indices
; Greater Than
cmp_indices:
    ; get index value from sized index in register a
    ; get index value from sized index in register b
    ; premature optamization - compare the sizes first
    ; then only when the sizes are the same, do the values need to be compared
    ; if regA > regB, then set zero flag to true
    ; if regA == regB, then set negative flage to true
    ; if regA < regB zero flag is false
    ; if regA <> regB then negative flag is false
    ret
