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

;MAIN PROGRAM.

        ORG #6000       ;START ADDRESS
        LD (ALASM_STACK),SP
        LD SP,(PROGRAM_STACK)
        PUSH DE
        LD DE,IM2
        CALL IM2_SETUP

;DevLog 6, 10 july 2021.
;News, comments and multiplication.

;News:  Streams and plans.
;       Yandex Retro Games Battle.
;       Demodulation 2021.

;Comments:

;1) kr4snod4r: только зешел на стрим.
;допишите? допишите? помню были скрины
;видать с компрессией. о чем пишем на
;следующем стриме расскажите сразу. я как
;понял что-то хотите представить похожее
;на приключения вилли.
;1-2) я обычно пишу код а потом иду по
;факторингу.кода время экономится...

;2) Axel_MAG: Вопрос: запустится ли АЛАЗМ
;на Ленинград-48К, Хочется, так сказать,
;на натурном железе потискать.

;Alone Coder: ALASM 4.46 работает на 48К.
;Но надо учесть, что он занимает
;#8000..#BFFF под себя, #C000.. под
;исходник(затирается в процессе
;компиляции), ..#FFFF под метки.

;3) Алексей Тов.Жюков: А, почему не MASM.
;Перепутали с ассмеблером от КСА.
;Alone Coder: ALASM and STORM - менее.
;Подробнее на SPECCY.INFO.

;4) Николай Питен: CPU. могу представить
;"тенологический" комп. прошивка для того
;чтобы играть AY-шную музыку. Все есть.
;Все работает. с 90-ых лежит. Есть еще:
;картридж для Спекки. FIFO -
;"первый вошол - первый вышел". Экранную
;область тоже можно использовать как
;изменяемую область! для переадресации!

;5) Арсений Силаев: Запилите пожалуйста
;видео просто как подключить этот Аласм к
;эмулятору, как его запустить и как начать
;на нем писать, а то начать невозможно.

;6) Сергей Москалев: При использовании
;маркера конца строки не нужно тратить
;регистры на обработку длины строки. Мы
;узнаем о конце строки не по счетчику,
;а по очередному взятому символу.

;STRING BASIC STRUCTURE(8-BIT):
;OFFS(SIZE): DATA(PARAMETER)
;+00h(1)     string length [0..255];
;+01h(1)     text offset [2..255].

;7) Вадим Дерябкин: А если я хочу
;"в продакшн" утилиту, то я могу как-то
;скомпилированную программу сохранить?
;Чтоыбы запускать с дискеты или по аудио
;каналу там...
;Комментарии от AloneCoder & ExSet.

;8)Дмитрий Стрекалов: Честно говоря с SP
;не понял никогда так не делали но коли-
;чество PUSH и POP должно было совпасть
;Развернутый комментарий от Michael.

;9) Silent GameRZX: Интересно, а на чем
;сам ассемблер писали.

;10) Ex Set(ред.): В плане атрибутов
;диапазоны перекрываются, как так?
;Вещание #2. Установка атрибута цвета.

;Attribute:  Bits:   Values(shift):
;Ink         0..2    0..7 (0)
;Paper       3..5    0..7 (3)
;Bright      6       0..1 (6)
;Flash       7       0..1 (7)

;DevLog 6. Binary print and multiply.

;1. Convert binary 8,16,32-bit to string.

        JP MULT_5

        LD DE,#0101
        LD BC,#011E
        LD HL,FONT_ENG
        LD IX,STR_8B
        LD IY,SCREEN_PIXELS
        CALL PRINT_STRING_WIN
        LD D,#04
        LD IX,STR_16B
        CALL PRINT_STRING_WIN
        LD D,#07
        LD IX,STR_32B
        CALL PRINT_STRING_WIN

        LD A,%00000001
        LD L,#AA
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD DE,#0201
        CALL PRINT_STRING_WIN
        LD A,%00000010
        LD HL,#FA50
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD DE,#0501
        CALL PRINT_STRING_WIN
        LD A,%00000100
        LD DE,#FFAA
        LD HL,#5500
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD DE,#0801
        CALL PRINT_STRING_WIN

;2. Multiply 8 and 16 bits.

;2.1. Simple adder.

