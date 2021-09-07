;8-Bit Tea Party!
;License: Creative Commons.

;Пока что общий файл вместе с тестированием и работой с палитрой адаптера.
;Позже уже разделим на файл демонстрации и непосредственно на файл процедуры.

CPU 8086                                ;Поменять дриективы, если другой асм.

;Список пожеланий на правки:
;1. Постараться переделать структура вызовов в процедуре, более плоский код с
;циклами и биты по типу палитры.
;2. Почистить метки и желательно отступы.
;3. Обязательно добавить подробные комментарии в код процедуры, можно на
;русском или английском. Можно использовать комментарии на всю строку. Для
;Демо кода комменатрии желательны, особенно в части вызова.
;4. Процедуры записи/чтения отдельного цвета, вынести и оформить.
;5. Черновик процедуры установки точки по координатам.

;Используем пока константы, которые здесь и после их перенесем в глобальный
;файл имен либо в заголовок библиотеки режима Х.

SCR_GFX_ADDR            EQU 0A000H      ;Сегментный адрес графического экрана.

;Video DAC palette registers.

VGA_DAC_WRITE           EQU 3C8h
VGA_DAC_READ            EQU 3C7h
VGA_DAC_DATA            EQU 3C9h
VGA_PEL_MASK            EQU 3C6h

        org 100h

        pushf
        mov ax,13h                      ;13h standard video mode.
        int 10h

        mov     di, palette_rgb_6
        xor     ax, ax
        xor     cx, cx
        mov     si, 100h

        mov     bl, 0           ;Пометить как начало цикла и его параметры.
        mov     bh, 0           ;Регистры - отвечают за Н, кратко.
        mov     dl, 0
Lp1:
; rrrrrrgg ggggbbbb bbrrrrrr ggggggbb bbbbrrrr rrgggggg bbbbbbrr rrrrgggg
; ggbbbbbb
        mov     al, bl
        mov     cl, 2
        shl     al, cl
        mov     cl, 8
        sub     cl, ch          ;Не совсем ясно зачем вычитать 8 - 0.
        shr     ah, cl          ;АН - неопределен
        shl     ax, cl
        add     ch, 6           ;Магические цифры.
        cmp     ch, 8           ;Использовать циклы или параметры сдвига.
        jb short Lbl1           ;Не забыть длину адреса.
        mov     [di], ah        ;Сохраняем таблицу.
        inc     di
        mov     cl, 8           ;8 раз, возможно можно скопировать части.
        shl     ax, cl          ;Зачем сдвигать именно 16 бит.
        sub     ch, cl          ;Если можно просто задать.

Lbl1:   mov     al, bh          ;Можно просто применять поток байт, два,
        mov     cl, 2           ;и применять один общий цикл, заполнять.
        shl     al, cl
        mov     cl, 8
        sub     cl, ch
        shr     ah, cl
        shl     ax, cl
        add     ch, 6
        cmp     ch, 8
        jb      Lbl2
        mov     [di], ah
        inc     di
        mov     cl, 8
        shl     ax, cl
        sub     ch, cl

Lbl2:   mov     al, dl
        mov     cl, 2
        shl     al, cl
        mov     cl, 8
        sub     cl, ch
        shr     ah, cl
        shl     ax, cl
        add     ch, 6
        cmp     ch, 8
        jb      Lbl3
        mov     [di], ah
        inc     di
        mov     cl, 8
        shl     ax, cl
        sub     ch, cl

Lbl3:   mov     bp, si          ;Сохраняем СИ и используем БП.
        and     bp, 11000000b   ;Подпсиываем маски и что она делает.

        cmp     bp, 11000000b   ;Эти манипуляции остались загадкой.
        jnz     Lbl4
        inc     bl
        and     bl, 00111111b
Lbl4:
        cmp     bp, 10000000b   ;Сравнение 16-ти и 8битного числа.
        jnz short Lbl5
        inc     bh
        and     bh, 00111111b
