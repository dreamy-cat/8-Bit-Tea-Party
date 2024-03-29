;8-��� �����⨥! 2021.
;��業���: Creative Commons.
;�����ଠ: 8086, VGA(256Kb).
;�����㬥���: NASM.
;���㫨: VGA-X,...
;�����: ������ ��஢(peroff@protonmail.com).
;����த���⢨�: �ਬ�୮� ������⢮ ⠪⮢ ��� ������ ��楤���.
;������: ��楤_1 = N, ��楤_2 �������� � ����.
;��⪠� ����� ���������:
;��.��.��, �.�.: ���⪮� ᮮ�饭�� �� ���������, 㤠���� ��� ��ࠢ����.

%include "VGA-X.ASM"            ;��४⨢� ����祭�� ��������� ��� NASM.

;��������� ��������, �� �᫮��� �᫨ ��� ��, � �� 14 �����.
;����� ��ப� ���� ��� ����, �ᯮ���� ��� �ଠ� � � ��ࠬ��஬ ᬥ饭�� �
;������⢮� ᨬ����� ��� ����. ��⠫쭮� 㦥 �㤥� 諨䮢��� ��᫥.


; ��楤��� ���� � ��࠭��� ������ ०��� �, ��襣� 16-� ��⭮�� �ଠ�
;��ப. ����� 䠩� string.asm ��� ���஡���� ���ᠭ�� �ଠ�.
; �ᯮ���� �������⥫쭮 ���� ��������� ��ࠬ��஢: ���� �� 㬮�砭�� �
;⥪�騥 ����樨 �뢮�� ��� 㤮��⢠ �맮���. ��� ���� ����� ����� ����
;��⥬�� ���� ��� ������. ��� ����� ������� �� �맮�� �㭪樨.
;���� �������쭮 �୮-���� ࠧ���� �뫨 �� 㬮�砭�� 8*8.


; �������� ��६���� � ����⠭��, ����� �㤥� ��������, � ᪨��� �� �
;��騩 䠩� ������⥪� ०��� �.


;����, �����騥 ����⠡, � ��ࠬ���� �㭪権 VXPrintChar � VXPrintString
CHAR_SCALE_MASK         EQU 00001111b


vx_cursor_x     dw 0000h        ;����� �窠 ����樨 �����, 0..319.
vx_cursor_y     dw 0000h        ;������ �窠 ����樨 �����, 0..239.
vx_font_addr    dd 00000000h    ;����� ���� ����, ᬥ饭�� � ᥣ����.
vx_font_first_c db 00h          ;��� ��ࢮ�� ᨬ���� � ����.
vx_font_chars   db 00h          ;������⢮ ᨬ����� � ����, 0 = 256.
vx_font_char_b  db 00h          ;������⢮ ���� �� ���� ᨬ���.

;! ���� ��⠢�� ��� ��������� ��६�����, ����� �ਣ������.
;�� 㦥 ��� ���� �㤥� �ᯮ�짮���� ⠡���� �ਭ� ��� ������� ᨬ����.
vx_font_width   db 00h          ;��ਭ� ᨬ���� � �窠�

;! ������ �ਭ� ᨬ����� ��� ����, ���� ����, 1..255, �᫨ �� ��᫥
;����� �㤥� 㡠���� � 㯠������, �� ���� ��� 㤮���� � ����॥. :)
vx_font_width_t db 0100h dup (08h)      ;������ �ਭ� ᨬ�����.

;! ����� ᨬ����� ��⠢�塞 ��� ����, ���窨 ⥪�� �⮨� ��ঠ��.
vx_font_height  db 00h          ;���� ᨬ���� � ������.
vx_font_color   db 00h          ;�������� 梥� ��� ���� ��-㬮�砭��.
vx_font_bkg     db 00h          ;�������� 梥� 䮭�, ���� १��.


;����㦠�� � �������� ��६���� ���� � ��稥 ����� ��⥬���� ����
;�� 㬮�砭��, ࠧ���: 8x8.
;�室:  ���;
;��室: ��������� �������� ��६���� vx_font_*

