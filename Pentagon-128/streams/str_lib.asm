;LIBRARY OF BASIC FUNCTIONS FOR STREAMS.
;LIST OF FUNCTIONS, ALPHABET ORDER.

;CLEAR_SCR
;CLEAR_SCR_STACK
;IM2_DELAY
;SET_ATTRIBUTE

;GLOBAL NAMES AND CONSTANTS, LATER.

;Clear screen functon, pixels and attr.
;DE     attribute and pixel for fill.

CLEAR_SCR:
        PUSH AF
        PUSH BC
        PUSH HL
        LD HL,SCREEN_PIXELS
        LD BC,SCREEN_P_SIZE
CLR_1:  LD (HL),E       ;TACTS:11
        INC HL          ;6
        DEC BC          ;6
        LD A,B          ;4
        OR C            ;4
        JR NZ,CLR_1     ;12=43tacts
        LD BC,SCREEN_A_SIZE
CLR_2:  LD (HL),D       ;43*6912=297k
        INC HL
        DEC BC
        LD A,B
        OR C
        JR NZ,CLR_2
        POP HL
        POP BC
        POP AF
        RET 

;Clear screen fast, using stack.
;DE     attribute and pixel for fill.

CLEAR_SCR_STACK:
        PUSH AF
        PUSH BC
        PUSH HL
        PUSH IX
        LD BC,SCREEN_ATTR_WS
        LD IX,#0000
        ADD IX,SP       ;IX PROGRAM STACK
        LD SP,SCREEN_ADDR_TOP
        LD H,D
        LD L,D          ;TACTS:(37)
CLRF_1: PUSH HL         ;11
        DEC BC          ;6
        LD A,B          ;4
        OR C            ;4
        JR NZ,CLRF_1    ;12
        LD BC,SCREEN_PIX_WS
        LD H,E          ;37*3456=128k
        LD L,E
CLRF_2: PUSH HL
        DEC BC
        LD A,B
        OR C
        JR NZ,CLRF_2
        LD SP,IX
        POP IX
        POP HL
        POP BC
        POP AF
        RET 

;Delay in 1/50 seconds, only with IM2.
;A      delay in 1/50, 50 for 1 second.

IM2_DELAY:
        PUSH AF
DELAY_1:HALT 
        DEC A
        JR NZ,DELAY_1
        POP AF
        RET 

;Set attribute on screen at coordinates.
;A      attribute[bits]:
;0..3   Ink,
;4..6   Paper,
;5      Bright,
;6      Flash,
;DE     Vertical and horizontal
;       coordinates [0..23] and [0..31].

SET_ATTRIBUTE:
        PUSH DE         ;Y AND X -> OFFSET
        PUSH AF         ;Y * 32 + X=16BITS
        LD A,D          ;NO CHECK
        AND %00000111   ;Y=00010100
        RRCA 
        RRCA 
        RRCA 
        OR E
        LD E,A          ;E LOW OFFSET
        LD A,D
        AND %00011000
        RRCA            ;D HIGH OFFSET
        RRCA 
        RRCA 
        OR SCREEN_ATTRIB_H
        LD D,A          ;#58=01011000
        POP AF
        LD (DE),A
        POP DE
        RET 
        POP HL
        POP AF
        IM 2
        EI 
        RET 
