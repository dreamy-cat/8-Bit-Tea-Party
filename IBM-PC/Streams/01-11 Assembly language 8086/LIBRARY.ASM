;Welcome to 8-Bit Tea Party!
;
;Assembler, Intel 8086/8087, IBM PC.
;
;Grabbag (Duke Nukem Theme).
;Composed by Lee Jackson.

;������ Intel 8086\8088, 5 ���.
;����來���� ���: 16 ���.
;���� ������: 16 ���.
;���� ����: 20 ���, 1 �����.
;������ ०�� ����樨, DOS 5.0.
;�᭮���� ������: 640 �����.
;���⥬��� ������: 384 �����.

;�᭮��� ॣ����� ������ 8086.
;AX[ah,al] �᭮���� ��������;
;BX[bh,bl] ����, ᬥ饭�� ������;
;CX[ch,cl] ����稪 ��� �������;
;DX[dh,dl] �����, ����� �����-�뢮��,"���� ��������".
;SI        ������ ���筨��, 16 ���.
;DI        ������ ��񬭨��, 16 ���.
;BP        ����, ᬥ饭�� �⥪�.
;SP        㪠��⥫� ���設� �⥪�.
;CS:IP     ���� ᥣ���� ����.
;DS:[offs] ᥣ���� ������.
;ES:[offs] ᥣ���� ������, �������⥫쭮.
;SS:SP     ᥣ���� �⥪�, � ���設��.
;IP        㪠��⥫� �� ⥪���� ��������.

;������� 䫠���, 16 ���, 䫠��:
;CF        䫠� ��७��;
;ZF        䫠� ���.
;OF        䫠� ��९�������.
;SF        䫠� �����.
;AF        �ᯮ����⥫쭮� ��९�������.
;PF        �ਧ��� ��⭮��.
;������ ���� ॣ���� 䫠�� AF.

;�������   ᥣ����   ������
;  IP        CS        -
;  SP        SS        -
;BP+SI[DI]   SS     CS,DS,ES
;  BX        DS     CS,SS,ES
;SI,DI[base] DS     CS,SS,ES
;SI -> DI   DS,ES      -
;������ �����:
;tiny
;small
;compact
;medium
;large
;flat



CPU 8086        ;⮫쪮 ������� ������ 8086.

;�������� ����⠭��.

SCR_BUFF_ADDR      equ 0xB800
SCR_SIZE_WIDTH     equ 0x0028
SCR_SIZE_HEIGHT    equ 0x0019
SCR_BUFF_SIZE_B    equ 0x0FA0
SCR_BUFF_SIZE_W    equ 0x03E8

;����⠭�� ��� ࠡ��� � ����㦠��� �������� ���⮬.

FONT_CHAR_SIZE    equ 0x60         ;������ ���� � ᨬ�����.
FONT_CHAR_BYTE    equ 0x08         ;������ ������ ᨬ���� � �����.
FONT_WIDTH_PIX    equ 0x08         ;������ ���� � �窠� �� ��ਧ��⠫�.
FONT_HEIGHT_PIX   equ 0x08         ;������ ���� � �窠� �� ���⨪���.
FONT_WIDTH_BYTE   equ 0x01         ;��ਭ� ���� � ����� �� �����.
FONT_FIRST_CHAR   equ 0x20         ;���� ᨬ��� ����, ���筮 �஡��.

;����⠭�� ��� ��ப����� ⨯�.
STRING_LEN      equ 0x0000         ;���饭�� ࠧ��� ��ப�, ᫮��.
STRING_OFFS     equ 0x0002         ;���饭�� (ᬥ饭�� �� ᬥ饭��) ⥪�� ��ப� (᫮��).

;������� ⨯� ��ப�, ������ ��ਠ��. ���� �� ��� ��������.
;���饭��:      ���� ��������:
;+0x0000        ������ ��ப�, ⮫쪮 ⥪��;
;+0�0002        ᬥ饭�� �� ���஬� ��稭����� �����।��⢥��� ⥪��;
;[+0x0002]      ᠬ ⥪��, � �����, �������� ������.
;string_example       dw 0x000C
;text_offs            dw 0x0008
;reserver             db 0x04 dup (0) - ��� �ਬ��.
;�ਬ�� १�ࢨ஢���� ��� ��ࠡ�⪨ ��� ��ਠ樨 �㭪樨 ����.
;string_text          db 'Hello World!'


        org 100h
        pushf
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push bp
        push es
        push ds
