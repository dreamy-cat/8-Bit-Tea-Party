;8-Bit Tea Party! 2021.
;License: Creative Commons.
;Platform: 8086/87, VGA(256Kb), DOS.
;Tools: NASM.
;Author: Daniil Peroff.

CPU 8086

%include "VGA-X.ASM"            ;NASM.

; Draw a pixel to coordinates X and Y with color С to active page, in Mode-X.
;Using VGA-X constants for screen parameters. Check for data correctnes.
;Input:
;AL     color index from table, 0..255;
;AH     index video page to write(0..2);
;DX     horizontal coordinate X(left-right), 0..319;
;CX     vertical coordinate Y(up-down), 0..239;
;Output: videobuffer.

; Процедура рисования отдельного пикселя по координатам экрана горизонталь X,
;вертикаль Y и цвет Z в заданную страницу адаптера(относительное смещение)
;режима Х. Глобальные параметры экрана в заголовочном файле библиотеки.
;Простая проверка параметров на допустимость.
;Вход:
;AL     индекс цвета в таблице, 0..255;
;AH     индекс видео страницы для записи(0..2);
;DX     горизонтальная координата в точках X, 0..319;
;CX     вертикальная координата в точках Y, 0..239;
;Выход: измененный видео буффер.

VXSetPixel:
        pushf
        ; checks
        cmp     bx, GFX_WIDTH
        jae     VXPutPixelExit
        cmp     cl, GFX_HEIGHT
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
        mov     dx, VGA_SEQUENCER_ADDR
        mov     al, 02h         ; mask register addr
        out     dx, ax

        ; calc byte address
        mov     al, cl          ; Y
        mov     dl, GFX_BYTES_PER_LINE
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

; Процедура получения цвета пикселя С из страницы видеобуффера по заданным
;координатам по горизонтали X, вертикали Y в режиме X. Глобальные параметры
;экрана в заголовочном файле библиотеки. Активная страница является смещением
;в буффере. Простая проверка входных данных на корректность. Вернуть регистр
;AH неизменным, для удобства внешних вызовов(возможно пригодится).
;Вход:
;AH     индекс видео страницы для записи(0..2);
;DX     горизонтальная координата в точках X, 0..319;
;CX     вертикальная координата в точках Y, 0..239;
;Выход:
;AL     индекс цвета в таблице, 0..255;

VXGetPixel:
        pushf

        popf
        ret
