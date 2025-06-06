;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, BIOS, CGA+.
;�����㬥���: NASM(2.15).
;���㫨: system.asm, screen.asm, clear.asm, print.asm.
;�����: ������ ��⠯�� (danilzatruda23@gmail.com) [1],
;        ����ᠭ�� ��஢ (funny.dreamy.cat@gmail.com) [2].
;����த���⢨�: �������쭮� �� 16-��� ॣ���� � ᤢ����, 284 ⠪⮢;
;                ���ᨬ��쭮� �� 8-��� ॣ���� � ��᪠��, 820 ⠪⮢.
;������: 118 ���� ���� � ��� ��������� ������.

; �����:
; - �������� �� ����७�� ����쭮��, �뭥�� ����������, ����� � �����;
; - ��������� ���������� ������� ��������ﬨ �� �뢮�� �� ��࠭;
; - 64 ��� ��� ����ᮬ, �� ᮢᥬ ����⭠ �ਬ��������, �� ����� �१ ������.

; ���������� � ���஢���� �८�ࠧ������ ॢ��� ������ � ����筮�
;�।�⠢�����. �뢮� � �ଠ� ��ப ��� ࠧ��୮�⥩ 8-16-32 ���.

CPU 8086

        org 00100h                      ;���饭�� ��� ���ᮢ ��� .COM 䠩�� �
        pushf                           ;��������� ��࠭����� 䫠���.
        mov ax,00F20h                   ;���⪠ ��࠭� ��� 䮭�� � �ન�
        mov dl,00000011b                ;���� ⥪�⮬.
        call near ClearScreen
        xor al,al                       ;�������� ⥪��, � ���ᠭ��� ���� �
        mov bx,str_reverse              ;����묨, ����� ���������.
        xor dx,dx
        call near Print
        mov cl,00Eh                     ;�ᥣ� 14 ��⮢�� ������ 8-16-32 ���.
        mov bp,00500h                   ;���⮢� ����樨 �뢮�� ��᫥ ⥪��.
        lea si,debug_byte
        lea bx,str_reverse              ;��ப� 蠡��� ��� �뢮�� �������
        cld                             ;������ � 䫠� ���ࠢ�����.
Demo4:  cmp cl,06h                      ;���� 8 ������ �� 8 ���.
        jbe short Demo1
        jnz short DemoA
        add bp,00100h                   ;���頥� ���न���� ����, ��� ����㯠.
DemoA:  lodsb                           ;8-��� ����㧪� ������ �� ⠡���� �
        mov ch,00000000b                ;��⠭���� 䫠�� �������樨.
        jmp short Demo2
Demo1:  jnz short DemoB
        add bp,00100h
DemoB:  cmp cl,001h
        jbe short Demo3
        lodsw                           ;����㦠�� 16-���� ����� � ��⠭����
        mov ch,00000001b                ;��ࠬ��� �८�ࠧ������.
        jmp short Demo2
Demo3:  jnz short DemoC
        add bp,00100h                   ;�⤥�塞 ��᫥���� ����� � 32 ���.
DemoC:  lodsw                           ;����㦠�� ᭠砫� ����訥 16-�� ���
        mov dx,[si]                     ;� ॣ���� AX � ������ � DX.
        add si,02h
        mov ch,00000010b                ;���頥� ����� � ����ன��.
Demo2:  lea bx,str_binary               ;��ப� ��� ����୮�� �뢮��.
        mov di,cx
        mov cl,08h                      ;����塞 ������⢮ ���, ����室����
        xchg cl,ch                      ;��� �८�ࠧ������ � ��ப�.
        shl ch,cl
        xchg ch,cl
        xor ch,ch
        mov [bx],cx                     ;���࠭塞 ����� ��ப� ��אַ � ��砫�.
        mov cx,di
        call near BinaryToString
        push ax
        push dx
        mov dx,bp                       ;���न���� ��� �뢮�� �� ॣ���� BP.
        xor al,al
        call near Print
        add bp,[bx]                     ;���頥� ����� ��ࠢ� � ����
        add bp,00004h                   ;ࠧ����⥫�.
        pop dx
        pop ax
        call near ReverseBits           ;������ ��� � �८�ࠧ������ ������ �
        call near BinaryToString        ;��ப� ��� �뢮��.
        push ax
        push dx
        mov dx,bp
        xor al,al
        call near Print
        sub bp,[bx]                     ;���頥��� ᭮�� ����� � ���窮� ����.
        sub bp,00004h
        add bp,00100h
        pop dx
        pop ax
        dec cl
        ;cmp cl,05h                     ;��� �⫠��� ��࠭��⥫� �뢮��.
        jnz short Demo4                 ;�᭮���� 横�.
