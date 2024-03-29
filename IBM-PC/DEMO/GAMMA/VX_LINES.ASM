;8-��� �����⨥! 2021.
;��業���: Creative Commons.
;�����ଠ: 8086, VGA(256Kb), BIOS.
;�����㬥���: NASM(2.15.05).
;���㫨: VGA-X, VX_SYS, VX_PIXEL.
;�����: ������ ��⠯�� (daniilzatruda23@gmail.com).
;����த���⢨�: �ਬ�୮� ������⢮ ⠪⮢ ��� ������ ��楤���.
;������: ��楤_1 = N, ��楤_2 �������� � ����.
;��⪠� ����� ���������:
;18.11.2021, �.�.: ���न���� ��אַ㣮�쭨�� ��।����� �१ ���� ⠡����.
;09.10.2021, �.�.: ������ 梥⮢ � ����ன�� ०��� �.

CPU 8086

%include "VGA-X.asm"

;����஢���� ��� �⫠��� �㭪権 ���ᮢ�� �����.
        org 100h
        pushf
        call near VXSetModeX
        mov al,00001111b
        call near VXSetPlanes
        xor ax,ax
        call near VXSetActDispPage
        mov al,0
        mov ah,0
        mov bx,0
        mov cx,0
        mov si,20
        mov di,20
RecTab0:mov bx,0
        mov si,20
RecTab1:call near VXDrawRect
        add bx,20
        add si,20
        inc al
        cmp si,320
        jbe RecTab1
        add cx,20
        add di,20
        cmp di,240
        jbe RecTab0
        mov ah,00h      ;press any key.
        int 16h

        popf
        ret

;��楤�� �ᮢ���� ��אַ㣮�쭨�� � �������� � �ࠤ���⮬� �� 梥⠬.
;Input
;al - color
;ah - diff for color.
;bx - ���� ���न��� 㣫��. (���孨� ���� - �ࠢ� ������)

VXDrawRect:              ; �ᯮ�짮���� �㭪�� �뢮�� �窨.
        pushf
        push ax
        push cx
        push dx
        cmp word [bx + 00h],GFX_SCR_WIDTH
        jnc short VXRectR
        cmp word [bx + 02h],GFX_SCR_HEIGHT
        jnc short VXRectR
        cmp word [bx + 04h],GFX_SCR_WIDTH
        jnc short VXRectR
        cmp word [bx + 06h],GFX_SCR_HEIGHT
        jnc short VXRectR
        mov cx,[bx + 02h]       ;draw x
VXRect2:mov dx,[bx + 00h]
VXRect1:call near VXSetPixel
        inc dx
        cmp dx,[bx + 04h]
        jna short VXRect1
        add al,ah
        inc cx
        cmp cx,[bx + 06h]
        jna short VXRect2
VXRectR:pop dx
        pop cx
        pop ax
        popf
        ret

;��楤�� �ᮢ���� ��ਧ��⠫쭮� ����� �� 梥�� � �ࠤ���⮬.
;input
;al - color
;ah - diff of color
;bx,cx - first point
;si    - last point

DrawHorizontalLine:
        pushf
        push ax
        push cx
        push dx
        push bx
        push si
        push es
        cmp dx,GFX_SCR_WIDTH
        jnc short HorLin0
        cmp cx,GFX_SCR_HEIGHT
        jnc short HorLin0
        mov dx,bx
HorLin1:call near VXSetPixel
        inc dx
        add al,ah
        cmp dx,si
        jne HorLin1
HorLin0:pop es
        pop si
        pop bx
        pop dx
        pop cx
        pop ax
        popf
        ret


;��楤�� �ᮢ���� ���⨪��쭮� ����� �� 梥�� � �ࠤ���⮬.
;input
;al - color
;ah - diff of color
;bx,cx - first point
;   di - last point

DrawVerticalLine:
        pushf
        pushf
        push ax
        push cx
        push dx
        push bx
        push di
        cmp dx,GFX_SCR_WIDTH
        jnc short VerLin0
        cmp cx,GFX_SCR_HEIGHT
        jnc short VerLin0
        mov dx,bx
VerLin1:call near VXSetPixel
        inc cx
        add al,ah
        cmp cx,di
        jne VerLin1
VerLin0:pop di
        pop bx
        pop dx
        pop cx
        pop ax
        popf
        ret






