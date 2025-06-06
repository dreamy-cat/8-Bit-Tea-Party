;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, BIOS, CGA+.
;�����㬥���: NASM(2.15).
;���㫨: system.asm, screen.asm, clear.asm, print.asm.
;�����: ������ ��⠯�� (danilzatruda23@gmail.com) [1],
;        ����ᠭ�� ��஢ (funny.dreamy.cat@gmail.com) [2].
;����த���⢨�: �������쭮� �� 8-��� �᫥ � ��אַ� ���浪� - 750 ⠪⮢;
;                ���ᨬ��쭮� �� 32-��� �᫥ � ���⭮� ���浪� - 4060 ⠪⮢.
;������: 106 ���� ���� � ��� ��������� ������.

; �����:
; - �������� �� ����७�� ����쭮��, �뭥�� ����������, ����� � �����;
; - ���㬠�� ��� ��⨬���樥� �१ �뢮� ��� ᬥ饭�� ���, ᫨誮� ����� jmp;
; - ��������� �뢮� � ��⮬ 䫠�� ⮫쪮 ���稬�� ��� �᫠;
; - 64 ��� ��� ����ᮬ, �� ᮢᥬ ����⭠ �ਬ��������.

; ���������� � ���஢���� �८�ࠧ������ ������ � ����୮� ��� ����筮�
;�।�⠢����� ��ப����� �ଠ�. �� 12 ��������� �������権 �� 䫠���.

        org 00100h
Demo:   pushf
        mov ax,00F20h
        mov dl,00000011b
        call near ClearScreen           ;������ ���⪠ ��࠭�.
        mov si,0004h                    ;4 ॠ��������� �業��� �� 3 ⨯�
        mov ch,00000000b                ;������ 8-16-32 ��� � ������.
        xor dx,dx
        cld                             ;�� ���뢠�� 䫠� ���ࠢ�����.
Demo4:  cmp si,00004h                   ;�ᥣ� 4 ����� �뢮��� ������� �ᥫ.
        jnz short Demo1
        lea bx,string_debug             ;�᫨ ��ࢠ� ��ப�, � �뢮��� �����
        xor al,al                       ;���ଠ�� �� �⫠��� � ᬥ頥���
        call near Print                 ;�� ���� ����権 ����.
        add dh,002h
        lea bx,string_forward           ;����� �뢮��� �� ��࠭ ��� ����
        call near Print                 ;���� � ���� �뢮��� ���.
        inc dh
Demo1:  cmp si,00002h
        jnz short Demo2
        inc dh
        lea bx,string_backward          ;�᫨ ��ன ����, � �뢮��� �� ��࠭
        call near Print                 ;ᮮ�饭��, �� ���⭮� ���浪� ��� �
        or ch,00001000b                 ;����砥� ��� 䫠�.
        inc dh
Demo2:  mov cl,003h                     ;� 横�� �뢮��� 8-16-32 ��� ����
        lea bx,string_binary            ;�������� �ᥫ, � �८�ࠧ�������.
Demo3:  mov di,dx
        mov ax,0FEDCh
        mov dx,00F0Ah
        call near BinaryToString        ;�맮� �᭮���� ��楤���.
        mov dx,di
        xor al,al                       ;�뢮��� ������� ��ப� ��� ����.
        call near Print
        inc dh                          ;���頥� ���न���� �뢮�� ����,
        inc ch                          ;㢥��稢��� ⨯ ������(����) �
        dec cl                          ;㬥��蠥� ���稪 ⨯��.
        jnz short Demo3
        cmp si,00004h                   ;����� �஢�ન �஬����筮�� �뢮�� �
        jz short Demo6                  ;��।��塞, �� �㦭�-�� ���������
Demo7:  cmp si,00003h                   ;��� ������ ������� ��ப� �窠��.
        jz short Demo6
        cmp si,0002h
        jnz short Demo5
Demo6:  mov di,bx                       ;������塞 ��ப� �窠��, ��� 㤮��⢠
        mov bx,cx                       ;������� ��� �� �뢮�� �� ��࠭.
        mov al,'.'
        mov cx,[di + STR_LEN_OFFS]
        add di,[di + STR_TEXT_OFFS]
        rep stosb                       ;�� ��אַ�� 䫠�� ���ࢫ����.
        mov cx,bx
        xor ch,00000111b
Demo5:  dec si                          ;���몠�� 横� � ������� �� ���頥��� �
        jz short Demo0                  ;���⪨� �᫮��� ���室.
        jmp near Demo4
Demo0:  xor ah,ah                       ;�������� ������ ������ � ��室��.
        int 16h
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

; ���� ��ப� �⫠��� ��� ��������� � ������� �ᥫ ��� �஢�ન १����.
string_debug    dw 00038h
                dw 00004h
                db "Print binary integers 00F0A and 0FEDC in hex with flags."
; ��ப� ��� ����� �뢮�� ᫥�� � �ࠢ�, � ��אַ� ���浪� ���.
string_forward  dw 00035h
                dw 00004h
                db "Print binary left-right and right-left, bits forward."
; ��ப� ��� ����� �뢮�� ᫥�� � �ࠢ�, � ���⭮� ���浪� ���.
string_backward dw 00036h
                dw 00004h
                db "Print binary left-right and right-left, bits backward."
; ��ப� �����祭�� ��� ��楤��� ����୮�� �८�ࠧ������, 32 �窨.
string_binary   dw 00020h
                dw 00004h
                db 020h dup ('.')

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


;30.03.25 [1,2]: ��ࢠ� ����� �८�ࠧ������ �᫠ � ������� ��ப� � �⫠���.

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
;���譨�� ��६���묨. ��६���� �뭥�� � ��⥬�� 䠩�.
; �������⥫쭮, �������� ��� ���न��� ��襣� �����.
; �室:
;AH     ��ਡ�� ᨬ���� �� �ଠ�� ⥪�⮢��� ��࠭�;
;AL     ᨬ��� ��� ����������, �⠭����� ASCII;
;DL     ��⮢� ����(䫠��) �������⥫��� ����஥�:
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
