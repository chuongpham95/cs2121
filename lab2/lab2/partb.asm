/*
 * partb.asm
 *
 *  Created: 2/05/2018 5:37:42 AM
 *   Author: chuongpham
 */
 .def char = r17
 .cseg rjmp start
validstring: .db "abcdABCD", 0
invalidstring: .db "74(*&Q#$^}{:?<>", 0

start:
	; stack initialization
	ldi YL, low(RAMEND)
	ldi YH, high(RAMEND)
	out SPL, YL
	out SPH, YH
	; point validstring from program memory to Z
	ldi ZL, low(validstring << 1)
	ldi ZH, high(validstring << 1)
	call checkalpha
	mov r20, r16
	; r20 should be 1
	; point invalidstring from program memory to Z
	ldi ZL, low(invalidstring << 1)
	ldi ZH, high(invalidstring << 1)
	call checkalpha
	mov r21, r16
	; r21 should be 0

halt:
	rjmp halt

checkalpha:
	; prolouge
	push YL
	push YH
	push char
	in YL, SPL
	in YH, SPH
	out SPL, YL
	out SPH, YH
	; end of prolouge
load:
	; function body
	; load char from Z pointer
	lpm char, Z+
	; check if end of string
	cpi char, 0
	breq valid
first_check:
	; if char < A
	cpi char, 65
	brlt invalid
	; if char > Z
	cpi char, 91
	brlt continue
second_check:
	; if char < a
	cpi char, 97
	brlt invalid
	; if char > z
	cpi char, 123
	brsh invalid
continue:
	rjmp load
valid:
	; set return value r16 to 1
	ldi r16, 1
	rjmp done
invalid:
	; set return value r16 to 0
	clr r16

	; end of function body
done:
	; epilouge
	; deallocate stack frame
	in YL, SPL
	in YH, SPH
	out SPL, YL
	out SPH, YH
	pop char
	pop YH
	pop YL
	ret
	; end of epilogue

 
