;LIBRARY AND CODE MODULE FOR BASIC.
;USING IN 48K MODE ON DEFINED ADDRESS.

;GLOBAL SETTTINGS
;All functions addresses.
;To use DEF FN=F(...)=USR ADDR - in 48K.

START_ADDRESS   EQU #8000
SPRITE_ADDR     EQU #8100       ;+256 BYTE

;GLOBAL CONSTANTS AND VARIABLES.
;WILL CHANGE LATER.

SCREEN_X_SIZE   EQU #20         ;32 ATTRIB
SCREEN_Y_SIZE   EQU #18         ;24 ATTRIB
SCREEN_ADDR     EQU #4000       ;STANDARD
DEF_FN_PAR_ADDR EQU #5C0B       ;ADDR DATA

        ORG START_ADDRESS

        ;JP BASIC_SPRITE        ;DEBUG

        NOP             ;IF ERROR THEN
        RET             ;CALLED

CONFIGURATION:
CONFIG_TABLE:   ;FUNCTION'S DATA, 16 BYTES
FUNCTION_ID:    DW #0000        ;TO CALL
DATA_TABLE:     DB %00000001    ;DATA
                DW #2010        ;FOR
                DW #0004        ;REGISTERS
                DW #8000        ;RND DATA
                DW #0000        ;NO MASK
                DW #0000        ;NO STORE
                DUP #01         ;FREE
                DB #00          ;RESERVED
                EDUP 

        ORG SPRITE_ADDR         ;#8100

;BASIC parameters in order left to right,
;offset +4 bytes base and +8 for next.
;[1]    type draw;
;[2]    X position to draw [0..31];
;[3]    Y position to draw [0..23];
;[4]    X size of sprite [0..31];
;[5]    Y size of sprite [0..23];
;[6]    low part of address data;
;[7]    high part of address data;
;[8]    low part of address mask;
;[9]    high part of address mask;
;[10]   low part of address to store;
;[11]   high part of address to store;


BASIC_SPRITE:
        DI              ;DISABLE IM1 INTS
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        LD IY,(DEF_FN_PAR_ADDR)
        LD A,(IY+4)     ;FN CALL PARAMS
        AND %00011111   ;DRAW TYPE
        LD D,(IY+12)    ;X POSITION
        LD E,(IY+20)    ;Y POSITION
        LD B,(IY+28)    ;X SIZE
        LD C,(IY+36)    ;Y SIZE
        BIT 3,A         ;IF MASK
        JR Z,B_SPR_0
        LD L,(IY+60)    ;LOW PART MASK
        LD H,(IY+68)    ;HIGH PART MASK
        PUSH HL
        POP IX          ;IX = HL
B_SPR_0:LD L,(IY+44)    ;LOW ADDR
        LD H,(IY+52)    ;HIGH ADDR
        BIT 4,A         ;IF SAVE BG
        JR Z,B_SPR_1
        PUSH HL
        LD L,(IY+76)    ;IY BUFFER
        LD H,(IY+84)
        PUSH HL         ;IY = HL
        POP IY
        POP HL
B_SPR_1:CALL DRAW_SPRITE

        POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        EI              ;ENABLE IM1 INTS
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
;IY OPTIONAL ADDR FOR STORE SCREEN DATA.

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
