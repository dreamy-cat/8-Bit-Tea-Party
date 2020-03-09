;WELCOME TO 8-BIT TEA PARTY!
;
;MAIN FILE FOR ASSEMBLER CODE ON STREAMS.
;WE USING PENTAGON-128K MODEL EMULATION.
;
;CPU:   Zilog Z80, 3.5MhZ, 1976.
;RAM:   48Kb BASE, 128Kb WITH MORE MEMORY.
;ROM:   16Kb base and more with 128Kb.
;SCREEN:256x192 PIXELS IN MONOCHROME.
;       32x24 COLOR ATTRIBUTES.
;SOUND: 1-Bit beeper,
;       AY-3-8910 or YM2149F CHIP.
;CTRL:  Keyboard and Kempston joystick.
;
;ADDRESS WIDTH:
;       16 BITS OR 0..64Kb OR #0000..#FFFF
;REGISTERS: 8-BIT PART OR 16-BIT AS PAIR.
;       AF - ACCUMULATOR AND FLAGS
;       BC - DATA/ADDR, FOR LOOPS.
;       DE - DATA/ADDR, OPERAND WITH HL.
;       HL - 16-BIT ACCUMULATOR.
;       AF',BC',DE',HL' - ALTERNATE.
;       I - INTERRUPT, R(DRAM).
;REGISTERS: 16-BIT ONLY.
;       IX,IY - 16-BIT INDEX REGISTERS.
;       SP - STACK POINTER.
;       PC - PROGRAM COUNTER.
;INTERRUPTS:
;       NMI - NON MASKABLE INTERRUPT.
;       IM0 - MASKABLE, HARDWARE.
;       IM1 - MASKABLE, STANDARD.
;       IM2 - MASKABLE, USER DEFINED.

;GLOBAL NAMES AND CONSTANTS.

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
FONT_CODE_START EQU #00         ;32 Space
IM2_PER_SEC     EQU #32         ;50 ints
SEC_PER_MIN     EQU #3C         ;60 secs
NUM_SYS_BASE    EQU #0A         ;DEC(10)
IM2_I_REG       EQU #5B
IM2_B_DATA      EQU #FF

KEMPSTON_PORT   EQU #1F         ;PORT 31
KEMPSTON_MASK   EQU %00011111   ;5 BITS
KEMPSTON_RIGHT  EQU #00         ;N OF BIT
KEMPSTON_LEFT   EQU #01
KEMPSTON_DOWN   EQU #02
KEMPSTON_UP     EQU #03
KEMPSTON_FIRE   EQU #04

PRINT_STRING    EQU #203C
OPEN_CHANNEL    EQU #1601

        ORG #6000       ;START ADDRESS
        LD (ALASM_STACK),SP
        LD SP,(PROGRAM_STACK)
        PUSH DE
        LD DE,IM2
        CALL IM2_SETUP

        LD A,"а"
        LD D,#00
        LD E,%01100000
        LD HL,PRESS_START_2P
        LD BC,#0608
FNT_2:  PUSH BC
FNT_1:  PUSH BC
        LD BC,SCREEN_PIXELS
        CALL PRINT_CHAR_AT
        POP BC
        INC A           ;LAST CHAR
        JR Z,FNT_0
        INC E
        DEC C
        JR NZ,FNT_1
        POP BC
        LD E,%01100000
        INC D
        DJNZ FNT_2
FNT_0:
        ;CALL PRINT_AND_SCROLL
        ;CALL PRINT_STR_SCALE
        ;CALL PRINT_CHARS_SCR
        ;CALL SCROLL_TEXT_ATTR
        ;CALL TIMER_ATTR_FONT
        ;CALL TEXT_DYNAMIC_COLORS
        ;CALL FILL_SCR_ATTRIB
        ;CALL IM2_PERFORMANCE
;       ;CALL DYNAMIC_COLOR_TABLE

TO_RET: POP DE
        LD SP,(ALASM_STACK)
        RET 

;GLOBAL VARIABLES AND DATA.

