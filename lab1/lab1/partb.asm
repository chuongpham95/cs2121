/*
 * AsmFile1.asm
 *
 *  Created: 1/05/2018 9:10:59 PM
 *   Author: Chuong
 */ 

.include "m2560def.inc"
.cseg rjmp main
	a1: .db 1,2,3,4,5
	a2: .db 5,4,3,2,1

main:
	; set up pointers for a1
	ldi ZL, low(a1<<1)
	ldi ZH, high(a1<<1)
	; store numbers of a1 into 5 registers
	lpm r16, Z+
	lpm r17, Z+
	lpm r18, Z+
	lpm r19, Z+
	lpm r20, Z+
	; set up pointers for a2
	ldi ZL, low(a2<<1)
	ldi ZH, high(a2<<1)
	; store numbers of a2 into 5 registers
	lpm r11, Z+
	lpm r12, Z+
	lpm r13, Z+
	lpm r14, Z+
	lpm r15, Z+
	; add 2 values
	add r16, r11
	add r17, r12
	add r18, r13
	add r19, r14
	add r20, r15
	; set up pointer for a3
	ldi YL, low(a3)
	ldi YH, high(a3)
	st Y+, r16
	st Y+, r17
	st Y+, r18
	st Y+, r19
	st Y+, r20

end:
	rjmp end

.dseg
	a3: .byte 5
