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


; decode the encoded index size in rdx 4 bits
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
	
	ret
	

; for sized index in rdx
; put 11 in the 2  most signigicant bits for system max 
; and with rdx
; shift right system max - 2
; return rax ints from size lookup table
get_indexSize_encoded:
	push	rbx
	push	rcx
	push	rdx
	call	getSysMaxBits	; into rbx
				; assume that all the registers are SysMaxBits
	sub	rbx,	2	; get the number of bits to shift
	push	rdx
	shr	rdx,	62	; **!** This value shouldn't be hard coded and needs a counted loop to fix it

	pop	rdx
	pop	rcx
	pop	rbx
	ret

; encoded indexValue in rdx
; return
; rax encoded indexSize
; rbx decoded indexSize
get_indexSize_decoded:
	push	rdx
	call	get_indexSize_encoded
	mov	rdx,	rbx
	mov	rax,	rbx	; put rbx into rax so the function doesn't have to be called again
	call	decode_indexSize
	pop	rdx
	ret

; encoded indexValue in rdx
; return decoded indexValue in rbx
decode_indexValue:
	push rdx
	call get_indexSize_decoded	; into rbx
	sub	rbx,	2	; remove encoded size, size

	shl	rdx,	2	; cut off index encoding
	shr	rdx,	2
.shiftRightLoop:
	shr	rdx,	1	; 
	dec	rbx
	cmp	rbx,	0	; may need to add a single shift before the loop
	jmp	.shiftRightLoop
	mov	rbx,	rdx
	pop	rdx	

	ret

; encoded indexSize in rax
; decoded indexSize in rbx   These two could exist in the same register
; unencoded indexValue in rdx
; returns encoded indexValue in rbx
encode_indexValue:
	sub	rbx,	2	; remove encoded size, size
.shiftLeftloop:
	push	rdx
	shl	rdx,	1
	dec	rbx
	cmp	rbx,	0
	jmp	.shiftLeftloop
	shl	rax,	62
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
