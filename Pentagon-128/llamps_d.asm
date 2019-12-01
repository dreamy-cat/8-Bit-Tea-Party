;GAME LONELY LAMPS
;FILE CONTAINS GLOBAL DATA FOR GAME WORLD
;MOSTLY CONSTANT, BUT MAY BE VARIABLES.
;ONLY TESTED DATA, FOR RELEASE FUNCTIONS.

;GAME WORLD DATA, SEVERAL BYTES FOR EVERY
;LOCATION, CONTAINS OBJECTS AND
;CHARACTERS, 8 BYTES FOR EVERY OBJECT.
;MAXIMUM DATA: 4 AREAS INCLUDE EXITS,
;AND 4 OBJECTS.
;IN GAME WORLD, ONLY FOR GFX FOR NOW.
;[0]            OBJECTS IN LOCATION
;[1]            AREAS FOR MOVE IN LOCATION
;[2]            AREAS FOR OTHER LOCATION
;[3,4]          OFFSET OF OBJECTS
;[5..6]         ADDRESS OF BACKGROUND
;[7]            RESERVED
;[8..OBJS]      N AREAS MAX, FORMAT
;[0..3]         LEFT-UP AND RIGHT DOWN
;               CORNER IN ATTRIBUTES
;[4]            LOCATION TO EXIT
;[5,6]          BOB START Y AND X ON NEW
;VARIABLE PART.
;[OFFS..[0]*8]  OBJECT ADDRESS
;[2,3]          OBJECT POS X,Y(TO SRPITE)
;[4]            OBJECT TYPE
;[5]            OBJECT FLAGS BITS
;               0 DECORATION OBJECT
;               1 OBJECT CAN INTERACT
;               2 OBJECT IS PICKABLE
;               3..6 RESERVED
;               7 IS OBJECT EXIST
;[6,7]          INTERACTIVE Y AND X.

LOCATION_1:
        DB #04,#01      ;OBJECTS AND AREAS
        DB #01          ;EXITS
        DW LMP_O1       ;OBJECTS OFFSET
        DW LOC_DATA_0   ;BACKGROUND
        DB #00          ;RESERVED
        DB #00,#12      ;ROAD AREA
        DB #20,#18
        DB #00          ;NOT EXIT
        DB #00,#00
        DB #1C,#12      ;RIGHT PART
        DB #20,#18
        DB #01          ;TO FLOWER SHOP
        DB #01,#13      ;BOB NEW POSITION
LMP_O1: DW LAMP_ON      ;ADDR ANIM
        DB #1B,#0D      ;POS X,Y
        DB OBJ_LAMP_ON  ;TYPE
        DB %10000001    ;DECORATION
        DB #1C,#16      ;X AND Y OF ACT
LIGHT_1:DW LIGHT        ;ADDR ANIM
        DB #09,#12      ;POS X,Y
        DB OBJ_LIGHT    ;TYPE
        DB %10000100    ;CAN PICK
        DB #09,#12      ;X AND Y OF ACT
BONE_1: DW BONE         ;ADDR ANIM
        DB #1B,#15      ;POS X,Y
        DB OBJ_BONE     ;TYPE
        DB %10000100    ;CAN PICK
        DB #1B,#12      ;X AND Y OF ACT
RESERV1:DW #0000        ;ADDR ANIM
        DB #00,#00      ;POS X,Y
        DB OBJ_EMPTY    ;TYPE
        DB %00000000    ;CAN PICK
        DB #00,#00      ;X AND Y OF ACT

LOCATION_2:             ;TODO
        DB #04,#03      ;OBJ AND LOCS
        DB #03          ;EXITS
        DW LMP_O2
        DW LOC_DATA_1   ;GFX
        DB #00          ;RESERVED
        DB #00,#12      ;1 ROAD
        DB #20,#18
        DB #00          ;EMPTY
        DB #00,#00
        DB #16,#11      ;2 TO BIN
        DB #1C,#18
        DB #00          ;MOVE AREA
        DB #00,#00
        DB #08,#11      ;3 TO FLOWER SHOP
        DB #0E,#18
        DB #00          ;MOVE AREA
        DB #00,#00
        DB #00,#12      ;LEFT ROAD EXIT
        DB #04,#18
        DB #00          ;TO START LOCATION
        DB #1B,#13      ;BOB AT RIGHT
        DB #1C,#10      ;RIGHT ROAD EXIT
        DB #20,#18
        DB #02          ;TO MARKET
        DB #01,#13      ;NEW POSITION
        DB #08,#11      ;EXIT FLOWER SHOP
        DB #0E,#15
        DB #00          ;TO START LOCATION
        DB #01,#13
