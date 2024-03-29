;8-Bit Tea Party! 2021.
;License: Creative Commons.
;Platform: 8086/87, VGA(256Kb).
;Tools: NASM.
;Author: Danila Peroff.

;��������� � ������� � ���ࠢ��.

CPU 8086

%include "VGA-X.ASM"            ;NASM.

; Offset in videobuffer for all drawing functions. Determines active video
; page.

;vx_scr_offs dw 0000h

; Draw a pixel to coordinates X and Y with color � to active page, in Mode-X.
;Using VGA-X constants for screen parameters. Check for data correctnes.
;Input:
;AL     color index from table, 0..255;
;DX     horizontal coordinate X(left-right), 0..319;
;CX     vertical coordinate Y(up-down), 0..239;
;ES     segment of videobuffer
;Output: videobuffer.

; ��楤�� �ᮢ���� �⤥�쭮�� ���ᥫ� �� ���न��⠬ ��࠭� ��ਧ��⠫� X,
;���⨪��� Y � 梥� Z � ��⨢��� ��࠭��� ������(�⭮�⥫쭮� ᬥ饭��)
;०��� �. �������� ��ࠬ���� ��࠭� � ��������筮� 䠩�� ������⥪�.
;����� �஢�ઠ ��ࠬ��஢ �� �����⨬����.
;�室:
;AL     ������ 梥� � ⠡���, 0..255;
;DX     ��ਧ��⠫쭠� ���न��� � �窠� X, 0..319;
;CX     ���⨪��쭠� ���न��� � �窠� Y, 0..239;
;ES     ᥣ���� ���������(�������� �� �������);
;��室: ��������� ����� �����, � ��⨢��� ��࠭��;

VXSetPixel:
        pushf
        ; checks
        cmp     dx, GFX_WIDTH
        jae     short SetPixelExit
        cmp     cx, GFX_HEIGHT
        jae     short SetPixelExit

        push    bx
        push    dx
        push    ax              ; must be pushed last!

        ; set mask register
        mov     bx, dx          ; save X
        xchg    cx, dx          ; cx = X, dx = Y
        and     cl, 00000011b   ; X & 3
        mov     ax, 0102h       ; ah = 1, al = mask register address
        shl     ah, cl          ; ah = plane mask = 1 << (X & 3)
        mov     cx, dx          ; restore cx = Y
;����� �뫮 �ᯮ�짮���� �맮� ��楤���, �� �� �������� ��室�.
        mov     dx, VGA_SEQUENCER_ADDR
        out     dx, ax          ; write mask to register
;���᫥��� ���� ᬥ饭��, ��� ����� ���� 梥�.
        mov     al, cl          ; Y
        mov     dl, GFX_BYTES_PER_LINE  ;������਩.
        mul     dl
        shr     bx, 1           ; faster than shr bx,cl and cannot trash cl
        shr     bx, 1           ; X/4
        add     bx, ax          ; addr = Y*GFX_BYTES_PER_LINE + X/4
        add     bx, [vx_scr_offs] ; move to active video page

        ; set byte and exit
        pop     ax
        mov     es:[bx], al
        pop     dx
        pop     bx
SetPixelExit:
        popf
        ret

VXSetPixelFast:
        pushf
        ; checks
        cmp     dx, GFX_WIDTH
        jae     short SetPixelFExit
        cmp     cx, GFX_HEIGHT
        jae     short SetPixelFExit

        push    bx
        push    dx
        push    ax
; Calc byte address and bit plane mask
; ByteOffset = Y*GFX_BYTES_PER_LINE + X/4 = Y*320/4 + X/4 = Y*80 + X/4 =
; = Y*64 + Y*16 + X/4 = Y<<6 + Y<<4 + X>>2 = (Y<<8)>>2 + Y<<4 + X>>2 =
; = (Y<<8 + X)>>2 + Y<<4
; PlaneMask = 1<<(X & 3)
        mov     ax, 0102h       ; ah = plane mask, al = mask register address
        mov     bx, dx          ; X
        add     bh, cl          ; X + Y<<8
        shr     bx, 1           ; (Y<<8 + X)>>1, carry = bit 0 of X
        adc     ah, 0           ; shift mask: 01b -> 10b if bit 0 of X set
        shr     bx, 1           ; (Y<<8 + X)>>2, carry = bit 1 of X
        jnc     short SetPixelF1; mask = mask<<2 if bit 1 of X set
        shl     ah, 1
        shl     ah, 1
