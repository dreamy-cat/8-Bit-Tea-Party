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
        CALL INIT_GAME
        LD HL,FIRST_FREE_BYTE
        LD A,0
        LD (ACTIVE_LOCATION),A
        LD HL,LOCATION_1

        ;CALL DRAW_LOCATION
        ;XOR A
        ;CALL CREATE_SCENE
        CALL GAME_MAIN_CYCLE

        ;LD IX,BOB
        ;CALL DRAW_ANIMATION

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
        DUP 64
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
BG_LOC_POS_X    EQU #00 ;BACKGROUND
BG_LOC_POS_Y    EQU #05 ;LOCATION START
BG_LOC_SIZE_X   EQU #20 ;AND BOTH SIZES
BG_LOC_SIZE_Y   EQU #10
BG_LOC_BYTES    EQU #1000       ;MEM SIZE
ROAD_POSY       EQU #15 ;ROAD Y POSITION
BG_DEFAULT_A    EQU %01000111
BG_DEBUG_A      EQU %01111000   ;ATTRIB
BG_DEFAULT_BT   EQU %00000000   ;BYTE TO
BG_DEBUG_BT     EQU %11111111   ;FILL

HEROES_IN_GAME  EQU 2

;OBJECT TYPES AND ADRESSES.

OBJ_EMPTY       EQU #00
OBJ_LAMP_ON     EQU #01
OBJ_LAMP_OFF    EQU #02
OBJ_ITEM_BLANK  EQU #04

ITEMS_TABLE:
        DW #0000
        DW LAMP_ON
        DW LAMP_OFF
        DW #0000
        DW SB_ITEM_BLANK

;SYSTEM VARIABLES

KEMPSTON:       DB #00  ;EVERY INTERRUPT

;GAME VARIABLES

STARS:          DUP STARS_ON_SKY
                DW #0000
                EDUP 
ACTIVE_LOCATION:DB #00  ;HERO LOCATION
ACT_LOC_ADDR:   DW GAME_WORLD
LOCATION_ADDR:  DW LOC_DATA_0
;BOB POSITIONS MUST BE EQUAL ON ASSEMBLE
BOB_START_X:    EQU #00 ;DEFAULT
BOB_START_Y:    EQU #14

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

;TYPES OF ACTION FOR CHARACTERS

EMPTY_ACTION    EQU #00
CHAR_STAND      EQU #01
CHAR_MOVE_LR    EQU #02
CHAR_MOVE_RL    EQU #03

SIZEOF_CHAR     EQU #10 ;IN BYTES

;CHARACTERS GLOBAL VARIABLES.

HEROES_TABLE:
HERO_BOB:
BOB_ACTION_T:   DB CHAR_MOVE_LR
BOB_POS_Y:      DB BOB_START_Y ;ACTIVE POS
BOB_POS_X:      DB BOB_START_X
BOB_PREV_Y:     DB BOB_START_Y ;PREVIOS
BOB_PREV_X:     DB BOB_START_X
BOB_SIZE_Y:     DB #04  ;SIZES
BOB_SIZE_X:     DB #04
BOB_ANIMATION:  DW BOB_WALK_LR ;ANIMATION ADDR
BOB_RESTORE:    DW BOB_R1 ;STORE
BOB_ENERGY:     DB #03 ;BOB ENERGY
BOB_ITEM_1:     DB OBJ_EMPTY
BOB_ITEM_2:     DB OBJ_EMPTY

DOG:    DB #02          ;MARKET
        DB CHAR_STAND
        DB #10,#15
        DB #10,#15
        DB #04,#03
        DW DOG_STAND
        DW 0            ;CHANGE
        DB #00,#00,#00,#00 ;RESERVED

;GAME WORLD DATA, 64 BYTES FOR EVERY
;LOCATION, CONTAINS OBJECTS AND
;CHARACTERS, 8 BYTES FOR EVERY OBJECT.
;MAXIMUM DATA: 4 AREAS INCLUDE EXITS,
;AND 4 OBJECTS.
;IN GAME WORLD, ONLY FOR GFX FOR NOW.
;[0]            OBJECTS IN LOCATION
;[1]            AREAS FOR MOVE IN LOCATION
;[2]            AREAS FOR OTHER LOCATION
;[3]            RESERVED
;[4..31]        4 AREAS MAX, FORMAT
;[0..3]         LEFT-UP AND RIGHT DOWN
;               CORNER IN ATTRIBUTES
;[4]            LOCATION TO EXIT
;[5,6]          BOB START Y AND X ON NEW
;VARIABLE PART.
;[32..[0]*8]    OBJECT ADDRESS
;[2,3]          OBJECT POS X,Y(TO SRPITE)
;[4]            OBJECT TYPE
;[5]            COMMON FLAGS
;[6]            OBJECT PLANE, PRIORITY
;[7]            RESERVED

