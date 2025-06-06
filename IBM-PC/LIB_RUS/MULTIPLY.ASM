;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, BIOS, CGA+.
;�����㬥���: NASM(2.15).
;���㫨: system.asm, screen.asm.
;�����: ������ ��⠯�� (daniilzatruda23@gmail.com) [1],
;        ����ᠭ�� ��஢ (funny.dreamy.cat@gmail.com) [2].
;����த���⢨�: �� 㬭������ 1 � 1 - 227(�����) ⠪⮢, � �� ����� �᫨ 0;
;                �� 㬭������ 255 � 255 - 902 ⠪⮢.
;������: 61 ����.

; �����:
; - �������� ���� ��� � ��⮬ ����쭮�� � ��ନ�� ��楤��� �⤥�쭮;
; - ��࠭�祭�� ��� ������ �� �������, ���祢� ��࠭�祭�� ��� ��楤���;
; - �ଠ� ᢮����� ��� ��������樨, ���⮩ �뢮� ⠡���� 㬭������;
; - �������⥫쭮, �᫨ ���� ����� �������樨 ��� ��������� �����⥫��.

CPU 8086
        org 00100h
        pushf
        ;mov al,0FFh
        ;mov ah,0FFh
        ;call near DebugMultiply
        
; C:    0   0   1   1   1
; D:    0   1   0   0   1
; B:    0   0   0   1   1
; R:C:  0:0 1:0 1:0 0:1 1:1

        mov ax,01003h
        int 10h
        mov ax,00F20h
        mov dl,00000011b
        call near ClearScreen
        mov bx,str_multiply
        xor ax,ax
        xor dx,dx
        call near Print
        ;jmp DemoR
;Main cycle
        mov cl,004h
        mov bp,data_debug
Demo1:  mov ax,ds:[bp]
        mov dx,[bin_pos_xy]
        add dl,008h
        xor ch,ch
        mov bx,str_bin_8
        call near BinaryToString
        xor al,al
        call near Print
        mov ax,ds:[bp]
        xchg ah,al
        inc dh
        call near BinaryToString
        xor al,al
        call near Print
        sub dl,008h
        inc dh
        mov bx,str_spacer
        call near Print
        inc dh
        mov [bin_pos_xy],dx
        mov ax,ds:[bp]
        push bx
        push cx
        push dx
        push bp
        cmp al,ah
        jc short MulB0
        xchg al,ah
MulB0:  xor di,di                       ;di - result
        mov dl,ah                       ;si - copy
        xor dh,dh                       ;dx - adder, cx - cflag
MulB5:  xor bp,bp
        shr al,1
        jnc short MulB1
        mov bx,00001h
        xor cx,cx
        mov si,ax
MulB4:  mov ax,dx
        and ax,bx
        test ax,cx
        jnz short MulB2
        xor ax,cx
        xor cx,cx
MulB2:  xor ax,cx
        test di,ax
        jz short MulB3
        mov cx,bx
MulB3:  xor di,ax
        shl cx,1
        shl bx,1
        jnc short MulB4
        mov ax,si
        mov bp,dx
MulB1:  call near PrintBin
        shl dx,1
        test al,al
        jnz short MulB5
        mov ax,di
        pop bp
        pop dx
        pop cx
        pop bx
        mov dx,[bin_pos_xy]
        mov dh,004h
        add dl,014h
        mov [bin_pos_xy],dx
        add bp,002h
        dec cl
        jz short DemoR
        jmp Demo1
DemoR:  xor ah,ah
        int 16h
        popf
        ret
        
data_debug      db 003h, 007h, 0FFh, 000h, 0AAh, 055h, 0FFh, 0FFh

str_multiply    dw 000DBh
                dw 00004h
                db " Procedure multiply 8-bit registers and save result to "
                db "16-bit register without using 'MUL' and 'ADD' instructions "
                db "of CPU. Debug data and result in hex: 003x007 = 00015; "
                db "0FFx000 = 00000; 0AAx055 = 03872; 0FFx0FF = 0FE01."