Demo0:  xor ah,ah                       ;�������� ������ � ��室��.
        int 16h
        popf
        ret

; �⫠���� �����, 8-16-32 ��� ᮮ⢥��⢥���, ᨬ������ � ��ᨬ�����.
debug_byte      db 000h, 0FFh, 001h, 080h, 081h, 055h, 0AAh, 05Ah
debug_word      dw 00000h, 0FFFFh, 08001h, 05185h, 055AAh
debug_dword     dd 0FA518A50h

str_reverse     dw 00128h               ;���ଠ樮���� ��ப�.
                dw 00004h
                db " Procedure reverse bits in registers AL,AX and AX:DX. "
                db "Using masks and logicals instructions for 8-bit data. "
                db "Or using cycle rols with carry flag for 16-32 bits. "
                db "Bytes for debug: 000h, 0FFh, 001h, 080h, 081h, 055h, "
                db "0AAh, 05Ah. Words: 00000h, 0FFFFh, 08001h, 05185h, 055AAh. "
                db "Double word: 0FA518A50h."

str_binary      dw 00020h               ;������ ��� ������� ��ப� �뢮��.
                dw 00004h
                db 020h dup ('.')

; ��楤�� ॢ��� ��� ��������� ���浪� ��� � ॣ����� �� �����, �.�.
;ᠬ� ����訩 ��� �⠭������ ���訬 � �������. ����ন��� ॣ���஢ �� �����
;���祭��. 64 ��� �� �����ন������, 䫠�� � ��⠢訥�� ॣ����� �������
;��� ���������.
; �室:
;AL     8 ���;
;AX     16 ���;
;DX:AX  32 ���;
;CH     ���� 䫠���:
;0..1   ࠧ��୮��� ���࠭�� � ����, 00: 8 - 11:64 ���;
; ��室: ��������� ��室��� ॣ���஢ ������.

ReverseBits:
        pushf                           ;���࠭塞 䫠�� � ��騥 ॣ�����.
        push bx                         ;�� ��࠭塞 �/��� �� �ᯮ��㥬
        push cx                         ;ॣ����� � ����묨.
        push si
        push di
        mov cl,ch
        and ch,00000011b                ;��⠢�塞 ⮫쪮 ���稬� ���� ࠧ���.
        cmp ch,00000011b
        jz short RevBit0                ;�᫨ 64-���, � �����蠥� ��楤���.
        test ch,ch
        jnz short RevBit1               ;�஢��塞 ०�� 8 ��� ��� 16/32.
        mov cl,008h                     ;������⢮ ��� ��� ����⠭����.
        mov bl,10000000b                ;��᪠ ��� ���襣� 7-��� ���.
RevBit2:dec cl                          ;���� ������ ��⠬�, 㬥��蠥� ���稪.
        mov bh,al                       ;�����㥬 ⥪�饥 ���祭�� AL � BH.
        and bh,bl                       ;����砥� ���祭�� ������ ��� �� ��᪥.
        not bl                          ;�������㥬 ����⮢� ���� BL.
        and al,bl                       ;����뢠�� ���� ��� � AL.
        not bl                          ;����⠭�������� ��室��� ����.
        shr bh,cl                       ;�������� ���� ��� � �ࠢ�� ������.
        shr bl,cl                       ;��⮢�� ���� ��� �ࠢ��� ���.
        mov ch,al                       ;�����㥬 ⥪�饥 ���祭�� AL � BH.
        and ch,bl                       ;����砥� ���祭�� �ࠢ��� ���.
        shl ch,cl                       ;�������� �ࠢ� ��� � ����� ������.
        not bl                          ;�������㥬 ����⮢� ���� BL,
        and al,bl                       ;���뢠�� �ࠢ� ��� � AL �
        not bl                          ;����⠭�������� ����.
        or al,bh                        ;��⠭�������� ���� ��� � �ࠢ��
        or al,ch                        ;������ � ������� �ࠢ� � �����.
        dec cl                          ;�����蠥� ���稪 ��� ���� ��⮢.
        shl bl,cl                       ;�������� ���� ��� ᫥���饣� ���.
        test cl,cl
        jnz short RevBit2               ;�஢��塞 ���稪 � �����塞 横� ���
        jmp short RevBit0               ;��室�� �� ��楤���, AH �� �������.
