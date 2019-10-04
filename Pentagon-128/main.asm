        ORG #6000

;GLOBAL NAMES AND CONSTANTS.

SCREEN_ADDR     EQU #4000
SCREEN_SIZE     EQU #1800
SCREEN_ATTRIB   EQU #5800
ATTRIB_SIZE     EQU #300
SCREEN_X_SIZE   EQU #20
SCREEN_Y_SIZE   EQU #18

;MAIN PART

        LD HL,#0000
        ADD HL,SP
        LD SP,#5E00
        PUSH HL
        LD A,4
        OUT (#FE),A

        ;SET INTERRUPT

        DI 
        LD HL,#5EFF     ;IM2_ADDR
                        ;+FF FROM STACK.
        LD BC,IM2
        LD (HL),C
        INC HL
        LD (HL),B
        LD A,#5E
        LD I,A

        IM 2
        EI 

        ;CALL SET_PIXEL_DEBUG
        CALL DEBUG_SPRITES

        CALL KEMPSTON_JOYSTICK

        LD A,1
        OUT (#FE),A
        POP HL
        LD SP,HL
        RET 

; TESTING KEMPSTON.

KEMPSTON:
        DB #00

KEMPSTON_JOYSTICK:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD BC,#0400
KMP_S:  PUSH BC
        LD DE,(CHAR_POS)
        LD BC,#0404
        LD HL,CHARS
        HALT 

        CALL DRAW_SPRITE
        LD A,(KEMPSTON)
        BIT 0,A         ;RIGHT
        JR Z,KMP_1
        INC D
        JR KMP_N
KMP_1:  BIT 1,A         ;LEFT
        JR Z,KMP_2
        DEC D
        JR KMP_N
KMP_2:  BIT 2,A         ;DOWN
        JR Z,KMP_3
        INC E
        JR KMP_N
KMP_3:  BIT 3,A         ;UP
        JR Z,KMP_4
        DEC E
        JR KMP_N
KMP_4:  BIT 4,A         ;FIRE
        JR Z,KMP_N
        LD A,#07
        OUT (#FE),A
KMP_N:  LD (CHAR_POS),DE
        POP BC
        DEC BC
        LD A,B
        OR C
        JR NZ,KMP_S
KMP_RET:
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;TESTING IM2 INTERRUPT.

IM2_ADDR:
        DW #5800
IM2_COUNTER:
        DB #00
IM2_COLOR:
        DB %01010111

IM2:    DI 
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD A,1
        OUT (#FE),A
        ;JR IM2_3
        LD A,(IM2_COUNTER)
        CP 10
        JR NZ,IM2_1
IM2_3:  LD HL,(IM2_ADDR)
        LD A,(IM2_COLOR)
        LD (HL),A
        INC HL
        LD (IM2_ADDR),HL
        XOR A
        LD (IM2_COUNTER),A
        JR IM2_2
IM2_1:  INC A
        LD (IM2_COUNTER),A
IM2_2:  ;JR IM2_RET     ;TESTING COLORS.
        IN A,(#1F)      ;KEMPSTON.
        AND %00011111
        LD (KEMPSTON),A
        LD (IM2_COLOR),A
        POP HL
        POP DE
        POP BC
        POP AF
        EI 
        RETI 

DEBUG_SPRITES:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL

        LD HL,#4080     ;PERFOMANCE LABEL.
        LD (HL),#FF

        ;LD DE,#0006    ;16 PIXEL TILE.
        ;LD DE,#0005    ;24 PIXEL TILE.
        ;LD DE,#0004    ;32 PIXEL TILE.
        LD DE,#0003     ;40 PIXEL TILE.
        LD BC,#2010
        LD HL,LOCAL_MAP
DBG_1:  HALT 
        CALL DRAW_SPRITE
        ;JP DBG_RET
        LD A,#20
        ;LD BC,#0103    ;TILE SIZE.
        ;LD BC,#0104
        LD BC,#0105
        ;LD DE,#0015    ;TILE POSITION.
        ;LD DE,#0014
        LD DE,#0013
        LD HL,TEST_TILE
DBG_T:  CALL DRAW_SPRITE
        INC D
        DEC A
        JR NZ,DBG_T

DBG_S:  LD BC,#0200
DBG_3:  PUSH BC
        LD HL,LAMP_1
        LD DE,#140F
        LD BC,#0408
        HALT 
        CALL DRAW_SPRITE
        LD HL,CHARS
        LD DE,(CHAR_POS)
        LD BC,#0404
        CALL DRAW_SPRITE
        CALL DRAW_SPRITE
        JR DBG_7        ;TO STATIC CHAR
        LD A,(DIRECT)
        OR A
        JR NZ,DBG_4     ;TO RIGHT
        INC D
        LD (CHAR_POS),DE
        JR DBG_5
DBG_4:  DEC D
        LD (CHAR_POS),DE ;TO LEFT
DBG_5:  LD A,D           ;LIMITS
        CP #1C
        JR NZ,DBG_6     ;RIGHT LIMIT
        LD A,1
        LD (DIRECT),A
        JR DBG_7        ;CHANGE DIRECTION
DBG_6:  LD A,D
        CP 0
        JR NZ,DBG_7
        LD A,0          ;CHANGE DIRECTION
        LD (DIRECT),A
DBG_7:
        LD A,#04
        OUT (#FE),A
        POP BC
        DEC BC
        LD A,B
        OR C
        JR NZ,DBG_3
        JR DBG_RET

        LD HL,LAMP_2
        HALT 
        HALT 
        LD A,#02
        OUT (#FE),A
        CALL DRAW_SPRITE
        POP BC
        DJNZ DBG_3

DBG_RET:

        POP HL
        POP DE
        POP BC
        POP AF
        RET 

CHAR_POS:
        DW #0412
DIRECT: DB 0

TEST_TILE:
        DUP 20
        DB %10101010
        DB %01010101
        EDUP 

PATTERN:
;       DUP 6144
;       DB #AA
;       EDUP

LOCAL_MAP:
INCBIN  "MAP.C",4096
CHARS:
INCBIN  "BOB_1.C",128
GAME_OBJECTS:
LAMP_1: INCBIN "LAMP_1.C",256
LAMP_2: INCBIN "LAMP_2.C",256


;DRAW A SPRITE ON SCREEN.
;A - TYPE OF DRAW ON SCREEN MEMORY.
;A = 0 - SIMPLE DRAW, OVERWRITE MEMORY.
;A = 1 - 'AND' OPERATOR WITH MEMORY.
;A = 2 - 'OR' OPERATOR WITH MEMORY.
;A = 3 - 'XOR' OPERATOR WITH MEMORY.
;B - X SIZE OF SPRITE IN 8*8.
;C - Y SIZE OF SPRITE IN 8*8.
;D - X COORDINATE ON SCREEN [0..31]
;E - Y COORDINATE ON SCREEN [0..23]
;HL - ADDRES OF SPRITE, LINEAR IN MEMORY.

DRAW_SPRITE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL

SPR_3:  PUSH DE         ;SAVE COORDS.
        PUSH HL         ;MAKE ADDRESS.
        LD HL,SCREEN_ADDR
        LD A,E          ;LOW PART ADDR.
        AND %00000111
        RRCA 
        RRCA 
        RRCA 
        OR D
        LD L,A
        LD A,E          ;2048(1/3) PART.
        AND %00011000
        LD E,A
        LD A,H
        OR E
        LD H,A
        EX DE,HL
        POP HL

        PUSH BC         ;SIZES IN STACK!
        ;POP DE         ;COORDS IN STACK!
        LD C,8          ;DRAW 8 LINES * X.
SPR_2:  PUSH BC
        PUSH DE         ;SAVE LINE ADDR.

SPR_1:  LD A,(HL)       ;DRAW 1 LINE.
        LD (DE),A
        INC HL
        INC DE
        DJNZ SPR_1
        POP DE
        INC D
        POP BC
        DEC C
        JR NZ,SPR_2
        POP BC          ;COORDS AND SIZES,
        POP DE          ;IN REGS
        INC E
        DEC C
        JR NZ,SPR_3     ;NEW ADDR.

SPR_RET:

        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;GLOBAL STATIC VARIABLES.

BACK_1: DUP #10
        DW 0
        EDUP 

;BACK_PLANES WITH PIXELS.

BACK_PLANES:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD IX,BACK_1
        LD B,#10        ;FILL DATA
        LD DE,#0000
B_PL_1: LD (IX+0),D
        LD (IX+1),E
        INC D
        INC E
        INC IX
        INC IX
        DJNZ B_PL_1     ;NEXT STAR
        LD C,#10        ;MAIN LOOP
B_PL_3: LD HL,BACK_1    ;DRAW PIXELS
        LD B,#10
B_PL_2: LD E,(HL)
        INC HL
        LD D,(HL)
        LD A,1
        CALL SET_PIXEL
        INC HL
        DJNZ B_PL_1
        LD A,1
        CALL SIMPLE_DELAY
        ;LD HL,BACK_1   ;ERASE PIXELS
        ;LD B,#10
        ;LD E,(HL)
        ;INC HL
        ;LD D,(HL)

        DEC C
        LD A,C
        OR B
        JR NZ,B_PL_3
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

SET_PIXEL_DEBUG:
        LD D,#00
        LD E,%01000111
        ;CALL CLEARSCREEN
        LD DE,#0000
DPIX_1: LD A,1
        ;HALT
        CALL SET_PIXEL
       ;LD A,#1
       ;CALL SIMPLE_DELAY
        INC DE
        LD A,D
        OR E
        JR NZ,DPIX_1
TPIX    LD DE,#0000
DPIX_2: LD A,1
        OUT (#FE),A
        HALT 
        XOR A
        CALL SET_PIXEL
        LD A,1
        CALL SIMPLE_DELAY
        DEC E
        DEC D
        LD A,D
        OR E
        JR NZ,DPIX_2
        LD DE,#0000
DPIX3:  LD A,1
        OUT (#FE),A
        HALT 
        XOR A
        CALL SET_PIXEL
        ;LD A,1
        ;CALL SIMPLE_DELAY
        DEC D
        INC E
        LD A,D
        OR E
        JR NZ,DPIX3
        RET 

;SET PIXEL ON SCREEN, WITH COORDINATES.
;REGISTERS:
;A = 1 - SET PIXEL, A = 0 - RESET PIXEL.
;D - X(0..255), E - Y(0..191)
;RETURN: ON SCREEN.

SET_PIXEL:
        PUSH AF
        PUSH BC
        LD C,A
        LD A,E
        CP #C0
        JR NC,PIX_E
        PUSH DE
        PUSH HL
        LD HL,SCREEN_ADDR
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
        JR Z,PIX_4      ;OPTIM.
PIX_1:  RRCA 
        DJNZ PIX_1
PIX_4:  LD B,A          ;IF FLAG A == 0.
        LD A,C
        OR A
        JR NZ,PIX_2
        LD A,B
        CPL 
        AND (HL)
        JR PIX_3
PIX_2:  LD A,B
        OR (HL)
PIX_3:  LD (HL),A
        POP HL
        POP DE
PIX_E:  POP BC
        POP AF
        RET 

;SIMPLE DELAY FUNCTION FOR DEBUG.
;A - DELAY = A*256*30 TACTS.
;RETURN: NOTHING.

SIMPLE_DELAY:
        PUSH AF
        PUSH BC
        LD A,B
        LD C,0
SIM_D:  ;NOP
        DEC BC
        LD A,B
        OR C
        JR NZ,SIM_D
        POP BC
        POP AF
        RET 

;CLEAR SCREEN FUNCTION.
;D - BYTE FOR FILL SCREEN.
;E - BYTE FOR FILL ATTRIBUTES.

CLEAR_SCREEN:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,SCREEN_ADDR
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