SetPixelF1:
        mov     dx, VGA_SEQUENCER_ADDR
        out     dx, ax          ; write mask to register

        mov     dx, cx          ; Y
        shl     dx, 1           ;������ ����� �� ᪮����.
        shl     dx, 1
        shl     dx, 1
        shl     dx, 1           ; Y<<4
        add     bx, dx          ; offset = (Y<<8 + X)>>2 + Y<<4
        add     bx, [vx_scr_offs] ; move to active video page

        ; set byte and exit
        pop     ax
        mov     es:[bx], al
        pop     dx
        pop     bx
SetPixelFExit:
        popf
        ret

; ��楤�� ����祭�� 梥� ���ᥫ� � �� ��࠭��� ���������� �� �������
;���न��⠬ �� ��ਧ��⠫� X, ���⨪��� Y � ०��� X. �������� ��ࠬ����
;��࠭� � ��������筮� 䠩�� ������⥪�. ��⨢��� ��࠭�� ���� ᬥ饭���
;� �����. ����� �஢�ઠ �室��� ������ �� ���४⭮���.
;�室:
;DX     ��ਧ��⠫쭠� ���न��� � �窠� X, 0..319;
;CX     ���⨪��쭠� ���न��� � �窠� Y, 0..239;
;ES     ᥣ���� ���������
;��室:
;AL     ������ 梥� � ⠡���, 0..255;

VXGetPixel:
        pushf
        ; checks
        cmp     dx, GFX_WIDTH
        jae     short GetPixelExit
        cmp     cx, GFX_HEIGHT
        jae     short GetPixelExit

        push    bx
        push    dx
        push    ax              ; must be pushed last!

        ; select bit plane
        mov     bx, dx          ; save X
        mov     al, 04h         ; al = index register address
        mov     ah, dl
        and     ah, 00000011b   ; ah = plane index = X & 3
        mov     dx, VGA_GRAPHICS_ADDR
        out     dx, ax          ; write index to register
        ; calc byte address
        mov     al, cl          ; Y
        mov     dl, GFX_BYTES_PER_LINE
        mul     dl
        shr     bx, 1           ; faster than shr bx,cl and cannot trash cl
        shr     bx, 1           ; X/4
        add     bx, ax          ; addr = Y*GFX_BYTES_PER_LINE + X/4
        add     bx, [vx_scr_offs] ; move to active video page

        ; get byte and exit
        pop     ax
        mov     al, es:[bx]
        pop     dx
        pop     bx
GetPixelExit:

        popf
        ret

VXGetPixelFast:
        pushf
        ; checks
        cmp     dx, GFX_WIDTH
        jae     short GetPixelFExit
        cmp     cx, GFX_HEIGHT
        jae     short GetPixelFExit

        push    bx
        push    dx
        push    ax
; Calc byte address and bit plane index
; ByteOffset = Y*GFX_BYTES_PER_LINE + X/4 = Y*320/4 + X/4 = Y*80 + X/4 =
; = Y*64 + Y*16 + X/4 = Y<<6 + Y<<4 + X>>2 = (Y<<8)>>2 + Y<<4 + X>>2 =
; = (Y<<8 + X)>>2 + Y<<4
; PlaneIndex = X & 3
        mov     al, 04h         ; al = index register address
        mov     ah, dl
        and     ah, 00000011b   ; ah = plane index = X & 3
        mov     bx, dx
        mov     dx, VGA_GRAPHICS_ADDR
        out     dx, ax          ; write index to register

        add     bh, cl          ; X + Y<<8
        shr     bx, 1
        shr     bx, 1           ; (Y<<8 + X)>>2
        mov     dx, cx          ; Y
        shl     dx, 1
        shl     dx, 1
        shl     dx, 1
        shl     dx, 1           ; Y<<4
        add     bx, dx          ; offset = (Y<<8 + X)>>2 + Y<<4
        add     bx, [vx_scr_offs] ; move to active video page

        ; get byte and exit
        pop     ax
        mov     al, es:[bx]
        pop     dx
        pop     bx
GetPixelFExit:
        popf
        ret