LMP_O2: DW LAMP_OFF     ;ADDR ANIM
        DB #14,#0D      ;POS X,Y
        DB OBJ_LAMP_OFF ;TYPE
        DB %10000010    ;DECORATION
        DB #15,#12      ;X AND Y OF ACT
OIL_O1: DW OIL          ;ADDR ANIM
        DB #19,#15      ;POS X,Y
        DB OBJ_OIL      ;TYPE
        DB %10000001    ;CAN PICK
        DB #1A,#13      ;X AND Y OF ACT
LIGHT_2:DW LIGHT        ;ADDR ANIM
        DB #18,#12      ;POS X,Y
        DB OBJ_LIGHT    ;TYPE
        DB %10000100    ;CAN PICK
        DB #18,#12      ;X AND Y OF ACT
RESERV2:DW #0000        ;ADDR ANIM
        DB #00,#00      ;POS X,Y
        DB OBJ_EMPTY    ;TYPE
        DB %00000000    ;CAN PICK
        DB #00,#00      ;X AND Y OF ACT

LOCATION_3:             ;MARKET LOCATION
        DB #03,#02      ;OBJ AND AREAS
        DB #03
        DW LMP_O3
        DW LOC_DATA_2
        DB #00          ;RESERVED
        DB #00,#12      ;1 ROAD
        DB #20,#18
        DB #00
        DB #00,#00
        DB #0A,#11      ;2 TO MARKET
        DB #14,#18
        DB #00
        DB #00,#00
        DB #00,#12      ;1E LEFT  TO SHOP
        DB #04,#18
        DB #01          ;TO FLOWER SHOP
        DB #1B,#13      ;BOB AT RIGHT
        DB #1C,#12      ;2E ROAD
        DB #20,#18
        DB #03          ;TO HOUSE
        DB #01,#13      ;NEW POSITION
        DB #0A,#11      ;3E MARKET DOOR
        DB #14,#15
        DB #01
        DB #01,#13
LMP_O3: DW LAMP_OFF     ;ADDR ANIM
        DB #17,#0D      ;POS X,Y
        DB OBJ_LAMP_OFF ;TYPE
        DB %10000010    ;DECORATION
        DB #18,#12      ;X AND Y OF ACT
DOG_O1: DW DOG_STAND    ;ADDR ANIM
        DB #1C,#14      ;POS X,Y
        DB OBJ_DOG_DBG  ;TYPE
        DB %10000001    ;DECORATION
        DB #08,#16      ;X AND Y OF ACT
RESERV3:DW #0000        ;ADDR ANIM
        DB #00,#00      ;POS X,Y
        DB OBJ_EMPTY    ;TYPE
        DB %00000000    ;CAN PICK
        DB #00,#00      ;X AND Y OF ACT

LOCATION_4:             ;HOUSE
        DB #04,#02      ;OBJ AND LOC
        DB #02
        DW LMP_O4       ;EMPTY
        DW LOC_DATA_3
        DB #00          ;RESERVED
        DB #00,#12      ;1 ROAD
        DB #20,#18
        DB #00          ;EMPTY
        DB #00,#00
        DB #0F,#11      ;2 HIGHER
        DB #17,#18
        DB #00          ;EMPTY
        DB #00,#00
        DB #00,#12      ;1E - LEFT ROAD
        DB #04,#18
        DB #02          ;TO MARKET
        DB #1B,#13      ;BOB AT RIGHT
        DB #0F,#11      ;2E - TO HOUSE
        DB #17,#15
        DB #00          ;TO START
        DB #00,#13      ;BOB AT RIGHT
LMP_O4: DW LAMP_OFF     ;ADDR ANIM
        DB #03,#0D      ;POS X,Y
        DB OBJ_LAMP_OFF ;TYPE
        DB %10000010    ;DECORATION
        DB #03,#15      ;X AND Y OF ACT
CAPE_O1:DW CAPE_STAND   ;ADDR ANIM
        DB #1C,#12      ;POS X,Y
        DB OBJ_CAPE_DBG ;TYPE
        DB %10000001    ;DECORATION
        DB #1C,#12      ;X AND Y OF ACT
HOLE_O1:DW MHOLE        ;ADDR ANIM
        DB #08,#15      ;POS X,Y
        DB OBJ_MHOLE    ;TYPE
        DB %10000001    ;CAN PICK
        DB #09,#12      ;X AND Y OF ACT