MULT_1: LD IY,SCREEN_PIXELS
        LD IX,STR_ADD
        LD HL,FONT_ENG
        LD BC,#051E
        LD DE,#0101
        CALL PRINT_STRING_WIN

        LD D,#03        ;100 * 3
        LD E,#64
        LD HL,#0000
        LD B,D
        LD D,#00
MULT_2: ADD HL,DE       ;11T
        DJNZ MULT_2

        LD A,%00000010
        LD IX,BINARY_BUF
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD DE,#0201
        LD BC,#011E
        CALL PRINT_STRING_WIN

;2.2. Using shifts and adder, if
;parameter defined. First streams.
;D * E = D * (E1 + E2) = D*E1 + D*E2.

;2.3. Short result less than 8-Bit.

MULT_3: LD IY,SCREEN_PIXELS
        LD IX,STR_S8
        LD HL,FONT_ENG
        LD BC,#051E
        LD DE,#0401
        CALL PRINT_STRING_WIN

        LD D,#04
        LD E,#0C        ;OR CONSTANT
        XOR A           ;CF = 0, 4T
        LD A,D          ;12 = 8 + 4
        RLA 
        RLA 
        RLA             ;12T * 8
        LD L,A
        LD A,D
        RLA             ;*4
        RLA 
        ADD A,L
        LD L,A          ;L - RESULT

        LD A,%00000001
        LD IX,BINARY_BUF
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD DE,#0601
        LD BC,#0108     ;8 BIT OUT
        CALL PRINT_STRING_WIN

;2.4. 16-bit result, using bits commands.
;E(1..7 bits) -> H(0..6 bits), pixels.

MULT_4: LD IY,SCREEN_PIXELS
        LD IX,STR_S16
        LD HL,FONT_ENG
        LD BC,#021E
        LD DE,#0801
        CALL PRINT_STRING_WIN

        LD D,#FA
        LD E,#A0        ;123 + 32
        LD HL,#0000
        XOR A           ;CF = 0
        LD A,D
        RRA             ;7 BITS
        LD H,A          ;* 128
        LD A,D
        RRCA            ;CF
        AND %10000000   ;
        LD L,A
        ;PUSH HL        ;SLOW 20+ T
        ;POP BC
;Lisyako performance fix.
        LD B,H          ;8T
        LD C,L
        LD A,D          ;5 BITS
        RRA             ;SRL, SLOWER
        RRA             ;8T
        RRA 
        AND %00011111
        LD H,A
        LD A,D
        AND %00000111   ;LOWER 3 BIT
        RRCA 
        RRCA 
        RRCA 
        LD L,A
        ADD HL,BC

        LD A,%00000010
        LD IX,BINARY_BUF
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD DE,#0A01
        LD BC,#0110     ;16 BIT OUT
        CALL PRINT_STRING_WIN

;2.5. Konstantin. Bits multiply, 16-bits.

;SHIFT LEFT SUMM OR SHIFT ADDER.
;USING LESS-BIT MULTIPLY, SLOWER.
;HL - LOWER 16 BITS, AS RESULT,
;DE - HIGHER 16 BITS.

MULT_5: LD IY,SCREEN_PIXELS
        LD IX,STR_M32
        LD HL,FONT_ENG
        LD BC,#021E
        LD DE,#0101
        CALL PRINT_STRING_WIN
        LD D,#03
        DEC B
        LD IX,STR_MULT_1
        CALL PRINT_STRING_WIN
        INC D
        LD IX,STR_MULT_2
        CALL PRINT_STRING_WIN

        LD IX,BINARY_BUF
        LD A,%00000010
        LD HL,#F05B             ;NUM2
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD BC,#0110
        LD DE,#0310
        CALL PRINT_STRING_WIN
        LD IX,BINARY_BUF
        LD A,%00000010
        LD HL,#A0F5             ;NUM1
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD BC,#0110
        LD DE,#0410
        CALL PRINT_STRING_WIN
        LD IX,STR_DELIMITER
        LD DE,#0500
        LD BC,#0120
        CALL PRINT_STRING_WIN
        LD IX,STR_DELIMITER
        LD DE,#1600
        LD BC,#0120
        CALL PRINT_STRING_WIN

;Multiply column.

        LD HL,#A0F5     ;NUM1 ROTATE
        LD DE,#F05B     ;NUM2 FIX

        PUSH HL         ;IY = NUM1
        POP IY
        LD IX,#0000     ;OR USE DWORD
        LD HL,#0000     ;HIGHER PART
        LD BC,#0000     ;16-BIT ZERO