Lbl5:   cmp     bp, 00000000b
        jnz     Lbl6
        inc     bh
        and     bh, 00111111b
Lbl6:
        cmp     bp, 01000000b
        ja      Lbl7
        inc     dl
        and     dl, 00111111b
Lbl7:
        dec     si              ;Пометить как конец большого цикла, индексы.
        jnz     Lp1

        mov     al, 0
        mov     ah, 0
        mov     cl, 18          ;Типы палитры исправить на биты.
        mov     dx, palette_rgb_6
        call near VXSetPalette  ;Тип вызова обязателен в библиотеке, для
                                ;возможной будущей линковки сегм.
        call near ColorTableDraw

        mov ah,00h                      ;Press any key...
        int 16h

        ;jmp near ToRet

        mov     di, palette_rgb_8
        mov     cx, 64
        mov     bl, 0
Lp2:    mov     al, bl
        stosb
        mov     al, 0
        stosb
        mov     al, 0
        stosb
        inc     bl
        loop    Lp2
        mov     cx, 64
        mov     bl, 0
Lp3:    mov     al, 0
        stosb
        mov     al, bl
        stosb
        mov     al, 0
        stosb
        inc     bl
        loop    Lp3
        mov     cx, 64
        mov     bl, 0
Lp4:    mov     al, bl
        stosb
        mov     al, bl
        stosb
        mov     al, 0
        stosb
        inc     bl
        loop    Lp4
        mov     cx, 64
        mov     bl, 0
Lp5:    mov     al, bl
        stosb
        mov     al, 0
        stosb
        mov     al, bl
        stosb
        inc     bl
        loop    Lp5

        mov     al, 0
        mov     ah, 0
        mov     cl, 24
        mov     dx, palette_rgb_8
        call    VXSetPalette

        call near ColorTableDraw

ToRet:  mov     ah, 0
        int     16h
        popf
        ret

;Примеры данных для подачи на вход процедуры установки палитры.

palette_rgb_8   db 100h * 03h dup (0)   ;24бит * 256 цветов = 768 байт.
palette_rgb_6   db 240h dup (0)         ;18бит * 256 цветов = 576 байт.

;Процедура установки цветовой палитры для адаптера VGA, режим Х, 256 цветов).
; Для первой тренировки можно использовать стандартный формат RGB(8 бит), т.е.
;на каждый компонент по одному байту в массиве 256*3=768 байт. Если всё
;нормально заработало, то уже можно попробовать реалзовать максимально
;упакованный формат: 3байта(24 бита) упакованы по 6бит потоком RGBR, где
;последние 6бит уже являются компонентом следующего цвета и также, со
;смещением уже идут следущие цвета палитры.
; Функции вызова БИОС-а не использовать, напрямую работаем с железом и не
;забывать про прерывания. Комментарии приветствуются. :)
;
;Входные параметры:
;AL     индекс первого цвета для установки в таблице, 0..255;
;AH     количество цветов для установки(0..255, если 0, то полностью, 256);
;CL     тип палитры и резервные биты:
;0      18 - упакованный формат RGBR (6-6-6-6);
;1      24 - распакованный формат RGB (8-8-8);
;2      32 - формат BMP файла, BGRA (8-8-8-8);
;3..7   резерв.
;DS:DX  адрес таблицы компонентов цветов, только на чтение, контроль данных
;       на стороне вызова.

VXSetPalette:
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp

        cmp     cl, 18                  ;18 bits check.
        jnz     VXSetPal1               ;Удобней команда test.
        mov     di, Read6666Color
        xor     bp, bp
        mov     ch, 0
        jmp     VXSetPalRun
VXSetPal1:                              ;SetPal1:... SetPalA, B...
        cmp     cl, 24
        jnz     VXSetPal2
        mov     di, Read888Color
        jmp     VXSetPalRun             ;Процедуры лучше уложить в 16 симв.
VXSetPal2:
        cmp     cl, 32
        jnz     VXSetPalExit
        mov     di, Read8888Color

