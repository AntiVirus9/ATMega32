.include "M32def.inc"

.equ LCD_RS=6
.equ LCD_E=1

.MACRO LCD_CMD
		cbi PORTC, LCD_RS
		ldi r16, @0
		out PORTA, r16
		SBI PORTC, LCD_E
		nop
		cbi PORTC, LCD_E
		CALL LCD_Delay1
.ENDMACRO

.MACRO LCD_DATA
		sbi PORTC, LCD_RS
		ldi r16, @0
		out PORTA, r16
		sbi PORTC, LCD_E
		nop
		cbi PORTC, LCD_E
		call LCD_Delay1
.ENDMACRO

.cseg
.org 0
reset:	jmp start		;reset vektor

;-------------------------------------------------
.org 0x100
start: 	ldi r16,0x5F	;nastaveni ukazatele
		out SPL,r16		;zasobniku na 0x085F
		ldi r16,0x08		;konec SRAM
		out SPH,r16	

		ldi r16, 0xff
		out DDRA, r16
		out DDRC, r16

		call LCD_INIT

		LCD_CMD 0x80
		LCD_DATA 'B'
		LCD_DATA 'A'
		LCD_DATA 'T'
		LCD_DATA 'E'
		LCD_DATA 'R'
		LCD_DATA 'I'
		LCD_DATA 'E'
		LCD_DATA ':'
	

		LCD_CMD 0x40		;vlastní znak baterie: 0%
		LCD_DATA 0x04
		LCD_DATA 0x0E
		LCD_DATA 0x0A
		LCD_DATA 0x0A
		LCD_DATA 0x0A
		LCD_DATA 0x0A
		LCD_DATA 0x0A
		LCD_DATA 0x0E

		LCD_CMD 0x48		;vlastní znak baterie: 50%
		LCD_DATA 0x04
		LCD_DATA 0x0E
		LCD_DATA 0x0A
		LCD_DATA 0x0A
		LCD_DATA 0x0A
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E

		LCD_CMD 0x50		;vlastní znak baterie: 75%
		LCD_DATA 0x04
		LCD_DATA 0x0E
		LCD_DATA 0x0A
		LCD_DATA 0x0A
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E

		LCD_CMD 0x58		;vlastní znak baterie: 100%
		LCD_DATA 0x04
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		LCD_DATA 0x0E
		
		LCD_CMD 0x8C		; vypsání vlastních znaků
		LCD_DATA 0x00
		LCD_DATA 0x01
		LCD_DATA 0x02
		LCD_DATA 0x03





konec:	rjmp konec
;-------------------------------------------------

LCD_Delay1:	LDI r22, 180

LCD_D01:	NOP
			DEC r22
			BRNE LCD_D01
			RET

LCD_Delay2: LDI r21, 160

LCD_D02:	NOP
			DEC r22
			BRNE LCD_D02
			DEC r21
			BRNE LCD_D02
			RET
;------------------------------------
LCD_INIT:	call LCD_Delay2
			call LCD_Delay2
			LCD_CMD 0x30
			call LCD_Delay2
			LCD_CMD 0x30
			call LCD_Delay2
			LCD_CMD 0x30

			LCD_CMD 0x38
			LCD_CMD 0x0E
			LCD_CMD 0x06
			LCD_CMD 0x01
			LCD_CMD 0x02
			call LCD_Delay2

			RET