;���ࠡ��뢠�� � ����㥬 ��������� ��楤���, �� �⤥�쭮��.
;1) ������� ��楤��� ��������樨 ���஢����(��������樨) ��ப�;
;�������� �������� ��ਠ��� ��᫥����⥫쭮, �१ ����;
;2) ����� ��ப� ������� �� ������ ᨬ����, �� ���� ���� ��࠭�, ᨬ���� ࠧ��.
;����� ����� ��ப� �� ���� ���� ��࠭�, ᣥ���஢��� ��;
;3) ����� ��ப� ������� �� ���� ᨬ��� ����� �ᥣ� ����(���. ������� �������਩ �� ��࠭);
;�������� 25 ��ப, � ������ � �ਭ� ��࠭� ᢥ��� ����, ᫥�� �� �ࠢ�, ������ ������ 40.
;�������� ��ப� ������� 2 ᨬ���, � ��᫥��� ������� ����(���. �������਩).
;�ந����쭠� ��ப�, �⮡� �ࠡ�⠫ ��७��.
;4(���.)) ��楤�� ����⮢����� 㬭������ ���࠭��� ࠧ��筮� ࠧ�來��� � �뢮��� �� ��࠭.
;����來���� ���࠭��� �� 8 �� 32 ���(���� ��� �����), � ���⮬ ��७�� � ���訥 64 ���.


;��楤�� ���஢���� � ��������樨 �������樨 ����୨��.
;��易⥫쭮 ���ᨬ���� � ��������� �᫠ ��� ࠧ�冷�, ��� ⨯��.
;�����஢��� �����, 01010101, 10101010; �����஢��� ���ࢠ�� ��� ������� ⨯�.

        ;call near PrintStringDemo
        ;call near BinaryToStringDemo
        mov al,' '
        mov ah,00011111b
        mov bl,00000011b
        call near ClearTextScreen


;1) Simple addr.
        mov ax,0xF8B2
        mov dx,0x0003
        xor bx,bx ;low 16-bit
        xor cx,cx ;high 16-bit
        or dx,dx
        jz short Mult1
Mult1:  or ax,ax
        jz short Mult2
        xor di,di
Mult3:  add bx,ax
        adc cx,di
        dec dx
        jnz short Mult3
Mult2:  mov ax,bx
        mov dx,cx

;2) CPU mult, 80-100 clk
        mov ax,0x0005
        mov dx,0x0003
        mul dx

;3) shifts with data and add.
;a * b = a * (b1 + b2) = a * b1 + a * b2.
        mov al,0xEF
        mov ah,0x50  ; 80 = 64 + 16.
        xor ah,ah
        xor bx,bx
        mov dx,ax
;effective address = base + index + disp.
;mov ax,es:[bx+si*4+0x01]
        mov cl,0x06
        shl ax,cl
        add bx,ax
        mov ax,dx
        mov cl,0x04
        shl ax,cl
        add ax,bx
;4) column mult, 16-bit.

Mult4:  lea bx,str_mul_col
        mov ax,0x0101
        call near PrintTextString
        lea bx,str_mul_1
        mov ax,0x0201
        call near PrintTextString
        lea bx,str_mul_2
        mov ax,0x0301
        call near PrintTextString
        mov ax,0xF5B0
        lea bx,str_bin_word
        mov ch,00000010b
        call near BinaryToString
        mov ax,0x0211
        call near PrintTextString
        mov ax,0xCBEF
        lea bx,str_bin_word
        mov ch,00000010b
        call near BinaryToString
        mov ax,0x0311
        call near PrintTextString
        mov ax,0x0401
        lea bx,str_del
        call near PrintTextString
        mov dx,0xF5B0   ;num fix
        mov ax,0xCBEF   ;num role
        xor si,si       ;low 16-bit
        xor di,di       ;high 16-bit
        xor bp,bp       ; -1 clk.
        lea bx,str_bin_dword
        mov cx,0x0010
Mult6:  add si,si       ;or use shifts
        adc di,di
        shl ax,0x01
        jnc short Mult5
        add si,dx
        adc di,bp
Mult5:  push ax
        push cx
        push dx
        mov ax,si
        mov dx,di
        mov ch,00000100b
        call near BinaryToString
        mov ah,0x15
        sub ah,cl
        mov al,0x01
        call near PrintTextString
        mov ax,0x0001
        call near TimerDelay
        pop dx
        pop cx
        pop ax
        loop Mult6
        mov ax,0x1501
        lea bx,str_del
        call near PrintTextString
        lea bx,str_bin_dword
        mov ax,0x1601
        call near PrintTextString
        pop ds
        pop es
        pop bp
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

