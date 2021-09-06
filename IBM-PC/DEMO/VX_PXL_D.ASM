;8-Bit Tea Party! 2021.
;Licinse: Creative Commons.
;Platform: 8086/87, VGA(256Kb), DOS.
;Tools: NASM.
;Author: Daniil Peroff.

; Example for VXSetPixel function

%include "VGA-X.ASM"

        org 100h
        pushf

        call    SetModeX
        mov     ax, SCR_GFX_ADDR
        mov     es, ax

        mov     al, 2           ; green color
        xor     bx, bx          ; x = 0
        mov     cl, 0           ; y = 0

        ; top side
Lp1:    call    VXPutPixel
        inc     bx
        cmp     bx, SCR_GFX_WIDTH
        jb      Lp1

        ; right side
        dec     bx
        inc     cl
Lp2:    call    VXPutPixel
        inc     cl
        cmp     cl, SCR_GFX_HEIGHT
        jb      Lp2

        ; bottom side
        dec     cl
        dec     bx
Lp3:    call    VXPutPixel
        dec     bx
        jns     Lp3

        ; left side
        inc     bx
        dec     cl
Lp4:    call    VXPutPixel
        dec     cl
        jnz     Lp4

        ; diagonal line
        mov     al, 4
        mov     bx, 1
        mov     cl, 1
Lp5:    call    VXPutPixel
        inc     bx
        inc     cl
        cmp     cl, SCR_GFX_HEIGHT - 1 - 1
        jna     Lp5

        mov     ah, 00h         ; Press any key.
        int     16h
        popf
        ret

%include "VX_SYS.ASM"
%include "VX_PIXEL.ASM"
