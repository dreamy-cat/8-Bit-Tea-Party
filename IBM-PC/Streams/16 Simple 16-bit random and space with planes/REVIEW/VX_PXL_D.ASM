;8-��� �����⨥! 2021.
;��業���: Creative Commons.
;�����ଠ: 8086, VGA(256Kb).
;�����㬥���: NASM.
;���㫨: VGA-X, VX_SYS, VX_PIXEL.
;�����: ������ ��஢(peroff@protonmail.com).
;����த���⢨�: �ਬ�୮� ������⢮ ⠪⮢ ��� ������ ��楤���.
;������: ��楤_1 = N, ��楤_2 �������� � ����.
;��⪠� ����� ���������:
;��.��.��, �.�.: ���⪮� ᮮ�饭�� �� ���������, 㤠���� ��� ��ࠢ����.

%include "VGA-X.ASM"            ;��४⨢� ����祭�� ��������� ��� NASM.

; ���������� �㭪権 ��⠭���� � ���뢠��� ���ᥫ� �� ��࠭�. ���砫�
;��㥬 ࠬ�� ����� ��࠭� � ��� ���������� �����. ���� ������ ������.
;��⥬ ᪠���㥬 ��࠭ � ����� �� ��� ���ᥫ� ��४�訢��� � ஧���.
;���� �������. ������塞 ��࠭ �����ᥫ쭮 ���� 梥⮬, ��⥬ ��� �������
;���ᥫ�, ��稭�� � ��ண�, ����砥� ��� 梥� � ����訢��� _�।��騩_
;���ᥫ� 梥⮬, �⫨��騬�� �� �������.

        org 100h                ;COM 䠩�.
        pushf

        call    VXSetModeX

        ; ��ਠ��� �㭪権, ����� ����㥬
        mov     si, VXSetPixel
        ; mov     si, VXSetPixelFast
        mov     di, VXGetPixel
        ; mov     di, VXGetPixelFast

        mov     al, 2           ; green color
        xor     dx, dx          ; x = 0
        xor     cx, cx          ; y = 0
        ; top side
Lp1:    call    si              ; VXSetPixel(Fast)
        inc     dx              ; x++
        cmp     dx, GFX_WIDTH
        jb      short Lp1

        ; right side
        dec     dx              ; x--
        inc     cl              ; y++
Lp2:    call    si              ; VXSetPixel(Fast)
        inc     cl              ; y++
        cmp     cl, GFX_HEIGHT
        jb      short Lp2

        ; bottom side
        dec     cl              ; y--
        dec     dx              ; x--
Lp3:    call    si              ; VXSetPixel(Fast)
        dec     dx              ; x--
        jns     short Lp3

        ; left side
        inc     dx              ; x++
        dec     cl              ; y--
Lp4:    call    si              ; VXSetPixel(Fast)
        dec     cl              ; y--
        jnz     short Lp4

        ; diagonal line from left-top to right-bottom
        mov     al, 4           ; red color
        mov     dx, 1           ; x = 1
        mov     cl, 1           ; y = 1
Lp5:    call    si              ; VXSetPixel(Fast)
        inc     dx              ; x++
        inc     cl              ; y++
        cmp     cl, GFX_HEIGHT - 1 - 1
        jna     short Lp5

        ; diagonal line from right-top to left-bottom
        mov     al, 5           ; purple color
        mov     dx, GFX_WIDTH - 1 - 1 ; x = width-2
        mov     cl, 1           ; y = 1
Lp6:    call    si              ; VXSetPixel(Fast)
        dec     dx              ; x--
        inc     cl              ; y++
        cmp     cl, GFX_HEIGHT - 1 - 1
        jna     short Lp6

        mov     ah, 00h         ; Press any key.
        int     16h

        ; redraw all lines
        xor     dx, dx          ; x = 0
        xor     cx, cx          ; y = 0
Lp7:    call    di              ; VXGetPixel(Fast)
        cmp     al, 2           ; green
        je      short Redraw
        cmp     al, 4           ; red
        je      short Redraw
        cmp     al, 5           ; purple
        jne     short NextPxl
Redraw: mov     al, 13          ; bright purple
        call    si              ; VXSetPixel(Fast)
NextPxl:
        inc     dx              ; x++
        cmp     dx, GFX_WIDTH
        jb      Lp7
        xor     dx, dx          ; x = 0
        inc     cx              ; y++
        cmp     cx, GFX_HEIGHT
        jb      Lp7

        mov     ah, 00h         ; Press any key.
        int     16h

        mov al,0Fh                      ; white color
        xor cx,cx                       ; y = 0
Dem2:   xor dx,dx                       ; x = 0
Dem1:   call si                         ; VXSetPixel
        inc dx
        cmp dx,GFX_WIDTH
        jne short Dem1
        inc cx
        cmp cx,GFX_HEIGHT
        jne short Dem2

        xor cx,cx                       ; y = 0
Dem4:   mov dx,0001h                    ; x = 1
Dem3:   call di                         ; VXGetPixel
        dec dx                          ; x--
        dec al                          ;Prev color.
        call si                         ; VXSetPixel
        inc dx
        inc dx
        cmp dx,GFX_WIDTH
        jne short Dem3
        inc cx
        cmp cx,GFX_HEIGHT
        jne short Dem4

        mov     ah, 00h         ; Press any key.
        int     16h
        popf
        ret

%include "VX_SYS.ASM"                   ;��������� ��楤���.
%include "VX_PIXEL.ASM"