BitsMultiply:
        pushf
        push ax
        push bx
        push cx
        push dx
BitMul1:test ch,00000001b   ;8-bits
        jz BitMul2


BitMul2:test ch,00000010b   ;16-bits
        jz BitMul3

BitMul3:test ch,00000100b   ;32-bits
        jz BitMul0

BitMul0:pop dx
        pop cx
        pop bx
        pop ax
        popf

;��楤�� ����⮢����� 㬭������ ���࠭��� ࠧ��筮� ࠧ�來��� � �뢮��� �� ��࠭.
;�室
;al     8-bit data;
;ax     16-bit data;
;ax:dx  32-bit data;
;ch     control bits:
;0..2   data type to convert, 8, 16, 32 bits.
;��室
;al     8-bit data;
;ax     16-bit data;
;ax:dx  32-bit data;
;ch     add bits:
;0..2   data type to convert, 8, 16, 32 bits.
;����������� ��� �� �� ᯮᮡ� 㬭������:
;�१ ᫮�����, �� �ᯮ���� ������ 㬭������
;���⮥ 㬭������, �ᯮ���� ������� ������, �஬� 32-���.
;� ��砥 ᮢ������� �ᥫ �� �⥯��� 2-�, ॠ�������� � ������� ᤢ����.
;㬭������ ����⮢�� � �⮫��� ��� ����訪 ���࠭��� ⮦�.


BinaryToStringDemo:
        pushf
        mov ah,00011111b
        mov al,' '
        mov bl,00000011b
        call near ClearTextScreen
        lea bx,str_bin_byte
        mov ax,0x0101
        call near PrintTextString
        mov cl, 0x04
        lea si,bytes_data
        mov ch,00000001b
BitDem1:mov al,[si]
        call near BinaryToString
        mov ax,0x0601
        sub ah,cl
        call near PrintTextString
        mov al,'_'
        call near ClearString
        xor ch,00001000b
        inc si
        dec cl
        jnz short BitDem1
        lea bx,str_bin_word
        mov ax,0x0701
        call near PrintTextString
        mov cl, 0x04
        lea si,words_data
        mov ch,00000010b
BitDem2:mov ax,[si]
        call near BinaryToString
        mov ax,0x0C01
        sub ah,cl
        call near PrintTextString
        mov al,'_'
        call near ClearString
        xor ch,00001000b
        inc si
        inc si
        dec cl
        jnz short BitDem2
        lea bx,str_bin_dword
        mov ax,0x0D01
        call near PrintTextString
        mov cl, 0x04
        lea si,dwords_data
        mov ch,00000100b
BitDem3:mov ax,[si]
        mov dx,[si+0x02]
        call near BinaryToString
        mov ax,0x1201
        sub ah,cl
        call near PrintTextString
        mov al,'_'
        call near ClearString
        xor ch,00001000b
        add si,0x0004
        dec cl
        jnz short BitDem3


        popf
        ret

str_bin_byte dw 0x0008, 0x0004
             db '__8-Bit:'
bytes_data db 0000000b, 00001010b, 11111111b, 00000001b

str_bin_word dw 0x0010, 0x0004
             db '_________16-Bit:'
words_data dw 0xFA50, 0x05AF, 0xFFFF, 0x0000

str_bin_dword dw 0x0020, 0x0004
             db 25 dup "_"
             db '32-bit:'
dwords_data dd 0xFFAA5500, 0x0055AAFF, 0xFFFFFFFF, 0x00000000


str_mul_col dw 0x001C, 0x0004
            db 'Multiply 16-bits to 32-bits: '
str_mul_1   dw 0x0010, 0x0004
            db 'Multiplier fix: '
str_mul_2   dw 0x0010, 0x0004
            db 'Multiplier rol: '
str_del     dw 0x0020, 0x0004
            db 32 dup '-'
;��楤�� ���⪨ �������� ��ਠ�� ��ப� (����������).
;�室
;al  :symbol to fill
;ds:bx :addr string
;��室
;ds:bx :addr string

ClearString:
        pushf
        push cx
        push di
        push es
        mov di,ds
        mov es,di
        mov cx,[bx+STRING_LEN]
        mov di,bx
        add di,[bx+STRING_OFFS]
        cld
        rep stosb
        pop es
        pop di
        pop cx
        popf
        ret