RESERV4:DW #0000        ;ADDR ANIM
        DB #00,#00      ;POS X,Y
        DB OBJ_EMPTY    ;TYPE
        DB %00000000    ;CAN PICK
        DB #00,#00      ;X AND Y OF ACT

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

BOB_WALK_RL:    ;BOB WALK RIGHT TO LEFT
        DB #02,#12      ;POSITION
        DB #04,#04      ;SIZES
        DB 2            ;PARTS
        DB %00000000    ;FLAGS
        DW BOB_I_1      ;PART 1 - FACE
        DW BOB_I_2      ;PART 2 - FOOTS

BOB_I_1:DB #00,#00      ;LEFT-UP
        DB #04,#02      ;TOP OF HEAD
        DB #00,#00      ;FRAME AND DELAY
        DB #03          ;ALL
        DB %11011000    ;REDRAW+STATIC
        DW BOB_I_1_1    ;AND-OR
        DW BOB_I_M1     ;MASK
        DW BOB_R1
        DB #93,#00      ;SAVE BG
        DW BOB_I_1_2    ;SECOND FRAME
        DW BOB_I_M1     ;
        DW BOB_R1
        DB #04,#00      ;
        DW BOB_I_1_3    ;THIRD FRAME
        DW BOB_I_M1     ;
        DW BOB_R1
        DB #04,#00

BOB_I_2:DB #00,#02      ;NEXT LINES
        DB #04,#02      ;FOOTS
        DB #00,#01      ;FRAME AND DELAY
        DB #04          ;4 FRAMES
        DB %11011000    ;REDRAW+AND-OR
        DW BOB_I_2_1    ;DELAY AND FRAMES
        DW BOB_I_M2
        DW BOB_R2
        DB #0C,#00      ;SAVE BACKGROUND
        DW BOB_I_2_2
        DW BOB_I_M2
        DW BOB_R2
        DB #0C,#00
        DW BOB_I_2_1
        DW BOB_I_M2
        DW BOB_R2
        DB #0C,#00
        DW BOB_I_2_3
        DW BOB_I_M2
        DW BOB_R2
        DB #0C,#00

BOB_STAND_R:    ;BOB STAND STILL ONE FRAME
        DB #02,#12      ;POSITION
        DB #04,#04      ;SIZES
        DB 2            ;PARTS
        DB %00000000    ;FLAGS
        DW BOB_1        ;PART 1 - FACE
        DW BOB_SR       ;PART 2 - FOOTS
BOB_SR: DB #00,#02      ;LEFT-UP
        DB #04,#02      ;TOP OF HEAD
        DB #00,#00      ;FRAME AND DELAY
        DB #01          ;ALL
        DB %11011000    ;REDRAW+STATIC
        DW BOB_2_1      ;AND-OR
        DW BOB_M1       ;MASK
        DW BOB_R2       ;SAVE BG
        DB #00,#00

BOB_STAND_L:    ;BOB STAND STILL ONE FRAME
        DB #02,#12      ;POSITION
        DB #04,#04      ;SIZES
        DB 2            ;PARTS
        DB %00000000    ;FLAGS
        DW BOB_I_1      ;PART 1 - FACE
        DW BOB_SL       ;PART 2 - FOOTS
BOB_SL: DB #00,#02      ;LEFT-UP
        DB #04,#02      ;TOP OF HEAD
        DB #00,#00      ;FRAME AND DELAY
        DB #01          ;ALL
        DB %11011000    ;REDRAW+STATIC
        DW BOB_I_2_1    ;AND-OR
        DW BOB_I_M1     ;MASK
        DW BOB_R2       ;SAVE BG
        DB #00,#00

DOG_STAND:
        DB #10,#10      ;POS
        DB #04,#03      ;MAXIMUM SIZES
        DB #01          ;TWO FOR DEBUG
        DB %00000000
        DW DOG_0
DOG_0:  DB #00,#00      ;ONE PART
        DB #04,#03
        DB #00,#01      ;DYNAMIC
        DB #02          ;ALL
        DB %00001000    ;SINGLE-AND-STATIC
        DW DOG_DAT_0    ;AND-OR TEST
        DW DOG_MSK_0    ;MASK
        DW #0000        ;BG
        DB #20,#00
        DW DOG_DAT_3    ;AND-OR TEST
        DW DOG_MSK_0    ;MASK
        DW #0000        ;BG
        DB #20,#00

DOG_MOVE:
        DB #10,#10      ;POS
        DB #04,#03      ;MAXIMUM SIZES
        DB #01          ;TWO FOR DEBUG
        DB %00000000
        DW DOG_2
