;Using random function to crypt data on
;screen and check the result. Streamed
;on DevLog #4. 

RANDOM_INIT     EQU #17

        ORG #6000

;GENERATE RANDOM DATA TO ENCRYPT, TO SCR

        LD BC,#0800
XOR_T1: LD HL,#4000
        CALL RANDOM_SIMPLE
        AND %00000111   ;DE - OFFSET
        LD D,A
        CALL RANDOM_SIMPLE
        LD E,A
        ADD HL,DE
        CALL RANDOM_SIMPLE
        LD (HL),A
        INC HL
        DEC BC
        LD A,B
        OR C
        JR NZ,XOR_T1

;GENERATE XOR KEY

        LD DE,KEY_BUF
        LD HL,#4800
        LD BC,#0800
XOR_T2: CALL RANDOM_SIMPLE
        LD (HL),A
        LD (DE),A
        INC HL
        INC DE
        DEC BC
        LD A,B
        OR C
        JR NZ,XOR_T2

        LD BC,#0000
XOR_T3: NOP 
        DEC BC
        LD A,B
        OR C
        JR NZ,XOR_T3

;ENCRYPT OUR DATA WITH KEY.

        LD DE,#4000
        LD HL,KEY_BUF
        LD BC,#0800
        LD IX,#4800
XOR_T4: LD A,(DE)
        XOR (HL)
        LD (IX+0),A
        INC HL
        INC DE
        INC IX
        DEC BC
        LD A,B
        OR C
        JR NZ,XOR_T4

;DECRYPT OUR DATA WITH KEY...

        LD HL,KEY_BUF
        LD DE,#4800     ;SOURCE CRYPT
        LD IX,#5000
        LD BC,#0800
XOR_T5: LD A,(DE)
        XOR (HL)        ;USING KEY
        LD (IX+0),A
        INC HL
        INC DE
        INC IX
        DEC BC
        LD A,B
        OR C
        JR NZ,XOR_T5

        RET 

KEY_BUF:DUP #0800       ;2Kb
        DB #00
        EDUP 
