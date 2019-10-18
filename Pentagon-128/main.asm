;GLOBAL SYSTEM NAMES AND CONSTANTS.

;SCREEN PARAMETERS, PIXELS AND ATTRIBUTES.
SCREEN_ADDR     EQU #4000
SCREEN_SIZE     EQU #1800
SCREEN_ATTRIB   EQU #5800
ATTRIB_SIZE     EQU #300
SCREEN_X_SIZE   EQU #20
SCREEN_Y_SIZE   EQU #18

;KEMPSTON JOYSTICK BITS TO CHECK AND PORT.
KEMPSTON_PORT   EQU #1F
KEMPSTON_MASK   EQU %00011111   ;LOW
KEMPSTON_RIGHT  EQU #00
KEMPSTON_LEFT   EQU #01
KEMPSTON_DOWN   EQU #02
KEMPSTON_UP     EQU #03
KEMPSTON_FIRE   EQU #04

;AY MODULE REMOVE LATER TO DATA SECTION.
;       ORG #8000
;MOD:   INCBIN "MOD_1.C"

;MAIN PART STARTS FROM 24K, 40KB MAX.

        ORG #6000
        LD HL,#0000     ;SET STACK TO TOP
        ADD HL,SP       ;OF CODE PART
        LD SP,#5E00     ;RESERVED FOR IM2
        PUSH HL         ;STORE FOR SAFE

;SET INTERRUPT

        DI 
        LD HL,#5EFF     ;IM2_ADDR
        LD BC,IM2       ;+FF FROM STACK
        LD (HL),C
        INC HL
        LD (HL),B
        LD A,#5E        ;SET HIGHER PART
        LD I,A
        IM 2
        EI              ;INTS 50 FPS

        CALL INIT_GAME

        ;CALL GAME_MAIN_CYCLE

        ;CALL DEBUG_SPRITES
        ;CALL KEMPSTON_JOYSTICK