SIZEOF_AREA     EQU #0007 ;MOVE AND EXIT
OBJECTS_OFFSET  EQU #20

GAME_WORLD:
LOCATION_0:
        DB #01,#01      ;OBJECTS AND AREAS
        DB #01,#00      ;RESERVED
        DB #00,#12      ;ROAD AREA
        DB #20,#18
        DB #00          ;NOT EXIT
        DB #00,#00
        DB #1C,#12      ;RIGHT PART
        DB #20,#18
        DB #01          ;TO FLOWER SHOP
        DB #01,#13      ;BOB NEW POSITION
        DUP #02         ;RESERVED
        DB #00,#00
        DB #00,#00
        DB #00
        DB #00,#00
        EDUP 
LMP_1:  DW LAMP_ON      ;ADDR ANIM
        DB #1C,#0D      ;POS X,Y
        DB OBJ_LAMP_ON  ;TYPE
        DB #00,#00,#00  ;RESERVED
        DUP #03         ;OTHER 3 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 
LOCATION_1:             ;TODO
        DB #01,#01      ;OBJ AND LOC
        DB #03,#00      ;RESERVED
        DB #00,#10      ;ROAD
        DB #20,#18
        DB #00          ;EMPTY
        DB #00,#00
        DB #00,#10      ;LEFT ROAD
        DB #04,#18
        DB #00          ;TO START LOCATION
        DB #1B,#13      ;BOB AT RIGHT
        DB #1C,#10      ;ROAD
        DB #20,#18
        DB #02          ;TO MARKET
        DB #01,#13      ;NEW POSITION
        DB #09,#10      ;TO DOOR
        DB #0D,#15
        DB #00          ;TO START LOCATION
        DB #01,#13
LMP_2:  DW LAMP_OFF     ;ADDR ANIM
        DB #14,#0D      ;POS X,Y
        DB OBJ_LAMP_OFF ;TYPE
        DB #00,#00,#00  ;RESERVED
        DUP #03         ;3 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 
LOCATION_2:             ;MARKET LOCATION
        DB #00,#01      ;OBJ AND AREAS
        DB #03,#00      ;RESERVED
        DB #00,#10
        DB #20,#18
        DB #00
        DB #00,#00
        DB #00,#10      ;LEFT TO SHOP
        DB #04,#18
        DB #01          ;TO FLOWER SHOP
        DB #1B,#13      ;BOB AT RIGHT
        DB #1C,#12      ;ROAD
        DB #20,#18
        DB #03          ;TO HOUSE
        DB #01,#13      ;NEW POSITION
        DB #0C,#10      ;MARKET DOOR
        DB #14,#15
        DB #01
        DB #01,#13
        DUP #04         ;OTHER 4 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 
LOCATION_3:             ;HOUSE
        DB #00,#01      ;OBJ AND LOC
        DB #01,#00      ;RESERVED
        DB #00,#12
        DB #20,#18
        DB #00          ;EMPTY
        DB #00,#00
        DB #00,#12      ;LEFT ROAD
        DB #04,#18
        DB #02          ;TO MARKET
        DB #1B,#13      ;BOB AT RIGHT
        DUP #02         ;RESERVED
        DB #00,#00
        DB #00,#00
        DB #00
        DB #00,#00
        EDUP 
        DUP #04         ;OTHER 4 OBJECTS
        DW #0000
        DB #00,#00
        DB #00
        DB #00,#00,#00
        EDUP 

;STANDARD OBJECTS
LAMP_ON:DB #05,#05      ;POS
        DB #04,#08      ;MAXIMUM SIZES
        DB #02          ;TWO FOR DEBUG
        DB %00100000    ;RESET STATIC PART
        DW LAMP_1
        DW LAMP_2

