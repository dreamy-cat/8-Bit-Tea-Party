;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, VGA(256Kb).
;�����㬥���: NASM.
;���㫨: VGA-X.ASM, VX_SYS.ASM, VX_PRINT.ASM.
;�����: ������ ��஢(peroff@protonmail.com).
;        ����ᠭ�� ��஢(funny.dreamy.cat@gmail.com).
;����த���⢨�: �ਬ�୮� ������⢮ ⠪⮢ ��� ������ ��楤���.
;������: ��楤_1 = N, ��楤_2 �������� � ����.
;��⪠� ����� ���������:
;��.��.��, �.�.: ���⪮� ᮮ�饭�� �� ���������, 㤠���� ��� ��ࠢ����.

;! ����� ��� ������� ��᪮�쪮 ��⮢, ����� ������ � ��� ��室���,
;�� �᫮��� �������⥫쭮�� �㭪樮����.

%include "VGA-X.ASM"            ;��४⨢� ����祭�� ��������� ��� NASM.

CPU 8086                        ;�������� ��४⨢�, �᫨ ��㣮� ��ᥬ����.

; ���������� �㭪樨 ���� ����᪮�� ᨬ���� � ०��� X. �ᯮ����
; ��䮫�� ��⥬�� ���� 8x8 ��� ���� 䮭� � ���� ��ப.


;! �����, ��᪮�쪮 ��⮢, � ����� �� ��� �⮫����� ����� �����, ����
;�������� ���� �� ᮢᥬ ���� ��� ������ �ࠡ�⠫� � ��� ���� ����ன��.
;��⪮ �� ����室��� ��ࠢ��� � ��������� ��易⥫쭮(����� ����):
;��楤�� ���� ᨬ���� VXPrintChar.
;- �������� 䫠� ��७�� ��������� ���न��� ��/���, ��� � ��ப�;
;-



        org 100h                ;COM 䠩�.
        pushf

        call near VXSetModeX            ;Init gfx, set pages and clear VRAM.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        xor al,al
        ;mov al,90h
        mov ah,00001111b
        call near VXClearVRAM
        call near VXLoadFontBIOS        ; ����㦠�� ��⥬�� ���� 8x8

;1. ����஢���� ��楤��� ���� ᨬ���� �� ��࠭ � �ᥬ� ����⠡���.

        mov word [vx_cursor_x],0000h
        mov word [vx_cursor_y],0000h
        mov cx,04B1h
        mov al,178
        mov ah,00h
        mov dl,00h
DebP1:  call near VXPrintChar
        ;inc al
        inc dl
        ;test dh,00010000b
        loop DebP1
        ;jz short DebP1



        jmp short LpR

        ; ������塞 ��࠭ ��ࠬ� �� 0 �� 9 � ����⠡� x2, � ���� ��⠢�塞
        ; ���⮥ ���� ��� ������
        mov cx,(GFX_SCR_WIDTH/8/2) * (GFX_SCR_HEIGHT/8/2) - 13
        mov al,'0'                      ; ��砫�� ᨬ���
        mov ah,1                        ; x2 ����⠡
        mov dl,2                        ; ������ 梥�
Lp1:    call near VXPrintChar
        inc al                          ; ᫥���騩 ᨬ���
        cmp al,'9'                      ; ��᫥ 9 ᭮�� 0
        jna short L1
        mov al,'0'
L1:     loop Lp1

        ; �뢮��� ��㯭�� ������� ᢥ���
        mov word [vx_cursor_x],20       ; ������� �����
        mov word [vx_cursor_y],40
        mov byte [vx_font_color],7      ; ��� 梥�

        mov ah,5                        ; x6 ����⠡
        mov al,0                        ; ����� �� ���� ��ப�
        xor dx,dx                       ; � ��ࢮ�� ᨬ����
        mov bx,msg1                     ; ���� ��ப� (��������)
        call near VXPrintString         ; ��뢠�� �㭪�� ����

        ; �뢮��� ������� �ࠢ� ����� (��ᨬ���쭮)
        mov word [vx_cursor_x],120      ; ������� �����
        mov word [vx_cursor_y],226
        mov byte [vx_font_color],5      ; 䨮��⮢� 梥�

        mov ah,00100000b                ; x1 ����⠡, ��ᨬ����� �뢮�
        mov al,0                        ; ����� �� ���� ��ப�
        xor dx,dx                       ; ��稭��� � ��ࢮ�� ᨬ����
        mov bx,msg2                     ; ���� ��ப� (��������)
        mov cx,msg2TextEnd - msg2Text   ; �᫮ ᨬ����� � ��ப�
Lp2:    ; 横� ���� ᨬ�����
        call near VXPrintString         ; ��뢠�� �㭪�� ����
        inc dx                          ; ���室�� � ᫥���饬� ᨬ����
        loop Lp2

LpR:    mov ah,00h
        int 16h

        popf
        ret

msg1            dw msg1TextEnd - msg1Text
                dw msg1Text - msg1
msg1Text        db "Hello World!"
msg1TextEnd:

msg2            dw msg2TextEnd - msg2Text
                dw msg2Text - msg2
                db 1                    ; ������� �������⥫�� �����
                dw 2
                dd 3
msg2Text        db "8-Bit Tea Party rulezz!"
msg2TextEnd:


%include "VX_SYS.ASM"                   ;��������� ��楤���.
%include "VX_DAC.ASM"
%include "VX_PRINT.ASM"
