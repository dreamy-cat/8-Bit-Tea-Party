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
        LD A,0
        LD (ACTIVE_LOCATION),A
        CALL INIT_GAME
        OR A
        LD DE,#6000
        LD HL,BINARY_DATA_START
        SBC HL,DE
        OR A
        LD HL,FIRST_FREE_BYTE
        SBC HL,DE

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
STARS_ON_SKY    EQU 150
STARS_POSITION  EQU 16  ;AFTER STATUS BAR
STARS_SIZE      EQU 24  ;2 ATTRIBUTES
BG_LOC_POS_X    EQU #00 ;BACKGROUND
BG_LOC_POS_Y    EQU #05 ;LOCATION START
BG_LOC_SIZE_X   EQU #20 ;AND BOTH SIZES
BG_LOC_SIZE_Y   EQU #10
BG_LOC_BYTES    EQU #1000       ;MEM SIZE
ROAD_POSY       EQU #15 ;ROAD Y POSITION
GAME_BORDER     EQU #00 ;BLACK UNLESS DBG
BG_DEFAULT_A    EQU %01000111
BG_DEBUG_A      EQU %01111000   ;ATTRIB
BG_DEFAULT_BT   EQU %00000000   ;BYTE TO
BG_DEBUG_BT     EQU %11111111   ;FILL
;BOB POSITIONS MUST BE EQUAL ON ASSEMBLE
BOB_START_X:    EQU #07 ;DEFAULT
BOB_START_Y:    EQU #13
BOB_SZ_X        EQU #04 ;BOB SIZES
BOB_SZ_Y        EQU #04

HEROES_IN_GAME  EQU 2
ITEMS_MAX       EQU #02

;OBJECT TYPES AND ADRESSES.

OBJ_EMPTY       EQU #00
OBJ_LAMP_ON     EQU #01
OBJ_LAMP_OFF    EQU #02
;OBJECT RESERVED
OBJ_LIGHT       EQU #04
OBJ_BONE        EQU #05
OBJ_FLOWERS     EQU #06
OBJ_KEYS        EQU #07
OBJ_OIL         EQU #08
OBJ_MHOLE       EQU #09

OBJ_DOG_DBG     EQU #10
OBJ_CAPE_DBG    EQU #11

;ITEMS TABLE WITH ANIMATION AND INVENTORY
;IMAGES. 4 BYTES FOR EVERY ITEM.

IMG_OFFSET      EQU #02 ;FOR STATUS BAR

ITEMS_TABLE:
        DW #0000
        DW SB_ITEM_BLANK
        DW LAMP_ON
        DW #0000
        DW LAMP_OFF
        DW #0000
        DW #0000        ;RESERVED
        DW #0000
        DW LIGHT
        DW SB_LIGHT_ITEM
        DW BONE
        DW SB_BONE_ITEM
        DW FLOWERS
        DW SB_FLOWERS_ITEM
        DW KEY
        DW SB_KEY_ITEM

;SYSTEM VARIABLES

KEMPSTON:       DUP 07
                DB #00  ;EVERY INTERRUPT
                EDUP    ;PREVIOUS PUSHES
KEMPSTON_TOP:   DB #00  ;TOP FOR QUE
KEMPSTON_DEEP:  EQU #08 ;FOR MOVING
KEMPSTON_INACTIVE:      DB #00
BOB_INACTIVE    EQU #80 ;TIMER FOR STAND
BOB_RIGHT_ACT:  DB #00
BOB_LEFT_ACT:   DB #00
BOB_SPEED       EQU #08 ;BOB SPEED

;GAME VARIABLES

STARS:          DUP STARS_ON_SKY
                DW #0000
                EDUP 