VXSetPalRun:
        mov     bl, ah                  ;Тестирование счетчика на 256.
        mov     bh, 0
        test    bx, bx
        jnz     VXSetPal3
        mov     bx, 100h                ;Не расходовать 16 бит.

VXSetPal3:
        mov     si, dx
        cld

        cli
        mov     dx, VGA_DAC_WRITE
        out     dx, al
        mov     dx, VGA_DAC_DATA
VXSetPalLp:
        push    bx
        call    di              ;Косвенный вызов желательно использовать
        out     dx, al          ;только в самом крайнем случае и стараться
        mov     al, bl          ;в целом не злопотреблять вызовами.
        out     dx, al          ;19 тиков + 3 байта, 28 тактов на дальный
        mov     al, bh          ;+ 5байт + 4-8 такта на трансфер.
        out     dx, al          ;Активней используй циклы если возможно.
        pop     bx

        dec     bx
        jnz     VXSetPalLp
        sti

VXSetPalExit:
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

;

Read6666Color:
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        mov     bh, al
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        mov     bl, al
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        xchg    bh, al
        ret

Read6666ColNeed6Bits:
        cmp     ch, 6
        jae     Read6666ColNeed6BitsExit
        mov     ah, 0
        lodsb                           ;аккуратнее с флагом направления.
        mov     cl, 8
        sub     cl, ch
        shl     ax, cl                  ;Можно смещать данные влево-вправо.
        or      bp, ax                  ;Циклический сдвиг использовать.
        add     ch, 8
Read6666ColNeed6BitsExit:
        ret

Read6666ColGet6Bits:
        mov     ax, bp
        mov     cl, 6
        shl     bp, cl
        sub     ch, cl
        rol     ax, cl
        and     al, 00111111b
        ret

Read888Color:
        lodsw
        mov     bl, ah
        mov     bh, al
        lodsb
        xchg    bh, al
        ret

Read8888Color:
        lodsw           ; gb
        mov     cl, 2
        shr     ah, cl
        shr     al, cl
        mov     bl, ah
        mov     bh, al
        lodsb           ; r
        shr     al, cl
        inc     si      ; a
        ret

; Set one color of the palette

; Input:
;   AL = color
;   AH = r
;   BL = g
;   BH = b
VXSetPalColor:
        push    ax
        push    dx
        cli
        mov     dx, VGA_DAC_WRITE
        out     dx, al          ; color
        mov     dx, VGA_DAC_DATA
        mov     al, ah
        out     dx, al          ; r
        mov     al, bl
        out     dx, al          ; g
        mov     al, bh
        out     dx, al          ; b
        sti
        pop     dx
        pop     ax
        ret

; Get one color of the palette

; Input:
;   AL = color
; Output:
;   AH => r
;   BL => g
;   BH => b
VXGetPalColor:
        push    cx
        push    dx
        mov     cl, al          ; save color
        cli
        mov     dx, VGA_DAC_READ
        out     dx, al          ; color
        mov     dx, VGA_DAC_DATA
        in      al, dx          ; r
        mov     ah, al
        in      al, dx          ; g
        mov     bl, al
        in      al, dx          ; b
        mov     bh, al
        sti
        mov     al, cl          ; restore color
        pop     dx
        pop     cx
        ret

;Draw standard palette to screen.

ColorTableDraw:
        pushf
        push ax
        push dx
        push si
        push di
        push es
        mov ax,SCR_GFX_ADDR
        mov es,ax                       ;Screen.
        xor di,di                       ;3clk
        ;sub di,di                       ;3clk
        mov si,di
        cld                             ;Forward.
        mov dx,0C8h                     ;200.
CTabDr2:mov di,si
        mov cx,0100h                    ;All 256 colors.
CTabDr1:mov es:[di],al
        inc al
        inc di
        loop CTabDr1
        add si,0140h
        dec dx
        jnz short CTabDr2
        pop es
        pop di
        pop si
        pop dx
        pop ax
        popf
        ret
