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
        ORG #C000
MOD:    INCBIN "MOD.C"

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
        CALL INIT_GAME

        ;CALL DRAW_BACKGROUND
        ;CALL CREATE_SCENE

        CALL GAME_MAIN_CYCLE

        JP TO_RET

        LD BC,#0100
TST_1:  HALT 
        PUSH BC
        PUSH IY
        POP HL
        LD A,SPRITE_MOV
        LD DE,#1110
        LD BC,#0403
        CALL DRAW_SPRITE
        LD A,SPRITE_A_O
        OR SPRITE_SAV
        LD DE,#1110
        LD BC,#0403
        LD HL,LAMP_DAT_1
        LD IX,LAMP_DAT_M1
        CALL DRAW_SPRITE
TST_2:  LD A,#04
        OUT (#FE),A
        POP BC
        DEC BC
        LD A,B
        OR C
        JR NZ,TST_1

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

TEST_SPR:
        DUP 20
        DB %10101010
        DB %01010101
        EDUP 

;GLOBAL GAME CONSTANTS AND VARIABLES.
SPRITE_MOV      EQU %00000001
SPRITE_AND      EQU %00000010
SPRITE_OR       EQU %00000100
SPRITE_A_O      EQU %00001000
SPRITE_SAV      EQU %00010000
SPRITE_MSK      EQU %00011111

RANDOM_INIT     EQU %10101010
WORLD_SIZE_X    EQU 1024
WORLD_SIZE_Y    EQU 32  ;X AND Y IN PIXELS
WORLD_LOCATIONS EQU 4
STARS_ON_SKY    EQU 255
STARS_POSITION  EQU 16  ;AFTER STATUS BAR
STARS_SIZE      EQU 24  ;2 ATTRIBUTES

;SYSTEM VARIABLES

KEMPSTON:       DB #00  ;EVERY INTERRUPT

;GAME VARIABLES

STARS:          DUP STARS_ON_SKY
                DW #0000
                EDUP 
ACTIVE_LOCATION:DB #00  ;HERO LOCATION
LOCATION_ADDR:  DW LOC_DATA_0
;BOB POSITIONS MUST BE EQUAL ON ASSEMBLE
BOB_START_POS:  DW #0215;DEFAULT
BOB_POSITION:   DW #0215;X AND Y OF CENTER
BOB_PREV_POS    DW #0215;PREVIOUS POSITION
BOB_DIRECTION:  DB #00  ;LEFT OR RIGHT
BOB_ACTION:     DW #0000;ADDR OF ANIMATION
BOB_ENERGY:     DB #03

GAME_TIMER:     DB #00  ;ALL TIME FOR BOB
BAR_A_SIZE      EQU #0C         ;SIZE
BAR_WIDTH       EQU #02
BAR_ATTRIB:     DB %01010111    ;RED
                DB %01010111
                DB %01010111
                DB %01010111
                DB %01110111    ;YELLOW
                DB %01110111
                DB %01110111
                DB %01110111
                DB %01100111    ;GREEN
                DB %01100111
                DB %01100111
                DB %01100111

INVENTORY:      DB #00,#00      ;ITEMS

ITEMS_TABLE:    DW ITEM_A
                DW ITEM_B

ITEM_A:         INCBIN "ITM_A.C",72
ITEM_B:         INCBIN "ITM_B.C",72

;GAME WORLD DATA, 64 BYTES FOR EVERY
;LOCATION, CONTAINS OBJECTS AND
;CHARACTERS, 8 BYTES FOR EVERY OBJECT.
;MAXIMUM DATA: 5 LOCTIONS AND OBJECTS.
;IN GAME WORLD, ONLY FOR GFX FOR NOW.
;[0]            OBJECTS IN LOCATION
;[1]            AREAS FOR MOVE IN LOCATION
;[2..3]         RESERVED
;[4..23]        5 AREAS MAX, FORMAT
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
        DB #15,#0E      ;POS X,Y
        DB #00          ;PLANE
        DB #00,#00,#00  ;RESERVED
        DUP #04         ;OTHER 4 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 
LOCATION_1:             ;TODO
        DB #01,#01      ;OBJ AND LOC
        DB #00,#00      ;RESERVED
        DB #00,#14
        DB #31,#17
        DUP #04         ;RESERVED
        DB #00,#00
        DB #00,#00
        EDUP 
DOG_A:  DW DOG          ;ADDR ANIM
        DB #15,#14      ;POS X,Y
        DB #00          ;PLANE
        DB #00,#00,#00  ;RESERVED
        DUP #04         ;4 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 
LOCATION_2:             ;TODO
        DB #00,#01      ;OBJ AND LOC
        DB #00,#00      ;RESERVED
        DB #00,#14
        DB #31,#17
        DUP #04         ;RESERVED
        DB #00,#00
        DB #00,#00
        EDUP 
        DUP #05         ;4 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 
LOCATION_3:             ;TODO
        DB #00,#01      ;OBJ AND LOC
        DB #00,#00      ;RESERVED
        DB #00,#14
        DB #31,#17
        DUP #04         ;RESERVED
        DB #00,#00
        DB #00,#00
        EDUP 
        DUP #05         ;5 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 

;STANDARD OBJECTS
LAMP_A: DB #10,#10      ;POS
        DB #04,#08      ;MAXIMUM SIZES
        DB #02          ;TWO FOR DEBUG
        DB %00000000
        DW LAMP_1
        DW LAMP_2

LAMP_1: DB #01,#03      ;STAND WITH MASK
        DB #02,#05
        DB #00,#00      ;STAT
        DB #01          ;ALL
        DB %10111000    ;SINGLE-AND-STATIC
        DW LAMP_DAT_0   ;AND-OR TEST
        DW LAMP_DAT_M0  ;MASK
        DW LAMP_BG      ;SAVING BG
        DB #00,#00      ;NO DELAYS

LAMP_2: DB #00,#00      ;ANIM FOR LIGHT
        DB #04,#03
        DB #00,#01
        DB #02          ;FRAMES
        DB %00001000    ;DRAW-DYNAMIC
        DW LAMP_DAT_1   ;AND-OR
        DW LAMP_DAT_M1
        DW #0000        ;NOT SAVING BG
        DB #25,#00
        DW LAMP_DAT_2
        DW LAMP_DAT_M1
        DW #0000        ;NOT SAVING BG
        DB #25,#00

LAMP_BG:        DUP 80
                DB #00
                EDUP 

DOG:    DB #10,#10      ;POS
        DB #04,#03      ;MAXIMUM SIZES
        DB #01          ;TWO FOR DEBUG
        DB %00000000
        DW DOG_1
DOG_1:  DB #00,#00      ;ONE PART
        DB #04,#03
        DB #00,#00      ;STAT
        DB #01          ;ALL
        DB %10110001    ;SINGLE-AND-STATIC
        DW DOG_DAT_0    ;AND-OR TEST
        DW #0000        ;MASK
        DW #0000        ;BG
        DB #00,#00

LAMP_DAT_M0:    INCBIN "LMPP2MSK.C",80
LAMP_DAT_0:     INCBIN "LMP_P2F1.C",80
LAMP_DAT_M1:    INCBIN "LMPP1MSK.C",96
LAMP_DAT_1:     INCBIN "LMP_P1F1.C",96
LAMP_DAT_2:     INCBIN "LMP_P1F2.C",96

DOG_DAT_0:      INCBIN "CHAR_1.C",96
MAN_DAT_0:      INCBIN "CHAR_2.C",80

LAMP_SHAD_0:    INCBIN "LMPSHD_C.C",8
LAMP_SHAD_1:    INCBIN "LMPSHD_V.C",8
LAMP_SHAD_2:    INCBIN "LMPSHD_H.C",8
LAMP_SHAD_3:    DUP 08
                DB #00
                EDUP 

LOC_DATA_0:     INCBIN "BG01.C",4096
LOC_DATA_1:     INCBIN "BG02.C",4096
LOC_DATA_2:     INCBIN "BG03.C",4096
LOC_DATA_3:     INCBIN "BG04.C",4096

ROAD_TILE:      INCBIN  "TILE2X3.C"

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
;       0..3 MOV,AND,OR,AND_OR FOR SPRITE
;       4 IS STATIC PART
;       5 DRAW SINGLE CALL, RESET AFTER
;       6 DRAW EVERY CALL, COUNT DELAYS
;       7 SAVE BACKGROUND
;VARIABLE PART WITH FRAMES AND DELAYS.
;[8..N*[6]]
;[0,1]  ADRESSE OF ANIMATION FRAME.
;[2,3]  ADDRESS OF MASK FOR FRAME (OPT)
;[4,5]  ADDRESS OF SAVE BACKGROUND (OPT)
;[6]    DELAY OF FRAME IN 50 FPS SPEED.
;[7]    RESERVED.

;MAIN CHARACTER STRUCTURE OF THE GAME.
BOB:
        DB #02,#12      ;POSITION
        DB #04,#04      ;SIZES
        DB 3            ;PARTS
        DB %00000000    ;FLAGS
        DW BOB_1        ;PART 1 - FACE
        DW BOB_2        ;PART 2 - FOOTS

;MAIN CHARACTER PARTS STRUCTURE.

BOB_1:  DB #00,#00      ;LEFT-UP
        DB #04,#02      ;TOP OF HEAD
        DB #00,#00      ;FRAME AND DELAY
        DB #03          ;ALL
        DB %11011000    ;REDRAW+STATIC
        DW BOB_1_1      ;AND-OR
        DW BOB_M1       ;MASK
        DW BOB_R1
        DB #93,#00      ;SAVE BG
        DW BOB_1_2      ;SECOND FRAME
        DW BOB_M1       ;
        DW BOB_R1
        DB #04,#00      ;
        DW BOB_1_3      ;THIRD FRAME
        DW BOB_M1       ;
        DW BOB_R1
        DB #04,#00

BOB_2:  DB #00,#02      ;NEXT LINES
        DB #04,#02      ;FOOTS
        DB #00,#01      ;FRAME AND DELAY
        DB #04          ;4 FRAMES
        DB %11001000    ;REDRAW+AND-OR
        DW BOB_2_1      ;DELAY AND FRAMES
        DW BOB_M2
        DW BOB_R2
        DB #0C,#00      ;SAVE BACKGROUND
        DW BOB_2_2
        DW BOB_M2
        DW BOB_R2
        DB #0C,#00
        DW BOB_2_1
        DW BOB_M2
        DW BOB_R2
        DB #0C,#00
        DW BOB_2_3
        DW BOB_M2
        DW BOB_R2
        DB #0C,#00

BOB_R1: DUP 64  ;STORE BACKGROUND FOR BOB
        DB #00
        EDUP 
BOB_R2: DUP 64
        DB #00
        EDUP 

BOB_M1:         INCBIN "BOB_MSK1.C",64
BOB_M2:         INCBIN "BOB_MSK2.C",64
BOB_1_1:        INCBIN "BOB_P1F1.C",64
BOB_1_2:        INCBIN "BOB_P1F2.C",64
BOB_1_3:        INCBIN "BOB_P1F3.C",64
BOB_2_1:        INCBIN "BOB_P2F1.C",64
BOB_2_2:        INCBIN "BOB_P2F2.C",64
BOB_2_3:        INCBIN "BOB_P2F3.C",64
BOB_2_4:        ;INCBIN "BOB_P3F4.C",64

;CREATE SCENE, ON EVERY FRAME IN GAME,
;DRAW/UPDATE ALL OBJECTS IF NEEDED
;ON SCREEN, SAVE BACKGROUND FOR HERO.
;A - 0  IF ZERO, DRAW AS DEFAULT
;       IF NOT, DRAW ONLY OBJECTS WITHOUT
;       CHARACTERS

CREATE_SCENE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX

;CREATE LOCATIONS AND OBJECTS
        PUSH AF         ;SAVE FLAG
        ;JP SCENE_4
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

        LD A,B          ;CHECK FOR EMPTY,
        OR A            ;REMOVE LATER
        JR Z,SCENE_4

        LD DE,#0018     ;OFFSET OF OBJECT
        ADD HL,DE
        PUSH HL
        POP IY
SCENE_3:LD E,(IY+0)
        INC HL
        LD D,(IY+1)
        INC HL
        PUSH DE
        POP IX
        LD A,(IY+2)
        LD (IX+0),A
        LD A,(IY+3)
        LD (IX+1),A

        CALL DRAW_ANIMATION
        DJNZ SCENE_3

SCENE_4:POP AF
        OR A
        JR NZ,SCENE_R   ;WITHOUT HERO
;RESTORE BACKGROUND FROM BOB PREVIOUS POS
        LD HL,BOB_R1
        LD DE,(BOB_PREV_POS)
        LD A,D
        SUB #02
        LD D,A
        LD A,E
        SUB #02
        LD E,A
        LD BC,#0404
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE

;DRAW MAIN CHARACTER ON NEW POSITION

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

        JR SCENE_R
;DEBUG
        LD HL,(BOB_POSITION)
        LD (BOB_PREV_POS),HL
        INC H
        LD (BOB_POSITION),HL
        POP BC
        DEC C
        ;JP NZ,SCN_S

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

ANIM_FRAME_POS: DW #0000 ;COORDS FROM (IX)

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
        RES 0,B         ;RESET DELAY FLAG
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
        SET 0,B         ;RESET DELAY IN B
        INC (IY+4)      ;NEXT FRAME
        LD A,(IY+4)
        CP (IY+6)
        JR NZ,ANIM_2
        LD (IY+4),0     ;TO 0-FRAME
ANIM_2: BIT 5,C         ;DRAW OR NOT PART
        JR NZ,ANIM_5
        BIT 6,C         ;SINGLE OR EVERY
        JR Z,ANIM_4     ;FRAME TO DRAW
ANIM_5: RES 5,(IY+7)    ;NOT DRAW NEXT FR
        LD A,(IY+4)     ;DRAW PART
        PUSH IY
        POP HL          ;ADDR OF 0-FRAME
        RLCA            ;ADD TO INDEX*8
        RLCA            ;PERFORMANCE SLA
        RLCA 
        ADD A,#08       ;OFFSET OF TABLE
        LD E,A
        LD D,#00
        ADD HL,DE       ;START FRAME
        LD D,(IX+0)     ;SAVE BASE POS
        LD E,(IX+1)
        PUSH IX         ;SAVE IX
;       LD (ANIM_FRAME_POS),DE
        PUSH HL         ;HL TO IX
        POP IX          ;IX - FRAME TABLE
        BIT 0,B         ;IF NEED TO SET
        JR Z,ANIM_3
        LD A,(IX+6)     ;OFFSET OF DELAY
        LD (IY+5),A     ;SET NEW DELAY
ANIM_3:
        ;LD DE,(ANIM_FRAME_POS)
        LD A,D
        ADD A,(IY+0)    ;POSITION WITHOUT
        LD D,A          ;CHECK OF RANGES
        LD A,E
        ADD A,(IY+1)
        LD E,A          ;DE - FRAME POS
        LD A,(IY+7)     ;A - FLAGS
        LD B,(IY+2)     ;BC - SIZES
        LD C,(IY+3)
        BIT 7,A         ;NEED SAVE BG
        JR Z,ANIM_6
        OR SPRITE_SAV
        LD L,(IX+4)     ;HL - BACKGROUND
        LD H,(IX+5)
        PUSH HL
        POP IY          ;OVERWRITE STR IY
ANIM_6: LD L,(IX+0)     ;HL - FRAME ADDR
        LD H,(IX+1)
        BIT 3,A
        JR Z,ANIM_7     ;WITHOUT MASK
        PUSH HL
        LD L,(IX+2)
        LD H,(IX+3)
        PUSH HL
        POP IX          ;IX - MASK
        POP HL
ANIM_7: AND %00011111   ;DRAW TYPE
        CALL DRAW_SPRITE
        POP IX          ;RESTORE STRUC
ANIM_4: POP HL
        POP BC
        DEC B
        JP NZ,ANIM_1
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

GAME_MAIN_CYCLE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
;TODO THINK LATER ON SIMPLE FUNCTION
        CALL DRAW_LOCATION

        ;JP DBG_RET

DBG_S:  LD BC,#2000     ;MAIN CYCLE
DBG_3:  PUSH BC
        HALT 
        XOR A
        CALL CREATE_SCENE

        ;JP DBG_7

;TODO MOVING LOGIC
        LD DE,(BOB_POSITION)
        LD (BOB_PREV_POS),DE
        CALL KEMPSTON_JOYSTICK

        LD DE,(BOB_POSITION)
;SWITCH SCREENS TEST.
        LD A,D
        CP 30           ;LATER
        JR NZ,DBG_5
        LD A,(ACTIVE_LOCATION)
        CP 3
        JR Z,DBG_7
        LD D,3
        INC A
        JR DBG_6
DBG_5:  CP 2
        JR NZ,DBG_7
        LD A,(ACTIVE_LOCATION)
        OR A
        JR Z,DBG_7
        LD D,29
        DEC A
DBG_6:  LD (BOB_POSITION),DE
        LD (BOB_PREV_POS),DE
        LD (ACTIVE_LOCATION),A
        CALL DRAW_LOCATION
        LD A,1
        CALL CREATE_SCENE
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
        CP 30           ;INSERT LIMIT X
        JR Z,KMP_J6
        INC H
        JR KMP_J5
KMP_J1: BIT KEMPSTON_LEFT,A
        JR Z,KMP_J2
        LD A,H
        CP 2            ;GLOBAL LIMIT X
        JR Z,KMP_J6
        DEC H
        JR KMP_J5
KMP_J2: BIT KEMPSTON_DOWN,A
        JR Z,KMP_J3
        LD A,L
        CP 22           ;INSERT LIMIT Y
        JR Z,KMP_J6
        INC L
        JR KMP_J5
KMP_J3: BIT KEMPSTON_UP,A
        JR Z,KMP_J4
        LD A,L
        CP 20           ;GLOBAL
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

;DRAW GAME ACTIVE LOCATION ON SCREEN.
;LOCATION, ROAD AND STATUS BAR.
;USGIN GLOBAL VARIABLES:
;ACTIVE_LOCATION - 0..3.

DRAW_LOCATION:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD D,%00000000
        ;LD D,%11111111
        LD E,%01000111
        CALL CLEAR_SCREEN

        ;JP LMP_T

        LD HL,(LOCATION_ADDR)
        LD A,(ACTIVE_LOCATION)
        OR A
        JR Z,STAT_1
        LD DE,#1000
STAT_4: ADD HL,DE
        DEC A
        JR NZ,STAT_4
STAT_1: LD A,SPRITE_MOV
        LD DE,#0005
        LD BC,#2010
        HALT 
        CALL DRAW_SPRITE

;DRAW STATUS BAR, MOVE LATER TO SCENE
        LD HL,SCREEN_ATTRIB
        LD B,#02        ;ENERGY + TIMER
S_BAR1: PUSH BC
        LD B,BAR_WIDTH
S_BAR3: LD C,BAR_A_SIZE
        LD DE,BAR_ATTRIB
        PUSH HL
S_BAR2: LD A,(DE)
        LD (HL),A
        INC HL
        INC DE
        DEC C
        JR NZ,S_BAR2
        POP HL
        LD DE,SCREEN_X_SIZE
        ADD HL,DE       ;NEXT LINE
        DJNZ S_BAR3
        POP BC
        LD DE,SCREEN_X_SIZE
        OR A
        SBC HL,DE
        OR A
        SBC HL,DE
        LD DE,#0014     ;TO RIGHT CORNER
        ADD HL,DE
        DJNZ S_BAR1

        LD HL,ITEM_A
        LD DE,#0D00
        LD BC,#0303
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        LD HL,ITEM_B
        LD DE,#1000
        LD BC,#0303
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE

        LD A,#10
        LD BC,#0203     ;ROAD SIZE
        LD DE,#0015     ;ROAD POSITION
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
        AND %00011111   ;FOR 16 PIXELS
        CP STARS_SIZE
        JR C,STAT_5
        RES 3,A
STAT_5: ADD A,STARS_POSITION
        LD E,A
        CALL RANDOM
        LD D,A
        CALL SET_PIXEL
        DJNZ STAT_3

;TESTING SHADOW FOR LAMP, MOVE TO FUNCTION

LMP_T:  LD A,(ACTIVE_LOCATION)
        OR A
        JP NZ,DRAW_LR
        LD A,1          ;WITHOT CHARACTERS
        CALL CREATE_SCENE

        LD DE,#170E     ;CORNER
        LD B,#01
        LD HL,LAMP_SHAD_0
        LD A,SPRITE_AND
LMP_S1: PUSH BC
        LD BC,#0101
        CALL DRAW_SPRITE
        INC D
        POP BC
        DJNZ LMP_S1
        LD DE,#180E     ;VERTICAL RIGHT
        LD HL,LAMP_SHAD_1
        LD B,8
        LD A,SPRITE_AND
LMP_S2: PUSH BC
        LD BC,#0101
        CALL DRAW_SPRITE
        INC D
        POP BC
        DJNZ LMP_S2
        LD DE,#170F     ;HORIZONTAL DOWN
        LD HL,LAMP_SHAD_2
        LD B,9
        LD A,SPRITE_AND
LMP_S3: PUSH BC
        LD BC,#0101
        CALL DRAW_SPRITE
        INC E
        POP BC
        DJNZ LMP_S3
        LD HL,LAMP_SHAD_3
        LD DE,#180F     ;OTHER DARK PART
        LD BC,#0809
LMP_S5: PUSH BC
        PUSH DE
LMP_S4: PUSH BC
        LD BC,#0101
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        POP BC
        INC D
        DJNZ LMP_S4
        POP DE
        INC E
        POP BC
        DEC C
        JR NZ,LMP_S5


DRAW_LR:POP HL
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
        CALL MOD        ;CALL AY-PLAYER.
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
;IF BITS 0..4 ARE NOT SET, THEN CHECK
;NEXT 5TH BIT CHECKED. IF ALL ZEROS THEN
;FUNCTION DO NOTHING AND RETURN.
;[0] SIMPLE DRAW, OVERWRITE MEMORY.
;[1] 'AND' OPERATOR WITH MEMORY.
;[2] 'OR' OPERATOR WITH MEMORY.
;[3] 'AND-OR' PERFORMANCE, IX ADDR AND.
;[4] SAVE SCREEN TO (IY), NO CHECK.
;[5-7] RESERVED.
;TODO REMAKE FOR XOR LATER.
;B - X SIZE OF SPRITE IN 8*8.
;C - Y SIZE OF SPRITE IN 8*8.
;D - X COORDINATE ON SCREEN [0..31]
;E - Y COORDINATE ON SCREEN [0..23]
;HL - ADDRES OF SPRITE, LINEAR IN MEMORY.
;IX OPTIONAL ADDR FOR 'AND' PART OF 4 BIT.
;IY OPTIONAL ADDR FOR STORE SCREEN DATA

SPRITE_JMP:     DW #0000
SPRITE_FLAGS:   DB #00

DRAW_SPRITE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
        LD (SPRITE_FLAGS),A
        PUSH BC         ;CHECK SIZES
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
        JP SPR_RET
SPR_OK: POP BC
        LD A,(SPRITE_FLAGS)
        PUSH HL
        BIT 0,A         ;ADDRESS OF JUMP
        JR Z,SPR_4      ;TYPE DRAW MOVE
        LD HL,SPR_MOV
        JR SPR_DRW
SPR_4:  BIT 1,A
        JR Z,SPR_5      ;AND DRAW(MASK)
        LD HL,SPR_AND
        JR SPR_DRW
SPR_5:  BIT 2,A         ;OR DRAW(UNION)
        JR Z,SPR_6
        LD HL,SPR_OR
        JR SPR_DRW
SPR_6:  BIT 3,A         ;AND-OR PART
        JR Z,SPR_7      ;IN ONE CALL
        LD HL,SPR_A_O
        JR SPR_DRW
SPR_7:  BIT 4,A         ;JUST SAVE SCREEN
        JP Z,SPR_RET    ;NOTHING TO DO
        LD HL,SPR_SAV
SPR_DRW:LD (SPRITE_JMP),HL ;SAVE ADDRESS
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
        EX DE,HL        ;HL - SPRITE
        POP HL          ;DE - SCREEN
        PUSH BC         ;SIZES IN STACK
        ;POP DE         ;COORDS IN STACK
        LD C,#08        ;DRAW 8 LINES * X
SPR_2:  PUSH BC
        PUSH DE         ;SAVE LINE ADDR.
SPR_1:  LD A,(SPRITE_FLAGS)
        BIT 4,A
        JR Z,SPR_NSV    ;NOT SAVE SCREEN
        LD A,(DE)       ;DRAW 1 LINE
        LD (IY+0),A
        INC IY
SPR_NSV:PUSH IY
        LD IY,(SPRITE_JMP)
        LD A,(DE)
        JP (IY)         ;INDERECT CALL
SPR_AND:AND (HL)
        JR SPR_ST       ;TYPES OF DRAW
SPR_OR: OR (HL)
        JR SPR_ST
SPR_A_O:AND (IX+0)      ;COMPLEX AND-OR
        INC IX
        OR (HL)
        JR SPR_ST
SPR_MOV:LD A,(HL)
SPR_ST: LD (DE),A       ;STORE BYTE
SPR_SAV:POP IY          ;JUST SAVE SCREEN
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
        POP IY
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