PROGRAM_STACK   DEFW #5F00
ALASM_STACK     DEFW #0000
STR_HELLO       DEFB "Hello World!",0
KEMPSTON        DB #00

;Stream 11. Scroll text on screen, music.

PRINT_AND_SCROLL:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        ;CALL SCROLL_SCREEN
        ;CALL PRINT_CHARS_SCR

;MAIN STREAM SHOW EFFECT OF TEXT MOVE UP.

        LD D,%01000111
        LD E,#00
        CALL CLEAR_SCR

;ROLL MID SCREEN.

        LD C,#0C        ;ANIMATION
        LD IX,STRING_TXT
M_TXT_9:PUSH BC
        PUSH IX
;PRINT STRING TO BUFFER, DRAW OUR ATTR.

        LD IX,TXT_ATTR_1
        LD B,#08
        LD DE,#0000
        LD HL,FONT_ENG
M_TXT_1:PUSH BC
        LD A,C          ;FROM COUNTER
        AND %00000111
        RLCA 
        RLCA 
        RLCA 
        OR %01000000
        LD B,A
        LD C,%01000000
        LD A,(IX+0)
        SCF 
        CALL PRINT_A_CHAR
        LD A,E
        ADD A,FONT_SIZE
        CP #20          ;IN LINE
        JR NZ,M_TXT_2
        LD A,#00
        LD D,#10
M_TXT_2:LD E,A
        INC IX
        POP BC
        DJNZ M_TXT_1

        POP IX

        LD IY,STRING_BUFFER
        LD HL,FONT_ENG
        LD D,#00
        LD E,%00100000  ;SCALE 2X
        LD BC,#0110
        CALL PRINT_STRING_WIN
        ;LD IY,STRING_BUFFER
        LD B,#10        ;ONE LINE
M_TXT_7:PUSH BC
        LD HL,#4800     ;MID SCREEN
        LD DE,#4800
        LD A,#08        ;8 PARTS
