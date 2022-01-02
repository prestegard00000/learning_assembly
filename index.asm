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

%ifndef index
	%define index
; non-negative lookup numbers
; first two bits are size
; 00 - four bits total, two for the size, two for the index
; 01 - eight bits total, two for the size, six for the index
; 10 - half of the system max bits, two for the size, ((system max)/2 -2) for the index
; 11 - full system max bits, two for the size, ((system max)-2) for the index


; decode the encoded index size in rdx 2 bits
; remove 2 bits for index size
; return int amount in rbx
decode_indexSize:
	mov	rbx,	4
	cmp	rdx,	00b
	je	.indexSizeDecoded
	mov	rbx,	8
	cmp	rdx,	01b
	je	.indexSizeDecoded

	call	getSysMaxBits	; (const) into rbx

	cmp	rdx,	11b
	je	.indexSizeDecoded
	shr	rbx,	1

.indexSizeDecoded:
	sub	rbx,	2

	ret
	

; for sized encoded index value in rdx
; put 11 in the 2  most signigicant bits for system max 
; and with rdx
; shift right system max - 2
; return rax ints from size lookup table
get_indexSize_encoded:
	push	rbx
	call	getSysMaxBits	; into rbx
				; assume that all the registers are SysMaxBits
	sub	rbx,	2	; get the number of bits to shift
	mov	rax,	rdx
	shr	rax,	62	; **!** This value shouldn't be hard coded and needs a counted loop to fix it
				; **!** however, nasm doesn't let rbx be the second value

	pop	rbx
	ret

; encoded indexValue in rdx
; return
; rax encoded indexSize
; rbx decoded indexSize
get_indexSize_decoded:
	push	rdx
	call	get_indexSize_encoded	; returns endcoded size in rax

	mov	rdx,	rax
	call	decode_indexSize
	pop	rdx
	ret

; encoded indexValue in rdx
; return
; rax Number of bytes needed to hold encoded index Value in rdx
; 0 (1/2)
; 1
; ((system max bits) /2)/8
; (system max bits)/8
get_indexSize_bytes_decoded:
	push	rdx
	push	rbx
	call	get_indexSize_decoded	; get the decoded size
	mov	rax,	rbx
	mov	rbx,	8
	div	rbx
	pop	rbx
	pop	rdx
	ret	

; encoded indexValue in rdx
; return decoded indexValue in rbx
decode_indexValue:
	push rdx
	push rax
	call get_indexSize_decoded	; into rbx

	shl	rdx,	2	; cut off index encoding **!** this likely doesn't work
	shr	rdx,	1
.shiftRightLoop:
	shr	rdx,	1	; 
	dec	rbx
	;cmp	rbx,	0	; may need to add a single shift before the loop
	jz	.shiftRightLoop
	mov	rbx,	rdx

	pop	rax
	pop	rdx	

	ret

; encoded indexSize in rax
; decoded indexSize in rbx   These two could exist in the same register
; unencoded indexValue in rdx
; returns encoded indexValue in rbx
encode_indexValue:
	push	rdx
.shiftLeftloop:
	shl	rdx,	1
	dec	rbx
	; cmp	rbx,	0
	jz	.shiftLeftloop
	shl	rax,	62
	mov	rbx,	rdx
	or	rbx,	rax
	pop	rdx
	ret


; encoded indexValue in rdx
; return
; decoded indexValue in rbx
get_indexValue_decoded:
	push	rdx
	call	get_indexSize_decoded
	call	decode_indexValue
	pop	rdx

	ret

set_indexValue_encoded:
	; index value in rdx
	; get the indexSize
	; set register to zero
	; place index value in register rbx
	push	rdx
	call compute_indexSize_encoded	; set_indexSize
	push	rax
	call	decode_indexSize
	call	encode_indexValue
	pop	rax
	pop	rdx


	ret

compute_indexSize_encoded:
	; return four bits depending on value in rdx
	; rdx does not have a size encoding on it and must be less than maxSysBits - 2 bits
	; return
	; rax
	push	rcx
	push	rdx
	shr	rdx,	2
	cmp	rdx,	0
	je	.indexSize2
	shr	rdx,	4
	cmp	rdx,	0
	je	.indexSize4
	call	getSysMaxBits
	mov	rax,	rbx
	shr	rax,	1	; divide the SysMaxBits in half
	sub	rax,	2	; take off two for the size encoding
	mov	rcx,	0	; counter (should I use rdi instead?)
.shiftLoop01:		;utilizing a loop as shift ops won't take a register for the number of bits to shift
	shr	rdx,	1
	inc	rcx
	cmp	rcx,	rax
	je	.shiftLoop01

	cmp	rdx,	0
	je	.indexSizeHalfMax
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
	mov	rax,	10b	; needs to check to see if the value is greater than (SysMaxBits - 2)
.indexFoundSize:
	pop	rdx
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


%endif
