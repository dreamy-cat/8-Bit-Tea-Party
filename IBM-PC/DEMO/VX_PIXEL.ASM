;8-Bit Tea Party!
;License: Creative Commons.

CPU 8086

%include "vgax.asm"

; Draw single pixel in ModeX.

; Input:
;   AL = color
;   BX = X
;   CL = Y
VXPutPixel:
        pushf
        ; checks
        cmp     bx, SCR_GFX_WIDTH
        jae     VXPutPixelExit
        cmp     cl, SCR_GFX_HEIGHT
        jae     VXPutPixelExit

        push    bx
        push    dx
        push    ax              ; must be pushed last!

        ; setup mask register
        mov     dx, cx          ; save cx
        mov     cl, bl          ; cl = low(X)
        and     cl, 00000011b
        mov     ah, 1
        shl     ah, cl          ; ah = plane mask = 1 << (X & 3)
        mov     cx, dx          ; restore cx
        mov     dx, VGA_SEQ_ADDR
        mov     al, 02h         ; mask register addr
        out     dx, ax

        ; calc byte address
        mov     al, cl          ; Y
        mov     dl, SCR_GFX_WIDTH_BYTES
        mul     dl
        shr     bx, 1           ; faster than shr bx,cl and cannot use cl
        shr     bx, 1           ; X / 4
        add     bx, ax          ; addr = Y * width + X / 4

        ; set byte and exit
        pop     ax
        mov     es:[bx], al
        pop     dx
        pop     bx
VXPutPixelExit:
        popf
        ret

