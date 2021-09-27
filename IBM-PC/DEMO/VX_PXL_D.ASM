;8-Бит Чаепитие! 2021.
;Лицензия: Creative Commons.
;Платформа: 8086, VGA(256Kb).
;Инструменты: NASM.
;Модули: VGA-X, VX_SYS, VX_PIXEL.
;Авторы: Данила Перов(peroff@protonmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.
;Краткая история изменений:
;ДД.ММ.ГГ, И.И.: Короткое сообщение что добавлено, удалено или исправлено.

%include "VGA-X.ASM"            ;Директива включения заголовка для NASM.

;Краткое описание демонстрации на русском добавить, один абзац.
;Комментарии на русском тоже добавить, желательно чтобы было понятно,
;как именно можно использовать тестируемую процедуру.

        org 100h                ;COM файл.
        pushf

        ; function to test
        mov     si, VXSetPixel
        ; mov     si, VXSetPixelFast
        mov     di, VXGetPixel
        ; mov     di, VXGetPixelFast

        call    VXSetModeX
        mov     ax, GFX_SCR_ADDR
        mov     es, ax
        mov al,0Fh
        xor cx,cx
Dem2:   xor dx,dx
Dem1:   call VXSetPixel
        ;call VXSetPixelFast
        inc dx
        cmp dx,320
        jne short Dem1
        inc cx
        cmp cx,240
        jne short Dem2

        xor cx,cx
Dem4:   mov dx,0001h
Dem3:   call near VXGetPixel
        dec dx
        dec al                          ;Prev color.
        call near VXSetPixel
        inc dx
        inc dx
        cmp dx,320
        jne short Dem3
        inc cx
        cmp cx,240
        jne short Dem4

        jmp short Dem0

        mov     ax, GFX_SCR_ADDR
        mov     es, ax
        mov     al, 2           ; green color
        xor     dx, dx          ; x = 0
        xor     cx, cx          ; y = 0
        ; top side
Lp1:    call    si              ; SetPixel
        inc     dx              ; x++
        cmp     dx, GFX_WIDTH
        jb      short Lp1

        ; right side
        dec     dx              ; x--
        inc     cl              ; y++
Lp2:    call    si              ; SetPixel
        inc     cl              ; y++
        cmp     cl, GFX_HEIGHT
        jb      short Lp2

        ; bottom side
        dec     cl              ; y--
        dec     dx              ; x--
Lp3:    call    si              ; SetPixel
        dec     dx              ; x--
        jns     short Lp3

        ; left side
        inc     dx              ; x++
        dec     cl              ; y--
Lp4:    call    si              ; SetPixel
        dec     cl              ; y--
        jnz     short Lp4

        ; diagonal line from left-top to right-bottom
        mov     al, 4           ; red color
        mov     dx, 1           ; x = 1
        mov     cl, 1           ; y = 1
Lp5:    call    si              ; SetPixel
        inc     dx              ; x++
        inc     cl              ; y++
        cmp     cl, GFX_HEIGHT - 1 - 1
        jna     short Lp5

        ; diagonal line from right-top to left-bottom
        mov     al, 5           ; purple color
        mov     dx, GFX_WIDTH - 1 - 1 ; x = width-2
        mov     cl, 1           ; y = 1
Lp6:    call    si              ; SetPixel
        dec     dx              ; x--
        inc     cl              ; y++
        cmp     cl, GFX_HEIGHT - 1 - 1
        jna     short Lp6

        mov     ah, 00h         ; Press any key.
        int     16h

        ; redraw all lines
        xor     dx, dx          ; x = 0
        xor     cx, cx          ; y = 0
Lp7:    call    di              ; GetPixel
        cmp     al, 2           ; green
        je      short Redraw
        cmp     al, 4           ; red
        je      short Redraw
        cmp     al, 5           ; purple
        jne     short NextPxl
Redraw: mov     al, 13          ; bright purple
        call    si              ; SetPixel
NextPxl:
        inc     dx              ; x++
        cmp     dx, GFX_WIDTH
        jb      Lp7
        xor     dx, dx          ; x = 0
        inc     cx              ; y++
        cmp     cx, GFX_HEIGHT
        jb      Lp7

Dem0:   mov     ah, 00h         ; Press any key.
        int     16h
        popf
        ret

%include "VX_SYS.ASM"                   ;Библиотечные процедуры.
%include "VX_PIXEL.ASM"