;��楤�� �������樨 �᫠ � ������ ��ਠ�� ��ப�, � ����筮� �ଥ;
;������ ��ப� ������ ���� ����� ��� ࠢ�� ���� ������, ���� ��室. ������� ������� �ᯮ�짮���� �����.
;Input:
;al     8-bit data;
;ax     16-bit data;
;ax:dx  32-bit data;
;ds:bx  addr of string structure;
;ch     control bits:
;0..2   data type to convert, 8, 16, 32 bits.
;3      fill empty chars with zeroes to left.
;4..7   reserved.

BinaryToString:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
;check string length
        mov di,bx
        mov bh,ch
        mov cl,0x03   ;㬭������ �� 8
        and ch,00000111b
        shl ch,cl
        ;mov bl,ch  ;bl - bits counter
        mov cl,ch
        xor ch,ch
        cmp cx,[di]
        ja short BinToS0
        mov ch,bh
        mov bx,di
        mov di,[bx+STRING_OFFS]
        add di,[bx+STRING_LEN]
BinToS3:dec di     ;cl - bits counter
        test ch,00000001b   ;8-bit data
        jz short BinToS6
        or al,al
        jz short BinToS4
        shr al,1
        jc short BinToS1
        jmp short BinToS8
BinToS6:test ch,00000010b   ;16-bit data
        jz short BinToS7
        or ax,ax
        jz short BinToS4
        shr ax,1
        jc short BinToS1
        jmp short BinToS8
BinToS7:test ch,00000100b
        jz short BinToS0
        mov si,ax
        or ax,dx
        jz short BinToS4
        mov ax,si
        shr dx,1
        rcr ax,1
        jc short BinToS1
BinToS8:mov ds:[bx+di], byte '0'
;��� �ᯮ�짮���� ������� stob, ᮢ�� �� ������(CourierR)
        jmp short BinToS2
BinToS1:mov ds:[bx+di], byte '1'
BinToS2:dec cl
        jnz short BinToS3
BinToS4:or cl,cl
        jz short BinToS0
        test ch,00001000b
        jnz short BinToS0
BinToS5:mov ds:[bx+di], byte '0'
        dec di
        dec cl
        jnz short BinToS5
BinToS0:pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;������� ��楤��� ��������樨
;���஢����(��������樨) ��ப�;
PrintStringDemo:
        pushf
        push ax
        push bx
        push cx
        push dx
        push di
        mov ah,00011111b
        mov al,' '
        mov bl,00000011b
        call near ClearTextScreen
        jmp short TestPr8
;1) �뢮� ��ப� �����筮� ������ �� �� ����樨.
TestPr1:lea bx,str_single
        xor ax,ax
        mov cx,SCR_BUFF_SIZE_W
        mov di,bx
        add di,[bx+STRING_OFFS]
TestPr3:call near PrintTextString
        inc al
        cmp al,SCR_SIZE_WIDTH
        jne short TestPr2
        inc ah
        xor al,al
TestPr2:mov dx,ax
        mov ax,0x0001
        call near TimerDelay
        mov ax,dx
        inc byte ds:[di]
        loop TestPr3
;2)���⠢��� ��ப� ������� 10 �� 4.
TestPr4:lea bx,str_part
        mov ch,SCR_SIZE_HEIGHT
        xor ax,ax
TestPr7:mov cl,0x04
TestPr6:call near PrintTextString
        mov dx,ax
        mov ax,0x0001
        call near TimerDelay
        mov ax,dx
        add al,0x0A
        cmp al,SCR_SIZE_WIDTH
        jna short TestPr5
        inc ah
        xor al,al
TestPr5:dec cl
        jnz short TestPr6
        dec ch
        jnz short TestPr7
;3)����� ��ப� �� ���������, � 㬥��襭��� ������ � ��७�ᮬ.
TestPr8:lea bx,str_long
        xor ax,ax
        mov cx,SCR_SIZE_HEIGHT
TestPr9:call near PrintTextString
        mov dx,ax
        mov ax,0x0001
        call near TimerDelay
        mov ax,dx
        dec word ds:[bx]
        ;dec word ds:[bx]
        inc al
        inc al
        inc ah
        loop TestPr9
        pop  di
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        popf
        ret

str_single dw 0x0001, 0x0004
           db '!'
str_part   dw 0x000A, 0x0004
           db '0123456789'
str_long   dw SCR_SIZE_WIDTH, 0x0004
           db SCR_SIZE_WIDTH dup '.'
