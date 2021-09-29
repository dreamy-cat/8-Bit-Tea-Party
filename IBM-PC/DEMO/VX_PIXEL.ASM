;8-Бит Чаепитие! 2021.
;Лицензия: Creative Commons.
;Платформа: 8086, VGA(256Kb).
;Инструменты: NASM.
;Модули: VGA-X, VX_SYS.
;Авторы: Данила Перов(peroff@protonmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.
;Краткая история изменений:
;ДД.ММ.ГГ, И.И.: Короткое сообщение что добавлено, удалено или исправлено.

%include "VGA-X.ASM"            ;Директива включения заголовка для NASM.

; Процедура рисования отдельного пикселя по координатам экрана горизонталь X,
;вертикаль Y и цвет Z в активную страницу адаптера(относительное смещение)
;режима Х. Глобальные параметры экрана в заголовочном файле библиотеки.
;Простая проверка параметров на допустимость.
;Вход:
;AL     индекс цвета в таблице, 0..255;
;DX     горизонтальная координата в точках X, 0..319;
;CX     вертикальная координата в точках Y, 0..239;
;Выход: измененный видео буффер, в активной странице.

VXSetPixel:
        pushf
        ; checks
        cmp     dx, GFX_WIDTH
        jae     short SetPix0
        cmp     cx, GFX_HEIGHT
        jae     short SetPix0

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
;Можно было использовать вызов процедуры, но это накладные расходы.
        mov     dx, VGA_SEQUENCER_ADDR
        out     dx, ax          ; write mask to register
;Вычисление адреса смещения, для записи байта цвета.
        mov     al, cl          ; Y
        mov     dl, GFX_BYTES_PER_LINE  ;Коментарий.
        mul     dl
        shr     bx, 1           ; faster than shr bx,cl and cannot trash cl
        shr     bx, 1           ; X/4
        add     bx, ax          ; addr = Y*GFX_BYTES_PER_LINE + X/4
        add     bx, [vx_scr_active] ; go to active video page

        ; set byte and exit
        pop     ax
        mov     es:[bx], al
        pop     dx
        pop     bx
SetPix0:popf
        ret

; Быстрая версия процедуры рисования отдельного пикселя по координатам экрана
;горизонталь X, вертикаль Y и цвет Z в активную страницу адаптера
;(относительное смещение) режима Х. Глобальные параметры экрана в заголовочном
;файле библиотеки. Простая проверка параметров на допустимость.
; Оптимизация за счет отказа от инструкции MUL (очень медленной на 8086) и
;замены умножения сдвигами (см. подробную формулу в комментариях к коду
;ниже). Кроме того, не используется инструкция SHL(R) r,CL (также медленная),
;а маска битовых плоскостей формируется по результатам двух отдельных сдвигов
;на один бит вправо координаты X (после каждого анализируем carry флаг).
;При этом те же два сдвига параллельно участвуют в формировании смещения
;байта: как часть кода умножения и для удаления двух младших бит
;координаты X.
; Ядро функции занимает около 50 тактов в то время как один MUL в
;"классической" версии - 70-77 тактов.
;Вход:
;AL     индекс цвета в таблице, 0..255;
;DX     горизонтальная координата в точках X, 0..319;
;CX     вертикальная координата в точках Y, 0..239;
;Выход: измененный видео буффер, в активной странице.

VXSetPixelFast:
        pushf
        ; checks
        cmp     dx, GFX_WIDTH
        jae     short SPixF0
        cmp     cx, GFX_HEIGHT
        jae     short SPixF0

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
        jnc     short SPixF1    ; mask = mask<<2 if bit 1 of X set
        shl     ah, 1
        shl     ah, 1
SPixF1:
        mov     dx, VGA_SEQUENCER_ADDR
        out     dx, ax          ; write mask to register

        mov     dx, cx          ; Y
        shl     dx, 1           ;Размен памяти на скорость.
        shl     dx, 1
        shl     dx, 1
        shl     dx, 1           ; Y<<4
        add     bx, dx          ; offset = (Y<<8 + X)>>2 + Y<<4
        add     bx, [vx_scr_active] ; go to active video page

        ; set byte and exit
        pop     ax
        mov     es:[bx], al
        pop     dx
        pop     bx
SPixF0: popf
        ret

; Процедура получения цвета пикселя С из страницы видеобуффера по заданным
;координатам по горизонтали X, вертикали Y в режиме X. Глобальные параметры
;экрана в заголовочном файле библиотеки. Активная страница является смещением
;в буффере. Простая проверка входных данных на корректность.
;Вход:
;DX     горизонтальная координата в точках X, 0..319;
;CX     вертикальная координата в точках Y, 0..239;
;Выход:
;AL     индекс цвета в таблице, 0..255;

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
        add     bx, [vx_scr_active] ; go to active video page

        ; get byte and exit
        pop     ax
        mov     al, es:[bx]
        pop     dx
        pop     bx
GetPixelExit:

        popf
        ret

; Быстрая версия процедуры получения цвета пикселя С из страницы видеобуффера
;по заданным координатам по горизонтали X, вертикали Y в режиме X. Глобальные
;параметры экрана в заголовочном файле библиотеки. Активная страница является
;смещением в буффере. Простая проверка входных данных на корректность.
; Оптимизация за счет отказа от инструкции MUL (очень медленной на 8086) и
;замены умножения сдвигами (см. подробную формулу в комментариях к коду
;ниже).
;Вход:
;DX     горизонтальная координата в точках X, 0..319;
;CX     вертикальная координата в точках Y, 0..239;
;Выход:
;AL     индекс цвета в таблице, 0..255;

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
        add     bx, [vx_scr_active] ; go to active video page

        ; get byte and exit
        pop     ax
        mov     al, es:[bx]
        pop     dx
        pop     bx
GetPixelFExit:
        popf
        ret
