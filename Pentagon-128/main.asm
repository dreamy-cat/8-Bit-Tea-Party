        ORG #6000

;GLOBAL NAMES AND CONSTANTS.

SCREEN_RAM      EQU #4000
SCREEN_SIZE     EQU #1800
SCREEN_ATTRIB   EQU #5800
ATTRIB_SIZE     EQU #300

        LD D,#00
        LD E,%01000111
        CALL CLEARSCREEN
        LD DE,#0000
DPIX_1: CALL SET_PIXEL
        LD A,#10
        SIMPLE_DELAY
        INC DE
        LD A,D
        OR E
        JR NZ,DPIX_1
        RET 

;SET PIXEL ON SCREEN, WITH COORDINATES.
;REGISTERS:
;D - X (0..255), E - Y (0..191)
;RETURN: ON SCREEN.

SET_PIXEL:
        PUSH AF
        LD A,E
        CP #C0
        JR NC,PIX_E
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,SCREEN_RAM
        LD A,E          ;2048 BYTES PART.
        AND %11000000
        RRCA 
        RRCA 
        RRCA 
        LD B,A
        LD A,H
        OR B
        LD H,A
        LD A,E          ;256 BYTES PART.
        AND %00000111
        LD B,A
        LD A,H
        OR B
        LD H,A
        LD A,E          ;32 BYTES PART.
        AND %00111000
        RLCA 
        RLCA 
        LD B,A
        LD A,L
        OR B
        LD L,A
        LD A,D          ;HORIZONTAL BYTE.
        AND %11111000
        RRCA 
        RRCA 
        RRCA 
        LD B,A
        LD A,L
        OR B
        LD L,A
        LD A,D          ;PIXEL IN BYTE.
        AND %00000111
        LD B,A
        LD A,%10000000
PIX_1:  RRCA 
        DJNZ PIX_1
        OR (HL)
        LD (HL),A
        POP HL
        POP DE
        POP BC
PIX_E:  POP AF
        RET 

;SIMPLE DELAY FUNCTION FOR DEBUG.
;A - DELAY IN 4 TACTS MULTIPLY IN 256.
;RETURN: NOTHING.

SIMPLE_DELAY:
        PUSH AF
        PUSH BC
        LD A,B
        LD C,0
SIM_D:  NOP 
        DEC BC
        LD A,B
        OR C
        JR NZ,SIM_D
        POP BC
        POP AF
        RET 

;CLEAR SCREEN FUNCTION AND TESTING.
;D - BYTE FOR FILL SCREEN.
;E - BYTE FOR FILL ATTRIBUTES.
;Тестирование функции заполнения.


CLEARSCREEN:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,SCREEN_RAM
        LD BC,#1800
CLR_1:  LD A,D
        LD (HL),A
        INC HL
        DEC BC
        LD A,B
        OR C
        JR NZ,CLR_1
        LD BC,#300
CLR_2:  LD A,E
        LD (HL),E
        INC HL
        DEC BC
        LD A,B
        OR C
        JR NZ,CLR_2
        POP HL
        POP DE
        POP BC
        POP AF
        RET 