str_spacer      dw 00010h
                dw 00004h
                db 010h dup ('-')

str_bin_8       dw 00008h
                dw 00004h
                db 008h dup ('.')

str_bin_16      dw 00010h
                dw 00004h
                db 010h dup ('.')

bin_pos_xy      dw 00402h


;Extra print bp at bin pos xy, di - result
PrintBin:
        pushf
        push ax
        push bx
        push cx
        push dx
        mov ax,bp
        mov bx,str_bin_16
        mov ch,00000001b
        call near BinaryToString
        xor ax,ax
        mov dx,[bin_pos_xy]
        call near Print
        inc dh
        mov [bin_pos_xy],dx
        mov bx,str_spacer
        call near Print
        inc dh
        mov ax,di
        mov bx,str_bin_16
        call near BinaryToString
        xor ax,ax
        call near Print
        xor ah,ah
        int 16h
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

; ������ �⫠��� ��� ��������� �����⥫�� � �뢮�� ���ਡ�� �᫨ �訡��.
;�஢�ઠ �ࠢ������ १����� ��襩 ��楤��� � ���஥���� � ������.
DebugMultiply:
        pushf
        push ax
        push bx
        push dx
        push es
        mov ax,0B800h
        mov es,ax
        xor dx,dx
DemMul1:mov ax,dx
        ;call near MultiplyBit
        mov bx,ax
        mov ax,dx
        mul ah
        cmp ax,bx
        jz short DemMul0
        mov byte es:[0281h],0FFh
DemMul0:inc dx
        jnz short DemMul1
        pop es
        pop dx
        pop bx
        pop ax
        popf
        ret

; 8 ��⮢�� 㬭������ ���� �ᥫ ��� �ᯮ�짮����� ������権 ������
;㬭������ � ᫮����� ⮫쪮 ��⮢� �������. ������᪨� ��⮤ �⮫�����.
;�室�� ����� ��易⥫�� � ����������, �������� ��� ��� �������⥫쭮��
;�㬬���, �᫠ �।���������� ���������묨.
; �室:
;AL,AH  8-���� 楫��᫥��� �����⥫�;
; ��室:
;AX     16-� ���� १����.
Multiply:
        pushf
        push bx
        push cx
        push dx
        push si                         ;di push
        push di
        cmp al,ah
        jnc short Mult0
        xchg al,ah
Mult0:  xor dx,dx                      ;result
        mov bx,ax                      ;dx - factors
        xor bh,bh
Mult4:  test ah,ah
        jz short Mult1
        shr ah,1                       ;cf
        jnc short Mult2
        mov si,dx                      ;dx - result
        mov cx,bx                      ;cx - adder
Mult3:  mov di,si                      ;di - copy
        xor di,cx                      ;di add copy of adder (cx)
        and si,cx                      ;dx - carry flag
        shl si,1                       ;dx - part result
        mov cx,si                      ;cx - carry flag
        mov si,di
        jnz short Mult3
        mov dx,si                      ;bx - result
Mult2:  shl bx,1
        jnz short Mult4
Mult1:  mov ax,dx
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        popf
        ret