VXLoadFontBIOS:
        pushf
        push ax
        push bx
        push cx
        push dx
        push bp
        push es

        mov ax,1130h                    ; ������� ��ࠬ���� ���� �� BIOS
        mov bh,3                        ; �롨ࠥ� ���� 8x8
        int 10h
        mov ax,es
        mov [vx_font_addr],ax           ; ᥣ���� ������ ����
        mov [vx_font_addr + 2],bp       ; ᬥ饭�� ������ ����
        mov byte [vx_font_chars],0      ; ������⢮ ᨬ����� � ����, 0=256
        mov byte [vx_font_char_b],8     ; ���⮢ �� ���� ᨬ���
        mov byte [vx_font_width],8      ; �ਭ� ᨬ����
        mov byte [vx_font_height],8     ; ���� ᨬ����
        mov byte [vx_font_color],7      ; 梥� ����, ��� �� 㬮�砭��
        mov byte [vx_font_bkg],0        ; 梥� 䮭�

        pop es
        pop bp
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret


;�������⥫쭮, ⮫쪮 �᫨ 㦥 ���� ��楤��� ॠ��������.
;��� �� ��������, ⮫쪮 � ��⮬ �뢮�� � ����.
;��ࠬ���� ���� ���㬠��, �� �������, �� �� �뢮� 襫 � ��࠭�祭���
;�⭮�⥫쭮 �����᪮�� ����, � �� ��࠭� � ���� � ࠧ�묨 �������⥫�묨
;����������ﬨ.

VXPrintStrWin:
        pushf
        popf
        ret


;��楤�� ���� ����᪮� ��ப� �� ��࠭ � ०��� �, �� ���न��⠬.
;����� �ᯮ���� �������� ��ࠬ���� ��-㬮�砭��: ������, ���� � �.�.
;�� ��室� �� �।��� ��࠭�, ��室�� ��.
;�室:
;AH     ����:
;0..3   ����⠡�஢���� ��� ᨬ�����, 1..16;
;4      १��
;5      ������ �� ������ ᨬ����, ��������� �������� ���न���� � ���,
;       �⮡� 㫮������ � ���� ����;
;6      ��⠭�������� �뢮� �� ���⨦���� ���� ��ਧ��⠫쭮�� �뢮��;
;7      ��७���� ��� ��� �������� ���न���� ����;
;AL     ���� �� ������⢮ ᨬ����� ��� ����, �᫨ 0, � ����� �� ����
;       ��ப�, ��� ���� �� ��������� ��࠭.
;DS:BX  ���� ��ப�;
;DX     ᬥ饭�� � ��ப�, ᨬ��� � ���ண� �㦭� ��稭��� ������.
;��室: ��������� ���������� � ��⨢��� ��࠭�� � �᫨ ���� 5 ��� 7, � �
;       �����.

VXPrintString:
        pushf                           ; ��࠭塞 䫠�� � ॣ�����
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        cld                             ; ���ࠢ����� - ���।

;! �� �஢�ન �� ����, ���, ���� ���-� ������� ������� JCXZ. :)

        mov cx,[bx]                     ; CX = ����� ��ப�
        jcxz PrntStrR                   ; �᫨ ����� ��ப�, � ��室��
        sub cx,dx                       ; �᫨ ��砫�� ᨬ��� �� �।�����
        jc short PrntStrR               ; ��ப�, � ��室��
        mov si,[bx + 02h]               ; ᬥ饭�� ��⮪� ᨬ�����
        add si,bx                       ; + ���� ��ப�
        add si,dx                       ; SI = ���� ��ࢮ�� ᨬ����

        mov bx,ax                       ; BX = ��ࠬ���� ����

        ; ���������� ��室��� ������ �����
        mov di,[vx_cursor_x]
        mov bp,[vx_cursor_y]

        ; ��।��塞 ��䥪⨢��� ������⢮ ᨬ�����, ���஥ �㤥� ������
        test bh,00100000b               ; ०�� �����筮�� ᨬ����
        jz short PrntStr0

;! ��� �� ����, ������� �� ��⪮, �� ��� �������� 1 - ��� 01h ��� ��
;��� ������ࠧ�� �ᥫ �� ��� ���� ��室�����, � 0 ⠪��. ;)

        mov cx,1                        ; ���⠥� ���� ᨬ���
        jmp short PrntStr1
PrntStr0:
        mov ah,0                        ; ���㫨�� ���訩 ����
        test ax,ax                      ; �᫨ ���稪 ࠢ�� ���,
        jz short PrntStr1               ; � �� ��१��� ��ப�
        cmp ax,cx                       ; �ࠢ������ ���稪 � ��室��� ������
        jnb short PrntStr1
        mov cx,ax                       ; ��१��� �� ��������� ���-�� ᨬ�.

PrntStr1:
        ; ��⮢�� ��ࠬ���� ��� �맮�� VXPrintChar
        mov ah,bh
        and ah,CHAR_SCALE_MASK          ; AH = ����⠡�஢����
        mov dl,[vx_font_color]          ; DL = 梥� ����

        ; 横� ���� ᨬ�����
