/*
 * partc.asm
 *
 *  Created: 2/05/2018 5:37:42 AM
 *   Author: chuongpham
 */
 .def char = r17
 .def return = r16
 .cseg rjmp start
alphastring: .db "abcdABCD", 0
digitstring: .db "123456789", 0
invalidstring: .db "74(*&Q#$^}{:?<>", 0

.macro swapYZ
	movw X, Z
	movw Z, Y
	movw Y, X
.endmacro

start:
	; stack initialization
	ldi YL, low(RAMEND)
	ldi YH, high(RAMEND)
	out SPL, YL
	out SPH, YH
	; point validstring from program memory to Z
	ldi ZL, low(alphastring << 1)
	ldi ZH, high(alphastring << 1)
	; point checkalpha subroutine to Y
	ldi YL, low(checkalpha)
	ldi YH, high(checkalpha)
	call checkstring
	mov r20, r16
	; r20 should be 1
	; point digitstring from program memory to Z
	ldi ZL, low(digitstring << 1)
	ldi ZH, high(digitstring << 1)
	; point checkalpha subroutine to Y
	ldi YL, low(isdigit)
	ldi YH, high(isdigit)
	call checkstring
	mov r21, r16
	; r21 should be 1
	; point invalidstring from program memory to Z
	ldi ZL, low(invalidstring << 1)
	ldi ZH, high(invalidstring << 1)
	; point checkalpha subroutine to Y
	ldi YL, low(checkalpha)
	ldi YH, high(checkalpha)
	call checkstring
	mov r22, r16
	; r22 should be 0
	; point invalidstring from program memory to Z
	ldi ZL, low(invalidstring << 1)
	ldi ZH, high(invalidstring << 1)
	; point checkalpha subroutine to Y
	ldi YL, low(isdigit)
	ldi YH, high(isdigit)
	call checkstring
	mov r23, r16
	; r23 should be 0

halt:
	rjmp halt

checkstring:
	; prolouge
	push XL
	push XH
	push char
	in XL, SPL
	in XH, SPH
	out SPL, XL
	out SPH, XH
	; end of prolouge

	; body function
load:
	; load char from string in program memory
	lpm char, Z+
	; check if end of string
	cpi char, 0
	breq done_string
	; swap Y and Z
	swapYZ
	; call predicate function
	icall
	; swap Y and Z again
	swapYZ
	; check return value for each char
	cpi return, 0
	; if char is invalid
	breq done_string
	; jump back to the start of the loop
	rjmp load
	; end of body function

done_string:
	; epilouge
	; deallocate stack frame
	in XL, SPL
	in XH, SPH
	out SPL, XL
	out SPH, XH
	pop char
	pop XH
	pop XL
	ret
	; end of epilogue

isdigit:
	; prolouge
	push XL
	push XH
	in XL, SPL
	in XH, SPH
	out SPL, XL
	out SPH, XH
	; end of prolouge

	; function body
	; compare char with '0'
	cpi char, 48
	brlt invalid_1
	cpi char, 58
	brsh invalid_1
valid_1:
	; set return value r16 to 1
	ldi return, 1
	rjmp done_1
invalid_1:
	; set return value r16 to 0
	clr return

	; end of function body
done_1:
	; epilouge
	; deallocate stack frame
	in XL, SPL
	in XH, SPH
	out SPL, XL
	out SPH, XH
	pop XH
	pop XL
	ret
	; end of epilogue

checkalpha:
	; prolouge
	push XL
	push XH
	in XL, SPL
	in XH, SPH
	out SPL, XL
	out SPH, XH
	; end of prolouge

	; function body
first_check:
	; if char < A
	cpi char, 65
	brlt invalid_2
	; if char > Z
	cpi char, 91
	brlt valid_2
second_check:
	; if char < a
	cpi char, 97
	brlt invalid_2
	; if char > z
	cpi char, 123
	brsh invalid_2
valid_2:
	; set return value r16 to 1
	ldi return, 1
	rjmp done_2
invalid_2:
	; set return value r16 to 0
	clr return
	; end of function body
done_2:
	; epilouge
	; deallocate stack frame
	in XL, SPL
	in XH, SPH
	out SPL, XL
	out SPH, XH
	pop XH
	pop XL
	ret
	; end of epilogue

 
