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

;Stream 8. Scrolling text, with our font.

        LD D,%01000111
        LD E,%00000000
        CALL CLEAR_SCR
        LD A,#00
        OUT (#FE),A

        LD IX,TEXT_TO_SCROLL
        LD A,#75        ;SCROLL LENGTH
SCR_TA7:PUSH AF
        ;LD DE,SCR_A_MID_ADDR
        LD DE,SCROLL_BUFFER

        PUSH BC
        PUSH DE

        LD A,(IX+0)     ;THX TO D.KRAPIVIN
        LD BC,FONT_ENG  ;FOR OPTIMIZATION
        SUB FONT_CODE_START
        AND %00111111   ;MASK
        LD L,A
        LD H,#00
        LD A,#03        ;2 ^ 3 = 8
SCR_TA2:SLA L           ;OFFSET
        JR NC,SCR_TA1   ;CARRY
        RL H            ;IF MORE THAN 256
SCR_TA1:DEC A
        JR NZ,SCR_TA2
        ADD HL,BC       ;FONT OFFSET

        LD B,FONT_SIZE  ;WRITE CHAR
        LD C,B          ;TO BUFFER
SCR_TA6:PUSH BC
        PUSH DE
SCR_TA5:RLC (HL)        ;GET FLAG
        JR NC,SCR_TA3   ;IF NOT PAPER
        LD A,(ATTR_SCR_P)
        JR SCR_TA4
SCR_TA3:LD A,(ATTR_SCR_B)
SCR_TA4:LD (DE),A
        INC DE
        DJNZ SCR_TA5

        LD A,(ATTR_SCR_P)
        LD D,A          ;NEXT COLOR
        AND %11000111   ;OTHERS
        LD E,A
        LD A,D
        AND %00111000   ;PAPER
        ADD A,%00001000 ;+8 OR 1 COLOR
        AND %00111000
        OR E
        LD (ATTR_SCR_P),A

        POP DE
        ;LD C,SCR_ATTR_SIZE_X   ;B = 0!
        LD C,FONT_SIZE
        EX DE,HL
        ADD HL,BC       ;NEXT LINE BUF
        EX DE,HL
        INC HL          ;NEXT LINE FONT
        POP BC
        DEC C
        JR NZ,SCR_TA6   ;NEXT LINE
        POP DE
        POP BC

        LD H,FONT_SIZE
        LD IY,SCROLL_BUFFER
        PUSH IX
SCR_TA9:LD A,#02                ;NOT FAST
        CALL IM2_DELAY
        PUSH HL
        LD HL,SCR_A_MID_ADDR    ;SOURCE
        LD DE,SCR_A_MID_ADDR    ;DEST
        INC HL
        LD BC,SCR_A_PART_SIZE   ;COUNTER
        LDIR                    ;MOVE
        POP HL
        PUSH IY         ;ONLY FOR STREAM
        PUSH HL         ;MOVE FROM BUFFER
        LD IX,SCR_A_MID_ADDR
        LD DE,SCR_ATTR_SIZE_X
        ADD IX,DE
        DEC IX          ;SCR DESTINATION
        LD BC,FONT_SIZE
        LD L,FONT_SIZE  ;DE SOURCE
SCR_TA8:LD A,(IY+0)     ;19 TACTS
        LD (IX+0),A
        ADD IX,DE       ;15 TACTS + 32
        ADD IY,BC       ;NEXT LINE + 8
        DEC L
        JR NZ,SCR_TA8   ;NEXT LINE BUF

        POP HL
        POP IY
        INC IY          ;NEXT COLUMN BUF

        ;LD A,#04       ;GREEN
        ;OUT (#FE),A

        DEC H           ;NEXT SHIFT
        JR NZ,SCR_TA9
        POP IX
        INC IX          ;NEXT CHAR


        POP AF
        DEC A
        JP NZ,SCR_TA7

        ;CALL TIMER_ATTR_FONTS
        ;CALL TEXT_DYNAMIC_ATTR
        ;CALL CLEAR_SCR_FUNCS
        ;CALL IM2_PERFORMANCE
TO_RET: POP DE
        LD SP,(ALASM_STACK)
        RET 

;Global variables and data.

STR_HELLO       DEFB "Hello World!",0
PROGRAM_STACK   DEFW #6000
ALASM_STACK     DEFW #0000
;SCROLL COLORS
ATTR_SCR_P      DB %01001000    ;WHITE
ATTR_SCR_B      DB %01000000    ;BLUE

SCROLL_BUFFER   DUP 64
                DB %01001000
                EDUP 

TEXT_TO_SCROLL:
        DB "WELCOME TO 8-BIT TEA PARTY!  "
        DB "RETRO CODE FOR ZX SPECTRUM!  "
        DB "Z80 ASSEMBLER AND 8-BIT TEA! "
        DB "HELLO TO ALL OUR FRIENDS!    "

FONT_ENG:
        DB #00,#00,#00,#00,#00,#00,#00,#00
        DB #38,#38,#38,#30,#30,#00,#30,#00
        DB #00,#6C,#6C,#6C,#00,#00,#00,#00
        DB #6C,#FE,#6C,#6C,#6C,#FE,#6C,#00
        DB #10,#7C,#D0,#7C,#16,#FC,#10,#00
        DB #62,#A4,#C8,#10,#26,#4A,#8C,#00
        DB #70,#D8,#D8,#70,#DA,#CC,#7E,#00
        DB #30,#30,#30,#00,#00,#00,#00,#00
        DB #0C,#18,#30,#30,#30,#18,#0C,#00
        DB #60,#30,#18,#18,#18,#30,#60,#00
        DB #00,#6C,#38,#FE,#38,#6C,#00,#00
        DB #00,#18,#18,#7E,#18,#18,#00,#00
        DB #00,#00,#00,#00,#00,#30,#30,#60
        DB #00,#00,#00,#7E,#00,#00,#00,#00
        DB #00,#00,#00,#00,#00,#30,#30,#00
        DB #02,#04,#08,#10,#20,#40,#80,#00
        DB #38,#4C,#C6,#C6,#C6,#64,#38,#00
        DB #18,#38,#18,#18,#18,#18,#7E,#00
        DB #7C,#C6,#0E,#3C,#78,#E0,#FE,#00
        DB #7E,#0C,#18,#3C,#06,#C6,#7C,#00
        DB #1C,#3C,#6C,#CC,#FE,#0C,#0C,#00
        DB #FC,#C0,#FC,#06,#06,#C6,#7C,#00
        DB #3C,#60,#C0,#FC,#C6,#C6,#7C,#00
        DB #FE,#C6,#0C,#18,#30,#30,#30,#00
        DB #78,#C4,#E4,#78,#9E,#86,#7C,#00
        DB #7C,#C6,#C6,#7E,#06,#0C,#78,#00
        DB #00,#30,#30,#00,#30,#30,#00,#00
        DB #00,#30,#30,#00,#30,#30,#60,#00
        DB #0C,#18,#30,#60,#30,#18,#0C,#00
        DB #00,#00,#FE,#00,#FE,#00,#00,#00
        DB #60,#30,#18,#0C,#18,#30,#60,#00
        DB #7C,#FE,#C6,#0C,#38,#00,#38,#00
        DB #7C,#82,#BA,#AA,#BE,#80,#7C,#00
        DB #38,#6C,#C6,#C6,#FE,#C6,#C6,#00
        DB #FC,#C6,#C6,#FC,#C6,#C6,#FC,#00
        DB #3C,#66,#C0,#C0,#C0,#66,#3C,#00
        DB #F8,#CC,#C6,#C6,#C6,#CC,#F8,#00
        DB #FE,#C0,#C0,#FC,#C0,#C0,#FE,#00
        DB #FE,#C0,#C0,#FC,#C0,#C0,#C0,#00
        DB #3E,#60,#C0,#CE,#C6,#66,#3E,#00
        DB #C6,#C6,#C6,#FE,#C6,#C6,#C6,#00
        DB #7E,#18,#18,#18,#18,#18,#7E,#00
        DB #06,#06,#06,#06,#06,#C6,#7C,#00
        DB #C6,#CC,#D8,#F0,#F8,#DC,#CE,#00
        DB #60,#60,#60,#60,#60,#60,#7E,#00
        DB #C6,#EE,#FE,#FE,#D6,#C6,#C6,#00
        DB #C6,#E6,#F6,#FE,#DE,#CE,#C6,#00
        DB #7C,#C6,#C6,#C6,#C6,#C6,#7C,#00
        DB #FC,#C6,#C6,#C6,#FC,#C0,#C0,#00
        DB #7C,#C6,#C6,#C6,#DE,#CC,#7A,#00
        DB #FC,#C6,#C6,#CE,#F8,#DC,#CE,#00
        DB #78,#CC,#C0,#7C,#06,#C6,#7C,#00
        DB #7E,#18,#18,#18,#18,#18,#18,#00
        DB #C6,#C6,#C6,#C6,#C6,#C6,#7C,#00
        DB #C6,#C6,#C6,#EE,#7C,#38,#10,#00
        DB #C6,#C6,#D6,#FE,#FE,#EE,#C6,#00
        DB #C6,#EE,#7C,#38,#7C,#EE,#C6,#00
        DB #66,#66,#66,#3C,#18,#18,#18,#00
        DB #FE,#0E,#1C,#38,#70,#E0,#FE,#00
        DB #3C,#30,#30,#30,#30,#30,#3C,#00
        DB #80,#40,#20,#10,#08,#04,#02,#00
        DB #78,#18,#18,#18,#18,#18,#78,#00
        DB #38,#6C,#00,#00,#00,#00,#00,#00
        DB #00,#00,#00,#00,#00,#00,#00,#FE


;Stream 7. Simple timer using our fonts.

TIMER_ATTR_FONTS:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        LD E,%00000000
        LD D,%00111000
        CALL CLEAR_SCR
        LD C,#03        ;NUMBER OF FONTS
        LD B,SEC_PER_MIN
        LD IX,FONT_DOTS
TIME_A3:PUSH BC
        LD HL,#0000     ;HIGH, LOW SECONDS
        LD (TIMER_L_SEC),HL
        PUSH IX
        POP HL
        PUSH BC
        LD A,(TIMER_MINS)
        LD DE,#0800
        LD B,%01111111
        LD C,%00111000
        ;OR A           ;ONE COLOR
        SCF             ;MANY COLORS
        CALL PRINT_A_CHAR
        LD A,#0A
        LD E,#08
        OR A
        CALL PRINT_A_CHAR
        POP BC
TIME_A1:LD A,#31
        CALL IM2_DELAY
        PUSH BC         ;BC - SECS
        LD A,(TIMER_H_SEC)      ;SECS
        LD B,%01111111
        LD C,%00111000  ;COLORS
        LD E,#10
        SCF 
        CALL PRINT_A_CHAR
        LD A,(TIMER_L_SEC)      ;X10 SECS
        LD E,#18
        CALL PRINT_A_CHAR
        ;LD A,#04
        ;OUT (#FE),A
        PUSH HL         ;SAVE FONT ADDR
        LD HL,(TIMER_L_SEC)
        INC L
        LD A,L
        CP NUM_SYS_BASE ;IF SECS = 10
        JR NZ,TIME_A2
        LD L,#00        ;SECS = 0
        INC H
        LD A,H
        CP NUM_SYS_BASE ;IF X10 SECS = 10
        JR NZ,TIME_A2
        LD H,#00
TIME_A2:LD (TIMER_L_SEC),HL
        POP HL          ;RESTORE ADDR
        POP BC
        DJNZ TIME_A1    ;NEXT SECOND
        LD A,(TIMER_MINS)
        INC A
        LD (TIMER_MINS),A
        LD BC,TIMER_FONT_SIZE
        ADD IX,BC       ;NOT HL
        ;LD A,#20       ;DEBUG FOR MINS
        ;CALL IM2_DELAY
        POP BC
        DEC C
        JR NZ,TIME_A3   ;NEXT FONT
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

TIMER_L_SEC     DEFB #00        ;SECONDS
TIMER_H_SEC     DEFB #00        ;X10 SEC
TIMER_MINS      DEFB #00        ;MINS

;Stream 6. Text with dynamic colors attr.

TEXT_DYNAMIC_ATTR:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        LD IX,FONT_BIT
        LD HL,#0100     ;COUNTER ANIM
        LD B,#00        ;N COLOR
        LD C,%00111000  ;GREY
TXT_A1: PUSH HL
        PUSH BC
        PUSH IX
        POP HL          ;HL=IX
        LD A,B          ;N COLOR
        AND %00000111   ;MASK
        RLCA            ;3 BITS LEFT
        RLCA 
        RLCA 
        OR %01000000    ;BRIGHT
        LD B,A          ;PAPER TO DRAW
        PUSH BC
        POP IY          ;IY=BC
        LD B,#04        ;LETTERS
        LD C,#00        ;N CHAR
        LD DE,#0800     ;CENTER SCREEN
TXT_A2: LD A,#01
        CALL IM2_DELAY
        LD A,C
        PUSH BC
        PUSH IY
        POP BC          ;BC=IY
        ;OR A           ;ONE COLOR
        SCF             ;MANY COLORS
        CALL PRINT_A_CHAR
        LD A,E
        ADD A,FONT_SIZE ;NEXT POSITION
        LD E,A
        POP BC          ;BC COUNTER
        INC C
        DJNZ TXT_A2
        LD A,#04        ;GREEN COLOR
        OUT (#FE),A
        POP BC          ;COLORS
        INC B           ;NEXT COLOR
        POP HL
        DEC HL
        LD A,H
        OR L
        JR NZ,TXT_A1    ;NEXT FRAME
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

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
        LD D,#00
        RLCA            ;A(CHAR)*8
        RLCA 
        RLCA 
        LD E,A
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

FONT_DOTS:      ;'0..9' and ':'
        DB #00,#00,#00,#00,#00,#00,#00,#00
        DB #00,#00,#00,#00,#10,#00,#00,#00
        DB #00,#00,#00,#00,#24,#00,#00,#00
        DB #00,#00,#00,#00,#54,#00,#00,#00
        DB #00,#00,#44,#00,#00,#00,#44,#00
        DB #00,#00,#44,#00,#10,#00,#44,#00
        DB #00,#00,#44,#00,#44,#00,#44,#00
        DB #00,#00,#44,#00,#54,#00,#44,#00
        DB #00,#00,#54,#00,#44,#00,#54,#00
        DB #00,#00,#54,#00,#54,#00,#54,#00
        DB #00,#00,#00,#10,#00,#00,#10,#00

FONT_MAYA:
        DB #7E,#81,#AB,#AB,#C3,#BD,#81,#7E
        DB #00,#00,#00,#00,#10,#00,#00,#00
        DB #00,#00,#00,#00,#24,#00,#00,#00
        DB #00,#00,#00,#00,#54,#00,#00,#00
        DB #00,#00,#00,#00,#55,#00,#00,#00
        DB #00,#00,#00,#00,#00,#7E,#00,#00
        DB #00,#00,#00,#10,#00,#7E,#00,#00
        DB #00,#00,#00,#28,#00,#7E,#00,#00
        DB #00,#00,#00,#54,#00,#7E,#00,#00
        DB #00,#00,#00,#AA,#00,#FE,#00,#00
        DB #00,#00,#00,#10,#00,#00,#10,#00

FONT_ROME:
        DB #00,#A5,#42,#A5,#00,#00,#3C,#00
        DB #00,#38,#10,#10,#10,#10,#38,#00
        DB #00,#7E,#24,#24,#24,#24,#7E,#00
        DB #00,#FE,#54,#54,#54,#54,#FE,#00
        DB #00,#F1,#51,#4A,#4A,#44,#E4,#00
        DB #00,#44,#44,#28,#28,#10,#10,#00
        DB #00,#8F,#8A,#52,#52,#22,#27,#00
        DB #00,#BF,#AA,#AA,#AA,#4A,#5F,#00
        DB #00,#BF,#B5,#B5,#B5,#55,#5F,#00
        DB #00,#E9,#49,#46,#46,#49,#E9,#00
        DB #00,#00,#00,#10,#00,#00,#10,#00

FONT_BIT:
        DB #00,#00,#54,#00,#44,#00,#54,#00
        DB #00,#7C,#42,#7C,#42,#42,#7C,#00
        DB #00,#3E,#08,#08,#08,#08,#3E,#00
        DB #00,#FE,#10,#10,#10,#10,#10,#00

;Stream 5. IM2 setup and clear screen.
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

;Stream 4. Interrupts and performance.

IM2_PERFORMANCE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,#0010
        LD DE,#1000
        LD BC,#2008
PERF_1: ;HALT
        LD A,#32
        CALL IM2_DELAY
        CALL DYNAMIC_COLOR_TABLE
        LD A,4
        OUT (#FE),A
        DEC HL
        LD A,H
        OR L
        JR NZ,PERF_1
        POP HL
        POP DE
        POP BC
        POP AF
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

;Stream 3. Dynamic color table.

DYNAMIC_COLOR_TABLE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
COL_T2: PUSH BC
        PUSH DE
        LD A,D
        AND %00000111   ;COLOR
        ADD A,L
        AND %00000111
        RLCA 
        RLCA 
        RLCA            ;PAPER
        LD C,A          ;C = TMP
COL_T1: LD A,E          ;X > 16
        AND %00010000
        RLCA            ;
        RLCA            ;6 BIT BRIGHT
        OR C
        CALL SET_ATTRIBUTE
        INC E
        DJNZ COL_T1     ;NEXT COLUMN
        POP DE
        INC D
        POP BC
        DEC C
        JR NZ,COL_T2
        POP HL
        POP DE
        POP BC
        POP AF
        RET 

;Stream 2. Set attribute at coordinates.

SCR_ATTRIB:
        PUSH AF
        PUSH BC
        PUSH DE
        LD BC,#2018
        LD DE,#0000
        LD A,%01011111
SCR_A2: PUSH BC
        PUSH DE
SCR_A1: CALL SET_ATTRIBUTE
        INC E
        DJNZ SCR_A1
        POP DE
        INC D
        POP BC
        DEC C
        JR NZ,SCR_A2
        POP DE
        POP BC
        POP AF
        RET 

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

;Stream 1. Print "Hello World!"

HELLO_WORLD:
        PUSH AF
        PUSH BC
        PUSH DE
        LD A,02
        CALL OPEN_CHANNEL
        LD DE,STR_HELLO
        LD BC,#000C
        CALL PRINT_STRING
        POP DE
        POP BC
        POP AF
        RET 