LAMP_1: DB #01,#03      ;STAND WITH MASK
        DB #02,#05
        DB #00,#00      ;STAT
        DB #01          ;ALL
        DB %01111000    ;SINGLE-AND-STATIC
        DW LAMP_DAT_0   ;AND-OR TEST
        DW LAMP_DAT_M0  ;MASK
        DW #0000        ;NO SAVE DELAY
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

LAMP_OFF:
        DB #10,#10      ;POS
        DB #04,#08      ;MAXIMUM SIZES
        DB #02          ;TWO FOR DEBUG
        DB %00100000
        DW LAMP_1       ;ALREADY DEFINE
        DW LAMP_3       ;SWITCH OFF

LAMP_3: DB #00,#00      ;ANIM FOR LIGHT
        DB #04,#03
        DB #00,#01
        DB #01          ;FRAMES
        DB %01111000    ;DRAW-STATIC
        DW LAMP_DAT_3   ;AND-OR
        DW LAMP_DAT_M2
        DW #0000        ;NOT SAVING BG
        DB #00,#00

DOG_STAND:
        DB #10,#10      ;POS
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
LAMP_DAT_M2:    INCBIN "LMP1AMSK.C",96
LAMP_DAT_1:     INCBIN "LMP_P1F1.C",96
LAMP_DAT_2:     INCBIN "LMP_P1F2.C",96
LAMP_DAT_3:     INCBIN "LMP_P1F3.C",96

DOG_DAT_0:      ;INCBIN "DOG_F1.C",96
MAN_DAT_0:      INCBIN "CHAR_2.C",80

LAMP_SHAD_B:    DUP 08
                DB #00
                EDUP 
LAMP_SHAD_L:    INCBIN "LMPSHD.C",32
LAMP_SHAD_R:    INCBIN "ROADSHD.C",72

LOC_DATA_0:     INCBIN "BG01.C",4096
LOC_DATA_1:     INCBIN "BG02.C",4096
LOC_DATA_2:     INCBIN "BG03.C",4096
LOC_DATA_3:     INCBIN "BG04.C",4096

ROAD_TILE:      INCBIN  "TILE2X3.C"

;CONSTANT PART OF ANIMATION STRUCTURE.
;[0,1] POSITION X AND Y ON SCREEN.
;[2,3]  SIZES OF CHAR X AND Y, ALL.
;[4]    PARTS OF CHARACTER AND ANIMATION.
;[5]    COMMON FLAGS FOR ANIMATION.
;       0..4 RESERVED
;       5 STATIC PARTS REDRAW ON LOCATION
;       6 SINGLE DRAW ALL STATIC PARTS
;       7 RESERVED
;VARIABLE PART OF STRUCTURE, USE RESERVED.
;[6..N*[4]]
;       ADDRESESS OF PARTS, 16BITS.
;PART OF ANIMATION STRUCTURE, MASKS HERE.
;[0,1]  POSITION OF PART X AND Y FROM 0.
;[2,3]  SIZES OF PART X AND Y.
;[4]    CURRENT ANIMATION FRAME.
;[5]    CURRENT DELAY IN /50 FPS.
;[6]    ANIMATIONS TOTAL.
;[7]    FLAGS.
;       0..3 MOV,AND,OR,AND_OR FOR SPRITE
;       4 SAVE BACKGROUND
;       5 IS STATIC PART
;       6 DRAW SINGLE CALL, RESET AFTER
;       7 DRAW EVERY CALL, COUNT DELAYS
;VARIABLE PART WITH FRAMES AND DELAYS.
;[8..N*[6]]
;[0,1]  ADRESSE OF ANIMATION FRAME.
;[2,3]  ADDRESS OF MASK FOR FRAME (OPT)
;[4,5]  ADDRESS OF SAVE BACKGROUND (OPT)
;[6]    DELAY OF FRAME IN 50 FPS SPEED.
;[7]    RESERVED.

BOB_STAND:      ;BOB STAND STILL ONE FRAME
        DB #02,#12      ;POSITION
        DB #04,#04      ;SIZES
        DB 2            ;PARTS
        DB %00000000    ;FLAGS
        DW BOB_1        ;PART 1 - FACE
        DW BOB_2        ;PART 2 - FOOTS

;MAIN CHARACTER STRUCTURES OF THE GAME.
BOB_WALK_LR:
        DB #02,#12      ;POSITION
        DB #04,#04      ;SIZES
        DB 2            ;PARTS
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
        DB %11011000    ;REDRAW+AND-OR
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

