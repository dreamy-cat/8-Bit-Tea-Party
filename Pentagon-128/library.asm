;OUR LIBRARY FUNCTIONS FOR PROJECTS.
;ALL FUNCTIONS IN ONE PLACE FOR NOW.
;EVERY FUNCTION MUST HAVE DISCRIPTION WITH
;PARAMETERS AND DATA ON EXIT.

;FULL LIST IN ALPHABET ORDER:
;CLEAR SCREEN
;

;SOME GLOBAL CONSTANTS, ADD LATER

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
        RES 0,B         ;RESET DELAY FLAG
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL          ;NEXT PART IN HL
        PUSH HL         ;SAVE PART
        EX DE,HL        ;DE - ADDR PART
        PUSH HL
        POP IY          ;IY - PART STRUC
        BIT 6,(IX+5)    ;IF ALL REDRAW
        JR Z,ANIM_8
        SET 6,(IY+7)    ;SET REDRAW FLAG
ANIM_8: LD C,(IY+7)     ;FLAGS IN REG C
        BIT 5,C         ;EXTRA BIT
        JR NZ,ANIM_2    ;STATIC PART
        DEC (IY+5)      ;CURRENT DELAY
        JR NZ,ANIM_2
        SET 6,C         ;RE-DRAW PART
        SET 0,B         ;RESET DELAY IN B
        INC (IY+4)      ;NEXT FRAME
        LD A,(IY+4)
        CP (IY+6)
        JR NZ,ANIM_2
        LD (IY+4),0     ;TO 0-FRAME
ANIM_2: BIT 6,C         ;DRAW OR NOT PART
        JR NZ,ANIM_5
        BIT 7,C         ;SINGLE OR EVERY
        JR Z,ANIM_4     ;FRAME TO DRAW
ANIM_5: RES 6,(IY+7)    ;NOT DRAW NEXT FR
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
        PUSH HL         ;HL TO IX
        POP IX          ;IX - FRAME TABLE
        BIT 0,B         ;IF NEED TO SET
        JR Z,ANIM_3
        LD A,(IX+6)     ;OFFSET OF DELAY
        LD (IY+5),A     ;SET NEW DELAY
ANIM_3: LD A,D
        ADD A,(IY+0)    ;POSITION WITHOUT
        LD D,A          ;CHECK OF RANGES
        LD A,E
        ADD A,(IY+1)
        LD E,A          ;DE - FRAME POS
        LD A,(IY+7)     ;A - FLAGS
        LD B,(IY+2)     ;BC - SIZES
        LD C,(IY+3)
        BIT 4,A         ;NEED SAVE BG
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
ANIM_7: CALL DRAW_SPRITE
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

DRAW_SPRITE:
        PUSH AF
        EX AF,AF'       ;SAVE AF' TOO
        PUSH AF
        EX AF,AF'
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY
        PUSH AF         ;AF' SPRITE FLAGS
        EX AF,AF'
        POP AF
        EX AF,AF'
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
SPR_1:  EX AF,AF'
        BIT 4,A
        JR Z,SPR_NSV    ;NOT SAVE SCREEN
        EX AF,AF'
        LD A,(DE)       ;SAVE BG
        LD (IY+0),A     ;44 TACTS
        INC IY
        EX AF,AF'
SPR_NSV:BIT 3,A         ;AND-OR PART
        JR Z,SPR_MOV    ;ORDED IN MORE
        EX AF,AF'       ;CALLS IN GAME
        LD A,(DE)
        AND (IX+0)
        OR (HL)         ;57 TACTS
        INC IX
        JR SPR_ST       ;TO STORE
SPR_MOV:BIT 0,A         ;MOVE PART
        JR Z,SPR_AND
        EX AF,AF'
        LD A,(HL)       ;21 TACTS
        JR SPR_ST
SPR_AND:BIT 1,A         ;AND PART
        JR Z,SPR_OR
        EX AF,AF'
        LD A,(DE)       ;28 TACTS
        AND (HL)
        JR SPR_ST
SPR_OR: BIT 2,A         ;OR PART
        JR Z,SPR_NXT    ;NOTHING TO DO
        EX AF,AF'       ;18 TACTS
        LD A,(DE)
        OR (HL)
        JR SPR_ST
SPR_NXT:EX AF,AF'       ;NO DRAW NEXT
        JR SPR_NST
SPR_ST: LD (DE),A       ;STORE BYTE
        INC HL
SPR_NST:INC DE          ;NEXT BYTE
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
SPR_RET:POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        EX AF,AF'       ;RESTORE AF'
        POP AF
        EX AF,AF'
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
