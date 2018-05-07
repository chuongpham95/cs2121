
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

.equ PORTLDIR = 0xF0		; 1111 0000
.equ INITCOLMASK = 0xEF		; 1110 1111
.equ INITROWMASK = 0x01		; 0000 0001
.equ ROWMASK = 0x0F			; 0000 1111
.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4
.equ LCD_FUNC_SET = 0b00111000 ; Function set command with N = 1 and F = 0  for 2 line display and 5*7 font
.equ LCD_DISP_OFF = 0b00001000 ; Turn Display off
.equ LCD_DISP_CLR = 0b00000001 ; Clear Display
.equ LCD_ENTRY_SET = 0b00000110 ; Entry set command with I/D = 1 and S = 0. Set Entry mode: Increment = yes and Shift = no
.equ LCD_DISP_ON = 0b00001110 ; Display On command with C = 1 and B = 0
.equ LCD_RETURN_HOME = 0b000000001 ; Return the cursor to the start of first line
.equ LCD_SECOND_LINE = 0b0011000000 ; Go to the start of second line

; set lcd control port
.macro lcd_set
	sbi PORTA, @0
.endmacro

; clear lcd control port
.macro lcd_clr
	cbi PORTA, @0
.endmacro
; 4 cycles per iteration - setup/call-return overhead

; execute command
.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

; execute data
.macro do_lcd_data
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

; clear a word in data memory at @0
.macro clear
	ldi YL, low(@0)
	ldi YH, high(@0)
	clr temp2
	st Y+, temp2
	st Y, temp2
.endmacro

; clear second line and insert with 0
.macro clearSecondLine
; clear second line
	do_lcd_command LCD_DISP_CLR ; clear display
	; go to second line
	do_lcd_command LCD_SECOND_LINE
	; write 0
	ldi temp2, '0'
	do_lcd_data temp2
	; set cursor at the start of second line
	do_lcd_command LCD_SECOND_LINE
.endmacro

; write digits of accumulator



.cseg

.org 0x0000
	jmp RESET



; divide 2 8-bit numbers
div8:
	push temp1 ; A dividend
	push temp2	; B divisor

	;mov temp1, accumulator
	ldi temp2, 10
	ldi bcounter,9           ;Load bit counter
	sub rem, rem       ;Clear Remainder and Carry
	mov ans, temp1        ;Copy Dividend to Answer
loop:   
	rol ans           ;Shift the answer to the left
	dec bcounter             ;Decrement Counter
	breq done        ;Exit if eight bits done
	rol rem           ;Shift the remainder to the left
	sub rem,temp2         ;Try to Subtract divisor from remainder
	brcc skip        ;If the result was negative then
	add rem,temp2         ;reverse the subtraction to try again
	clc               ;Clear Carry Flag so zero shifted into A 
	rjmp loop        ;Loop Back
skip:   
	sec              ;Set Carry Flag to be shifted into A
    rjmp loop
done:
	pop temp2
	pop temp1
	ret

; sleep for 1ms
sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)

delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

; sleep for 5ms
sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret

sleep_450ms:
	push temp2
	ldi temp2, 90
start_sleep:
	dec temp2
	rcall sleep_5ms
	cpi temp2, 0
	breq exit_sleep
	rjmp start_sleep
exit_sleep:
	pop temp2	
	ret

; Send a command to the LCD (r16)
lcd_command:
	out PORTF, r16
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	ret

; send data to LCD (r16)
lcd_data:
	out PORTF, r16
	lcd_set LCD_RS
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	lcd_clr LCD_RS
	ret

; wait until lcd is not busy
lcd_wait:
	push r16
	clr r16
	out DDRF, r16
	out PORTF, r16
	lcd_set LCD_RW

lcd_wait_loop:
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	in r16, PINF
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	out DDRF, r16
	pop r16
	ret

RESET:
	; initialize stack pointer
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
	ser r16
	; set LCD
	out DDRF, r16
	out DDRA, r16
	clr r16
	out PORTF, r16
	out PORTA, r16
	do_lcd_command LCD_FUNC_SET ; 2x5x7
	rcall sleep_5ms
	do_lcd_command LCD_FUNC_SET ; 2x5x7
	rcall sleep_1ms
	do_lcd_command LCD_FUNC_SET ; 2x5x7
	do_lcd_command LCD_FUNC_SET ; 2x5x7
	do_lcd_command LCD_DISP_OFF ; display off
	do_lcd_command LCD_DISP_CLR ; clear display
	do_lcd_command LCD_ENTRY_SET ; increment, no display shift
	do_lcd_command LCD_DISP_ON ; Cursor on, bar, no blink
	; clear accumulator
	clr accumulator
	; clear input
	clr input
	; display default value of accumulator 0
	ldi temp1, 0
	; convert to ascii value
	subi temp1, - '0'
	do_lcd_data temp1
	; go to second line
	do_lcd_command LCD_SECOND_LINE
	; set PORTL to be output for column and input for row
	ldi temp1, PORTLDIR
	sts DDRL, temp1
	; output 0xFF (all lit) to PORTC (leds)
	;ser temp1
	;out DDRC, temp1
	;out PORTC, temp1

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
	subi temp1, -1
	; update input
	; ex. input 125
	; input 1: input = 0 * 10 + 1 = 1
	; input 2: input = 1 * 10 + 2 = 12
	; input 5: input = 12 * 10 + 5 = 125
update_input:
	ldi temp2, 10
	mul input, temp2
	mov input, r0
	add input, temp1
	; temp1 = 3 * row + col + 1
	; since there is no add immediate instruction of AVR, use subi -(immediate) instead
	subi temp1, - '0'
	jmp convert_end

symbols:
	; if we have a '*'
	cpi col, 0
	breq star
	; if we have a 0
	cpi col, 1
	breq zero
	; if we have other symbols, ignore
	jmp main

star:
	; reset everything
	jmp RESET
zero:
	ldi temp1, 0
	rjmp update_input

letters:
	; if we have an 'A', do addition
	cpi row, 0
	breq addition
	; if we have a 'B', do subtraction
	cpi row, 1
	breq subtraction

addition:
	; clear the second line
	clearSecondLine
	; add accumulator with input
	add accumulator, input
	; do calculation
	rcall calculation
	jmp main

subtraction:
	; clear the second line
	clearSecondLine
	; add accumulator with input
	sub accumulator, input
	; do calculation
	rcall calculation
	jmp main

convert_end:
	; write value to PORTC (leds)
	out PORTC, temp1
	; write the input to the second line of PORTF (lcd)
	do_lcd_data temp1
	; debouncing
	rcall sleep_450ms
	; repeat the scanning
	jmp main

writeDigits:
	push temp1
	push temp2
	push r5
	; return to the first line
	do_lcd_command LCD_RETURN_HOME
	; check if number >= 100
	cpi accumulator, 100
	brsh writeHundreds
	; check if number >= 10
	cpi accumulator, 10
	brsh writeTens
	; write ones
	call div8
	mov temp2, rem
	subi temp2, - '0'
	do_lcd_data temp2
	rjmp done_write
writeTens:
	call div8
	; write tens	
	mov temp2, ans
	subi temp2, - '0'
	do_lcd_data temp2
	; write ones
	mov temp2, rem
	subi temp2, - '0'
	do_lcd_data temp2
	rjmp done_write
writeHundreds:
	call div8
	; save the ones
	mov r5, rem
	; update new temp1 to do division
	mov temp1, ans
	; divide by 10 again
	call div8
	; display the hundreds
	mov temp2, ans`
	subi temp2, - '0'
	do_lcd_data temp2
	; display the tens
	mov temp2, rem
	subi temp2, - '0'
	do_lcd_data temp2
	; display the ones
	mov temp2, r5
	subi temp2, - '0'
	do_lcd_data temp2

done_write:
	pop r5
	pop temp2
	pop temp1
	ret

calculation:
	push temp1
	; copy accumulator to temp1
	mov temp1, accumulator
	; write digits of accumulator
	call writeDigits
	; clear input
	clr input
	; return to the second line to accept input
	do_lcd_command LCD_SECOND_LINE
	; write 0 to the second line
	ldi temp1, '0'
	do_lcd_data temp1
	; move the cursor to the start to overwrite '0'
	do_lcd_command LCD_SECOND_LINE
	pop temp1
	ret