ACTIVE_LOCATION:DB #00  ;HERO LOCATION
ACT_LOC_ADDR:   DW GAME_WORLD
GAME_IM2:       DB #00
GAME_TIMER:     DB #00  ;ALL TIME FOR BOB
BAR_ATTRIB:     DB %01010111    ;RED
                DB %01110111    ;YELLOW
                DB %01100111    ;GREEN

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
BOB_ACTION_F:   DB %00000000    ;FLAGS
BOB_ANIMATION:  DW BOB_WALK_LR ;ANIMATION ADDR
BOB_POS_Y:      DB BOB_START_Y ;ACTIVE POS
BOB_POS_X:      DB BOB_START_X
BOB_PREV_Y:     DB BOB_START_Y ;PREVIOS
BOB_PREV_X:     DB BOB_START_X
BOB_SIZE_Y:     DB #04  ;SIZES
BOB_SIZE_X:     DB #04
BOB_RESTORE:    DW BOB_R1 ;STORE
BOB_ENERGY:     DB #03 ;BOB ENERGY
BOB_ITEM_1:     DB OBJ_EMPTY
ITEM_FLAGS_1:   DB %00000000
BOB_ITEM_2:     DB OBJ_LIGHT
ITEM_FLAGS_2:   DB %10000100
BOB_ITEM_3:     DB OBJ_EMPTY   ;FOR DROP
ITEM_FLAGS_3:   DB %00000000

AREAS_OFFSET    EQU #08
SIZEOF_AREA     EQU #0007 ;MOVE AND EXIT
OBJECTS_OFFSET  EQU #03   ;OFFSET
SIZEOF_OBJECT   EQU #08   ;IN BYTES

GAME_WORLD:
LOC_1_ENTRANCE: DW LOCATION_1
LOC_2_SHOP:     DW LOCATION_2
;LOC_2A_FLOWERS: DW LOCATION_2A
LOC_3__MALL:    DW LOCATION_3
;LOC_3A_MARKET: DW LOCATION_3A
LOC_4_HOUSE:    DW LOCATION_4

;STANDARD OBJECTS USING ANIM STRUCTURE

