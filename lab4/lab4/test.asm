.include "m2560def.inc"

.def ans = r0 ; to hold answer
.def rem = r2 ; to hold remainder
.def bcounter = r24 ; bit counter
.def row = r16
.def col = r17
.def rmask = r18
.def cmask = r19
.def temp1 = r20
.def temp2 = r21
.def accumulator = r22
.def input = r23

main:
	; update input
	; ex. input 125
	; input 1: input = 0 * 10 + 1 = 1
	; input 2: input = 1 * 10 + 2 = 12
	; input 5: input = 12 * 10 + 5 = 125
	clr input
	clr accumulator
	ldi input, 25
	ldi temp1, 5
	ldi temp2, 10
	mul input, temp2
	mov input, r0
	add input, temp1
	add accumulator, input
done:
	rjmp done
	