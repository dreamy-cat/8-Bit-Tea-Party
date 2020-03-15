;LIBRARY AND CODE MODULE FOR BASIC.
;USING IN 48K MODE ON DEFINED ADDRESS.

;GLOBAL SETTINGS

START_ADDRESS   EQU #8000

;GLOBAL CONSTANTS AND VARIABLES.
;WILL CHANGE LATER.

SCREEN_X_SIZE   EQU #20         ;32 ATTRIB
SCREEN_Y_SIZE   EQU #18         ;24 ATTRIB
SCREEN_ADDR     EQU #4000       ;STANDARD


        ORG START_ADDRESS

        JR CONFIGURE_CALL       ;TEMPORARY

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

CONFIGURE_CALL:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        LD IX,CONFIG_TABLE
        LD A,(IX+2)     ;TYPE MOVE
        LD C,(IX+3)     ;COORDINATES
        LD B,(IX+4)     ;CHANGE ORDER!
        LD E,(IX+5)
        LD D,(IX+6)
        LD L,(IX+7)
        LD H,(IX+8)
        CALL DRAW_SPRITE

        POP IY
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
