;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, BIOS, CGA+.
;�����㬥���: NASM(2.15).
;���㫨: system.asm, screen.asm.
;�����: ������ ��⠯�� (danilzatruda23@gmail.com) [1],
;        ����ᠭ�� ��஢ (funny.dreamy.cat@gmail.com) [2].
;����த���⢨�: �ਬ�୮ ⠪⮢, �/�� ����ᨬ��� �� �室��� ��ࠬ��஢.
;������: ���� �ᥣ� ���� � ᪮�쪮 ������/���譨� ����� ������.

; �����:
; - �������� ��楤���, � ᮮ⢥��⢨� � ����쭮���� ������⥪�;
; - �������⥫쭮� ᬥ饭�� �� ��砫� ⥪�� ��ப�.
; - �������� ��� � �᫮���� ᡮન �� �����;
; - �������� ��६���� ���न��� � ���� � ��⮬ ��������� ������;
; - ��������� �� �������� �業�ਨ ���஢����;
; - ��������� ०�� �뢮�� �� ᫮���;
; - ��������� ०�� �뢮�� � ��ࠢ��������;
; - �᫮����� �뢮� � ��⮬ ��ࠣ�䮢.

CPU 8086

        org 00100h
        pushf
        mov ax,00F20h
        mov dl,00000111b
        call near ClearScreen

; ����஢���� 㣫���� ���न��� ��� ��७�� � ⥪�� ������ ��������.

Demo1:  mov al,00000010b                ;����� ��७��, ⮫쪮 ��ப�.
        lea bx,string_chars
        mov dx,00008h
        call near Print
        xor dx,dx
        lea bx,string_one
        call near Print
        mov dx,0004Fh                   ;���譨� ��६����.
        call near Print
        mov dx,01800h
        call near Print
        mov dx,0184Fh
        call near Print
        xor ah,ah
        int 16h
        ;jmp short Demo0

; ����஢���� ������ ��ப� �� ���� ��࠭ � ����������� ������� ����.

Demo2:  xor al,al
        xor dx,dx
        lea bx,string_full
        call near Print
        xor ah,ah
        int 16h
        ;jmp short Demo0

; ����஢���� ��ப � �뢮��� ������ �� ������ �����, � ��࠭�祭���.

Demo3:  mov cl,[scr_height]
        lea bx,string_line
        xor dx,dx
        mov si,[bx + STR_TEXT_OFFS]
Demo32: call near Print
        inc byte [bx + si + 001h]
        cmp byte [bx + si + 001h],03Ah
        jne short Demo31
        mov byte [bx + si + 001h], 030h
        inc byte [bx + si]
Demo31: inc dh
        dec cl
        jnz short Demo32
        xor ah,ah
        int 16h
        ;jmp short Demo0

; ����஢���� ��ப� ����� �� ���頥��� � ��࠭, �� �뢮����� ����࠭�筮.

Demo4:  mov al,00000100b
        xor dx,dx
        lea bx,string_page
        call near Print
        xor ah,ah
        int 16h
        ;jmp short Demo0

; ����஢���� ��ப� ����� �� ����頥��� � ��࠭ � �� �뢮������ ᮢᥬ.

Demo5:  mov si,01234h                   ;��� �஢�ન ॣ���஢ ��/��᫥ �맮��,
        mov di,05678h                   ;⮫쪮 ��� �⫠�稪�.
        xor al,al
        lea bx,string_header
        xor dx,dx
        call near Print
        xor ah,ah
        int 16h
        xor al,al
        lea bx,string_long
        call near Print

Demo0:  xor ah,ah
        int 16h
        popf
        ret

string_chars    dw 00033h
                dw 00004h
                db "Print exact one char 'A' in every corner of screen."
string_one      dw 00001h
                dw 00004h
                db 'A'
string_line     dw 00050h
                dw 00004h
                db "00 This line is a full line using flag 'only line'."
                db 050h dup ('_')
string_full     dw 007D0h
                dw 00004h
                db "Print string as is but length is equal to buffer size!"
                db 007D0h dup ('.')
string_page     dw 007D1h
                dw 00004h
                db "Print string as page, length is more than buffer size."
                db 007D1h dup ('-')
string_header   dw 000A7h
                dw 00004h
                db "Print string as is, length is more than buffer size. "
                db "So if this string overwritten, then error in procedure. "
                db "Press any key to try print very long string without pages."
string_long     dw 007D1h
                dw 00004h
                db 007D1h dup ('*')

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
SCR_WIDTH               EQU 050H        ;��ਭ� ��࠭� 80 ᨬ�����, ०�� 1.
SCR_HEIGHT              EQU 019H        ;���� ��࠭� 25 ᨬ�����, ०��� 1,3.
SCR_SIZE_BYTE           EQU 00FA0H      ;������ ��࠭�(��࠭���) � �����.
SCR_SIZE_WORD           EQU 007D0H      ;������ ��࠭�(��࠭���) � ᫮���.
STR_LEN_OFFS            EQU 00000H      ;���饭�� ����� ��ப� �� ��砫� ����.
STR_TEXT_OFFS           EQU 00002H      ;���饭�� ⥪�� �� ��砫� ����.
STR_TEXT_MAX            EQU -00004H     ;���ᨬ��쭠� ����� ⥪�� � ��ப�.

scr_width       db SCR_WIDTH
scr_height      db SCR_HEIGHT
scr_cursor_x    db 000h
scr_cursor_y    db 000h
scr_size_word   dw SCR_SIZE_WORD
scr_size_byte   dw SCR_SIZE_BYTE

;29.03.25 [1,2]: ���������� �������� �㭪樮���� ��楤��� ���� �� ��頭��.
;23.03.25 [1,2]: ���� ࠡ�稩 ��ਠ�� ���� � 䫠���� � ��������樥�.
;17.03.25 [1,2]: ���� ��ਠ�� �୮���� � �業�ਨ �⫠���.
