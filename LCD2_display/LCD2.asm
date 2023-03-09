;LCD displej H44780
;PA7-0: DATA7-0
;PC6: R/S
;PC1: E
;-------------------------------------------------------------- 
;R16 - pracovni registr (hlavni program)
;R17 - pocitadlo
;R18 - pracovni registr UART
;R20 - pracovni registr LCD
;R21, R22 - zpozdovaci smycky
;R27, R26 - ukazatel LCD_TEXT (X)
;R29, R28 - ukazatel LCD_TEXT (Y) 

.include "M32def.inc"
;-------------------------------------------------------------- 
.equ LCD_DELKA=16				;delka displeje
.equ LCD_RS=6					;pripojeni signalu RS
.equ LCD_E=1					;pripojeni signalu E

.equ rychlost=600		;prenosova rychlost Bd
.equ konstR=(16000000/16/rychlost-1) 
						;konstanta prenosove rychlosti

;-------------------------------------------------------------- 
.MACRO LCD_CMD					;odeslani prikazu do displeje
		cbi PORTC,LCD_RS		;nastaveni bitu rs = 0
		ldi r16,@0				;posilani dat
		out PORTA,r16			
		sbi PORTC,LCD_E			;puls E
		nop
		cbi PORTC,LCD_E
		call LCD_Delay1			;zpozdeni 
.ENDMACRO

.MACRO LCD_DATA					;odeslani dat do displeje
		sbi PORTC,LCD_RS		;nastaveni bitu rs = 1
								;posilani dat
		out PORTA,@0			
		sbi PORTC,LCD_E			;puls E
		nop
		cbi PORTC,LCD_E	
		call LCD_Delay1			;zpozdeni 
.ENDMACRO
;--------------------------------------------------------------
.dseg
.org 0x60				;textoveho pole pro LCD
LCD_TEXT:.byte 256

;--------------------------------------------------------------
.cseg
.org 0
reset:	jmp start		;reset vektor

.org 0x1a
		jmp USART_Prijimac	;prijem znaku RxD USART 

;--------------------------------------------------------------
.org 0x100
start: 	ldi r16,0x5F	;nastaveni ukazatele
		out SPL,r16		;zasobniku na 0x085F
		ldi r16,0x08	;konec SRAM
		out SPH,r16	

		ldi r16,0xff	;nastaveni portu A a C na vystupni
		out DDRA,r16
		out DDRC,r16
		
		call LCD_INIT	;inicializace displeje
		call USART_INIT	;inicilizace USART
	
		call LCD_Erase 	;vymazani textu
		
	
konec:	rjmp konec

;--------------------------------------------------------------
;		    Prijimace       (R18,X)
USART_prijimac:	
			
			in r18,UDR		;precteni prijatych dat
			cpi r18,13		;test 'ENTER'
			breq USART_P0	;konec prenosu
			st X+,r18		;zapis znaku do TEXT
			rjmp USART_PK

USART_P0:	call LCD_write	;odeslani textu na displej
			call LCD_erase			
USART_PK:	reti


;--------------------------------------------------------------
;           Odeslani textu na LCD   (R17,R20,R28,R29)

LCD_Write:	ldi r28,low(LCD_TEXT)	;nastaveni ukazatele Y
			ldi r29,high(LCD_TEXT)	;na zacatek pole

			ldi r17,LCD_DELKA	;pocitadlo znaku
			LCD_CMD 0x80		;zacatek 1 radku displeje
LCD_WR1:	ld r20,Y+			;precteni znaku z TEXT pole
			LCD_DATA r20
			dec r17				;snizeni pocitadla
			brne LCD_WR1
			
			ldi r17,LCD_DELKA	;pocitadlo znaku
			LCD_CMD 0xC0		;zacatek 2 radku displeje
LCD_WR2:	ld r20,Y+			;precteni znaku z TEXT pole
			LCD_DATA r20
			dec r17				;snizeni pocitadla
			brne LCD_WR2

			ret

;-------------------------------------------------------
;           Vymazani TEXT		(R16,R17,R26,R27)

LCD_Erase:							;vymazani textoveho pole
			ldi r26,low(LCD_TEXT)	;nastaveni ukazatele X
			ldi r27,high(LCD_TEXT)	;na zacatek pole
			ldi r17,0				;delka retezce = 256znaku
			ldi r16,0x20			;znak mezera
LCD_ER:		st X+,r16				;zapis znaku do TEXT
			dec r17					;snizeni pocitadla
			brne LCD_ER				;opakovani
			ldi r26,low(LCD_TEXT)	;nastaveni ukazatele X
			ldi r27,high(LCD_TEXT)	;na zacatek pole
			ret
;--------------------------------------------------------------
LCD_Delay1:	ldi r22,180		;pocet cyklu: 4*180/16MHz=45us 
LCD_D01:	nop				;zpozdeni 4 takty na cyklus
			dec r22
			brne LCD_D01
			ret 

LCD_Delay2:	ldi r21,160		;pocet cyklu: 1000*160/16MHz=10ms
			ldi r22,0x00	;zpozdeni 1000 taktu na cyklus
LCD_D02:	nop
			dec r22
			brne LCD_D02
			dec r21
			brne LCD_D02
			ret 
;--------------------------------------------------------------	

LCD_INIT:	call LCD_Delay2	;zpozdeni po zapnuti
			call LCD_Delay2
			LCD_CMD 0x30	;inicializace
			call LCD_Delay2
			LCD_CMD 0x30	;inicializace
			call LCD_Delay2
			LCD_CMD 0x30	;inicializace

			LCD_CMD 0x38	;2 radky 5x8
			LCD_CMD 0x0E	;Disp set (0C/OE - zobrazeni kurzor)
			LCD_CMD 0x06	;Mode set (1,I/D,S)
			LCD_CMD 0x01	;Vymazani		
			LCD_CMD 0x02	;Navrat na zacatek	
			call LCD_Delay2
			
			ret
;--------------------------------------------------------------	
;			Inicializace USART

USART_INIT:	ldi r16,0x00	;nastaveni ridicich registru
			out UCSRA,r16	;USART
			ldi r16,0x98	;8 bit, parita none, 1 stop bit
			out UCSRB,r16	;povoleni preruseni RXC
			ldi r16,0x86
			out UCSRC,r16

			ldi r16,high(konstR)	;nastaveni rychlosti 
			out UBRRH,r16
			ldi r16,low(konstR)
			out UBRRL,r16
			sei				;povoleni preruseni	
			ret

;--------------------------------------------------------------	
