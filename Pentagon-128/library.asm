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
        JR Z,SPR_ST     ;SAVE ZERO TO SPR
        EX AF,AF'       ;18 TACTS
        LD A,(DE)
        OR (HL)
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