TO_RET: LD A,1          ;RESTORE BORDER
        OUT (#FE),A
        POP HL
        LD SP,HL        ;RESTORE STACK
        RET 

;GLOBAL STATIC VARIABLES.

BACK_1: DUP #10
        DW 0
        EDUP 

TEST_SPR:
        DUP 20
        DB %10101010
        DB %01010101
        EDUP 

;GLOBAL GAME CONSTANTS AND VARIABLES.
SPRITE_MOV      EQU %00000001
SPRITE_AND      EQU %00000010
SPRITE_OR       EQU %00000100
SPRITE_XOR      EQU %00001000

WORLD_SIZE_X    EQU 1024
WORLD_SIZE_Y    EQU 32  ;X AND Y IN PIXELS

KEMPSTON:       DB #00  ;EVERY INTERRUPT.

ACTIVE_LOCATION:DB #00

BOB_POSITION:           ;GAME COORDINATES
        DW #0412        ;LEFT START X
        ;DW #0000       ;TOP START Y
BOB_DIRECTION:
        DB #00

LOCATION_0:     ;INCBIN "01.C",4096
;LOCATION_1:    INCBIN "02.C",4096
;LOCATION_2:    INCBIN "03.C",4096
;LOCATION_3:    INCBIN "04.C",4096

STATUS_BAR:     ;INCBIN "STATUS.C",512

ROAD_TILE:
        INCBIN "TILE.C"

CHARACTERS:
;CONSTANT PART OF CHARACTER STRUCTURE.
;[0,1]  POSITION X AND Y ON SCREEN.
;[2,3]  SIZES OF CHAR X AND Y, ALL.
;[4]    PARTS OF CHARACTER AND ANIMATION.
;[5]    FLAGS FOR CHARACTER.
;VARIABLE PART OF STRUCTURE, USE RESERVED.
;[6..N*[4]]
;       ADDRESESS OF PARTS, 16BITS.

;PART OF CHARACTER STRUCTURE, MASKS HERE.
;[0,1]  POSITION OF PART X AND Y FROM 0.
;[2,3]  SIZES OF PART X AND Y.
;[4]    CURRENT ANIMATION FRAME.
;[5]    CURRENT DELAY IN /50 FPS.
;[6]    ANIMATIONS TOTAL.
;[7]    FLAGS.
;VARIABLE PART WITH FRAMES AND DELAYS.
;[8..N*[6]]
;[0]    DELAY OF FRAME IN 50 FPS SPEED.
;[1,2]  ADRESSES OF ANIMATION FRAMES.

;MAIN CHARACTER STRUCTURE OF THE GAME.
BOB:
        DB #01,#12      ;POSITION
        DB #04,#04      ;SIZES
        DB 4            ;PARTS
        DB %00000000    ;FLAGS
        DW BOB_1        ;PART 1 - MASK
        DW BOB_2        ;PART 2 - HEAD
        DW BOB_3        ;PART 3 - FACE
        DW BOB_4        ;PART 4 - FOOTS

;MAIN CHARACTER PARTS STRUCTURE.
BOB_1:  DB #00,#00      ;LEFT-UP CORNER
        DB #04,#04      ;MASK
        DB #00          ;FRAME
        DB #00          ;DELAY
        DB #01          ;ALL FRAMES
        DB %00000010    ;FLAGS(AND)
        DB #00          ;STATIC
        DW BOB_MASK

BOB_2:  DB #00,#00      ;LEFT-UP
        DB #04,#01      ;TOP OF HEAD
        DB #00,#00      ;FRAME AND DELAY
        DB #01          ;ALL
        DB %00000100    ;(OR)
        DB #00          ;STATIC
        DW BOB_1_1

BOB_3:  DB #00,#01      ;NEXT LINES
        DB #04,#01      ;FACE
        DB #00,#00      ;FRAME AND DELAY
        DB #01          ;ONE FRAME
        DB %00000100    ;(OR)
        DB #00          ;STATIC
        DW BOB_2_1

BOB_4:  DB #00,#02      ;NEXT LINES
        DB #04,#02      ;FOOTS
        DB #00,#00      ;FRAME AND DELAY
        DB #01          ;ONE FRAME
        DB %00000100    ;(OR)
        DB #00          ;STATIC
        DW BOB_3_1

BOB_MASK:       INCBIN "BOB_MSK.C",128
BOB_1_1:        INCBIN "BOB_P1F1.C",32
BOB_2_1:        INCBIN "BOB_P2F1.C",32
BOB_3_1:        INCBIN "BOB_P3F1.C",64

BOB_DATA:       INCBIN "BOB.C",128

GAME_OBJECTS:

LAMP_1: ;INCBIN "LAMP_01.C",256
LAMP_2: ;INCBIN "LAMP_02.C",256
LAMP_M: ;INCBIN "LAMP_M.C",256

;DRAW CHARACTER FUNCTION IN BYTES.
;USING "DRAW_SPRITE" FUNCTION AND STRUC.
;IX - ADDRESS OF CHARACTER DATA STRUCTURE.

DRAW_ANIMATION:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
;IY - PARTS. IX - MAIN STRUCTURE.

        CALL DRAW_STAT_ELEM

        LD B,(IX+4)
        PUSH IX
        POP HL
        LD DE,#0006     ;TABLE OF PARTS
        ADD HL,DE

ANIM_1: PUSH BC
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL          ;NEXT PART IN HL
        PUSH HL
        EX DE,HL        ;DE - ADDR PART
        PUSH HL
        POP IY          ;IY - PART STRUC
        LD L,(IY+9)     ;ADDR OF FRAME
        LD H,(IY+10)
        LD A,(IX+0)
        ADD A,(IY+0)
        LD D,A
        LD A,(IX+1)
        ADD A,(IY+1)
        LD E,A
        LD B,(IY+2)
        LD C,(IY+3)
        LD A,(IY+7)
        CALL DRAW_SPRITE
        POP HL
        POP BC
        DJNZ ANIM_1

AN_RET: POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;INITIALIZATION OF GAME PARAMETERS.
;MAY BE NOT NEEDED.
INIT_GAME:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
        LD D,0
        LD E,%01000111
        CALL CLEAR_SCREEN

        LD IX,BOB
        CALL DRAW_ANIMATION

        POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;GAME MAIN CYCLE.

LAMP_FRAME:     DB 0

GAME_MAIN_CYCLE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        CALL DRAW_STAT_ELEM

DBG_S:  LD BC,#0100     ;MAIN CYCLE
DBG_3:  PUSH BC

        LD HL,LAMP_M
        LD DE,#140F
        LD BC,#0408
        LD A,2
        HALT 
        CALL DRAW_SPRITE
        LD DE,#140F
        LD BC,#0408
        LD A,(LAMP_FRAME)
        BIT 0,A
        JR Z,FRAME_2
        LD HL,LAMP_1
        JR DRW
FRAME_2:LD HL,LAMP_2
DRW:    INC A
        LD (LAMP_FRAME),A
        LD A,4
        CALL DRAW_SPRITE
        LD A,2
        LD HL,CHARACTERS
        LD DE,(BOB_POSITION)
        LD BC,#0404
        LD A,1
        CALL DRAW_SPRITE
        ;JR DBG_7       ;WITHOUT CONTROL
        CALL KEMPSTON_JOYSTICK
        LD DE,(BOB_POSITION)
;SWITCH SCREENS TEST.
        LD A,D
        CP 28           ;LATER
        JR NZ,DBG_5
        LD D,1
        LD A,(ACTIVE_LOCATION)
        CP 3
        JR Z,DBG_6
        INC A
        JR DBG_6
DBG_5:  CP 0
        JR NZ,DBG_7
        LD D,27
        LD A,(ACTIVE_LOCATION)
        OR A
        JR Z,DBG_6
        DEC A
DBG_6:  LD (ACTIVE_LOCATION),A
        CALL DRAW_STAT_ELEM
        LD (BOB_POSITION),DE
DBG_7:  LD A,#04
        OUT (#FE),A
        POP BC
        DEC BC
        LD A,B
        OR C
        JP NZ,DBG_3
DBG_RET:
        POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;MOVING CHARACTER WITH KEMPSTON JOYSTICK.
;USING GLOBAL VARIABLES:
;"KEMPSTON" - INPUT FROM IM2.
;"BOB_POSITION" - X AND Y ON SCREEN.

KEMPSTON_JOYSTICK:
        PUSH AF
        PUSH HL
KMP_J0: LD HL,(BOB_POSITION)
        LD A,(KEMPSTON)
        BIT KEMPSTON_RIGHT,A
        JR Z,KMP_J1
        LD A,H
        CP 28           ;INSERT LIMIT X
        JR Z,KMP_J6
        INC H
        JR KMP_J5
KMP_J1: BIT KEMPSTON_LEFT,A
        JR Z,KMP_J2
        LD A,H
        OR H            ;GLOBAL
        JR Z,KMP_J6
        DEC H
        JR KMP_J5
KMP_J2: BIT KEMPSTON_DOWN,A
        JR Z,KMP_J3
        LD A,L
        CP 20           ;INSERT LIMIT Y
        JR Z,KMP_J6
        INC L
        JR KMP_J5
KMP_J3: BIT KEMPSTON_UP,A
        JR Z,KMP_J4
        LD A,L
        CP 16           ;GLOBAL
        JR Z,KMP_J6
        DEC L
        JR KMP_J5
KMP_J4: BIT KEMPSTON_FIRE,A
        JR Z,KMP_J6
        LD A,#07        ;JUST WHITE BORDER
        OUT (#FE),A
        HALT 
KMP_J5: LD (BOB_POSITION),HL
KMP_J6: POP HL
        POP AF
        RET 

;DRAW STATIC GAME ELEMENTS ON SCREEN.
;LOCATION, ROAD AND STATUS BAR.
;USGIN GLOBAL VARIABLES:
;ACTIVE_LOCATION - 0..3.

DRAW_STAT_ELEM:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD A,(ACTIVE_LOCATION)
        LD DE,#1000     ;MAIN BACKGROUND
        LD HL,LOCATION_0
        OR A
        JR Z,STAT_1
STAT_0: ADD HL,DE
        DEC A
        JR NZ,STAT_0
STAT_1: LD DE,#0004
        LD BC,#2010
        HALT 
        CALL DRAW_SPRITE
;TEMPORARY FOR STATUS BAR
        LD HL,STATUS_BAR
        LD DE,#0000
        LD BC,#2002
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        LD A,#10
        LD BC,#0204     ;ROAD SIZE
        LD DE,#0014     ;ROAD POSITION
        LD HL,ROAD_TILE
STAT_2: PUSH AF
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        POP AF
        INC D
        INC D
        DEC A
        JR NZ,STAT_2
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
        DB %01001111

IM2:    DI 
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
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
IM2_2:  ;JR IM2_RET     ;TESTING COLORS
        IN A,(KEMPSTON_PORT)
        AND KEMPSTON_MASK
        LD (KEMPSTON),A
;CALL MINIMAL AY-PLAYER.
;       CALL MOD
        POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        EI 
        RETI 

;DRAW A SPRITE ON SCREEN.
;A - TYPE OF DRAW ON SCREEN MEMORY, BIT N.
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
        PUSH IX
        PUSH AF         ;CHECK PARAMETERS
        PUSH BC
        LD A,D
        ADD A,B
        JR C,SPR_ERR    ;MORE THAN 255
        LD B,A
        LD A,SCREEN_X_SIZE
        CP B
        JR C,SPR_ERR    ;TOO BIG
        LD A,E
        ADD A,C
        JR C,SPR_ERR
        LD C,A
        LD A,SCREEN_Y_SIZE
        CP C
        JR NC,SPR_OK
SPR_ERR:POP BC
        POP AF
        JR SPR_RET
SPR_OK: POP BC
        POP AF
        PUSH HL
        BIT 0,A         ;ADDRESS OF JUMP
        JR Z,SPR_4      ;TYPE DRAW MOVE
SPR_7:  LD HL,SPR_MOV
        JR SPR_DRW
SPR_4:  BIT 1,A
        JR Z,SPR_5      ;AND DRAW(MASK)
        LD HL,SPR_AND
        JR SPR_DRW
SPR_5:  BIT 2,A         ;OR DRAW(UNION)
        JR Z,SPR_6
        LD HL,SPR_OR
        JR SPR_DRW
SPR_6:  BIT 3,A         ;XOR DRAW(EXTRA)
        JR Z,SPR_7      ;IF ERROR, MOVE
        LD HL,SPR_XOR
SPR_DRW:PUSH HL
        POP IX          ;SAVE ADDRESS
        POP HL
SPR_3:  PUSH DE         ;SAVE COORDS
        PUSH HL         ;MAKE ADDRESS
        LD HL,SCREEN_ADDR
        LD A,E          ;LOW PART ADDR
        AND %00000111
        RRCA 
        RRCA 
        RRCA 
        OR D
        LD L,A
        LD A,E          ;2048(1/3) PART
        AND %00011000
        LD E,A
        LD A,H
        OR E
        LD H,A
        EX DE,HL
        POP HL

        PUSH BC         ;SIZES IN STACK
        ;POP DE         ;COORDS IN STACK
        LD C,8          ;DRAW 8 LINES * X
SPR_2:  PUSH BC
        PUSH DE         ;SAVE LINE ADDR.
SPR_1:  LD A,(DE)       ;DRAW 1 LINE
        JP (IX)         ;INDERECT CALL
SPR_AND:AND (HL)
        JR SPR_ST       ;TYPES OF DRAW
SPR_OR: OR (HL)
        JR SPR_ST
SPR_XOR:XOR (HL)
        JR SPR_ST
SPR_MOV:LD A,(HL)
SPR_ST: LD (DE),A       ;STORE BYTE
        INC HL
        INC DE
        DJNZ SPR_1
        POP DE
        INC D
        POP BC
        DEC C
        JR NZ,SPR_2
        POP BC          ;COORDS AND SIZES,
        POP DE          ;IN REGISTERS
        INC E
        DEC C
        JR NZ,SPR_3     ;NEW ADDRESS
SPR_RET:POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;NIGHT SKY WITH STARS.
;TODO.

BACK_PLANE:
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
;       CALL SIMPLE_DELAY
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

;CLEAR SCREEN FUNCTION.
;D - BYTE FOR FILL SCREEN.
;E - BYTE FOR FILL ATTRIBUTES.

CLEAR_SCREEN:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,SCREEN_ADDR
        LD BC,SCREEN_SIZE
CLR_1:  LD A,D
        LD (HL),A
        INC HL
        DEC BC
        LD A,B
        OR C
        JR NZ,CLR_1
        LD BC,ATTRIB_SIZE
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
  