PrntStrLp:
        lodsb                           ; ����㦠�� ��।��� ᨬ���
        call near VXPrintChar           ; �맮� ����
        test bh,01000000b               ; � ०��� 6-�� ��� �஢��塞,
        jz short PrntStr2               ; �� ���⨣�� �� �ࠢ�� �࠭��� ��࠭�
        cmp [vx_cursor_y],bp            ; �᫨ ��������� Y, ����� ���⨣��
        jne short PrntStr3              ; ⮣�� ��室��
PrntStr2:
        loop PrntStrLp                  ; ᫥���騩 ᨬ���

PrntStr3:
        ; �᫨ �� ����祭 ०�� �����筮�� ᨬ���� � �� ��⠭����� ��� 7, �
        ; ����⠭�������� ��室��� ������ �����
        test bh,10100000b
        jnz short PrntStrR
        mov [vx_cursor_x],di
        mov [vx_cursor_y],bp

;! � ��⠫쭮�, ��� ��. ��� �ᯮ�짮���� ���� ��� ��楤���, ����� ��࠭���
;�� � ᥡ�, � 㦥 ��������� �����, ��楤�� ���� ⥪�� � �ந����쭮�
;�ਭ�� � ���ᥫ��.

PrntStrR:
        pop bp                          ; ����⠭�������� ॣ�����
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret


;��楤�� ���� ����᪮�� ᨬ���� �� ��࠭ � ०�� �, �� ���न��⠬.
;���� �� �ᯮ�짮���� ���� � ������ ���������, ��ࠬ���� ���� ⠪ ��.
;��᫥ �ᯮ������ ᤢ����� ������ ᫥�� ���ࠢ� �� ࠧ��� ����, �᫨ ��
;������� ��ࠢ�, � ��७�ᨬ �� ᫥������ ��ப�, ⠪ �� �� ࠧ���� ����
;�� ���⨪���.
;��楤�� �� ������뢠�� ������� ��࠭�祭�� �� ࠧ��� ���� (���ਬ��,
;�� ����� �� ���� ��⥭ 8), �஬� ������: �ਭ� ᨬ���� � ��⮬
;����⠡�஢���� �� ������ �ॢ���� 256 ���ᥫ��.
;�室:
;AL     ᨬ��� ��� �뢮��;
;AH     ����:
;  0..3   ����⠡�஢���� ��� ᨬ����, 1..16;
;  4..7   १��, ����� ����� �⨫� �뢮�� �㤥� ᤥ����, ����প�,
;         ���� � �.�.
;DL     梥� ᨬ����
;��室: ��������� ���������� � ��⨢��� ��࠭��.

VXPrintChar:
        ; ��࠭塞 ॣ�����, ᥣ����� ��࠭�� �����
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        cld                             ; ���ࠢ����� - ���।

        ; �᭮��� ��ࠬ���� ���ᮢ�� �࠭�� � BX, �� �� ������� ��
        ; ��室� �� �㭪樨:
        ; BL - 梥�
        ; BH - ��⮢� ��ࠬ���� (������ ����⠡�஢����)
        mov bh,ah
        mov bl,dl

        ; �஢��塞, ���� �� �㦭� ᨬ��� � ⥪�饬 ����
        mov cl,[vx_font_first_c]        ; ��� ��ࢮ�� ᨬ���� � ����
        cmp al,cl
        jnb short PrntChr0

PrntChrJExit:
        jmp near PrntChrR               ; ᫨誮� ������ ��� �᫮����� short

