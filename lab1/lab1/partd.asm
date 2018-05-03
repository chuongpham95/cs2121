/*
 * AsmFile1.asm
 *
 *  Created: 1/05/2018 10:02:39 PM
 *   Author: Chuong
 */ 
 .include "m2560def.inc"
 .def number = r16
 .def next_number = r17
 .def nswap = r18
 .def temp = r15
 .def counter = r19
 .equ size = 7
 .equ limit = size - 1

 ; swap Y and Y+1
.macro swap1
	std Y+1, @0
	st Y, @1
.endmacro

; reset Y pointer and counters
.macro reset_all
	; reset pointer Y to the start of sorted_a
	ldi YL, low(sorted_a)
	ldi YH, high(sorted_a)
	; reset counter to 0 again
	clr counter
	; reset nswap to 0
	clr nswap
.endmacro

 .dseg
	sorted_a: .byte 7

 .cseg rjmp main
	a: .db 7,4,5,1,6,3,2

 main:
	; set up pointer for a
	ldi ZL, low(a<<1)
	ldi ZH, high(a<<1)
	; set up pointer for sorted_a
	ldi YL, low(sorted_a)
	ldi YH, high(sorted_a)
	; reset counter to zero
	clr counter

; load a to sorted_a
load:
	; check end of array
	cpi counter, size
	breq reset
	; load number from a and increment Z pointer
	lpm	number, Z+
	; store number to sorted_a and increment Y pointer
	st Y+, number
	; increment counter
	inc counter
	; jump back to the start of the loop
	rjmp load

reset:
	reset_all

; sort sorted_a using bubble sort
bubble_sort:
	; check if reaching the end of array
	cpi counter, limit
	; reset pointer Y and counters
	breq reset_values
	rjmp load_values
reset_values:
	; compare nswap and 0
	cpi nswap, 0
	; if no swap, then finish sorting
	breq end
	reset_all
load_values:
	; load current number into number and increment pointer Y
	ld number, Y
	; load next number into next_number
	ldd next_number, Y+1
	; compare number and next number
	cp next_number, number
	brlt less_than
	rjmp continue
less_than:
	; increment nswap
	inc nswap
	; swap 2 adjacent numbers
	swap1 number, next_number
continue:
	; increment counter
	inc counter
	; increment Y
	inc YL
	; jump back to the start of the loop
	rjmp bubble_sort

 end:
	rjmp end