RevBit1:cmp ch,00000001b                ;�஢��塞, 16-���� �� ०�� ॣ����
        jnz short RevBit3               ;� �᫨ ���, � ��⠥��� 32-����.
        xor bx,bx                       ;����塞 BX ��� ��࠭���� १����.
        mov cl,008h                     ;������⢮ ᤢ���� � 横�� 16/2.
RevBit4:shl ah,1                        ;���頥� ���訩 ��� �� AH � 䫠� CF �
        rcr bl,1                        ;��頥� ��� CF � ���訩 ��� BL.
        shl al,1                        ;�������筮 ᬥ頥� ���� � AL � BH.
        rcr bh,1
        dec cl                          ;�����蠥� ���稪 ���権 � �����塞
        jnz short RevBit4               ;��� ��⠢���� ��⮢ ॣ����.
        mov ax,bx                       ;���࠭塞 १���� � AX � ��室��.
        jmp short RevBit0
RevBit3:xor si,si                       ;����塞 SI � DI ��� ���襩 � ����襩
        xor di,di                       ;��� १����, ���稪 32/2 ���.
        mov cl,010h
RevBit5:shl dx,1                        ;���頥� ���訩 ��� �� DX � 䫠� CF �
        rcr si,1                        ;��頥� ��� CF � ���訩 ��� SI, ⠪��
        shl ax,1                        ;�������筮 ��� ॣ���஢ AX � DI.
        rcr di,1
        dec cl                          ;�����蠥� ���稪 ���権 � �����塞
        jnz short RevBit5               ;��� ��⠢���� ��⮢ ॣ���஢.
        mov ax,si                       ;���࠭塞 ॢ��ᨢ�� ॣ����� SI, DI
        mov dx,di                       ;� ��室�� ����� ॣ���஢ DX:AX.
RevBit0:pop di
        pop si
        pop cx
        pop bx
        popf                            ;����⠭�������� 䫠��, ॣ����� �
        ret                             ;������ �� ��楤���.

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

;�������� ����⠭�� � ��⥬�� ��६����, �६����.

SCR_ADDRESS             EQU 0B800H      ;���� ���� ��࠭� CGA+.
SCR_WIDTH               EQU 050H        ;��ਭ� ��࠭� 80 ᨬ�����, ०�� 1.
SCR_HEIGHT              EQU 019H        ;���� ��࠭� 25 ᨬ�����, ०��� 1,3.
SCR_WIDTH_BYTE          EQU 0A0H        ;������⢮ ���� �� ������ �����.
SCR_WIDTH_WORD          EQU 050H        ;������⢮ ᫮� �� ������ �����.
SCR_SIZE_BYTE           EQU 00FA0H      ;������ ��࠭�(��࠭���) � �����.
SCR_SIZE_WORD           EQU 007D0H      ;������ ��࠭�(��࠭���) � ᫮���.

STR_LEN_SIZE            EQU 002H        ;������⢮ ���� ��� ࠧ��� ��ப�.
STR_LEN_OFFS            EQU 00000H      ;���饭�� ����� ��ப� �� ��砫� ����.
STR_TEXT_OFFS           EQU 00002H      ;���饭�� ⥪�� �� ��砫� ����.
STR_TEXT_MAX            EQU -00004H     ;���ᨬ��쭠� ����� ⥪�� � ��ப�.

scr_width       db SCR_WIDTH
scr_height      db SCR_HEIGHT
scr_size_word   dw SCR_SIZE_WORD
scr_cursor_x    db 000h
scr_cursor_y    db 000h
scr_size_byte   dw SCR_SIZE_BYTE

;19.04.2025 [1,2]: ��� ��������樨 � �⫠���� ��� ��ਠ�⮢ ॢ��� ���.
;18.04.2025 [1,2]: ������ �୮��� ��� ��������樨, ᠬ� ��楤�� � �⫠����.
