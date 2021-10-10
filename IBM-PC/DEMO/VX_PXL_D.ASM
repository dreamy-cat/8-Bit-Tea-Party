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

; Демонстрация функций установки и считывания пикселя на экране. Сначала
;рисуем рамку вокруг экрана и две диагональные линии. Ждем нажатия клавиши.
;Затем сканируем экран и каждый НЕ черный пиксель перекрашиваем в розовый.
;Ждем клавишу. Заполняем экран попиксельно белым цветом, затем для каждого
;пикселя, начиная со второго, получаем его цвет и закрашиваем _предыдущий_
;пиксель цветом, отличающимся на единицу.

        org 100h                ;COM файл.
        pushf

        call    VXSetModeX

        ; варианты функций, которые тестируем
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
        cmp     dx, GFX_SCR_WIDTH
        jb      short Lp1

        ; right side
        dec     dx              ; x--
        inc     cl              ; y++
Lp2:    call    si              ; VXSetPixel(Fast)
        inc     cl              ; y++
        cmp     cl, GFX_SCR_HEIGHT
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
        cmp     cl, GFX_SCR_HEIGHT - 1 - 1
        jna     short Lp5

        ; diagonal line from right-top to left-bottom
        mov     al, 5           ; purple color
        mov     dx, GFX_SCR_WIDTH - 1 - 1 ; x = width-2
        mov     cl, 1           ; y = 1
Lp6:    call    si              ; VXSetPixel(Fast)
        dec     dx              ; x--
        inc     cl              ; y++
        cmp     cl, GFX_SCR_HEIGHT - 1 - 1
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
        cmp     dx, GFX_SCR_WIDTH
        jb      Lp7
        xor     dx, dx          ; x = 0
        inc     cx              ; y++
        cmp     cx, GFX_SCR_HEIGHT
        jb      Lp7

        mov     ah, 00h         ; Press any key.
        int     16h

        mov al,0Fh                      ; white color
        xor cx,cx                       ; y = 0
Dem2:   xor dx,dx                       ; x = 0
Dem1:   call si                         ; VXSetPixel
        inc dx
        cmp dx,GFX_SCR_WIDTH
        jne short Dem1
        inc cx
        cmp cx,GFX_SCR_HEIGHT
        jne short Dem2

        xor cx,cx                       ; y = 0
Dem4:   mov dx,0001h                    ; x = 1
Dem3:   call di                         ; VXGetPixel
        dec dx                          ; x--
        dec al                          ;Prev color.
        call si                         ; VXSetPixel
        inc dx
        inc dx
        cmp dx,GFX_SCR_WIDTH
        jne short Dem3
        inc cx
        cmp cx,GFX_SCR_HEIGHT
        jne short Dem4

        mov     ah, 00h         ; Press any key.
        int     16h
        popf
        ret

%include "VX_SYS.ASM"                   ;Библиотечные процедуры.
%include "VX_PIXEL.ASM"
