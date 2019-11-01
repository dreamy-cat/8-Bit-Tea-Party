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
;       ORG #C000
;MOD:   INCBIN "MOD.C"

;MAIN PART STARTS FROM 24K, 40KB MAX.

        ORG #6000
        LD HL,#0000     ;SET STACK TO TOP
        ADD HL,SP       ;OF CODE PART
        LD SP,#5E00     ;RESERVED FOR IM2
        PUSH HL         ;STORE FOR SAFE

        PUSH AF         ;REMOVE LATER
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
;SET INTERRUPT
        ;JR NO_IM2
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
NO_IM2:
        ;CALL INIT_GAME
        ;CALL GAME_MAIN_CYCLE
        CALL DRAW_BACKGROUND

        LD HL,LOCATION_0
        LD DE,LOCATION_1
        LD HL,LOC_DATA_0

        LD A,0
        LD (ACTIVE_LOCATION),A
        CALL CREATE_SCENE

TO_RET: LD A,1          ;RESTORE BORDER
        OUT (#FE),A
        POP IY          ;RESTORE REGS
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF

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

RANDOM_INIT     EQU %10101010
WORLD_SIZE_X    EQU 1024
WORLD_SIZE_Y    EQU 32  ;X AND Y IN PIXELS
WORLD_LOCATIONS EQU 4
STARS_ON_SKY    EQU 255
STARS_POSITION  EQU 16  ;AFTER STATUS BAR
STARS_SIZE      EQU 16  ;MASKS FOR BITS

;SYSTEM VARIABLES

KEMPSTON:       DB #00  ;EVERY INTERRUPT

;GAME VARIABLES

STARS:          DUP STARS_ON_SKY
                DW #0000
                EDUP 
ACTIVE_LOCATION:DB #00  ;HERO LOCATION
LOCATION_ADDR:  DW LOC_DATA_0
BOB_POSITION:   DW #0414;X AND Y OF CENTER
BOB_PREV_POS    DW #0000;PREVIOUS POSITION
BOB_DIRECTION:  DB #00  ;LEFT OR RIGHT
BOB_ACTION:     DW #0000;ADDR OF ANIMATION

;GAME WORLD DATA, 64 BYTES FOR EVERY
;LOCATION, CONTAINS OBJECTS AND
;CHARACTERS, 8 BYTES FOR EVERY OBJECT.
;MAXIMUM DATA: 5 LOCTIONS AND OBJECTS.
;IN GAME WORLD, ONLY FOR GFX FOR NOW.
;[0]            OBJECTS IN LOCATION
;[1]            AREAS FOR MOVE IN LOCATION
;[2..3]         RESERVED
;[4..15]        5 AREAS MAX, FORMAT
;               LEFT-UP AND RIGHT DOWN
;               CORNER IN ATTRIBUTES
;VARIABLE PART.
;[24..[0]*4]    OBJECT ADDRESS
;[2,3]          OBJECT POS X,Y(TO SRPITE)
;[4]            PLANE OF OBJECT, PRIORITY
;[5..7]         RESERVED

GAME_WORLD:
LOCATION_0:
        DB #01,#01      ;OBJECTS AND AREAS
        DB #00,#00      ;RESERVED
        DB #00,#14      ;ROAD AREA
        DB #31,#17
        DUP #04         ;RESERVED
        DB #00,#00
        DB #00,#00
        EDUP 
LMP_1:  DW LAMP_A       ;ADDR ANIM
        DB #12,#08      ;POS X,Y
        DB #00          ;PLANE
        DB #00,#00,#00  ;RESERVED
        DUP #04         ;OTHER 4 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 
LOCATION_1:             ;TODO
        DB #01,#01
        DB #00,#00
        DB #00,#14
        DB #31,#17

;STANDARD OBJECTS
LAMP_A: DB #10,#10      ;POS
        DB #04,#08      ;MAXIMUM SIZES
        DB #04          ;TWO FOR DEBUG
        DB %00000000
        DW LAMP_1
        DW LAMP_2
        DW LAMP_3
        DW LAMP_4

LAMP_1: DB #01,#03      ;MASK FOR STAND
        DB #02,#05
        DB #00,#00      ;STAT
        DB #01          ;ALL
        DB %00110010    ;SINGLE-AND-STATIC
        DW LAMP_DAT_M0
        DB #00,#00

LAMP_2: DB #01,#03      ;STAND
        DB #02,#05
        DB #00,#00
        DB #01
        DB %00110100    ;SINGLE-OR-STATIC
        DW LAMP_DAT_0
        DB #00,#00      ;NOTHING TO ANIM

LAMP_3: DB #00,#00      ;MASK FOR LAMP
        DB #04,#03
        DB #00,#01
        DB #01
        DB %00000010    ;DRAW-OR-DYNAMIC
        DW LAMP_DAT_M1
        DB #25,#00

LAMP_4: DB #00,#00      ;ANIM FOR LIGHT
        DB #04,#03
        DB #00,#01
        DB #02          ;FRAMES
        DB %00000100    ;DRAW-OR-DYNAMIC
        DW LAMP_DAT_1
        DB #25,#00
        DW LAMP_DAT_2
        DB #25,#00

LAMP_DAT_M0:    INCBIN "LMPP2MSK.C",80
LAMP_DAT_0:     INCBIN "LMP_P2F1.C",80
LAMP_DAT_M1:    INCBIN "LMPP1MSK.C",96
LAMP_DAT_1:     INCBIN "LMP_P1F1.C",96
LAMP_DAT_2:     INCBIN "LMP_P1F2.C",96

LOC_DATA_0:     INCBIN "BG01.C",4096
LOC_DATA_1:     ;INCBIN "BG02.C",4096
LOC_DATA_2:     ;INCBIN "BG03.C",4096
LOC_DATA_3:     ;INCBIN "BG04.C",4096

STATUS_BAR:     INCBIN "STATUS.C",512

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
;       0..3 MOV,AND,OR,XOR FOR SPRITE
;       4 IS STATIC PART
;       5 DRAW SINGLE CALL, RESET AFTER
;       6 DRAW EVERY CALL, COUNT DELAYS
;VARIABLE PART WITH FRAMES AND DELAYS.
;[8..N*[6]]
;[0,1]  ADRESSES OF ANIMATION FRAMES.
;[2]    DELAY OF FRAME IN 50 FPS SPEED.
;[3]    RESERVED.

;MAIN CHARACTER STRUCTURE OF THE GAME.
BOB:
        DB #02,#12      ;POSITION
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
        DB #00,#00      ;FRAME AND DELAY
        DB #01          ;ALL FRAMES
        DB %01010010    ;REDRAW+AND+STATIC
        DW BOB_MASK
        DB #00,#00      ;

BOB_2:  DB #00,#00      ;LEFT-UP
        DB #04,#01      ;TOP OF HEAD
        DB #00,#00      ;FRAME AND DELAY
        DB #01          ;ALL
        DB %01010100    ;REDRAW+OR+STATIC
        DW BOB_1_1
        DB #00,#00      ;

BOB_3:  DB #00,#01      ;NEXT LINES
        DB #04,#01      ;FACE
        DB #00,#00      ;FRAME AND DELAY
        DB #03          ;FRAMES
        DB %01000100    ;REDRAW+OR
        DW BOB_2_1      ;DELAY AND FRAMES
        DB #93,#00
        DW BOB_2_2
        DB #04,#00
        DW BOB_2_3
        DB #04,#00

BOB_4:  DB #00,#02      ;NEXT LINES
        DB #04,#02      ;FOOTS
        DB #00,#01      ;FRAME AND DELAY
        DB #04          ;4 FRAMES
        DB %01000100    ;REDRAW+OR
        DW BOB_3_1      ;DELAY AND FRAMES
        DB #0C,#00
        DW BOB_3_2
        DB #0C,#00
        DW BOB_3_1
        DB #0C,#00
        DW BOB_3_3
        DB #0C,#00

BOB_MASK:       INCBIN "BOB_MSK.C",128
BOB_1_1:        INCBIN "BOB_P1F1.C",32
BOB_2_1:        INCBIN "BOB_P2F1.C",32
BOB_2_2:        INCBIN "BOB_P2F2.C",32
BOB_2_3:        INCBIN "BOB_P2F3.C",32
BOB_3_1:        INCBIN "BOB_P3F1.C",64
BOB_3_2:        INCBIN "BOB_P3F2.C",64
BOB_3_3:        INCBIN "BOB_P3F3.C",64
BOB_3_4:        ;INCBIN "BOB_P3F4.C",64

;CREATE SCENE ON EVERY FRAME IN GAME,
;UPDATING OBJECTS, CHARACTERS AND OTHER
;GRAPHICS ON SCREEN WITH DYNAMIC.
;WITHOUT GAME LOGIC. USING GLOBAL DATA.

BG_LEFT:        DUP #20
                DB #00
                EDUP 

BG_RIGHT:       DUP #20
                DB #00
                EDUP 

;BCKG_BOB:      DUP #80
;               DB #00
;               EDUP

CREATE_SCENE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX

        LD HL,(BOB_POSITION)
        LD (BOB_PREV_POS),HL

;CREATE LOCATIONS AND OBJECTS

        LD HL,GAME_WORLD
        LD A,(ACTIVE_LOCATION)
        LD B,6          ;* 64 BYTES
        LD D,0
SCENE_2:SLA A           ;TWO BYTES
        JR NC,SCENE_1
        INC D
SCENE_1:DJNZ SCENE_2
        LD E,A
        ADD HL,DE       ;HL ADDR LOCATION
        LD B,(HL)       ;OBJECTS COUNTER
        LD DE,#0018     ;OFFSET OF OBJECT
        ADD HL,DE
SCENE_3:LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        PUSH DE
        POP IX
        CALL DRAW_ANIMATION
        DJNZ SCENE_3

        LD C,2
SCN_S:  PUSH BC


        ;JP SCENE_R

;RESTORE BACKGROUND FROM BOB PREVIOUS POS



        LD HL,(LOCATION_ADDR)
        LD BC,(BOB_PREV_POS)    ;X AND Y
        LD DE,(BOB_POSITION)
        LD A,D
        CP B
        JR Z,SCENE_4    ;IF NOT HORIZONTAL
        JR C,SCENE_5    ;IF RIGHT MOVE

        LD HL,BG_LEFT
        LD A,B
        SUB #02
        LD D,A
        LD A,C
        SUB #02
        LD E,A
        LD BC,#0104


        JR SCENE_7
SCENE_5:
                        ;IF LEFT MOVE
        JR SCENE_7
SCENE_4:LD A,E
        CP C
        JR Z,SCENE_8    ;IF NOT VERTICAL
        JR NC,SCENE_6   ;IF DOWN MOVE

        JR SCENE_7
SCENE_6:                ;IF UP MOVE
        ;TODO

SCENE_7:LD A,SPRITE_MOV
        CALL DRAW_SPRITE
                        ;RESTORE

SCENE_8:                ;BOB STAY

;DRAW MAIN CHARACTER REMOVE LOGIC LATER

SCENE_9:LD IX,BOB
        LD HL,BOB_POSITION
        LD A,(HL)
        SUB #02         ;BOB CENTER
        LD E,A
        LD (IX+1),A
        INC HL
        LD A,(HL)
        SUB #02
        LD (IX+0),A
        LD D,A
        CALL DRAW_ANIMATION

        ;JR SCENE_R

;SAVE BACKGROUND FOR BOB
;FOR LEFT AND RIGHT DE - X AND Y

        LD C,4          ;BOB SIZE
SCN_11: LD HL,SCREEN_ADDR
        LD A,E
        AND %00000111   ;LOW PART ADDRESS
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
        PUSH DE
        LD DE,BG_LEFT
        LD B,8          ;BYTES PER ATTRIB
SCN_10: LD A,(HL)
        LD (DE),A
        INC H
        INC DE
        DJNZ SCN_10
        POP DE
        INC E
        DEC C
        JR NZ,SCN_11

        LD HL,(BOB_POSITION)
        LD (BOB_PREV_POS),HL
        INC H
        LD (BOB_POSITION),HL
        POP BC
        DEC C
        JP NZ,SCN_S


SCENE_R:POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;DRAW ANIMATION FUNCTION IN BYTES.
;USING "DRAW_SPRITE" FUNCTION AND STRUC.
;IX - ADDRESS OF CHARACTER DATA STRUCTURE.
;RESULT ON SCRREN.
;DRAW ALSO STATIC OBJECT, NO RANGE CHECKS.
;KNOWN BUG: USING STS DEBUGGER IN FUSE,
;SOMETIMES RANDOM DATA SAVED TO MEMORY.

DRAW_ANIMATION:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
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
        PUSH HL         ;SAVE PART
        EX DE,HL        ;DE - ADDR PART
        PUSH HL
        POP IY          ;IY - PART STRUC
        LD C,(IY+7)     ;FLAGS IN REG C
        BIT 4,C         ;EXTRA BIT
        JR NZ,ANIM_2    ;STATIC PART
        DEC (IY+5)      ;CURRENT DELAY
        JR NZ,ANIM_2
        SET 5,C         ;RE-DRAW PART
        SET 7,C         ;RESET DELAY
        INC (IY+4)      ;NEXT FRAME
        LD A,(IY+4)
        CP (IY+6)
        JR NZ,ANIM_2
        LD (IY+4),0     ;TO 0-FRAME
ANIM_2: BIT 5,C         ;DRAW OR NOT PART
        JR NZ,ANIM_5
        BIT 6,C         ;SINGLE OR EVERY
        JR Z,ANIM_4     ;FRAME TO DRAW
ANIM_5: LD A,(IY+4)
        PUSH IY
        POP HL          ;ADDR OF 0-FRAME
        RLCA            ;ADD TO INDEX*4
        RLCA            ;PERFORMANCE SLA
        ADD A,#08       ;OFFSET OF TABLE
        LD E,A
        LD D,#00
        ADD HL,DE
        BIT 7,C         ;IF NEED TO SET
        JR Z,ANIM_3
        INC HL          ;ADD OFFSET DELAY
        INC HL
        LD A,(HL)       ;OFFSET OF DELAY
        LD (IY+5),A     ;SET NEW DELAY
        DEC HL          ;TO ADDR OF FRAME
        DEC HL
ANIM_3: LD E,(HL)       ;DRAW CURRENT
        INC HL          ;HL ADDR OF TABLE
        LD D,(HL)
        EX DE,HL        ;HL ADDR OF FRAME
        LD A,(IX+0)
        ADD A,(IY+0)    ;POSITION WITHOUT
        LD D,A          ;CHECK OF RANGES
        LD A,(IX+1)
        ADD A,(IY+1)
        LD E,A
        LD A,C          ;DRAW TYPE
        LD B,(IY+2)
        LD C,(IY+3)
        CALL DRAW_SPRITE
        RES 5,(IY+7)    ;DO NOT DRAW NEXT
ANIM_4: POP HL
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

        CALL DRAW_BACKGROUND

DBG_S:  LD BC,#0200     ;MAIN CYCLE
DBG_3:  PUSH BC
        HALT 
        CALL CREATE_SCENE
        ;JP DBG_7
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
        CALL DRAW_BACKGROUND
        LD (BOB_POSITION),DE
DBG_7:  LD A,#04
        OUT (#FE),A
        POP BC
        DEC BC
        LD A,B
        OR C
        JP NZ,DBG_3
;REUSE LATER
;       LD A,(ACTIVE_LOCATION)
;       LD DE,#1000     ;MAIN BACKGROUND
;       LD HL,LOC_DATA_0
;       OR A
;       JR Z,STAT_1

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
        LD (BOB_PREV_POS),HL
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

;DRAW GAME BACKGROUND ON SCREEN.
;LOCATION, ROAD AND STATUS BAR.
;USGIN GLOBAL VARIABLES:
;ACTIVE_LOCATION - 0..3.

DRAW_BACKGROUND:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD D,%00000000
        LD E,%01000111
        CALL CLEAR_SCREEN
        LD HL,(LOCATION_ADDR)
        LD A,0
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
;DRAW A RANDOM STARS ON SKY.
        LD B,STARS_ON_SKY
STAT_3: CALL RANDOM
        AND %00001111   ;FOR 16 PIXELS
        ADD A,STARS_POSITION
        LD E,A
        CALL RANDOM
        LD D,A
        CALL SET_PIXEL
        DJNZ STAT_3

        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;IM2 INTERRUPT PART OF CODE.

IM2:    DI 
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
        LD A,1          ;PERFORMANCE
        OUT (#FE),A
        IN A,(KEMPSTON_PORT)
        AND KEMPSTON_MASK
        LD (KEMPSTON),A
;       CALL MOD        ;CALL AY-PLAYER.
IM2_R:  POP IY
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
SPR_RET:
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;FUNCTION OF SIMPLE RANDOM 8-BIT VALUE.
;USING GLOBAL VARAIABLE "RANDOM_INIT".
;RETURN: A - RANDOM VALUE, FLAGS NOT
;RESTORED.

RANDOM_DATA:    DB RANDOM_INIT
                DB #00  ;STORED DATA

RANDOM: PUSH BC
        LD A,(RANDOM_DATA)
        AND %00001111   ;15 ROTATIONS MAX
        LD B,A
        LD A,(RANDOM_DATA)
RND_1:  RLA 
        DJNZ RND_1
        LD BC,(RANDOM_DATA)
        XOR C
        ADD A,B
        LD B,C
        LD C,A
        LD (RANDOM_DATA),BC
        POP BC
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
