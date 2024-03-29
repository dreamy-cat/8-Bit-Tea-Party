;8-��� �����⨥! 2021.
;��業���: Creative Commons.
;�����ଠ: 8086, VGA(256Kb).
;�����㬥���: NASM.
;���㫨: VGA-X, VX_SYS, VX_PRINT.
;�����: ������ ��஢(peroff@protonmail.com).
;����த���⢨�: �ਬ�୮� ������⢮ ⠪⮢ ��� ������ ��楤���.
;������: ��楤_1 = N, ��楤_2 �������� � ����.
;��⪠� ����� ���������:
;��.��.��, �.�.: ���⪮� ᮮ�饭�� �� ���������, 㤠���� ��� ��ࠢ����.

%include "VGA-X.ASM"            ;��४⨢� ����祭�� ��������� ��� NASM.

CPU 8086                        ;�������� ��४⨢�, �᫨ ��㣮� ��ᥬ����.

; ���������� �㭪樨 ���� ����᪮�� ᨬ���� � ०��� X. �ᯮ����
; ��䮫�� ��⥬�� ���� 8x8 ��� ���� 䮭� � ���� ��ப.

        org 100h                ;COM 䠩�.

        pushf

        call near VXSetModeX

        call near VXLoadFontBIOS        ; ����㦠�� ��⥬�� ���� 8x8

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
        mov si, msg1
        ; ������� �����
        mov word [vx_cursor_x],20
        mov word [vx_cursor_y],40
        mov ah,5                        ; x6 ����⠡
        mov dl,7                        ; ��� 梥�
        cld
Lp2:    lodsb                           ; �⠥� ��।��� ᨬ���
        test al,al                      ; ���⠥�, ���� �� ����
        jz short L2
        call near VXPrintChar
        jmp short Lp2
L2:
        ; �뢮��� ������� �ࠢ� �����
        mov si,msg2
        ; ������� �����
        mov word [vx_cursor_x],120
        mov word [vx_cursor_y],226
        mov ah,0                        ; x1 ����⠡
        mov dl,5                        ; 䨮��⮢� 梥�
Lp3:    lodsb                           ; �⠥� ��।��� ᨬ���
        test al,al                      ; ���⠥�, ���� �� ����
        jz short L3
        call near VXPrintChar
        jmp short Lp3
L3:

        mov ah,00h
        int 16h

        popf
        ret

msg1    db "Hello World!", 0
msg2    db "8-Bit Tea Party rulezz!", 0

%include "VX_SYS.ASM"                   ;��������� ��楤���.
%include "VX_PRINT.ASM"
