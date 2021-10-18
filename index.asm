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

; for sized index in rdx
; put 11 in the 2  most signigicant bits for system max 
; and with rdx
; shift right system max - 2
; return rax ints from size lookup table
get_indexSize:
	push	rbx
	push	rcx
	push	rdx
	call	getSysMaxBits	; into rbx
				; assume that all the registers are SysMaxBits
	sub	rbx,	2	; get the number of bits to shift
	shr	rcx,	rbx	; shift right to remove the value and leave the size encoding
	mov	rax,	4	; 4 bits is the minimum size an index can have
	cmp	rcx,	00b	; is it the first size encoding
	je	.indexFoundSize	; if the two are equal, then jump ahead
	add	rax,	4	; 8 bits is the next size up
	cmp	rcx,	01b	; next size encoding
	je	.indexFoundSize	;
	add	rbx,	2	; get back to the SysMaxBits
	mov	rax,	rbx	; 
	cmp	rcx,	11b
	je	.indexFoundSize
	shr	rax,	1	; divide by two
.indexFoundSize:
	pop	rdx
	pop	rcx
	pop	rbx
	ret

set_indexSize:
	; compute the number of bits needed to store the index
	; convert the index to a sized index
	; value in rdx return value and index size in rbx
	call compute_indexSize
	mov	rbx,	rdx
	; and	rbx,	rax
	ret
	

get_indexValue:
	; encoded index in rdx
	; get the indexSize
	; set register to zero
	; place index value in register rbx
	call get_indexSize
	; currently using 64 bit register, assuming in the future the register will be sized
	mov	rax,	64
	sub	rax,	rbx
	mov	rbx,	rdx
	mov	rcx,	0
.shiftRightLoop01:		;utilizing a loop as shiftleft won't take a register for the number of bits to shift
	shr	rbx,	1
	inc	rcx
	cmp	rax,	rcx
	jmp	.shiftRightLoop01

	ret

set_indexValue:
	; index value in rdx
	; get the indexSize
	; set register to zero
	; place index value in register rbx
	call compute_indexSize	; set_indexSize
	; currently using 64 bit register, assuming in the future the register will be sized
	mov	rax,	64
	sub	rax,	rbx
	mov	rbx,	rdx
	mov	rcx,	msg_failed
	call	print_rcx
	mov	rcx,	0
.shiftRightLoop01:		;utilizing a loop as shiftleft won't take a register for the number of bits to shift
	shr	rbx,	1
	push	rcx
	mov	rcx,	msg_failed
	call	print_rcx
	pop	rcx
	inc	rcx
	cmp	rax,	rcx
	jmp	.shiftRightLoop01

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
	jmp	.indexSize4
	call	getSysMaxBits
	shl	rbx,	1
	mov	rax,	0
.shiftLeftLoop01:		;utilizing a loop as shiftleft won't take a register for the number of bits to shift
	shl	rcx,	1
	inc	rax
	cmp	rax,	rbx
	jmp	.shiftLeftLoop01

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
	mov	rax,	10b	; needs to check to see if the value is greater than (SysMaxBits - 2)
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