; ��楤�� �८�ࠧ������ 楫��᫥���� ������ � ����୮� ��� ����筮�
;⥪�⮢�� �।�⠢����� � �ଠ� ��襩 ��ப� � ��⮬ 䫠��� � ࠧ��୮�⥩.
; ������� 0 � 1 ��࠭����� � ������ �� �ᥩ �����, � ��ࢮ� ���ᨨ ��� ��� �
;����஫� �����⨬�� ����� ��ப�, ��� �ࠢ����� �� ��஭� �맮��. �஢������
;⮫쪮 ���㠫쭠� ����� � ᨬ���� ��१����뢠���� ��� ����.
; �室:
;AL     8 ���, 楫�� �᫮ ��� �����;
;AX     16 ���, 楫�� �᫮ ��� �����;
;AX:DX  32 ���, 楫�� �᫮ ��� �����;
;DS:BX  ���� ��ப� �����祭��;
;CH     ���� 䫠���:
;0..1   ࠧ��୮��� ���࠭�� � ����, 00: 8 - 11:64 ���;
;2      ��ࠢ������� � ��ப� 0 - ᫥�� ��� 1 - �ࠢ�;
;3      0 - �뢮� ��אַ� ᫥�� ���訩 � �ࠢ��� ����襬� ࠧ��� ��� �����;
;4      1 - �뢮���� ⮫쪮 ���稬� ࠧ��� ��� 0 - �� � ��⮬ ࠧ��୮��;
;5..7   १��. 3,4 ��� �������⥫쭮, ����� ��אַ �� ��頭�� ᤥ����.
;��室: ��࠭ ���������(��࠭���), �� ॣ����� ������� ��� ����.

BinaryToString:
        pushf                           ;���࠭塞 ॣ���� 䫠��� � ��⠫��
        push ax                         ;�ᯮ��㥬� ॣ����� AX,CX,DX,SI,DI.
        push cx
        push dx
        push si
        push di
        mov cl,ch                       ;�஢��塞 �� �����⨬���� ࠧ��୮���
        and cl,00000011b                ;�室��� ������, 64 ��� �� ॠ��������.
        cmp cl,00000011b
        je short BinStr0
        mov di,ax                       ;�����㥬 AX � ����塞 ������⢮ ���
        mov ax,00008h                   ;��� �뢮��, ��⥬ ᬥ饭�� �᫠ 8
        shl ax,cl                       ;����� �� ����訥 2 ��� 䫠��� � CH.
        mov cl,al                       ;CL ⥯��� 8-���� ࠧ��� ��ப�.
        mov si,ax                       ;SI 16-���� ࠧ��� ��� 㤮��⢠.
        mov ax,di                       ;����⠭�������� �᫮ � AX.
        test ch,00000100b               ;��ࠢ������� �뢮�� ᫥�� ��� �ࠢ�.
        jnz short BinStr1
        mov di,[bx + STR_TEXT_OFFS]
        add di,si                       ;��ࠢ������� ᬥ饭�� � ��ப� ᫥��.
        jmp short BinStr2
BinStr1:mov di,[bx + STR_TEXT_OFFS]
        add di,[bx + STR_LEN_OFFS]      ;��ࠢ������� ᬥ饭�� � ��ப� �ࠢ�.
BinStr2:dec di                          ;[DI-1] ᬥ饭�� �� ����� ������.
        clc                             ;����뢠�� 䫠� ��७�� ��� ᤢ����.
        test ch,00001000b               ;�஢��塞 ���冷� �����祭�� ���:
        jnz short BinStr4               ;�� ������ � ���訬 ��� �������.
        rcr dx,1
        rcr ax,1                        ;�������� � ᫥���饩 ���ᨨ �ਬ�����
        jmp short BinStr9               ;�⤥���� ��楤��� ॢ��� ���.
BinStr4:mov si,cx                       ;���࠭塞 䫠�� � ��������㥬 �����.
        and ch,00000011b                ;�������� ��⨬����� �१ ॢ���.
        jnz short BinStr5
        rcl al,1                        ;8-�� ��⭮� �᫮.
        jmp short BinStrA
BinStr5:cmp ch,00000001b
        jnz short BinStr6
        rcl ax,1                        ;16-� ��⭮� �᫮.
        jmp short BinStrA
BinStr6:rcl ax,1                        ;32-� ��⭮� �᫮.
        rcl dx,1
BinStrA:mov cx,si                       ;����⠭���� 䫠�� � ���稪.
BinStr9:jc short BinStr7                ;��������㥬 䫠� ��७�� � ��࠭塞
        mov [bx + di],byte '0'          ;�������� ���祭��.
        jmp short BinStr8               ;������� ⠪�� � ��⨬���஢���
BinStr7:mov [bx + di],byte '1'          ;��� ������ ���室�.
BinStr8:dec cl                          ;�����蠥� �᭮���� ��⮢� ���稪 �
        jnz short BinStr2               ;���室�� � ᫥���饬� ᨬ����.
BinStr0:pop di
        pop si
        pop dx
        pop cx
        pop ax                          ;����⠭�������� �� �ᯮ��㥬�
        popf                            ;��騥 ॣ�����, 䫠�� � �����頥�
        ret                             ;�ࠢ����� � ��� �맮��.


; ��楤�� ���७��� ���� � �⠭����� ⥪�⮢� ��࠭, ��ࠬ���� ०���
;�ᯮ�������� � �⤥�쭮� 䠩�� ��� � ��⥬��� ���������. ��ଠ� ��ப�
;㦥 �ᯮ��㥬 ���, � �� �⠭�����. ��室 �� �।��� ���� ��� ��࠭��� ��
;����᪠����. ����� ���न��� �⠭����� �� ���孥�� ������ 㣫� (0, 0),
;ᬥ饭�� +00000h �� ��砫쭮�� ����. ����஫� ���४⭮�� ��ப� ��
;��஭� �맮��. ������ ����� ��ୠ � �����頥��� �����������.
; �室:
;AL     ����(䫠��) �ࠢ�����:
;0      0 - �ᯮ������� ���न���� DL-DH ��� 1 - ��⥬����(᢮���) �����;
;1      1 - ��७�� ᨬ����� �� ᫥������ ��ப� ������;
;2      1 - ��ப� ������ ���� �����⠭� � �।���� ���� �.�. ����࠭�筮;
;3-7    ���� �� १��;
;DL     ���न��� �� ��ਧ��⠫� � ᨬ�����, ��� ��� ��ਡ�⮢;
;DH     ���न��� �� ���⨪��� � ᨬ�����;
;DS:BX  ���� �������� ��ப�;
; ��室:
;AX     ������⢮ �뢥������ ᨬ����� �� ��࠭(� ᫥������ �����).

Print:
        pushf                           ;���࠭塞 ���ﭨ� 䫠��� � ��⨢���
        push ax                         ;ॣ���஢ AX, BX, CX, DX, ��� �
        push bx                         ;㪠��⥫� �������� ��ப�.
        push cx
        push dx
        test al,00000001b               ;�஢��塞: �ᯮ�짮���� ��� ��⥬��
        jz short Print1                 ;����� ��� ���न���� � DL:DH.
        mov dl,[scr_cursor_x]           ;��⠭�������� ��ਧ��⠫��� �
        mov dh,[scr_cursor_y]           ;���⨪����� ������ ��襣� �����.
Print1: cmp dl,[scr_width]              ;�஢��塞, �� ��室�� �� ���न���� �� �।���.
        jnc short Print0                ;�।��� ࠧ��஢ ��࠭� � �᫨ ��室��,
        cmp dh,[scr_height]             ;� �����蠥� ��楤���.
        jnc short Print0
        mov cx,ax                       ;���������� ०�� ����.
        xor ax,ax                       ;��⮢�� AX ��� ���� ᬥ饭�� ����.
        mov al,dh                       ;��६ ���⨪����� ������ �
        mul byte [scr_width]            ;�����뢠�� ᬥ饭�� �� �ਭ� ��ப.
        xor dh,dh                       ;����塞 ��� ᫮����� ᬥ饭��.
        add ax,dx                       ;��ନ�㥬 ����� ���� � ᫮���.
        mov dx,di                       ;���࠭塞 ��砫�� ���祭�� DI.
        mov di,ax                       ;��⠭�������� ���� �뢮�� � ����.
        test cl,00000010b               ;�஢��塞 ०�� �����筮�� �뢮�� �
        jnz short Print2                ;�᫨ ��, � �뢮��� ��ப� ��� ����.
        test cl,00000100b               ;�஢��塞 ०�� ����࠭�筮�� �뢮�� �
        jnz short Print2                ;�᫨ �� ��⨢��, � �஢��塞 ������ ��
        add ax,[bx + STR_LEN_OFFS]      ;��室��� ��ப� �� ���� ��࠭.
        cmp ax,[scr_size_word]          ;�᫨ ��ப� ��室�� �� �।�� ����
        jnbe short Print5               ;��࠭�, � �⬥�塞 �뢮� ᮢᥬ.
