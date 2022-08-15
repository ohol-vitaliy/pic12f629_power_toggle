; PIC12F629 Configuration Bit Settings
; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
  CONFIG  WDTE = ON             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; GP3/MCLR pin function select (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
  CONFIG  BOREN = OFF           ; Brown-out Detect Enable bit (BOD disabled)
  CONFIG  CP = OFF              ; Code Protection bit (Program Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)

// config statements should precede project file includes.
#include <xc.inc>

; INFO: program increment 256*4 with sleep between (2.3 seconds) 
; and toogle pin 0 after

COUNT EQU 020h
COUNT_MULT EQU 021h
BANK_SEL EQU 5
ANSEL EQU 9Fh
 
 PSECT resetVect, class=CODE, delta=2
 resetVect:
    PAGESEL main
    goto main

PSECT code, delta=2
main:
    BCF STATUS,BANK_SEL ;Bank 0
    CLRF GPIO ;Init GPIO
    MOVLW 07h
    MOVWF CMCON
    MOVLW 0b10010000
    MOVWF INTCON
    CLRWDT ;Clear WDT
    CLRF TMR0 ;Clear TMR0 and prescaler
    
    BSF STATUS,BANK_SEL ;Bank 1
    CLRF ANSEL
    MOVLW 0b00000100 
    MOVWF TRISIO
    MOVLW 0b00101111 ;Set prescaler and interrupt on falling edge
    MOVWF OPTION_REG
    CLRWDT
    
;    BCF STATUS,BANK_SEL ;Bank 0
;    CLRWDT ;Clear WDT
;    CLRF TMR0 ;Clear TMR0 and prescaler
    
;    BSF STATUS,BANK_SEL ;Bank 1
;    MOVLW 0b00101111 ;Set prescaler and interrupt on falling edge
;    MOVWF OPTION_REG
;    CLRWDT
    
    BCF STATUS,BANK_SEL ;Bank 0
    
    MOVLW 0
    MOVWF GPIO
    SLEEP
    MOVLW 1
    MOVWF GPIO
    
    CLRF COUNT
    CLRF COUNT_MULT
LOOP:  
    SLEEP
    
    BCF GPIO, 1
    
    BTFSC INTCON, 2
    GOTO SETPIN
    
    INCFSZ COUNT, F ; when counted 256 -> proceed, else -> sleep
    GOTO LOOP
    
;    INCF COUNT_MULT, F
;    BTFSS COUNT_MULT, 2 ; when 4 -> proceed, else -> sleep
;    GOTO LOOP

SETPIN:
    CLRF COUNT
    CLRF COUNT_MULT
    BSF GPIO, 1
    GOTO LOOP
    
    NOP 
    NOP 

END resetVect        ; Program entry point.
    