;LIBRARY FUNCTIONS FOR GAME

INCLUDE "LIBRARY.A",4

;CREATE SCENE, ON EVERY FRAME IN GAME,
;DRAW/UPDATE ALL OBJECTS IF NEEDED
;ON SCREEN, SAVE BACKGROUND FOR HERO.
;SCENE MUST HAFE AT LEAST ONE OBJECT
;NO CHECKS FOR DATA RANGES.

CREATE_SCENE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        ;JP SCENE_4

;DRAW OBJECTS ON LOCATION
        LD HL,(ACT_LOC_ADDR)
        LD B,(HL)       ;OBJECTS COUNTER
        LD A,B          ;NO OBJECTS
        OR A
        JP Z,SCENE_4    ;CHECK TO HEROES
        LD DE,OBJECTS_OFFSET
        ADD HL,DE
SCENE_3:PUSH HL
        POP IY
        LD E,(IY+0)
        LD D,(IY+1)
        PUSH DE
        POP IX          ;IX - ANIM ADDR
        LD A,(IY+2)
        LD (IX+0),A
        LD A,(IY+3)
        LD (IX+1),A
        CALL DRAW_ANIMATION

;DRAW CHARACTERS ON ACTIVE LOCATION

SCENE_4:
;RESTORE BACKGROUND FROM BOB PREVIOUS POS
        LD A,(ACTIVE_LOCATION)
        LD DE,(BOB_PREV_Y)
        LD HL,(BOB_RESTORE)
        LD BC,(BOB_SIZE_Y)
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        LD IX,(BOB_ANIMATION)   ;DRAW NEW
        LD DE,(BOB_POS_Y)
        LD (IX+0),D
        LD (IX+1),E
        CALL DRAW_ANIMATION

SCENE_R:POP IY
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

;CLEAR ALL SCREEN AND SET BORDER

        LD D,BG_DEFAULT_BT
        ;LD D,BG_DEBUG_BT
        LD E,BG_DEFAULT_A
        ;LD E,BG_DEBUG_A
        CALL CLEAR_SCREEN

;DRAW A RANDOM STARS ON SKY.

        LD B,STARS_ON_SKY
INIT_1: CALL RANDOM
        AND %00011111   ;FOR 16 PIXELS
        CP STARS_SIZE
        JR C,INIT_2
        RES 3,A
INIT_2: ADD A,STARS_POSITION
        LD E,A
        CALL RANDOM
        LD D,A
        CALL SET_PIXEL
        DJNZ INIT_1

;DRAW STATUS BAR AND ITEMS

        LD DE,#0001     ;DRAW DECORATIONS
        LD BC,#0102
        LD HL,SB_DAT_L
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        LD DE,#1301
        CALL DRAW_SPRITE
        LD B,11
        LD DE,#0102
        LD HL,SB_DAT_M
SBAR_1: PUSH BC
        LD BC,#0101
        CALL DRAW_SPRITE
        INC D
        POP BC
        DJNZ SBAR_1
        LD B,11
        LD DE,#1402
SBAR_2: PUSH BC
        LD BC,#0101
        CALL DRAW_SPRITE
        INC D
        POP BC
        DJNZ SBAR_2
        LD HL,SB_DAT_R
        LD DE,#0C01
        LD BC,#0102
        CALL DRAW_SPRITE
        LD DE,#1F01
        CALL DRAW_SPRITE
        LD HL,SB_HEART_OFF      ;ENERGY
        LD DE,#0200
        LD BC,#0302
        CALL DRAW_SPRITE
        LD B,2
        LD HL,SB_HEART_ON
        LD DE,#0500
SBAR_3: PUSH BC
        LD BC,#0302
        CALL DRAW_SPRITE
        INC D
        INC D
        INC D
        POP BC
        DJNZ SBAR_3
        LD A,%00010111  ;COLORS FOR ENERGY
        LD HL,#5802
        LD BC,#0902
        LD DE,#0020
SBAR_5: PUSH HL
        PUSH BC
SBAR_4: LD (HL),A
        INC HL
        DJNZ SBAR_4
        POP BC
        POP HL
        ADD HL,DE
        DEC C
        JR NZ,SBAR_5
        CALL UPDATE_ITEMS
        LD HL,SB_GAME_TIMER     ;TIMER
        LD DE,#1400
        LD BC,#0B02
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE

