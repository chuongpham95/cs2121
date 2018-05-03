/*
 * AsmFile1.asm
 *
 *  Created: 1/05/2018 9:43:15 PM
 *   Author: Chuong
 */
.include "m2560def.inc"

.def char = r16

.dseg
	cap_string: .byte 19

.cseg rjmp main
	low_string: .db "this AAA is me @#@#&213", 0

main:
	; set up pointer for low_string
	ldi ZL, low(low_string<<1)
	ldi ZH, high(low_string<<1)
	; set up pointer for cap_string
	ldi YL, low(cap_string)
	ldi YH, high(cap_string)

load:
	; load char from low_string and increment Z pointer
	lpm char, Z+
	; check end of string
	cpi char, 0
	breq exit
	; check alphabetic character
	; if char >= 'a'
	cpi char, 97
	brlt store
	; if char >= 'z' + 1
	cpi char, 123
	brge store
	; convert to lower case letter
	subi char, 32
store:
	; store letter to cap_string
	st Y+, char
	rjmp load

exit:
	rjmp exit