;IX - LOWER PART
        ;SRL H          ;16T
        ;RRC L          ;CF - BIT

        LD A,#10        ;LOOP, SLOWER
MULT_7: ADD IX,IX       ;32b SHIFT LEFT
        ADC HL,HL
        ADD IY,IY       ;ROTATE MUL
        JR NC,MULT_6
        ADD IX,DE
        ADC HL,BC       ;CARRAY FLAG

MULT_6:

        PUSH AF         ;CHECK
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX
        PUSH IY


        LD D,A
        LD A,#16
        SUB D
        LD D,A
        LD E,#00        ;DE POSITION

        PUSH DE
        POP BC
        EX DE,HL
        PUSH IX
        POP HL          ;HL:DE - SUM
        LD IX,BINARY_BUF
        LD A,%00000100
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD D,B
        LD E,C
        LD BC,#0120
        LD IY,SCREEN_PIXELS
        CALL PRINT_STRING_WIN

        POP IY
        POP IX
        POP HL
        POP DE
        POP BC
        POP AF

        DEC A
        JR NZ,MULT_7

        EX DE,HL
        PUSH IX
        POP HL
        LD IX,BINARY_BUF
        LD A,%00000100
        CALL BINARY_TO_STRING
        LD HL,FONT_ENG
        LD DE,#1700
        LD BC,#0120
        LD IY,SCREEN_PIXELS
        CALL PRINT_STRING_WIN


;3. Quarter square multiplication.


TO_RET: POP DE
        LD SP,(ALASM_STACK)
        RET 

;GLOBAL VARIABLES AND DATA.

PROGRAM_STACK   DEFW #5F00
ALASM_STACK     DEFW #0000
KEMPSTON        DB #00
STRING_TST      DB "Hello!",0

;DevLog 6, variables.

BINARY_BUF      DUP 32          ;BUFFER
                DB "_"
                EDUP 
                DB 0

STR_8B  DB "8-bit binary, AAh:",0
STR_16B DB "16-bit binary, FA50h:",0
STR_32B DB "32-bit binary, FFAA5500h:",0

STR_ADD DB "Multiply 8-bit 100 * 3:",0
STR_S8  DB "Multiply 8-bit data 4 * 12 "
        DB "with shifts, result 8-bit:",0
STR_S16 DB "Multiply 8-bit data 250 * 160"
        DB " with shifts, result 16-bit:",0
STR_M32 DB "Multiply 16-bit data using "
        DB "column, result 32-bit:",0

STR_MULT_1      DB "Multiplier fix:",0
STR_MULT_2      DB "Multiplier rol:",0
STR_DELIMITER   DUP 32
                DB "-"
                EDUP 
                DB 0

;Convert binary value to string buffer.
;A      [BITS:]
;0      8-bit value,
;1      16-bit value,
;2      32-bit value;
;HL:DE  8..32 data, HL - low, DE - high;
;IX     string address.

BINARY_TO_STRING:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        PUSH IX

        AND %00000111
        JR Z,BIN_S0

        LD B,A          ;BIT COUNTER
        RLA             ;4T,1BYTE
        RLA             ;MULT *8
        RLA 
        LD C,A          ;CF IS CLEAR
        LD A,B
        LD B,#00        ;IX TO LAST CHAR
        ADD IX,BC       ;
        LD B,A          ;BIT CHECK
;SLOW LOOP WITH CHECKS

BIN_S6: DEC IX          ;WAS CODE 0
        BIT 2,B         ;CHECK EXTRA

        JR Z,BIN_S1
        SRL D           ;32 BITS
        RR E            ;CARRY FLAG
        JR BIN_S2
BIN_S1: BIT 1,B         ;16 BIT
        JR Z,BIN_S3
BIN_S2: RR H            ;LOWER PART
BIN_S3: RR L            ;8 BIT
        JR C,BIN_S4
        LD (IX),"0"
        JR BIN_S5
BIN_S4: LD (IX),"1"
BIN_S5: DEC C
        JR NZ,BIN_S6

BIN_S0: POP IX
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

;Interrupt function, called every 1/50sec.

IM2:    DI 
        PUSH AF
        LD A,#01
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

;LIBRARY IF NEEDED INCLUDE IN PAGES.

ALL_FONTS_DATA: INCLUDE "FONTS.A",0