;��楤�� ���� ��ப� � ⥪�⮢� ����.
;��ଠ� ��ப� ��������� �.���.
;�ᯮ��㥬 �������� ����⠭�� ��࠭�.
;�室.
;al ������ �� ��ਧ��⠫� ��� ��࠭�祭��.
;ah ������ �� ���⨪���, �।�� ⮫쪮 ����.
;ds:bx      ����  ������� �������� ��ப�.
;�஢�ઠ �� �����⨬���� ⮫쪮 � �।���� ����.

PrintTextString:
        pushf
        push ax
        push cx
        push dx
        push si
        push di
        push es

        mov dx,ax   ;����塞 ᬥ饭�� �� ���न��⠬.
        mov al,dh
        mov cl,SCR_SIZE_WIDTH
        mul cl
        xor dh,dh
        add ax,dx
        ;shl ax,1       ; 90-100 clk.

;������ ���� ᬥ饭�� �� ���न��⠬, ��⮤��� ᤢ����.
;����⠥� ⮫쪮 ��� ��頭�� �� 40 ᨬ����� �� ��ਧ��⠫�.
        ;mov dx,ax
        ;xchg al,ah
        ;xor ah,ah
        ;mov cl,0x03     ;char+atr*2 = 2 bytes
        ;shl ax,cl       ; 8+4*4 clk.
        ;mov di,ax
        ;mov cl,0x02
        ;shl ax,cl
        ;add di,ax       ; y ���᫥�
        ;xor dh,dh
        ;shl dx,0x01
        ;add di,dx
        ;mov ax,di ; 80 clk.

        mov dx,SCR_BUFF_SIZE_W
        cmp ax,dx;�஢��塞 �� ��९������� ����.
        ja short PrTxtS0  ;���㠫 ���.2-46

;�஢�ઠ �� ������ ��ப�. �᫨ ��������, ������뢠�� 墮��.

        mov cx,ds:[bx]
        jcxz PrTxtS0 ; �������� ���������
        mov di,ax
        shl di,0x01
        sub dx,ax    ; compare word
        cmp dx,cx
        jnc PrTxtS1
        mov cx,dx    ;����� ����� ��ப�, ᪫쪮 ���������.

;�����।�⢥��� �뢮��� �����.
PrTxtS1:mov si,bx
        add si,ds:[bx+0x02]  ;si ⥪�� ��ப�.
        mov ax,SCR_BUFF_ADDR
        mov es,ax
PrTxtS2:movsb
        inc di
        loop PrTxtS2
PrTxtS0:pop es
        pop di
        pop si
        pop dx
        pop cx
        pop ax
        popf
        ret


;TimerDelay - �㭪�� ����প� �� ��⥬���� ⠩����.
;�� - ����প� � ⨪��(18.2 � ᥪ㭤�).

TimerDelay:
        pushf           ;���.��⨬�����, �᫨ ����.
        push bx
        push dx
        push di
        push es
        mov bx,0x0040
        mov es,bx
        mov di,0x006C
        mov bx,es:[di] ;⨪� �� ����.
TimDel0:mov dx,es:[di] ;⥪�騥 ⨪�.
        sub dx,bx      ;����塞 ������ �� ⨪��.
        cmp dx,ax      ;�� ���⨣��� �� ��ࠬ��� ����প�.
        jc short TimDel0
        pop es
        pop di
        pop dx
        pop bx
        popf
        ret

;�����।�⢥��� ᠬ ⥪�� � ���ᨢ, ����஫� �� ������� �� ��஭� �맮��.
;��楤�� ���⪨ ⥪�⮢��� ���� ��࠭�.
;ah   ��ਡ�� ᨬ���� �� �ଠ�� ⥪�⮢��� ��࠭�.
;al   ᨬ��� ��� ����������.
;bl   ��⮢� ����.
;0    �ᯮ�짮���� �� ᨬ���� ��� ����������.
;1    �ᯮ�짮���� �� ��ਡ�� �� ���⪨ ��/���.
;2-7  १��.

ClearTextScreen:
        pushf
        push cx
        push di
        push es
        mov cx,SCR_BUFF_SIZE_W
        mov di,SCR_BUFF_ADDR
        mov es,di
        xor di,di
        cld
        test bl,00000001b       ;5 clk
        jz ClTxtS2
        ;if (!(bl & 0x01)) go to ClTxtS0
ClTxtS1:stosb
        inc di
        loop ClTxtS1
        mov cx,SCR_BUFF_SIZE_W
        xor di,di
ClTxtS2:test bl,00000010b
        jz ClTxtS0
        xchg al,ah
        inc di
ClTxtS3:stosb
        inc di
        loop ClTxtS3
ClTxtS0:pop es
        pop di
        pop cx
        popf
        ret
