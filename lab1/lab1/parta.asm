;
; lab1.asm
;
; Created: 1/05/2018 9:02:39 PM
; Author : Chuong
;
.include "m2560def.inc"


start:
    ; load 4060 into r17:r16
	ldi r16, low(40960)
	ldi r17, high(40960)
	; load 2730 into r19:r18
	ldi r18, low(2730)
	ldi r19, high(2730)
	; add low bytes and store in r16
	add r16, r18 
	; add high bytes with carry and store in r17
	adc r17, r19
	; store result in r25:r24
	mov r24, r16
	mov r25, r17

end:
	rjmp end