Print2: mov cx,es                       ;���࠭塞 ��室�� ॣ���� ES �
        mov ax,SCR_ADDRESS              ;��⠭�������� ᥣ����� ॣ���� ��
        mov es,ax                       ;��砫� ��������� ��࠭�(��࠭���).
        mov ax,si                       ;���������� ��室�� ॣ���� SI.
        mov si,bx                       ;��७����砥� 㪠��⥫� SI �� ��ப� �
        add si,[bx + STR_TEXT_OFFS]     ;���室�� � ��砫� ᠬ��� ⥪��.
        mov bx,[bx + STR_LEN_OFFS]      ;��������� ����� ��ப� � ᨬ�����.
        cld                             ;��⠭�������� 䫠� ��אַ�� ���ࠢ�����.
        shl di,1                        ;��ॢ���� ᬥ饭�� �� ᫮� � �����.
Print3: movsb                           ;�����㥬 ᨬ��� � ���������.
        inc di                          ;���頥� �����祭�� �� ᫥���騩 ᨬ���.
        cmp di,[scr_size_byte]          ;����஫� ��室� �� �।�� ����.
        jz short Print4                 ;�᫨ ���⨣��� �।��, �����蠥� �뢮�.
        dec bx                          ;�����蠥� ���稪 ᨬ����� � ��ப� �
        jnz short Print3                ;�த������, �᫨ ᨬ���� �� ����㯭�.
Print4: mov es,cx                       ;����⠭�������� ��室�� ॣ�����
        mov si,ax                       ;ES, SI, DI ��⥬ ����஢����.
Print5: mov di,dx
Print0: pop dx                          ;����⠭�������� ��騥 ॣ�����, 䫠��
        pop cx                          ;� �����頥� �ࠢ�����.
        pop bx
        pop ax
        popf
        ret

; ��楤�� ���⪨ ⥪�⮢��� ���� ��࠭�. �� ��ࠬ���� ०��� �����
;���譨�� ��६���묨. ��६���� �뭥�� � ��⥬�� 䠩�. �������⥫쭮,
;�������� ��� ���न��� ��襣� �����.
; �室:
;AH     ��ਡ�� ᨬ���� �� �ଠ�� ⥪�⮢��� ��࠭�;
;AL     ᨬ��� ��� ����������, �⠭����� ASCII;
;DL     ��⮢� 䫠�� �������⥫��� ����஥�:
;0      �ᯮ�짮���� �� ᨬ���� ��� ���������� ��࠭�;
;1      �ᯮ�짮���� �� ��ਡ�� �� ���⪨ ��࠭�;
;2      ����� � �㫨 ��� � ��砫� ���न���(0,0) ��� �����.
;3-7    १��.
; ��室: ���������� ���� ��࠭� � ��⮬ ����஥�(��ࢠ� ��࠭��).

ClearScreen:
        pushf                           ;���࠭塞 ॣ���� 䫠��� � �⥪, �
        push cx                         ;⠪�� �ᯮ��㥬� ॣ����� ��,DI,ES.
        push di
        push es
        mov cx,[scr_size_word]          ;����㦠�� � �� ࠧ��� ��࠭� � ᫮���.
        mov di,SCR_ADDRESS              ;����㦠�� � ES:DI ���� ���������
        mov es,di                       ;��࠭�. � ES ᥣ����� ����, �
        xor di,di                       ;� DI �㫥��� ᬥ饭�� ��砫� ��࠭�.
        cld                             ;����뢠�� 䫠� ���ࠢ����� DF(+1).
        test dl,00000001b               ;��� 0, ���������-�� ��࠭ ᨬ������,
        jz short ClrScr1                ;�᫨ ���, � �஢��塞 䫠� ��ਡ�⮢.
