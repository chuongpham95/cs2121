;
; lab2.asm
;
; Created: 2/05/2018 5:12:04 AM
; Author : chuongpham
;

.include "m2560def.inc"
.def char = r16
.def counter = r17
.cseg rjmp start
	s1: .db "cat",0

; Replace with your application code
start:
	; initialize stack pointer
    ldi YL, low(RAMEND)
	ldi YH, high(RAMEND)
	out SPL, YL
	out SPH, YH
	; load s1 from program memory to Z
	ldi ZL, low(s1<<1)
	ldi ZH, high(s1<<1)
	; point Y to data memory 0x200
	ldi YL, low(0x200)
	ldi YH, high(0x200)

	; reset counter to zero
	clr counter

	; load char to stack
load:
	; load char from s1 to char (r16)
	lpm char, Z+
	; check if end of string
	cpi char, 0
	breq save
	; push char on stack
	push char
	; increment counter
	inc counter
	rjmp load

	; save char from stack in reverse order
save:
	; compare counter with 0
	cpi counter, 0
	breq end
	; pop char off stack
	pop char
	; store char in data memory
	st Y+, char 
	; decrement counter
	subi counter, 1
	rjmp save

end:
	rjmp end
