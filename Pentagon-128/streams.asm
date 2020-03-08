;WELCOME TO 8-BIT TEA PARTY!
;
;MAIN FILE FOR ASSEMBLER CODE ON STREAMS.
;WE USING PENTAGON-128K MODEL EMULATION.
;
;CPU:   Zilog Z80, 3.5HhZ, 1976.
;RAM:   48Kb, 128Kb With more memory.
;ROM:   16Kb, base and more with 128Kb.
;SCREEN:256x192 monohrome pixels,
;       32x24 color attributes.
;SOUND: 1-Bit beeper,
;       AY-3-8910 or YM2149F chip.
;CTRL:  Keybord and kempston joystick.

;ADRESS WIDTH:
;       16 BITS OR 0..64Kb OR #0000..#FFFF
;REGISTERS: 8-BIT PART OR 16-BIT AS PAIR.
;       AF - ACCUMULATOR AND FLAGS
;       BC - DATA/ADDR, FOR LOOPS
;       DE - DATA/ADDR, OPERAND HL
;       HL - 16-BIT ACCUMULATOR
;       I - INTERRUPT, R(DRAM).
;REGISTERS: 16-BIT ONLY.
;       IX - INDEX REGISTER.
;       IY - INDEX REGISTER.
;       SP - STACK POINTER.
;       PC - PROGRAM COUNTER.
;INTERRUPTS:
;       NMI - NON MASKABLE INTERRUPT.
;       IM0 - MASKABLE, HARDWARE.
;       IM1 - MASKABLE, STANDARD.
;       IM2 - MASKABLE, USER DEFINED.
;IM2 function [I] * 256 + [D]=255.

OPEN_CHANNEL    EQU #1601
PRINT_STRING    EQU #203C
SCREEN_PIXELS   EQU #4000       ;16384
SCREEN_ATTRIB   EQU #5800       ;22528
SCREEN_P_SIZE   EQU #1800       ;6Kb
SCREEN_A_SIZE   EQU #300        ;768Bytes
SCREEN_ATTRIB_H EQU #58
SCREEN_ATTRIB_L EQU #00
SCREEN_ADDR_TOP EQU #5B00
SCREEN_ATTR_WS  EQU #180        ;In words
SCREEN_PIX_WS   EQU #0C00       ;In words
SCR_A_MID_ADDR  EQU #5900       ;S+256
SCR_ATTR_SIZE_X EQU #20         ;32
SCR_ATTR_SIZE_Y EQU #18         ;24
SCR_A_PART_SIZE EQU #100        ;256 Bytes
FONT_SIZE       EQU #08         ;8x8
TIMER_FONT_SIZE EQU #58         ;88 bytes
FONT_CODE_START EQU #20         ;32 Space
IM2_PER_SEC     EQU #32         ;50 ints
SEC_PER_MIN     EQU #3C         ;60 secs
NUM_SYS_BASE    EQU #0A         ;DEC(10)
IM2_I_REG       EQU #5B
IM2_B_DATA      EQU #FF

        ORG #6000       ;START ADDRESS
        LD (ALASM_STACK),SP
        LD SP,(PROGRAM_STACK)
        PUSH DE
        LD DE,IM2
        CALL IM2_SETUP

;Stream 11. Print string, vertical scroll.