INIT_GE:POP IY
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

DBG_S:  LD BC,#3000     ;MAIN CYCLE
DBG_3:  PUSH BC
        HALT 
        CALL CREATE_SCENE
        ;LD A,2
        ;LD (KEMPSTON),A

;TODO MOVING LOGIC
        CALL MOVE_BOB_KEMPSTON

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

;UPDATE ITEMS ON STATUS BAR.
;USING VARIABLES OF BOB ITEMS.
UPDATE_ITEMS:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,SB_ITEM_BLANK
        LD DE,#0D00
        LD BC,#0303
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        LD DE,#1000
        CALL DRAW_SPRITE

        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;USING ITEMS IN BOTH HANDS AND GAME LOGIC.
BOB_ACTION_KEMPSTON:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        LD A,(KEMPSTON)
        BIT KEMPSTON_FIRE,A
        JP Z,BACT_1
        LD A,#07        ;JUST WHITE BORDER
        OUT (#FE),A

        LD HL,GAME_WORLD
        LD A,(ACTIVE_LOCATION)
        LD B,6          ;* 64 BYTES
        LD D,0
KMP_2:  SLA A           ;TWO BYTES
        JR NC,KMP_1
        INC D
KMP_1:  DJNZ KMP_2
        LD E,A
        ADD HL,DE       ;HL ADDR LOCATION
        LD B,(HL)       ;OBJECTS COUNTER
        LD A,B          ;NO OBJECTS
        OR A
        JP Z,BACT_1     ;CHECK TO HEROES
        LD DE,OBJECTS_OFFSET
        ADD HL,DE
        PUSH HL
        POP IY
        LD A,(IY+4)
        CP OBJ_LAMP_ON
        JR NZ,KMP_4     ;SWITCH OFF LAMP
        LD DE,LAMP_OFF
        LD (IY+0),E
        LD (IY+1),D
        LD A,OBJ_LAMP_OFF
        LD (IY+4),A
        JP KMP_5
KMP_4:  LD DE,LAMP_ON   ;SWITCH ON LAMP
        LD (IY+0),E
        LD (IY+1),D
        LD A,OBJ_LAMP_ON
        LD (IY+4),A
KMP_5:  LD E,(IY+0)
        LD D,(IY+1)
        PUSH DE
        POP IX          ;IX - ANIM ADDR
        CALL DRAW_LOCATION

BACT_1: POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;MOVING CHARACTER WITH KEMPSTON JOYSTICK.
;USING GLOBAL VARIABLES:
;"KEMPSTON" - INPUT FROM IM2.
;HERO_BOB - SEE ALL NAMED DATA.
;LOCATIONS FOR MOVE LIMITS.

MOVE_BOB_KEMPSTON:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        LD DE,(BOB_POS_Y)       ;D - X
        LD (BOB_PREV_Y),DE      ;E - Y
        LD A,(KEMPSTON)
        BIT KEMPSTON_RIGHT,A
        JR Z,MB_K1
        INC D
        JR MB_K4
MB_K1:  BIT KEMPSTON_LEFT,A
        JR Z,MB_K2
        LD A,D          ;FOR C-FLAG ADD
        OR A
        JR Z,MB_K4
        DEC D
        JR MB_K4
MB_K2:  BIT KEMPSTON_DOWN,A
        JR Z,MB_K3
        INC E
        JR MB_K4
MB_K3:  BIT KEMPSTON_UP,A
        JP Z,MB_K5      ;NOTHING TO MOVE
        LD A,E          ;FOR C-FLAG ADD
        OR A
        JR Z,MB_K4
        DEC E
MB_K4:  LD BC,(BOB_SIZE_Y)
        PUSH DE
        POP HL          ;DE LEFT-UP
        ADD HL,BC       ;HL RIGHT-DOWN
        LD IX,(ACT_LOC_ADDR)
        LD B,(IX+1)     ;B - MOVE AREAS
        LD A,B
        OR A
        JP Z,MB_K5      ;NO AREAS
        LD C,(IX+2)     ;EXIT AREAS
        PUSH BC
        LD BC,#0004
        ADD IX,BC       ;IX - AREAS
        POP BC
MB_K6:  PUSH BC
        LD B,(IX+0)
        LD A,D          ;X
        CP B
        JR C,MB_KNA     ;NOT IN AREA
        LD B,(IX+1)
        LD A,E
        CP B
        JR C,MB_KNA     ;CORRECT IN DATA
        LD A,(IX+2)     ;RIGHT DOWN
        CP H
        JR C,MB_KNA
        LD A,(IX+3)
        CP L
        JR C,MB_KNA
        POP BC
        LD (BOB_POS_Y),DE       ;IN AREA
        JR MB_KLOC
MB_KNA: LD BC,SIZEOF_AREA
        ADD IX,BC       ;NEXT AREA
        POP BC
        DJNZ MB_K6
        JP MB_K5        ;NOT IN AREA
MB_KLOC:LD A,C          ;CHECK FOR EXITS
        OR A
        JR Z,MB_K5
        LD A,B          ;MOVE OK
        OR A            ;CHECK EXITS
        JR Z,MB_K7      ;ADD TO IX EXTRA
        PUSH DE
        LD DE,SIZEOF_AREA
MB_K8:  ADD IX,DE
        DJNZ MB_K8
        POP DE          ;IX - EXIT AREAS
MB_K7:  LD B,(IX+0)
        LD A,D          ;X
        CP B
        JR C,MB_KNE     ;NOT IN EXIT AREA
        LD B,(IX+1)
        LD A,E
        CP B
        JR C,MB_KNE     ;CORRECT IN DATA
        LD A,(IX+2)     ;RIGHT DOWN
        CP H
        JR C,MB_KNE
        LD A,(IX+3)
        CP L
        JR C,MB_KNE
        LD A,(IX+4)     ;CHANGE LOCATION
        LD (ACTIVE_LOCATION),A
        LD D,(IX+5)     ;BOB NEW POSITION
        LD E,(IX+6)
        LD (BOB_POS_Y),DE
        LD (BOB_PREV_Y),DE
        CALL DRAW_LOCATION
        JR MB_K5
MB_KNE: PUSH DE
        LD DE,SIZEOF_AREA
        ADD IX,DE
        POP DE
        DEC C
        JR NZ,MB_K7
MB_K5:  POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;DRAW GAME ACTIVE LOCATION ON SCREEN.
;LOCATION, ROAD AND STATUS BAR.
;USING GLOBAL VARIABLES:
;ACTIVE_LOCATION - 0..3.

DRAW_LOCATION:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        ;JP DLOC_8

        LD HL,SCREEN_ATTRIB
        LD DE,#00A0
        ADD HL,DE
        LD BC,#0260
DCLR_1: LD A,%01000111
        LD (HL),A
        INC HL
        DEC BC
        LD A,B
        OR C
        JR NZ,DCLR_1

;DRAW MAIN BACKGROUND IN LOCATION
        LD HL,(LOCATION_ADDR)
        LD A,(ACTIVE_LOCATION)
        OR A
        JR Z,DLOC_1
        LD DE,#1000
DLOC_2: ADD HL,DE
        DEC A
        JR NZ,DLOC_2
DLOC_1: LD A,SPRITE_MOV
        LD D,BG_LOC_POS_X
        LD E,BG_LOC_POS_Y
        LD B,BG_LOC_SIZE_X
        LD C,BG_LOC_SIZE_Y
        CALL DRAW_SPRITE
        LD A,#10        ;DRAW ROAD
        LD BC,#0203     ;ROAD SIZE
        LD DE,#0015     ;ROAD POSITION
        LD HL,ROAD_TILE
DLOC_3: PUSH AF
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        POP AF
        INC D
        INC D
        DEC A
        JR NZ,DLOC_3
;DRAW ALL OBJECTS IN LOCATION
        LD HL,GAME_WORLD
        LD A,(ACTIVE_LOCATION)
        LD B,6          ;* 64 BYTES
        LD D,0
DLOC_4: SLA A           ;TWO BYTES
        JR NC,DLOC_5
        INC D
DLOC_5: DJNZ DLOC_4
        LD E,A
        ADD HL,DE       ;HL ADDR LOCATION
        LD B,(HL)       ;OBJECTS COUNTER
        LD A,B          ;NO OBJECTS
        OR A
        JP Z,DLOC_8     ;CHECK TO HEROES
        LD DE,OBJECTS_OFFSET
        ADD HL,DE
DLOC_6: PUSH HL
        POP IY
        LD E,(IY+0)
        LD D,(IY+1)
        PUSH DE
        POP IX          ;IX - ANIM ADDR
        LD A,(IY+2)
        LD (IX+0),A
        LD A,(IY+3)
        LD (IX+1),A
        BIT 5,(IX+5)    ;IF STATIC OBJECT
        JR Z,DLOC_9
        SET 6,(IX+5)    ;REDRAW ONCE
DLOC_9: CALL DRAW_ANIMATION
        RES 6,(IX+5)
        LD A,(IY+4)
        CP OBJ_LAMP_OFF
        JR NZ,DLOC_7    ;DRAW LAMP SHADES
        PUSH HL
        PUSH BC
        LD B,8
        LD A,(IY+2)
        ADD A,#02       ;SIZE OF SHADE
        LD D,A
        LD E,BG_LOC_POS_Y
LMP_S1: PUSH BC
        LD HL,LAMP_SHAD_L
        LD A,E
        LD BC,#0202
        LD A,SPRITE_AND
        CALL DRAW_SPRITE
        POP BC
        INC E
        INC E
        DJNZ LMP_S1
        LD E,ROAD_POSY
        LD BC,#0303
        LD HL,LAMP_SHAD_R
        LD A,SPRITE_AND
        CALL DRAW_SPRITE
        LD HL,LAMP_SHAD_B
        LD E,BG_LOC_POS_Y
        INC D           ;DARK PART
        INC D
        LD A,SCREEN_X_SIZE
        SUB (IY+2)
        SUB (IX+2)
        ;SUB #02        ;SIZE OF SHADE
        LD B,A
        LD C,SCREEN_Y_SIZE-BG_LOC_POS_Y
LMP_S3: PUSH BC
        PUSH DE
        LD A,C
        CP #04          ;ROAD SIZE + 1
        JR NC,LMP_S2    ;IF SHADE TO ROAD
        INC D
        DEC B
LMP_S2: PUSH BC
        LD BC,#0101
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        PUSH DE         ;SET ATTRIBUTES
        PUSH HL
        LD HL,#0000
        LD A,E          ;Y TO H
        AND %00011000
        RRA 
        RRA 
        RRA 
        LD H,A
        LD A,E
        AND %00000111
        RRCA 
        RRCA 
        RRCA 
        OR D            ;ADD X POSITION
        LD L,A
        LD DE,SCREEN_ATTRIB
        ADD HL,DE
        LD (HL),%01000001
        POP HL
        POP DE
        POP BC
        INC D
        DJNZ LMP_S2
        POP DE
        INC E
        POP BC
        DEC C
        JR NZ,LMP_S3
        POP BC
        POP HL
DLOC_7: LD DE,#0008
        ADD HL,DE
        DEC B
        JP NZ,DLOC_6    ;NEXT OBJECT
;STORE BACKGROUND FOR LOCAL CHARACTERS
DLOC_8: LD DE,(BOB_POS_Y)
        LD BC,(BOB_SIZE_Y)
        LD IY,BOB_R1
        LD A,SPRITE_SAV
        CALL DRAW_SPRITE
;CALCULATE ACTIVE LOCATION ADDRESS
        LD HL,GAME_WORLD
        LD A,(ACTIVE_LOCATION)
        LD B,6          ;* 64 BYTES
        LD D,0          ;FIX! WITH LOC
DLOC_11:SLA A           ;TWO BYTES
        JR NC,DLOC_10
        INC D
DLOC_10:DJNZ DLOC_11
        LD E,A
        ADD HL,DE       ;HL ADDR LOCATION
        LD (ACT_LOC_ADDR),HL

DRAW_LR:POP IY
        POP IX
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

SB_DAT_L:       INCBIN "SBL_A.C",16
SB_DAT_M:       INCBIN "SBM_A.C",8
SB_DAT_R:       INCBIN "SBR_A.C",16
SB_HEART_ON:    INCBIN "LH_ON.C",48
SB_HEART_OFF:   INCBIN "LH_OFF.C",48
SB_ITEM_BLANK:  INCBIN "SBI_BLNK.C",72
SB_GAME_TIMER:  INCBIN "SB_TIME.C",176

FIRST_FREE_BYTE:        DB #00