M_TXT_6:PUSH AF
        PUSH HL
        LD A,#07        ;7 LINES
        ;OUT (#FE),A
M_TXT_3:INC H
        PUSH DE
        PUSH HL         ;MOVE LINE
        LD BC,#0020
        LDIR 
        POP HL
        POP DE
        INC D
        DEC A
        JR NZ,M_TXT_3   ;NEXT 7TH LINE
        POP HL
        POP AF
        BIT 0,A         ;NEXT FRAME
        JR Z,M_TXT_8
        HALT            ;PAUSE EVERY 16
M_TXT_8:DEC A           ;LAST PART LINE
        JR NZ,M_TXT_4
        POP BC          ;TAKE B LINE FONT
        PUSH BC
        LD A,B
        CP #08
        JR Z,M_TXT_A
        PUSH IY         ;FROM BUFFER
        POP HL
        LD BC,#0100     ;NEXT LINE
        ADD IY,BC
        XOR A           ;RESTORE ZERO
        JR M_TXT_5
M_TXT_A:LD IY,STRING_BUFFER
        LD BC,#0020
        ADD IY,BC
        PUSH IY
        POP HL
        XOR A           ;RESTORE ZERO
        JR M_TXT_5
M_TXT_4:LD BC,#0020
        ADD HL,BC
M_TXT_5:PUSH HL
        LD BC,#0020
        LDIR            ;LAST LINE
        POP HL
        PUSH HL
        POP DE
        OR A            ;NEXT PART
        JR NZ,M_TXT_6
        POP BC
        ;LD A,#04
        ;OUT (#FE),A
        DJNZ M_TXT_7
        LD BC,#0010
        ADD IX,BC
        POP BC          ;NEXT FRAME
        DEC C
        JP NZ,M_TXT_9

        JP PR_SC_0

;TESTING TO SHOW ALL CHARS ON SCREEN.

        ;JP TST_S

        LD IX,STRING_TXT
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
        RRCA 
        OR E
        LD E,A          ;ADD SCALE
        PUSH HL
        POP BC
        LD HL,FONT_ENG
        CALL PRINT_STRING_WIN
        POP HL
        SRL H           ;SIZES TO SCALE
        SRL L
        POP BC
        LD A,#32
        CALL IM2_DELAY
        INC C           ;NEXT SCREEN
        DJNZ P_WIN_1

        JP PR_SC_0

;TESTING AFTER SIMPLE FUNCTION.

TST_S:  LD D,#00
        LD E,%00000000  ;10
        LD BC,#1020
        LD HL,FONT_ENG
        LD IX,STRING_TXT
        ;LD IY,SCREEN_PIXELS
        LD IY,STRING_BUFFER
        CALL PRINT_STRING_WIN
        JP TO_RET

        LD A," "
        LD D,#00
        LD E,%00000000
        LD BC,#0C10
        LD HL,FONT_ENG

TST_3:  PUSH BC
        PUSH DE
TST_1:  PUSH BC
        LD BC,SCREEN_PIXELS
        CALL PRINT_CHAR_AT
        POP BC
        INC A
        CP #60
        JR NZ,TST_2
        LD A," "
TST_2:  INC E
        DEC C
        JR NZ,TST_1
        POP DE
        INC D
        POP BC
        DJNZ TST_3

        JP PR_SC_0

;Testing function of address offset from
;coordinates by D.Krapivin.

        LD DE,#0F00     ;TEST INCORRECT
        CALL OFFSET_ATTR
        JP TO_RET

        LD DE,#0000     ;NORMAL TEST
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

PR_SC_0:POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

TXT_ATTR_1:     DEFB "8BITTEA!"

STRING_TXT:
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
;               DEFB %01010101
;               DEFB %00000000
;               DEFB %00000000
                EDUP 

;Part only in draft, to save history.

SCROLL_SCREEN:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY

        ;LD HL,STRING_BUFFER
        ;LD DE,SCREEN_PIXELS
        ;LD BC,#0200
        ;LDIR

        LD A,%01111000
        LD HL,FONT_ENG
        LD IX,STRING_TXT
        LD IY,SCREEN_PIXELS
        ;LD IY,STRING_BUFFER
        LD BC,#1802
        LD D,#00
        LD E,%10000000
        ;CALL PRINT_STRING_WIN

        LD B,#01        ;ANIMATION
S_SCR_7:HALT 
        PUSH BC
        LD HL,SCREEN_PIXELS
        LD DE,SCREEN_PIXELS
        LD C,#01                ;PARTS
S_SCR_8:PUSH BC
        LD A,C
        CPL 
        AND %00000011   ;ONLY PART
        RLCA 
        RLCA 
        RLCA 
        LD B,A
        LD A,H          ;NEXT PART 2K
        AND %11100111
        OR B
        LD H,A
        LD L,#00
        LD A,#08        ;PARTS OF 2K

S_SCR_6:PUSH AF         ;CYCLE
        PUSH HL
        LD A,#07
        ;HALT
S_SCR_5:INC H           ;HL = NEXT LINE
        PUSH HL
        PUSH DE
        LD BC,#0020
        LDIR            ;MOVE 7 LINES
        POP DE
        INC D           ;NEXT LINE
        POP HL
        DEC A
        JR NZ,S_SCR_5
        POP HL
        POP AF          ;PARTS OF 2K
        CP #01
        JR NZ,S_SCR_9
        LD BC,#720      ;LAST LINE OF 2K
        JR S_SCR_A
S_SCR_9:LD BC,#0020     ;MOVE 8TH LINE
S_SCR_A:ADD HL,BC
        PUSH HL
        PUSH HL
        LD BC,#0020
        LDIR 
        POP HL          ;DE = HL
        POP DE          ;
        DEC A
        JR NZ,S_SCR_6   ;NEXT 8 LINES
        POP BC
        DEC C
        JR NZ,S_SCR_8   ;NEXT 2K PART
        POP BC
        LD A,#07
        OUT (#FE),A
        DEC B
        JR NZ,S_SCR_7   ;NEXT FRAME

        POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;Print text string to window with color.
;Scale factor only for font.
;D      window coordinate Y[0..23];
;E      [BITS]:
;0..4   window coordinate X[0..31];
;5..6   scaling for font;
;7      reserved;
;B      window size Y[1..24];
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

        PUSH DE         ;SAVE SOURCE
        PUSH BC         ;COORDINATES
        LD A,E          ;SCALE
        AND %01100000   ;PARAMETER
        RLCA 
        RLCA 
        RLCA 
        OR A
        JR Z,PR_ST_2
        PUSH HL
        LD H,A
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

PR_ST_2:LD A,B          ;CHECK Y SIZES
        OR A
        JR Z,PR_ST_3    ;IF SIZE Y = 0
        ADD A,D
        LD D,A
        LD A,SCR_ATTR_SIZE_Y
        CP D            ;OUT OF SCREEN
        JR C,PR_ST_3
        LD A,C          ;CHECK X SIZES
        OR A
        JR Z,PR_ST_3    ;IF SIZE X = 0
        LD A,E
        ADD A,C
        LD E,A
        LD A,SCR_ATTR_SIZE_X
        CP E            ;OUT OF SCREEN
        JR C,PR_ST_3
        JR PR_ST_4      ;SIZES OK
PR_ST_3:POP BC          ;WINDOW INCORRECT
        POP DE
        JP PR_ST_0      ;EXIT
PR_ST_4:POP BC          ;RESTORE SOURCE
        POP DE          ;COORDINATES

PR_ST_7:PUSH BC         ;PRINT TEXT
        PUSH DE
PR_ST_6:LD A,(IX+0)
        OR A            ;IF NULL CHAR
        JR Z,PR_ST_5
        PUSH BC         ;ABOUT INTERFACE
        PUSH IY
        POP BC
        CALL PRINT_CHAR_AT
        POP BC
        INC IX
        INC E           ;NEXT CHAR
        DEC C
        JR NZ,PR_ST_6
        POP DE
        INC D           ;NEXT LINE
        POP BC
        DJNZ PR_ST_7
        JR PR_ST_0
PR_ST_5:POP DE          ;NULL CHAR
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

        LD HL,#4800
        LD A,D
        AND %00011000   ;CORRECT IF ONLY
        ADD A,H         ;BITS 3,4 SET TO 0
        LD H,A
        LD A,D
        AND %00000111
        SRL D           ;L MUST BE 0
        RR L            ;4 BYTES, 16 TACTS
        SRL D
        RR L
        SRL D
        RR L            ;12 BYTES
        ADD HL,DE       ;48 TACTS

        LD A,#FF
        LD (HL),A

        POP DE
        POP AF
        RET 

;Stream 10. Print string with scaling.

PRINT_STR_SCALE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        ;LD HL,FONT_ENG
        ;LD BC,SCREEN_PIXELS
        ;LD A,48
        ;CALL PRINT_CHAR_AT
        LD IX,STRING_TXT
        LD B,#03
        LD HL,FONT_ENG
        LD D,%00000011
        LD E,%00111111
STR_1:  PUSH BC
        LD BC,SCREEN_PIXELS
        LD A,(IX+0)
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

;Stream 9. Print chars at screen position.

PRINT_CHARS_SCR:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD A,FONT_CODE_START
        LD DE,#0000
        LD BC,SCREEN_PIXELS
        LD HL,FONT_ENG
PRC_S3: CALL PRINT_CHAR_AT
        INC A
        CP #60
        JR NZ,PRC_S1
        LD A,FONT_CODE_START
PRC_S1: PUSH AF
        INC E
        LD A,E
        CP SCR_ATTR_SIZE_X
        JR NZ,PRC_S2
        XOR A
        LD E,A
        INC D
        LD A,D
        CP SCR_ATTR_SIZE_Y
        JR NZ,PRC_S2
        POP AF
        JR PRC_S4
PRC_S2: POP AF
        JR PRC_S3
PRC_S4: POP HL
        POP DE
        POP BC
        POP AF
        RET 

;Testing russian codepage.

        DEFB "йцукенгшщз"
        DEFB "фывапролд;'"
        DEFB "ячсмить,./"
        DEFB "бэЭхжЖ-+=;'"
        DEFB "<>ХБ;"
        DEFB ":ю?/*,.,"

;Print char 8x8 pixels on screen.
;Using scaling and
;A      char to print;
;BC     address of screen(left-top);
;E      [BITS]:
;0..4   coordinate on screen X [0..23];
;5..6   char scale [0..3] parameter:
;       0 - no scale;
;       1..3 - scale 2,4,8 pixel size;
;7      reserved;
;D      coordinate on screen Y [0..31];
;HL     address of font.

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
;LD H,#HIGH PART OF FONT ADDRESS.
;       LD H,#10        ;#10 TO #8000

        LD H,#00
        ADD HL,HL       ;MULTIPLY 8
        ADD HL,HL
        ADD HL,HL
        ADD HL,DE       ;ADD BASE ADDR
        PUSH HL
        POP IX          ;IX = FONT ADDR
        POP DE          ;HL CLEAR

;OPTIMIZATION

        LD A,E          ;SCALE
        AND %01100000   ;PARAMETER
        JR Z,P_CHR_2    ;IF NO SCALE
        RLCA            ;SCALE PARAMETER
        RLCA 
        RLCA 
        LD H,A          ;SAVE COUNTER
        LD L,A
        LD A,E
        AND %00011111   ;ONLY COORDINATES
        LD E,A
P_CHR_3:SLA E           ;SCALE COORDINATES
        SLA D
        DEC H
        JR NZ,P_CHR_3   ;NEXT
        LD A,L
P_CHR_2:
        LD L,A          ;CHECK COORDINATES
        LD A,D          ;FIX C
        CP SCR_ATTR_SIZE_Y
        JP NC,P_CHR_R
        LD A,E
        CP SCR_ATTR_SIZE_X
        JP NC,P_CHR_R
        LD A,L

;USING L REGISTER

;       PUSH AF         ;SAVE SCALE
        LD A,D          ;[0..23]
        AND %00011000   ;3,4 BITS 2K PART
        ADD A,B
        LD B,A
        LD A,D
        AND %00000111   ;[0..7] * 32
        RRCA            ;5,6,7 BITS OFFS
        RRCA            ;CYCLE
        RRCA            ;12 TACTS, 3 BYTES
        ADD A,E         ;PLUS X POSITION
        ADD A,C         ;LOW PART BASE
        JR NC,P_CHR_G
        INC B           ;CARRY ONE BIT
P_CHR_G:LD C,A          ;BC OFFSET BUFFER
        LD A,L
        PUSH BC         ;BC CLEAR
        POP IY          ;IY = ADDR BUFFER

;       LD A,#FF        ;TEST
;       LD (IY+0),A
;       JR P_CHR_R

;0 = 8, 1 = 4, 2 = 1, 3 = 0

        LD H,#08        ;H = PIXS PER BYTE
        LD L,#01        ;L = CELLS ON CHAR
        OR A            ;AS 0 = DEFAULT 1
        JR Z,P_CHR_C
P_CHR_4:SRL H           ;DIV 2 PIXELS
        SLA L           ;MUL 2 CELLS
        DEC A
        JR NZ,P_CHR_4   ;NEXT SCALE
P_CHR_C:
        LD C,L          ;C = VERT CELLS
P_CHR_B:PUSH IY
        LD B,FONT_SIZE  ;B = LINES IN CELL
        LD A,L          ;FONT NEXT LINE
P_CHR_A:PUSH AF
        PUSH BC
        PUSH IY
        LD E,L          ;E = HORIZ CELLS
        LD A,(IX+0)     ;A = FONT DATA ROM
P_CHR_9:LD C,H          ;C = PIXS PER BYTE
        LD D,#00        ;D = DATA TO WRITE
P_CHR_8:LD B,L          ;FOR ONE BYTE
        RLCA            ;TAKE 7 BIT
        JR C,P_CHR_5    ;IF BIT SET
P_CHR_6:RL D            ;SAVE 0 AND ROLL
        DJNZ P_CHR_6
        JR P_CHR_7
P_CHR_5:SCF             ;SAVE 1 AND ROLL
        RL D
        DJNZ P_CHR_5
P_CHR_7:DEC C           ;NEXT PART OF BYTE
        JR NZ,P_CHR_8
        LD (IY+0),D     ;WRITE DATA BUFFER
        INC IY
        DEC E
        JR NZ,P_CHR_9   ;NEXT HORIZ CELL
        POP IY
        LD DE,#0100     ;NEXT LINE BUFFER
        ADD IY,DE
        POP BC
        POP AF
        DEC A           ;DEC FNT COUNTER
        JR NZ,P_CHR_F
        LD A,L          ;RESET COUNTER
        INC IX          ;NEXT FONT LINE
P_CHR_F:DJNZ P_CHR_A    ;NEXT LINE CELL
        POP IY
        LD DE,#0020     ;NEXT CELL BUFFER
        ADD IY,DE
        DEC C
        JR NZ,P_CHR_B

P_CHR_R:POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

IM2_COUNTER     DB #00  ;SIMPLE COUNTER
TIMER_L_SEC     DB #00  ;SECONDS
TIMER_H_SEC     DB #00  ;10TH SECONDS

;Print character using colors attributes.
;A[BITS]:
;0..7   character from '0'..'9' and ':',
;F      [FLAGS]:
;C      is using next color on next line;
;BC     first color attribute and paper;
;DE     vertical and horizontal position;
;HL     address of font with starting '0'.

PRINT_A_CHAR:
        PUSH AF         ;Save registers
        EX AF,AF'       ;USING IN PROGRAM
        PUSH AF
        EX AF,AF'
        PUSH BC
        PUSH DE
        PUSH HL         ;No performance
        PUSH IX

        PUSH AF         ;AF' = AF
        EX AF,AF'       ;C FLAG FOR
        POP AF          ;NEXT COLOR
        EX AF,AF'

        PUSH DE
        EX DE,HL
        SUB FONT_CODE_START
        LD L,A
        LD H,#00        ;CHAR * 8
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        ADD HL,DE
        PUSH HL         ;HL = CHAR
        POP IX          ;IX = HL
        POP DE

        LD H,FONT_SIZE
PRA_C3: PUSH DE         ;SAVE COORDS
        PUSH BC
        LD L,FONT_SIZE  ;BITS IN LINE
PRA_C2: LD A,C          ;BACKGROUND
        RLC (IX+0)      ;HIGH -> LOW
        JR NC,PRA_C1
        LD A,B
PRA_C1: CALL SET_ATTRIBUTE
        INC E           ;NEXT COLUMN
        DEC L
        JR NZ,PRA_C2
        POP BC
        EX AF,AF'       ;IF NEXT COLOR
        JR NC,PRA_C5
        EX AF,AF'
        LD A,B          ;NEXT PAPER COLOR
        AND %11000111   ;INVERT MASK
        LD E,A          ;SAVE
        LD A,B
        AND %00111000   ;PAPER
        ADD A,%00001000 ;MULTIPLY COMMON
        AND %00111000   ;ONLY PAPER
        OR E            ;WITH OTHER BITS
        LD B,A          ;NEW COLOR
        JR PRA_C4
PRA_C5: EX AF,AF'       ;MAIN AF
PRA_C4: POP DE
        INC D           ;NEXT LINE
        INC IX
        DEC H
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

;Interrupt function, called every 1/50sec.

IM2:    DI 
        PUSH AF
        LD A,1
        OUT (#FE),A
        IN A,(KEMPSTON_PORT)
        AND KEMPSTON_MASK
        LD (KEMPSTON),A
        LD A,(IM2_COUNTER)
        INC A
        LD (IM2_COUNTER),A
IM2_0:  POP AF
        EI 
        RETI 

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
        ;LD DE,IM2      ;CLEAR!
        LD (HL),E
        INC HL
        LD (HL),D       ;[IM2] - ADDR
        POP HL
        POP AF
        IM 2
        EI 
        RET 

;DATA AND OTHER INCLUDES.

LIBRARY:        INCLUDE "STR_LIB.A",1

ALL_FONTS_DATA: INCLUDE "FONTS.A",0
