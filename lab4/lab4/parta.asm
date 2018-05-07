;
; parta.asm
;
; Created: 5/02/2018 4:35:08 AM
; Author : chuongpham
;
.include "m2560def.inc"
.def row = r16
.def col = r17
.def rmask = r18
.def cmask = r19
.def temp1 = r20
.def temp2 = r21

.equ PORTLDIR = 0xF0		; 1111 0000
.equ INITCOLMASK = 0xEF		; 1110 1111
.equ INITROWMASK = 0x01		; 0000 0001
.equ ROWMASK = 0x0F			; 0000 1111

RESET:
	; initialize the stack
	ldi temp1, low(RAMEND)
	out SPL, temp1
	ldi temp1, high(RAMEND)
	out SPH, temp1
	; set PORTL to be output for column and input for row
	ldi temp1, PORTLDIR
	sts DDRL, temp1
	; output 0xFF (all lit) to PORTC (leds)
	ser temp1
	out DDRC, temp1
	out PORTC, temp1

main:
    ldi cmask, INITCOLMASK
	; col = 0
	clr col

colloop:
	; if already scanned all 4 cols, repeat
	cpi col, 4
	breq main
	; otherwise, scan a column
	sts PORTL, cmask

	; slow down the scan operation
	ldi temp1, 0xFF
delay:
	dec temp1
	brne delay

	; read PORTL
	lds temp1, PINL
	andi temp1, ROWMASK
	; check if any row is low
	breq nextcol

	; if yes, find which row is low
	ldi rmask, INITROWMASK
	; row = 0
	clr row

rowloop:
	; if has already scanned 4 rows
	cpi row, 4
	; move on to nextcol
	breq nextcol
	; check if the current row is pressed
	mov temp2, temp1
	and temp2, rmask
	; convert value to leds (PORTC)
	breq convert
	; increment row
	inc row
	; left shift row mask mask by one
	lsl rmask
	jmp rowloop

nextcol:	
	; left shift col mask by one
	lsl cmask
	; increment col
	inc col
	; go to the next collumn
	jmp colloop

convert:
	; if col 3 is pressed, then it must be letters
	cpi col, 3
	breq letters	
	; if row 3 is pressed, then it must be symbol
	cpi row, 3
	breq symbols
	; else it must be number 1-9
	; copy row to temp1
	mov temp1, row
	; temp1 = temp1 * 2
	lsl temp1
	; temp1 = 2*temp1 + temp1
	add temp1, row
	; temp1 = 2*temp1 + temp1 + col = 3*temp1 + col = 3*row + col
	add temp1, col
	; temp1 = 3 * row + col + 1
	; since there is not add immediate instruction of AVR, use subi -(immediate) instead
	subi temp1, -1
	jmp convert_end

letters:
	; if we have letters, ignore
	jmp main

symbols:
	; if we have a 0
	cpi col, 1
	breq zero
	; if we have other symbols, ignore
	jmp main
zero:
	ldi temp1, 0
convert_end:
	; write value to PORTC (leds)
	out PORTC, temp1
	; repeat the scanning
	jmp main