;SCROLL EFFECT FOR TEXT.

        LD D,%01000111
        LD E,#00
        CALL CLEAR_SCR
        LD A,#00
        OUT (#FE),A

        LD C,#0C        ;ANIMATION FRAMES
        LD IX,SCROLL_TXT
M_TXT_8:PUSH BC
        PUSH IX

        LD IX,TXT_ATTR_1
        LD B,#08
        LD DE,#0000
        LD HL,FONT_ENG
M_TXT_1:PUSH BC
        LD A,C          ;FROM COUNTER
        AND %00000111
        RLCA 
        RLCA 
        RLCA            ;TO PAPER ATTR
        OR %01000000    ;BRIGHT BIT
        LD B,A
        LD C,%01000000
        LD A,(IX+0)
        SCF 
        CALL PRINT_A_CHAR
        LD A,E
        ADD A,FONT_SIZE ;PLUS 8
        CP SCR_ATTR_SIZE_X
        JR NZ,M_TXT_2
        LD A,#00
        LD D,#10
M_TXT_2:LD E,A          ;NEXT POSITION
        INC IX
        POP BC
        DJNZ M_TXT_1
        POP IX          ;SCROLL TEXT

        LD IY,STRING_BUFFER
        ;LD IY,SCREEN_PIXELS
        LD HL,FONT_ENG
        LD D,#00
        LD E,%00100000  ;SCALE 2X
        LD BC,#0110
        CALL PRINT_STRING_WIN
        LD B,#10        ;LINE = 16PIXELS

M_TXT_7:PUSH BC
        LD HL,#4800     ;SECOND PART SCR
        LD DE,#4800
        LD A,#08        ;8 PARTS
M_TXT_6:PUSH AF
        PUSH HL
        LD A,#07        ;7 LINES
M_TXT_3:INC H           ;NEXT LINE
        PUSH DE
        PUSH HL
        LD BC,#0020     ;32 BYTES IN LINE
        LDIR 
        POP HL
        POP DE
        INC D
        DEC A           ;NEXT 7TH LINE
        JR NZ,M_TXT_3
        POP HL
        POP AF
        BIT 0,A         ;NEXT FRAM SCREEN
        JR Z,M_TXT_9
        HALT            ;PAUSE EVER 16PX
M_TXT_9:DEC A           ;LAST PART LINE
        JR NZ,M_TXT_4
        POP BC
        PUSH BC
        LD A,B
        CP #08          ;LOWER PART
        JR Z,M_TXT_A
        PUSH IY
        POP HL          ;COPY FROM BUFFER
        LD BC,#0100     ;NEXT LINE
        ADD IY,BC
        XOR A
        JR M_TXT_5
M_TXT_A:LD IY,STRING_BUFFER
        LD BC,#0020     ;NEXT LOWER PART
        ADD IY,BC
        PUSH IY
        POP HL          ;HL = IY
        XOR A
        JR M_TXT_5
M_TXT_4:LD BC,#0020
        ADD HL,BC
M_TXT_5:PUSH HL         ;LAST LINE
        LD BC,#0020
        LDIR 
        POP HL
        PUSH HL         ;DE = HL
        POP DE
        OR A            ;NEXT PART
        JR NZ,M_TXT_6

        POP BC
        DJNZ M_TXT_7    ;NEXT 16TH LINE
        LD BC,#0010
        ADD IX,BC
        POP BC          ;NEXT FRAME ANIM
        DEC C
        JP NZ,M_TXT_8

        JP TO_RET

;TESTING ALL WINDOW PRINT SCALES.

        LD IX,SCROLL_TXT
        LD IY,SCREEN_PIXELS
        LD B,#04
        LD C,%00000000
        LD H,SCR_ATTR_SIZE_Y
        LD L,SCR_ATTR_SIZE_X
P_WIN_1:PUSH BC
        PUSH HL
        LD DE,#0000
        LD A,C          ;SCALE
        RRCA 
        RRCA 
        RRCA            ;TO BITS 5,6
        OR E            ;ADD COORDINATE
        LD E,A
        PUSH HL         ;BC = SIZES
        POP BC          ;BC = HL
        LD HL,FONT_ENG
        CALL PRINT_STRING_WIN
        POP HL          ;HL = SIZES
        SRL H           ;SIZES TO SCALE
        SRL L
        POP BC
        LD A,#32
        CALL IM2_DELAY
        INC C
        DJNZ P_WIN_1

        JP TO_RET

        LD D,#02
        LD E,%01100010
        LD BC,#0102
        LD HL,FONT_ENG
        LD IX,STRING_TXT
        LD IY,SCREEN_PIXELS
        CALL PRINT_STRING_WIN

        JP TO_RET

;Testing function of address offsest from
;coordinates by D.Krapivin.

        LD DE,#0F00
        CALL OFFSET_ATTR

        LD DE,#0000
OFF_A_1:CALL OFFSET_ATTR
        INC E
        LD A,E
        CP SCR_ATTR_SIZE_X
        JR NZ,OFF_A_1
        LD E,#00
        INC D
        LD A,D
        CP SCR_ATTR_SIZE_Y
        JR NZ,OFF_A_1

        ;CALL PRINT_TEXT_SCALE
        ;CALL PRINT_CHARS_SCR
        ;CALL SCROLL_TEXT_ATTR
        ;CALL TIMER_ATTR_FONTS
        ;CALL TEXT_DYNAMIC_ATTR
        ;CALL CLEAR_SCR_FUNCS
        ;CALL IM2_PERFORMANCE
TO_RET: POP DE
        LD SP,(ALASM_STACK)
        RET 

;Global variables and data.

STR_HELLO       DEFB "Hello World!",0
PROGRAM_STACK   DEFW #5F00
ALASM_STACK     DEFW #0000

TXT_ATTR_1:     DEFB "8BITTEA!"

SCROLL_TXT:
        DEFB "   WELCOME TO   "
        DEFB "8-BIT TEA PARTY!"
        DEFB "                "
        DEFB " SLOW  VERTICAL "
        DEFB " SCROLL, USING  "
        DEFB " SIMPLE ADDRESS "
        DEFB " ARITHMETIC...  "
        DEFB "                "
        DEFB "HELLO TO ALL OUR"
        DEFB "  FRIENDS  AND  "
        DEFB "    VIEWERS!    "
        DEFB "                ",0

STRING_BUFFER:  DUP #0800       ;2Kb
                DEFB %10101010
                EDUP 

;Print text string to window.
;D      window coordinate Y[0..23];
;E      [BITS:]
;0..4   window coordinate X[0..31];
;5..6   scaling for font;
;7      reserved;
;B      window size Y[1..23];
;C      window size X[1..32];
;HL     address of font;
;IX     address of string;
;IY     address of screen or buffer.

PRINT_STRING_WIN:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX

        PUSH DE         ;SAVE COORDINATES
        PUSH BC         ;AND SIZES
        LD A,E          ;SCALE PARAMETER
        AND %01100000
        RLCA 
        RLCA 
        RLCA 
        OR A
        JR Z,PR_ST_2
        PUSH HL
        LD H,A          ;H SCALE
        LD A,E          ;ONLY COORDINATE
        AND %00011111
        LD E,A
PR_ST_1:SLA D           ;SCALE WINDOW
        SLA E           ;COORDINATES AND
        SLA B           ;SIZES X AND Y
        SLA C
        DEC H
        JR NZ,PR_ST_1
        POP HL          ;HL = FONT
PR_ST_2:
        LD A,B          ;CHECK Y SIZES
        OR A
        JR Z,PR_ST_3
        ADD A,D         ;PLUS COORDINATE
        LD D,A
        LD A,SCR_ATTR_SIZE_Y
        CP D            ;OUT OF SCREEN Y
        JR C,PR_ST_3
        LD A,C          ;CHECK X SIZES
        OR A
        JR Z,PR_ST_3    ;IF SIZE X = 0
        LD A,E
        ADD A,C
        LD E,A
        LD A,SCR_ATTR_SIZE_X
        CP E            ;OUT OF SCREEN X
        JR C,PR_ST_3
        JR PR_ST_4
PR_ST_3:POP BC          ;WINDOW INCORRECT
        POP DE
        JR PR_ST_0      ;EXIT

PR_ST_4:POP BC          ;RESTORE SOURCE
        POP DE          ;COORDINATES

PR_ST_7:PUSH BC         ;PRINT TEXT
        PUSH DE
PR_ST_6:LD A,(IX+0)     ;A = CHAR
        OR A            ;IF NULL CHAR
        JR Z,PR_ST_5
        PUSH BC
        PUSH IY
        POP BC          ;BC - BUFFER
        CALL PRINT_CHAR_AT
        POP BC
        INC IX          ;NEXT CHAR
        INC E
        DEC C
        JR NZ,PR_ST_6
        POP DE          ;NEXT LINE Y
        INC D
        POP BC
        DJNZ PR_ST_7
        JR PR_ST_0
PR_ST_5:POP DE          ;CORRECT STACK
        POP BC
PR_ST_0:POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;Convert char coordinates to address.
;DE     coordinates Y[0..23] and X[0..31];
;HL     address on screen.

OFFSET_ATTR:
        PUSH AF
        PUSH DE
        LD HL,#4000     ;#40 = %01000000
        LD A,D          ;CORRECT IF ONLY
        AND %00011000   ;BITS 3,4 SET TO 0
        ADD A,H
        LD H,A
        LD A,D
        AND %00000111
        LD D,A          ;L MUST BE 0
        SRL D           ;4 BYTES, 16 TACTS
        RR L            ;
        SRL D
        RR L
        SRL D
        RR L            ;12 BYTES AND
        ADD HL,DE       ;48 TACTS
        LD A,#FF
        LD (HL),A
        POP DE
        POP AF
        RET 

;Stream 10. Print text with scaling.

PRINT_TEXT_SCALE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        LD IX,STRING_TXT
        LD HL,FONT_ENG
        LD D,%00000001
        LD E,%01100000
        LD B,#04
STR_1:  PUSH BC
        LD A,(IX+0)
        LD BC,SCREEN_PIXELS
        CALL PRINT_CHAR_AT
        POP BC
        INC IX
        INC E
        DJNZ STR_1
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

STRING_TXT:     DEFB "8-BIT TEA PARTY!",0

;Stream 9. Print char at screen position.

PRINT_CHARS_SCR:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD A,FONT_CODE_START
        LD BC,SCREEN_PIXELS
        LD DE,#0000
        LD HL,FONT_ENG
PRC_S3: CALL PRINT_CHAR_AT
        INC A           ;NEXT CHAR
        CP #60
        JR NZ,PRC_S1
        LD A,FONT_CODE_START
PRC_S1: PUSH AF
        INC E           ;NEXT X
        LD A,E
        CP SCR_ATTR_SIZE_X
        JR NZ,PRC_S2
        XOR A           ;X = 0
        LD E,A
        INC D
        LD A,D          ;IF Y MAX
        CP SCR_ATTR_SIZE_Y
        JR NZ,PRC_S2
        POP AF
        JR PRC_S4
PRC_S2: POP AF
        JR PRC_S3       ;NEXT PRINT
PRC_S4: POP HL
        POP DE
        POP BC
        POP AF
        RET 

;Testing russian codepage.

        DEFB "??????????"

;Print char 8x8 pixels on screen.
;A      char to print;
;BC     address of screen(left-top);
;E      [BITS]:
;0..4   coordinate X [0..31];
;5..6   char scale [0..3] parameter:
;       0 - no scale;
;       1..3 - scale 2,4,8 pixel size;
;7      reserved;
;D      coordinate on screen Y [0..23];
;HL     address of font.

;EXAMPLE WITH DATA FONT TO SCREEN:
;01001101 SCALE 2: 00110000_11110011 PIX:4
;0100.... SCALE 4: 00001111_00000000_....
;SCALE: 0 - 8 PIXELS PER BYTE, X1.
;SCALE: 1 - 4 PIXELS PER BYTE, X2.

PRINT_CHAR_AT:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        PUSH DE         ;HL CHAR IN FONT
        EX DE,HL        ;THX TO D.KRAPIVIN
        SUB FONT_CODE_START
        LD L,A
        LD H,#00
; HACK FROM OUR VIEWERS LD H,#10
;FOR FIXED FONT ADDRESS.
        ADD HL,HL       ;CODE * 8 BYTES
        ADD HL,HL
        ADD HL,HL
        ADD HL,DE       ;ADD BASE ADDR
        PUSH HL         ;HL CLEAR
        POP IX          ;IX = FONT ADDR
        POP DE

        LD A,E          ;SCALE PARAMETER
        AND %01100000
        JR Z,P_CHR_1
        RLCA            ;A = 1..3 SCALE
        RLCA 
        RLCA 
        LD H,A          ;SAVE COUNTER
        LD L,A
        LD A,E
        AND %00011111   ;5 LOW BITS AS X
        LD E,A
P_CHR_2:SLA E           ;SCALE COORDINATES
        SLA D
        DEC H
        JR NZ,P_CHR_2
        LD A,L          ;RESTORE SCALE

P_CHR_1:LD L,A          ;CHECK COORDINATES
        LD A,D          ;COORDINATE Y
        CP SCR_ATTR_SIZE_Y
        JP NC,P_CHR_R
        LD A,E          ;COORDINATE X
        CP SCR_ATTR_SIZE_X
        JP NC,P_CHR_R
        LD A,L          ;SCALE

                        ;OFFSET OF SCREEN
        LD A,D          ;[0..23] 5 BITS
        AND %00011000   ;3,4 BITS 2K PART
        ADD A,B         ;2048 = 2^11
        LD B,A
        LD A,D
        AND %00000111   ;[0..7] * 32
        RRCA            ;5,6,7 BITS OFFS
        RRCA            ;CYCLE
        RRCA 
        ADD A,E         ;PLUS X POSITION
        ADD A,C         ;FROM BUFFER X
        JR NC,P_CHR_G
        INC B           ;INC H_BUFFER
P_CHR_G:LD C,A
        LD A,L          ;A = SCALE
        PUSH BC         ;BC CLEAR
        POP IY          ;IY = BUFFER ADDR

        LD H,#08        ;H = PIXS PER BYTE
        LD L,#01        ;L = CELLS ON CHAR
        OR A            ;AS 0 = DEFAULT X1
        JR Z,P_CHR_3
P_CHR_4:SRL H           ;DIV 2 PIXELS
        SLA L           ;MUL 2 CELLS
        DEC A           ;DEC COUNTER
        JR NZ,P_CHR_4

P_CHR_3:LD C,L          ;C = VERT CELLS
P_CHR_B:PUSH IY
        LD B,FONT_SIZE  ;B = LINES IN CELL
        LD A,L          ;FONT NEXT LINE
P_CHR_A:PUSH AF
        PUSH BC
        PUSH IY
        LD E,L          ;E = HORIZ CELLS
        LD A,(IX+0)     ;A = FONT DATA ROM
P_CHR_9:LD C,H          ;C = PIXS PER BYTE
        LD D,%00000000  ;D = DATA TO WRITE
P_CHR_8:LD B,L          ;FOR ONE BYTE
        RLCA            ;IF 7 IS BIT SET
        JR C,P_CHR_5
P_CHR_6:RL D            ;SAVE 0 AND ROLL
        DJNZ P_CHR_6
        JR P_CHR_7
P_CHR_5:SCF             ;SAVE 1 AND ROLL
        RL D
        DJNZ P_CHR_5
P_CHR_7:DEC C           ;NEXT PART OF BYTE
        JR NZ,P_CHR_8
        LD (IY+0),D
        INC IY          ;NEXT CELL
        DEC E
        JR NZ,P_CHR_9
        POP IY          ;MOVE TO LEFT BUF
        LD DE,#0100     ;NEXT LINE BUFFER
        ADD IY,DE       ;+256 BYTES OFFSET
        POP BC
        POP AF          ;IF NEED NEXT FONT
        DEC A
        JR NZ,P_CHR_C
        LD A,L          ;RESET COUNTER
        INC IX          ;NEXT FONT LINE
P_CHR_C:DJNZ P_CHR_A    ;NEXT LINE CELL
        POP IY
        LD DE,SCR_ATTR_SIZE_X
        ADD IY,DE       ;NEXT CELL BUFFER
        DEC C
        JR NZ,P_CHR_B

P_CHR_R:POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

TEXT_TO_SCROLL:
        DB "WELCOME TO 8-BIT TEA PARTY!  "
        DB "RETRO CODE FOR ZX SPECTRUM!  "
        DB "Z80 ASSEMBLER AND 8-BIT TEA! "
        DB "HELLO TO ALL OUR FRIENDS!    "

;Print character using colors attributes.
;A      character from 0..3;
;F[FLAGS]:
;C      is using next color on next line;
;BC     first color attribute and paper;
;DE     vertical and horizontal position;
;HL     address of font.

PRINT_A_CHAR:
        PUSH AF         ;SAVE REGS
        EX AF,AF'       ;SAVE AF'
        PUSH AF
        EX AF,AF'
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX         ;NO PERFORMANCE
        PUSH AF         ;AF' = AF
        EX AF,AF'       ;C FLAG FOR
        POP AF          ;NEXT COLOR
        EX AF,AF'
        PUSH DE
        EX DE,HL
        SUB FONT_CODE_START
        LD L,A
        LD H,#00
        ADD HL,HL       ;A(CHAR)*8
        ADD HL,HL
        ADD HL,HL
        ADD HL,DE
        PUSH HL
        POP IX          ;IX=HL=FONT CHAR
        POP DE
        LD H,FONT_SIZE  ;8 LINES
PRA_C3: PUSH DE
        PUSH BC
        LD L,FONT_SIZE  ;8 BITS(PIXELS)
PRA_C2: LD A,C
        RLC (IX+0)      ;IF BIT SET
        JR NC,PRA_C1    ;C-10110101
        LD A,B          ;COLOR
PRA_C1: CALL SET_ATTRIBUTE
        INC E
        DEC L
        JR NZ,PRA_C2
        POP BC
        EX AF,AF'
        JR NC,PRA_C5
        EX AF,AF'
        LD A,B          ;NEXT COLOR
        AND %11000111
        LD E,A          ;E OTHER BITS
        LD A,B          ;B=01011011
        AND %00111000   ;M=00111000
        ADD A,%00001000 ;R=00011000
        AND %00111000   ;MULTIPLY COMMON
        OR E            ;1+2=3 4+8=12
        LD B,A          ;NEW COLOR
        JR PRA_C4
PRA_C5: EX AF,AF'
PRA_C4: POP DE
        INC D           ;NEXT LINE
        INC IX
        DEC H           ;COUNTER LINE
        JR NZ,PRA_C3
        POP IX
        POP HL
        POP DE
        POP BC
        EX AF,AF'       ;AF' RESTORE
        POP AF
        EX AF,AF'
        POP AF
        RET 

;Testing simple and fast functions.

CLEAR_SCR_FUNCS:
        PUSH AF
        PUSH BC
        PUSH DE
        LD BC,#0100
        LD D,%01001111
        LD E,%10101010
CLRS_1: HALT 
        CALL CLEAR_SCR
        LD A,4
        OUT (#FE),A
        DEC BC
        LD A,B
        OR C
        JR NZ,CLRS_1
        LD BC,#0100
        LD D,%01101111
        LD E,%01010101
CLRS_2: HALT 
        CALL CLEAR_SCR_STACK
        LD A,4
        OUT (#FE),A
        DEC BC
        LD A,B
        OR C
        JR NZ,CLRS_2
        POP DE
        POP BC
        POP AF
        RET 

;Clear screen functon, pixels and attr.
;DE     attribute and pixel for fill.

CLEAR_SCR:
        PUSH AF
        PUSH BC
        PUSH HL
        LD HL,SCREEN_PIXELS
        LD BC,SCREEN_P_SIZE
CLR_1:  LD (HL),E       ;TACTS:11
        INC HL          ;6
        DEC BC          ;6
        LD A,B          ;4
        OR C            ;4
        JR NZ,CLR_1     ;12=43tacts
        LD BC,SCREEN_A_SIZE
CLR_2:  LD (HL),D       ;43*6912=297k
        INC HL
        DEC BC
        LD A,B
        OR C
        JR NZ,CLR_2
        POP HL
        POP BC
        POP AF
        RET 

;Clear screen fast, using stack.
;DE     attribute and pixel for fill.

CLEAR_SCR_STACK:
        PUSH AF
        PUSH BC
        PUSH HL
        PUSH IX
        LD BC,SCREEN_ATTR_WS
        LD IX,#0000
        ADD IX,SP       ;IX PROGRAM STACK
        LD SP,SCREEN_ADDR_TOP
        LD H,D
        LD L,D          ;TACTS:(37)
CLRF_1: PUSH HL         ;11
        DEC BC          ;6
        LD A,B          ;4
        OR C            ;4
        JR NZ,CLRF_1    ;12
        LD BC,SCREEN_PIX_WS
        LD H,E          ;37*3456=128k
        LD L,E
CLRF_2: PUSH HL
        DEC BC
        LD A,B
        OR C
        JR NZ,CLRF_2
        LD SP,IX
        POP IX
        POP HL
        POP BC
        POP AF
        RET 

;Setup IM2 interrupt mode and function.
;DE     address function to call AT 1/50s.

IM2_SETUP:
        DI 
        PUSH AF
        PUSH HL
        LD H,IM2_I_REG  ;HL - IM2 ADDR
        LD L,IM2_B_DATA
        LD A,H
        LD I,A          ;I - IM2
        LD DE,IM2
        LD (HL),E
        INC HL
        LD (HL),D       ;[IM2] - ADDR
        POP HL
        POP AF
        IM 2
        EI 
        RET 

;Delay in 1/50 seconds, only with IM2.
;A      delay in 1/50, 50 for 1 second.

IM2_DELAY:
        PUSH AF
DELAY_1:HALT 
        DEC A
        JR NZ,DELAY_1
        POP AF
        RET 

;Interrupt function, called every 1/50sec.

IM2:    DI 
        PUSH AF
        ;LD A,1
        ;OUT (#FE),A
        POP AF
        EI 
        RETI 

;Set attribute on screen at coordinates.
;A      attribute[bits]:
;0..3   Ink,
;4..6   Paper,
;5      Bright,
;6      Flash,
;DE     Vertical and horizontal
;       coordinates [0..23] and [0..31].

SET_ATTRIBUTE:
        PUSH DE         ;Y AND X -> OFFSET
        PUSH AF         ;Y * 32 + X=16BITS
        LD A,D          ;NO CHECK
        AND %00000111   ;Y=00010100
        RRCA 
        RRCA 
        RRCA 
        OR E
        LD E,A          ;E LOW OFFSET
        LD A,D
        AND %00011000
        RRCA            ;D HIGH OFFSET
        RRCA 
        RRCA 
        OR SCREEN_ATTRIB_H
        LD D,A          ;#58=01011000
        POP AF
        LD (DE),A
        POP DE
        RET 

ALL_FONTS_DATA: INCLUDE "FONTS.A",0