PrntChr0:
        mov dl,[vx_font_chars]          ; ������⢮ ᨬ����� � ����
        add dl,cl
        dec dl                          ; DL = ��� ��᫥����� ᨬ����
        cmp al,dl
        ja short PrntChrJExit

        ; ��室�� ���� ��ࠧ� �㦭��� ᨬ����:
        ; addr = (code-first_code)*symbol_size + font_addr
        mov si,[vx_font_addr + 2]       ; ᬥ饭�� ����
        sub al,cl                       ; code - first_code
        mov dl,[vx_font_char_b]         ; �ਭ� ᨬ���� � �����
        mul dl
        add si,ax

        mov ch,bh                       ; ��⮢� ��ࠬ����
        and ch,CHAR_SCALE_MASK          ; �뤥�塞 ����⠡�஢����
        inc ch                          ; CH = �����-� ����⠡�஢����

        ; �஢��塞, ����� �� ��������� ������ ᨬ��� � ⥪���� ������ ��
        ; ��࠭�, �᫨ ��� - �� ��室
        mov di,[vx_cursor_x]            ; ������ ����� �� X
        mov al,[vx_font_width]          ; �ਭ� ᨬ����
        mul ch                          ; 㬭����� �� ����⠡
        test ax,ax
        jz short PrntChrJExit           ; �㫥��� �ਭ�, �訡��
        add ax,di                       ; ���� ���ᥫ� �ࠢ� ��᫥ ᨬ����
        cmp ax,GFX_SCR_WIDTH            ; �� �멤�� �� �� ��࠭
        ja short PrntChrJExit
        mov dx,[vx_cursor_y]            ; ������ ����� �� Y
        mov al,[vx_font_height]         ; ���� ᨬ����
        mul ch                          ; ॠ�쭠� ���� � ��⮬ ����⠡�
        test ax,ax
        jz short PrntChrJExit           ; �㫥��� ����, �訡��
        add ax,dx                       ; ���� ���ᥫ� ᭨�� ��᫥ ᨬ����
        cmp ax,GFX_SCR_HEIGHT           ; �� �멤�� �� �� ��࠭
        ja short PrntChrJExit

        ; ��⠥� ���� ���孥�� ������ 㣫� ᨬ���� � ����������:
        ; DI = Y * GFX_BYTES_PER_LINE + (X >> 2) + active_page
        mov ax,dx                       ; Y �����
        mov dx,GFX_BYTES_PER_LINE
        mul dx
        shr di,1                        ; X ����� >> 2
        shr di,1
        add di,ax
        add di,[vx_scr_active]          ; ��砫� ��⨢��� �������࠭���

        ; �।���� ᬥ饭�� ���� �� K ��ப ��࠭�, ��� K = ����⠡
        mov al,ch                       ; ����⠡
        mov dl,GFX_BYTES_PER_LINE
        mul dl
        mov bp,ax                       ; ��࠭塞 � BP ��� �ᯮ�짮�����
                                        ; � 横�� ��⮬

        mov ax,[vx_cursor_x]            ; ������ ����� �� X
        mov cl,al
        and cl,00000011b
        mov al,00000001b
        shl al,cl
        mov cl,al                       ; CL = ��᪠ ��⮢�� ������ ���
                                        ; ��ࢮ�� ���ᥫ� ��ப�

        mov al,[vx_font_width]          ; �ਭ� ᨬ����
        mul ch                          ; 㬭����� �� ����⠡
        cmp ax,100h
        ja short PrntChrJExit           ; ॠ�쭠� �ਭ� ����� 256, �訡��
        mov ch,al                       ; CH = �ਭ� ᨬ�. � ��⮬ ����⠡�,
                                        ; 0 = 256

        mov dl,[vx_font_height]         ; DL = ���� ᨬ����, ���稪 横��

        ; ��࠭塞 � �����塞 ᥣ����� ॣ�����, ��᫥ �⮣� ����� �
        ; �������� ��६���� �㤥� ����������
        push ds
        push es
        mov ax,[vx_font_addr]
        mov ds,ax                       ; DS = ᥣ���� ����
        mov ax,GFX_SCR_ADDR
        mov es,ax                       ; ES = ���������

        ; AL - ��⮢� ���� ��� �⥭�� ����
        ; AH - ⥪�饥 ������⢮ ��⮢ � ���
        mov ah,0

PrntChr1:
        ; ��㥬 ᫥������ ����� ����
        push cx                         ; ���. ��᪠ � �᫮ ���ᥫ�� � ��ப�
        push dx                         ; ���稪 ��ப
        push di                         ; ������ � ���������

PrntChr2:
        ; �ନ�㥬 ���� ��⮢�� ������ ��� ��।���� ����� ���ᥫ��
        mov dh,0                        ; DH = ��᪠

PrntChr3:
        test ah,ah                      ; ���� �� ����� � ���� ����?
        jnz short PrntChr4
        lodsb                           ; �⠥� ��।�� 8 ���
        mov ah,08h                      ; bits = 8
        mov dl,bh                       ; ��⮢� ��ࠬ����
        and dl,CHAR_SCALE_MASK          ; �뤥�塞 ����⠡�஢����
        inc dl                          ; DL = ���稪 ����஢ = ����⠡
PrntChr4:
        test al,10000000b               ; �஢��塞 ��।��� ��� ����
        jz short PrntChr5
        or dh,cl                        ; ��⠭�������� ��� ��᪨