DOG_2:  DB #00,#00      ;ONE PART
        DB #04,#03
        DB #00,#01      ;STAT
        DB #02          ;ALL
        DB %00000001    ;SINGLE-AND-STATIC
        DW DOG_DAT_0    ;AND-OR TEST
        DW #0000        ;MASK
        DW #0000        ;BG
        DB #05,#00
        DW DOG_DAT_0
        DW #0000
        DW #0000
        DB #05,#00

CAPE_STAND:
        DB #10,#10      ;POS
        DB #02,#05      ;MAXIMUM SIZES
        DB #01          ;TWO FOR DEBUG
        DB %00000000
        DW CAPE_0
CAPE_0: DB #00,#00      ;ONE PART
        DB #02,#05
        DB #00,#01      ;FRAMES AND DELAY
        DB #02          ;ALL
        DB %00001000    ;DYNAMIC
        DW CAPE_DAT_0   ;AND-OR TEST
        DW CAPE_MSK_0   ;MASK
        DW #0000        ;BG
        DB #10,#00
        DW CAPE_DAT_6   ;AND-OR TEST
        DW CAPE_MSK_0   ;MASK
        DW #0000        ;BG
        DB #10,#00

;OBJECTS AND ANIMATION FOR THEM.

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

;STANDARD OBJECTS USING ANIM STRUCTURE

LIGHT:  DB #05,#05      ;SMALL LIGHT
        DB #01,#01
        DB #01          ;ONE PART
        DB %00100000    ;RESET STATIC
        DW LIGHT_0
LIGHT_0:DB #00,#00      ;POS
        DB #01,#01      ;SIZE
        DB #00,#00      ;STATIC
        DB #01
        DB %01100001
        DW LIGHT_DAT    ;DATA
        DW #0000        ;MASK
        DW #0000        ;NO SAVE
        DB #00,#00

BONE:   DB #05,#05      ;SMALL LIGHT
        DB #01,#01
        DB #01          ;ONE PART
        DB %00100000    ;RESET STATIC
        DW BONE_0
BONE_0: DB #00,#00      ;POS
        DB #01,#01      ;SIZE
        DB #00,#00      ;STATIC
        DB #01
        DB %01101000
        DW BONE_DAT     ;DATA
        DW BONE_MSK     ;MASK
        DW #0000        ;NO SAVE
        DB #00,#00

FLOWERS:DB #05,#05      ;SMALL LIGHT
        DB #01,#01
        DB #01          ;ONE PART
        DB %00100000    ;RESET STATIC
        DW FLOW_0
FLOW_0: DB #00,#00      ;POS
        DB #01,#01      ;SIZE
        DB #00,#00      ;STATIC
        DB #01
        DB %01100001
        DW FLOWERS_DAT  ;DATA
        DW #0000        ;MASK
        DW #0000        ;NO SAVE
        DB #00,#00

KEY:    DB #05,#05      ;SMALL KEY
        DB #01,#01
        DB #01          ;ONE PART
        DB %00100000    ;RESET STATIC
        DW KEY_0
KEY_0:  DB #00,#00      ;POS
        DB #01,#01      ;SIZE
        DB #00,#00      ;STATIC
        DB #01
        DB %01100001
        DW KEYS_DAT     ;DATA
        DW #0000        ;MASK
        DW #0000        ;NO SAVE
        DB #00,#00

OIL:    DB #05,#05      ;SMALL LIGHT
        DB #03,#02
        DB #01          ;ONE PART
        DB %00100000    ;RESET STATIC
        DW OIL_0
OIL_0:  DB #00,#00      ;POS
        DB #03,#02      ;SIZE
        DB #00,#00      ;STATIC
        DB #01
        DB %01101000
        DW OIL_DAT      ;DATA
        DW OIL_MSK      ;MASK
        DW #0000        ;NO SAVE
        DB #00,#00

MHOLE:  DB #05,#05      ;SMALL LIGHT
        DB #03,#02
        DB #01          ;ONE PART
        DB %00100000    ;RESET STATIC
        DW MHOLE_0
MHOLE_0:DB #00,#00      ;POS
        DB #03,#02      ;SIZE
        DB #00,#00      ;STATIC
        DB #01
        DB %01101000
        DW MHOLE_DAT    ;DATA
        DW MHOLE_MSK    ;MASK
        DW #0000        ;NO SAVE
        DB #00,#00

BOB_R1: DUP 64  ;STORE BACKGROUND FOR BOB
        DB #00
        EDUP 
BOB_R2: DUP 64
        DB #00
        EDUP 