ClrScr2:stosb                           ;�����뢠�� ᨬ��� �� AL � ���������.
        inc di                          ;�ய�᪠�� ���� ��ਡ��, ᬥ饭��
        loop ClrScr2                    ;�� ᫥���騩 ᨬ��� � �����塞 横�.
        mov cx,[scr_size_word]          ;����� � CX ࠧ��� ��࠭� � ᫮��� �
        xor di,di                       ;��⠭�������� ᬥ饭�� DI � ��砫�.
ClrScr1:test dl,00000010b               ;��� 1, ���������-�� ��࠭ ��ਡ�⠬�,
        jz short ClrScr3                ;�᫨ ���, � � �஢�થ ��� �����.
        xchg al,ah                      ;AL ᮤ�ন� ��ਡ��, � AH - ᨬ���.
ClrScr4:inc di                          ;�ய�᪠�� ᨬ���, 㢥��稢�� DI �� 1.
        stosb                           ;�����뢠�� ���� �� AL � ��������� �
        loop ClrScr4                    ;�����塞 横� ��������� ���������.
        xchg al,ah                      ;����⠭�������� ��室��� ���祭�� AX.
ClrScr3:test dl,00000100b               ;�஢��塞 ��� ��� ����� � DL.
        jz short ClrScr0
        xor cl,cl                       ;�᫨ ��� ��⠭�����, � ���뢠�� ���
        mov [scr_cursor_x],cl           ;����� � ��砫�� ���न���� X:Y(0,0).
        mov [scr_cursor_y],cl
ClrScr0:pop es                          ;����⠭�������� ॣ����� ES, DI, CX ��
        pop di                          ;�⥪�. ����� ॣ���� 䫠��� �
        pop cx                          ;�����頥� �ࠢ����� � ��� �맮��.
        popf
        ret

; �������� ����� � �।��⠭������ �६���� � �⮬ 䠩��, ��᫥ � system.asm.

SCR_ADDRESS             EQU 0B800H      ;���� ���� ��࠭� CGA+.
SCR_SIZE_BYTE           EQU 00FA0H      ;������ ��࠭�(��࠭���) � �����.
SCR_SIZE_WORD           EQU 007D0H      ;������ ��࠭�(��࠭���) � ᫮���.
SCR_WIDTH               EQU 050H        ;��ਭ� ��࠭� 80 ᨬ�����, ०�� 1.
SCR_HEIGHT              EQU 019H        ;���� ��࠭� 25 ᨬ�����, ०��� 1,3.

STR_LEN_SIZE            EQU 002H        ;������⢮ ���� ��� ࠧ��� ��ப�.
STR_LEN_OFFS            EQU 00000H      ;���饭�� ����� ��ப� �� ��砫� ����.
STR_TEXT_OFFS           EQU 00002H      ;���饭�� ⥪�� �� ��砫� ����.
STR_TEXT_MAX            EQU -00004H     ;���ᨬ��쭠� ����� ⥪�� � ��ப�.

scr_cursor_x    db 000h
scr_cursor_y    db 000h
scr_size_word   dw SCR_SIZE_WORD
scr_size_byte   dw SCR_SIZE_BYTE
scr_width       db SCR_WIDTH
scr_height      db SCR_HEIGHT

;13.05.25 [1,2]: ���� ����� ��������� ��������樥� � �뢮��� � �⮫���.
;02.05.25 [1,2]: ������ ���஢���� ��ࢮ� � ��ன ��⮢�� ���ᨨ 㬭������.
;27.04.25 [1,2]: ���㦤���� �୮���� � ��ࢠ� ࠡ���饥 㬭������ �� ����.