PrntChr5:
        shl cl,1                        ; ᤢ����� ���-����䨪��� ��᪨
        dec dl                          ; ���稪 ����஢ (��� ����⠡�)
        jnz short PrntChr6
        shl al,1                        ; 㤠�塞 ��� ���� �� ����
        dec ah                          ; bits--
        mov dl,bh                       ; ��⮢� ��ࠬ����
        and dl,CHAR_SCALE_MASK          ; �뤥�塞 ����⠡�஢����
        inc dl                          ; DL = ���稪 ����஢ = ����⠡
PrntChr6:
        dec ch                          ; ���稪 ���ᥫ�� � �����
        jz short PrntChr7               ; �����稫� �����
        cmp cl,00010000b                ; ���諨 �࠭��� �����?
        jnz short PrntChr3

PrntChr7:
        ; ��㥬 "�⮫���" �� ����襭��� ���ᥫ�� ���⮩, ࠢ��� �����-�
        ; ����⠡�஢����
        test dh,dh                      ; �᫨ ��᪠ �㫥���, �ᮢ��� ��祣�
        jz short PrntChr8

        push ax
        ;push bx
        mov cl,dl                       ; ��࠭塞 ���稪 ����஢
        mov ah,dh                       ; ��᪠ ��⮢�� ������
        mov al,02h                      ; ���� ॣ���� VGA
        mov dx,VGA_SEQUENCER_ADDR
        out dx,ax                       ; ��襬 � ॣ���� ��᪨
        mov dl,bh                       ; ��⮢� ��ࠬ����
        and dl,CHAR_SCALE_MASK          ; �뤥�塞 ����⠡�஢����
        inc dl                          ; �����-� ����⠡�஢����
PrntChr9:
        mov es:[di],bl                  ; ��襬 � ���������
        ;add bl,08h
        inc bl
        add di,GFX_BYTES_PER_LINE       ; ���室�� �� ����� ����
        dec dl
        jnz short PrntChr9              ; ᫥���騩 ���ᥫ� � �⮫����
        sub di,bp                       ; ����⠭�������� ������
        mov dl,cl                       ; ����⠭�������� ���稪 ����஢

        ;pop bx
        pop ax

PrntChr8:
        ; ���室�� � ᫥���饬� ����� � ��ப�
        inc di                          ; ᫥���騩 ���� � ����
        mov cl,00000001b                ; ���뢠�� ������ � ��᪥
        test ch,ch                      ; ᪮�쪮 ���ᥫ�� ��⠫��� � ��ப�
        jnz short PrntChr2

        ; ���室�� � ᫥���饩 ��ப�
        pop di                          ; ����⠭�������� ������ � ����
        pop dx
        pop cx

        add di,bp                       ; �� Scale ��ப ����
        dec dl                          ; ���稪 ��ப
        jnz short PrntChr1

        ; ����⠭�������� ᥣ����� ॣ����� (� ����� � ��६����)
        pop es
        pop ds

        ; ᤢ����� ����� �� �ਭ� ᨬ���� (� ��⮬ ����⠡�), �஢��塞,
        ; ������ �� �� ���� ᨬ��� �� �� �� ��ப�; �᫨ ���, ��᪠����
        ; �� ᫥������
        mov ch,bh                       ; ��⮢� ��ࠬ����
        and ch,CHAR_SCALE_MASK          ; �뤥�塞 ����⠡�஢����
        inc ch                          ; �����-� ����⠡�஢����
        mov dx,[vx_cursor_x]            ; X �����
        mov al,[vx_font_width]          ; �ਭ� ᨬ����
        mul ch                          ; 㬭����� �� ����⠡
        add dx,ax                       ; ���� ���ᥫ� �ࠢ� ��᫥ ᨬ����
        mov [vx_cursor_x],dx            ; = ����� ������ �����
        add dx,ax                       ; � �� ᨬ��� ������?
        cmp dx,GFX_SCR_WIDTH
        jna short PrntChrR              ; �᫨ ��, � �� ��室
        mov dx,[vx_cursor_y]            ; Y �����
        mov al,[vx_font_height]         ; ���� ᨬ����
        mul ch                          ; 㬭����� �� ����⠡
        add dx,ax
        mov [vx_cursor_y],dx            ; ᤢ����� ����� �� ����� ����
        xor ax,ax
        mov [vx_cursor_x],ax            ; � �⠢�� � ��砫� ��ப�

PrntChrR:
        pop bp                          ; ����⠭�������� ॣ�����
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret
