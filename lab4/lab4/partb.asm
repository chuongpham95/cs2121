
.include "m2560def.inc"

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
.equ LCD_SECOND_LINE = 0b0011000000 ; go to second line

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
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.org 0
	jmp RESET

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
	; 
	ser r16
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

	; display "COMP2121" on the first line
	do_lcd_data 'C'
	do_lcd_data 'O'
	do_lcd_data 'M'
	do_lcd_data 'P'
	do_lcd_data '2'
	do_lcd_data '1'
	do_lcd_data '2'
	do_lcd_data '1'

	; go to second line
	do_lcd_command LCD_SECOND_LINE
	do_lcd_data 'L'
	do_lcd_data 'a'
	do_lcd_data 'b'
	do_lcd_data '4'


halt:
	rjmp halt