;MAIN CHARACTER STRUCTURES OF THE GAME.

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
        LD A,GAME_BORDER
        OUT (#FE),A

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
        LD H,%00000010  ;COLORS FOR ENERGY
        LD L,%00000100  ;COLOR FOR TIMER
        LD IX,#5801     ;ADDRESSES
        LD IY,#5814
        LD BC,#0B02
        LD DE,#0020
SBAR_5: PUSH IX
        PUSH IY
        PUSH BC
SBAR_4: LD (IX+0),H
        LD (IY+0),L
        INC IX
        INC IY
        DJNZ SBAR_4
        POP BC
        POP IY
        POP IX
        ADD IX,DE
        ADD IY,DE
        DEC C
        JR NZ,SBAR_5
        CALL UPDATE_ITEMS
        LD BC,#0603     ;COLORS FOR ITEMS
        LD DE,#0020
        LD HL,#580D
        LD A,%00000111
SBAR_7: PUSH HL
        PUSH BC
SBAR_6: LD (HL),A
        INC HL
        DJNZ SBAR_6
        POP BC
        POP HL
        ADD HL,DE
        DEC C
        JR NZ,SBAR_7

        LD HL,SB_GAME_TIMER     ;TIMER
        LD DE,#1400
        LD BC,#0B02
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
;DRAW FIRST LOCATION ON START
INIT_GE:CALL DRAW_LOCATION
        POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;CREATE SCENE, ON EVERY FRAME IN GAME,
;DRAW/UPDATE ALL OBJECTS IF NEEDED
;ON SCREEN, SAVE BACKGROUND FOR HERO.
;SCENE MUST HAVE AT LEAST ONE OBJECT
;NO CHECKS FOR DATA RANGES.
;TIMINGS FOR GAME_IM2 IN BITS.
;[00]   DRAW OBJECTS
;[01]   DRAW BOB
;[10]   DRAW CHARACTERS, LATER.

CREATE_SCENE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
;CHECK FRAME COUNTER
        LD A,(GAME_IM2)
        BIT 0,A         ;IF OBJECTS
        JR NZ,SCENE_1
;DRAW OBJECTS ON LOCATION
SCENE_2:LD IX,(ACT_LOC_ADDR)
        LD B,(IX)       ;OBJECTS COUNTER
        LD A,B          ;NO OBJECTS
        OR A
        JP Z,SCENE_R    ;CHECK TO HEROES
        LD L,(IX+OBJECTS_OFFSET)
        LD H,(IX+OBJECTS_OFFSET+1)
SCENE_3:PUSH HL
        POP IY
        BIT 7,(IY+5)
        JR Z,SCENE_4
        LD E,(IY+0)
        LD D,(IY+1)
        PUSH DE
        POP IX          ;IX - ANIM ADDR
        LD A,(IY+2)
        LD (IX+0),A
        LD A,(IY+3)
        LD (IX+1),A
        CALL DRAW_ANIMATION
SCENE_4:LD DE,SIZEOF_OBJECT
        ADD HL,DE
        DJNZ SCENE_3
        JR SCENE_R
SCENE_1:
;DRAW BOB ON ACTIVE LOCATION
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
        ;JR SCENE_R
SCENE_5:
;DRAW OTHER CHARACTERS ON LOCATION

SCENE_R:POP IY
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

        ;JP GAME_R

        ;LD BC,#0100    ;MAIN CYCLE
GAME_1: PUSH BC
        HALT 
        CALL CREATE_SCENE
        ;LD A,#06       ;LOGIC PERFRORM
        ;OUT (#FE),A
        ;LD A,1
        ;LD (KEMPSTON),A

;TODO MOVING LOGIC
        LD A,(GAME_IM2)
        BIT 0,A
        JR NZ,GAME_2    ;NOT BOB FRAME
        CALL MOVE_BOB_KEMPSTON
GAME_2: LD A,(KEMPSTON)
        BIT KEMPSTON_FIRE,A
        JP Z,GAME_3
        CALL BOB_ACTION_KEMPSTON

GAME_3:
        ;LD A,#04       ;EXTRA PERFORMANCE
        ;OUT (#FE),A
        POP BC
        ;DEC BC
        ;LD A,B
        ;OR C
        JP GAME_1

GAME_R: POP IY
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
        LD B,ITEMS_MAX
        LD C,#0D        ;FIRST ITEM X
        LD HL,BOB_ITEM_1
UPD_I1: PUSH BC
        PUSH HL
        LD A,(HL)
        SLA A           ;4 BYTES
        SLA A
        ADD A,IMG_OFFSET ;2 BYTES FOR TAB
        LD D,#00
        LD E,A
        LD HL,ITEMS_TABLE
        ADD HL,DE
        LD E,(HL)
        INC HL
        LD D,(HL)
        EX DE,HL
        LD D,C
        LD E,0
        LD BC,#0303
        LD A,SPRITE_MOV
        CALL DRAW_SPRITE
        POP HL
        POP BC
        LD A,C
        ADD A,3
        LD C,A
        INC HL          ;WITH FLAG
        INC HL
        DJNZ UPD_I1
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

        LD IX,(ACT_LOC_ADDR)
        LD B,(IX+0)     ;NO OBJECTS
        LD A,B
        OR A
        JP Z,BOBA_R
        LD E,(IX+3)
        LD D,(IX+4)
        PUSH DE
        POP IY          ;IY - OBJECTS

BOBA_0: BIT 7,(IY+5)    ;IF EXIST
        JP Z,BOBA_1
        LD A,(IY+7)     ;RANGES
        LD DE,(BOB_POS_Y)
        SUB E
        JP C,BOBA_1     ;IF LOWER
        CP BOB_SZ_Y     ;IN RANGE Y
        JP NC,BOBA_1
        LD A,(IY+6)
        SUB D
        JP C,BOBA_1     ;IF RIGHTER
        CP BOB_SZ_X     ;CHECK RANGE X
        JP NC,BOBA_1

        BIT 0,(IY+5)    ;CHECK TYPE
        JP NZ,BOBA_1    ;IF DECORATION
        BIT 1,(IY+5)
        JR Z,BOBA_2     ;IF ACTIVE OBJ
;ACTIVE OBJECT WITH USE ITEMS
        LD A,(IY+4)
        CP OBJ_LAMP_OFF
        JR NZ,BOBA_1
        LD A,(BOB_ITEM_1)
        CP OBJ_LIGHT
        JR NZ,BOBA_A0
        LD E,OBJ_EMPTY  ;DELETE ITEM
        LD D,%00000000
        LD (BOB_ITEM_1),DE
        JR BOBA_A1
BOBA_A0:LD A,(BOB_ITEM_2)
        CP OBJ_LIGHT
        JP NZ,BOBA_R    ;NO ITEM LIGHT
        LD E,OBJ_EMPTY  ;DELETE ITEM
        LD D,%00000000
        LD (BOB_ITEM_2),DE
BOBA_A1:LD DE,LAMP_ON   ;SWITCH ON LAMP
        LD (IY+0),E
        LD (IY+1),D
        LD A,OBJ_LAMP_ON
        LD (IY+4),A
        CALL DRAW_LOCATION
        CALL UPDATE_ITEMS
        JP BOBA_R
BOBA_2: BIT 2,(IY+5)    ;CAN PICK OBJECT
        JP Z,BOBA_1
        LD DE,(BOB_ITEM_2) ;PICK OBJECT
        LD (BOB_ITEM_3),DE
        LD DE,(BOB_ITEM_1) ;WITH FLAG
        LD (BOB_ITEM_2),DE
        LD A,(IY+4)     ;OBJ TO PICK
        LD (BOB_ITEM_1),A
        LD A,(IY+5)
        LD (ITEM_FLAGS_1),A
        CALL UPDATE_ITEMS
        RES 7,(IY+5)    ;NOT EXIST
        CALL DRAW_LOCATION
        LD A,(BOB_ITEM_3)
        OR A            ;NEED TO DROP
        JP Z,BOBA_R
        LD A,#02
        JR BOBA_D
BOBA_1: DEC B
        JP Z,BOBA_4
        LD DE,SIZEOF_OBJECT
        ADD IY,DE       ;NEXT ITEM
        JP BOBA_0
;AFTER CYCLE CHECK FOR DROP ITEMS
BOBA_4: LD A,(ITEM_FLAGS_1)
        BIT 3,A         ;CHECK FOR DROP
        JR Z,BOBA_5
        LD A,#00
        JR BOBA_D
BOBA_5: LD A,(ITEM_FLAGS_2)
        BIT 3,A
        JP Z,BOBA_R
        LD A,#01
BOBA_D: BIT 7,(IY+5)    ;FIRST FREE
        JR Z,BOBA_D2
        LD DE,SIZEOF_OBJECT
        ADD IY,DE       ;TO FIRST FREE
        DJNZ BOBA_D     ;
BOBA_D2:LD HL,BOB_ITEM_1;DROP ITEM A = N
        SLA A
        LD E,A
        LD D,0
        ADD HL,DE
        LD B,(HL)       ;B = ITEM TO DROP
        LD A,OBJ_EMPTY  ;CLEAR ITEM
        LD (HL),A
        INC HL
        LD C,(HL)       ;C = FLAGS
        LD A,%00000000
        LD (HL),A
        LD HL,ITEMS_TABLE
        LD A,B
        SLA A           ;A * 4 BYTES
        SLA A
        LD E,A          ;D = 0 AS UPPER
        ADD HL,DE
        LD E,(HL)       ;REWRITE EMPTY OBJ
        INC HL
        LD D,(HL)
        LD (IY+0),E     ;ADDR OF ANIM
        LD (IY+1),D
        LD A,(BOB_POS_X)
        ADD A,BOB_SZ_X
        DEC A
        LD (IY+2),A
        LD (IY+6),A     ;NEW POSITION OBJ
        LD A,(BOB_POS_Y)
        ADD A,BOB_SZ_Y
        DEC A
        LD (IY+3),A
        LD (IY+7),A
        LD (IY+4),B     ;OBJ TYPE
        LD (IY+5),C     ;FLAG
        CALL DRAW_LOCATION
        CALL UPDATE_ITEMS
        JP BOBA_R

BOBA_R: POP IY
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
        LD BC,AREAS_OFFSET
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
        LD A,(BOB_PREV_Y)
        CP E
        JR NZ,MB_KLOC

        PUSH HL
        LD A,(BOB_PREV_X)
        CP D
        JR NC,MB_K9
        LD A,(BOB_RIGHT_ACT)    ;SPEED
        CP BOB_SPEED
        JP NC,MB_KS1
        LD DE,(BOB_PREV_Y)
        LD (BOB_POS_Y),DE
        JP MB_KS3
MB_KS1:
        XOR A
        LD (BOB_RIGHT_ACT),A
        LD HL,BOB_WALK_LR
        LD A,CHAR_MOVE_LR
        LD (BOB_ACTION_T),A
        JR MB_K10
MB_K9:
        LD A,(BOB_LEFT_ACT)     ;SPEED L
        CP BOB_SPEED
        JP NC,MB_KS2
        LD DE,(BOB_PREV_Y)
        LD (BOB_POS_Y),DE
        JP MB_KS3

MB_KS2: XOR A
        LD (BOB_LEFT_ACT),A
        LD HL,BOB_WALK_RL
        LD A,CHAR_MOVE_RL
        LD (BOB_ACTION_T),A
MB_K10: LD (BOB_ANIMATION),HL
MB_KS3: POP HL
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
MB_K5:  LD A,(KEMPSTON_INACTIVE)
        CP BOB_INACTIVE
        JR C,MB_KR
        LD A,(BOB_ACTION_T)
        CP CHAR_MOVE_LR
        JR NZ,MB_K12
        LD HL,BOB_STAND_R
        JR MB_K13
MB_K12: CP CHAR_MOVE_RL
        JR NZ,MB_KR
        LD HL,BOB_STAND_L
MB_K13: LD A,CHAR_STAND
        LD (BOB_ACTION_T),A
        LD (BOB_ANIMATION),HL
MB_KR:  POP IX
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
        LD HL,LOCATION_1

;CALCULATE ACTIVE LOCATION ADDRESS
        LD HL,GAME_WORLD
        LD A,(ACTIVE_LOCATION)
        SLA A
        LD E,A
        LD D,#00
        ADD HL,DE
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD (ACT_LOC_ADDR),DE

        ;JP DLT         ;WITHOUT ATTRIB

;CLEAR ATTRIBUTES FROM LAMPS
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
DLT:    LD IX,(ACT_LOC_ADDR)
        LD L,(IX+5)     ;BACKGROUND
        LD H,(IX+6)
DLOC_1: LD A,SPRITE_MOV
        LD D,BG_LOC_POS_X
        LD E,BG_LOC_POS_Y
        LD B,BG_LOC_SIZE_X
        LD C,BG_LOC_SIZE_Y
        CALL DRAW_SPRITE

        ;JP DLOC_T      ;WITHOUT ROAD

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
DLOC_T: LD IX,(ACT_LOC_ADDR)
        LD B,(IX)       ;OBJECTS COUNTER
        LD A,B          ;NO OBJECTS
        OR A
        JP Z,DLOC_8     ;CHECK TO HEROES
        LD L,(IX+OBJECTS_OFFSET)
        LD H,(IX+OBJECTS_OFFSET+1)
DLOC_6: PUSH HL
        POP IY
        BIT 7,(IY+5)    ;IF NOT EXIST
        JP Z,DLOC_7
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
        JR NC,LMP_S4    ;IF SHADE TO ROAD
        INC D
        DEC B
        OR A
        JR LMP_S2
LMP_S4: SCF             ;FIRST ATTRIB
LMP_S2  PUSH BC
        LD BC,#0101
        LD A,SPRITE_MOV
        ;CALL DRAW_SPRITE
        JR C,LMP_S5
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
LMP_S5: POP BC          ;AFTER ATTRIB
        INC D
        OR A
        DJNZ LMP_S2
        POP DE
        INC E
        POP BC
        DEC C
        JR NZ,LMP_S3
        POP BC
        POP HL
DLOC_7: LD DE,SIZEOF_OBJECT
        ADD HL,DE
        DEC B
        JP NZ,DLOC_6    ;NEXT OBJECT
;STORE BACKGROUND FOR LOCAL CHARACTERS
DLOC_8: LD DE,(BOB_POS_Y)
        LD BC,(BOB_SIZE_Y)
        LD IY,BOB_R1
        LD A,SPRITE_SAV
        CALL DRAW_SPRITE

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
;       LD A,1          ;PERFORMANCE
;       OUT (#FE),A
        IN A,(KEMPSTON_PORT)
        AND KEMPSTON_MASK
        LD (KEMPSTON),A
        JR NZ,IM2_1
        LD A,(KEMPSTON_INACTIVE)
        INC A
        LD (KEMPSTON_INACTIVE),A
        JR IM2_2
IM2_1:  BIT KEMPSTON_RIGHT,A
        JR Z,IM2_3
        LD A,(BOB_RIGHT_ACT)
        INC A
        LD (BOB_RIGHT_ACT),A
        JR IM2_2
IM2_3:  BIT KEMPSTON_LEFT,A
        JR Z,IM2_2
        LD A,(BOB_LEFT_ACT)
        INC A
        LD (BOB_LEFT_ACT),A
IM2_2:  LD A,(GAME_IM2)
        INC A
        LD (GAME_IM2),A
;       CALL MOD        ;CALL AY-PLAYER.
IM2_R:  POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        EI 
        RETI 

CREDITS:DB "   LONELY LAMPS GAME!   ",0
        DB "       CREATED BY       ",0
        DB "    8-BIT TEA PARTY!    ",0
        DB "                        ",0
        DB "    IDEAS, STORY, ORG   ",0
        DB "     DMITRY GALASHIN    ",0
        DB "                        ",0
        DB " HEROES & ITEM GRAPHICS ",0
        DB "      EUGENE MASLOV     ",0
        DB "                        ",0
        DB "   LOCATIONS GRAPHICS   ",0
        DB "         ZERDROS        ",0
        DB "                        ",0
        DB "          CODE          ",0
        DB "    ALEXANDER SEROV     ",0
        DB "                        ",0
        DB "   SPECIAL THANKS TO:   ",0
        DB "     VASILY KOLCHIN     ",0
        DB "      ROMAN NOTKOV      ",0
        DB "    VLADIMIR SMIRNOV    ",0
        DB "                        ",0
        DB "      AUTUMN  2019      ",0

;LIBRARY FUNCTIONS FOR GAME

INCLUDE "LIBRARY.A",0

BINARY_DATA_START:      DB #00

INCLUDE "LLAMPS_D.A",1

;BINARY GFX DATA

BOB_M1:         INCBIN "BOB_MSK1.C",64
BOB_M2:         INCBIN "BOB_MSK2.C",64
BOB_1_1:        INCBIN "BOB_P1F1.C",64
BOB_1_2:        INCBIN "BOB_P1F2.C",64
BOB_1_3:        INCBIN "BOB_P1F3.C",64
BOB_2_1:        INCBIN "BOB_P2F1.C",64
BOB_2_2:        INCBIN "BOB_P2F2.C",64
BOB_2_3:        INCBIN "BOB_P2F3.C",64
BOB_2_4:        ;INCBIN "BOB_P2F4.C",64

BOB_I_M1:       INCBIN "BOBIMSK1.C",64
BOB_I_M2:       INCBIN "BOBIMSK2.C",64
BOB_I_1_1:      INCBIN "BOBIP1F1.C",64
BOB_I_1_2:      INCBIN "BOBIP1F2.C",64
BOB_I_1_3:      INCBIN "BOBIP1F3.C",64
BOB_I_2_1:      INCBIN "BOBIP2F1.C",64
BOB_I_2_2:      INCBIN "BOBIP2F2.C",64
BOB_I_2_3:      INCBIN "BOBIP2F3.C",64
BOB_I_2_4:      ;INCBIN "BOB_P3F4.C",64

LAMP_DAT_M0:    INCBIN "LMPP2MSK.C",80
LAMP_DAT_0:     INCBIN "LMP_P2F1.C",80
LAMP_DAT_M1:    INCBIN "LMPP1MSK.C",96
LAMP_DAT_M2:    INCBIN "LMP1AMSK.C",96
LAMP_DAT_1:     INCBIN "LMP_P1F1.C",96
LAMP_DAT_2:     INCBIN "LMP_P1F2.C",96
LAMP_DAT_3:     INCBIN "LMP_P1F3.C",96

DOG_DAT_0:      INCBIN "DOG_F1.C",96
DOG_DAT_3:      INCBIN "DOG_F3.C",96
DOG_MSK_0:      INCBIN "DOG_MSK.C",96
CAPE_DAT_0:     INCBIN "CLOAK_F1.C",80
CAPE_DAT_6:     INCBIN "CLOAK_F6.C",80
CAPE_MSK_0:     INCBIN "CLOAK_M.C",80

LAMP_SHAD_B:    DUP 08
                DB #00
                EDUP 
LAMP_SHAD_L:    INCBIN "LMPSHD.C",32
LAMP_SHAD_R:    INCBIN "ROADSHD.C",72

LOC_DATA_0:     INCBIN "BG01.C",4096
LOC_DATA_1:     INCBIN "BG02.C",4096
LOC_DATA_2:     INCBIN "BG03.C",4096
LOC_DATA_3:     INCBIN "BG04.C",4096

ROAD_TILE:      INCBIN "TILE2X3.C"

LIGHT_DAT:      INCBIN "LIGHT.C",8
BONE_DAT:       INCBIN "BONE.C",8
BONE_MSK:       INCBIN "BONE_MSK.C",8
FLOWERS_DAT:    INCBIN "FMRS_SML.C",8
KEYS_DAT:       INCBIN "KEYS.C",8

OIL_DAT:        INCBIN "OIL.C",48
OIL_MSK:        INCBIN "OIL_MSK.C",48
MHOLE_DAT:      INCBIN "MHOLE.C",48
MHOLE_MSK:      INCBIN "MHOLEMSK.C",48

SB_DAT_L:       INCBIN "SBL_A.C",16
SB_DAT_M:       INCBIN "SBM_A.C",8
SB_DAT_R:       INCBIN "SBR_A.C",16
SB_HEART_ON:    INCBIN "LH_ON.C",48
SB_HEART_OFF:   INCBIN "LH_OFF.C",48
SB_ITEM_BLANK:  INCBIN "SBI_BLNK.C",72
SB_GAME_TIMER:  INCBIN "SB_TIME.C",176

SB_BONE_ITEM:   INCBIN "BONEICON.C",72
SB_KEY_ITEM:    INCBIN "KEY_ICON.C",72
SB_LIGHT_ITEM:  INCBIN "LIGHTICN.C",72
SB_FLOWERS_ITEM:INCBIN "FLWRSICN.C",72

FIRST_FREE_BYTE:        DB #00
