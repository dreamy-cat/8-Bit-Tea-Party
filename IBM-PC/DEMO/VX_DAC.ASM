;8-Bit Tea Party!
;License: Creative Commons.

;Пока что общий файл вместе с тестированием и работой с палитрой адаптера.
;Позже уже разделим на файл демонстрации и непосредственно на файл процедуры.

CPU 8086                                ;Поменять дриективы, если другой асм.

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

        mov     bl, 0
        mov     bh, 0
        mov     dl, 0
Lp1:
; rrrrrrgg ggggbbbb bbrrrrrr ggggggbb bbbbrrrr rrgggggg bbbbbbrr rrrrgggg
; ggbbbbbb
        mov     al, bl
        mov     cl, 2
        shl     al, cl
        mov     cl, 8
        sub     cl, ch
        shr     ah, cl
        shl     ax, cl
        add     ch, 6
        cmp     ch, 8
        jb      Lbl1
        mov     [di], ah
        inc     di
        mov     cl, 8
        shl     ax, cl
        sub     ch, cl

Lbl1:   mov     al, bh
        mov     cl, 2
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

Lbl3:   mov     bp, si
        and     bp, 11000000b

        cmp     bp, 11000000b
        jnz     Lbl4
        inc     bl
        and     bl, 00111111b
Lbl4:
        cmp     bp, 10000000b
        jnz     Lbl5
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
        dec     si
        jnz     Lp1

        mov     al, 0
        mov     ah, 0
        mov     cl, 18
        mov     dx, palette_rgb_6
        call    VXSetPalette

        call near ColorTableDraw

        mov ah,00h                      ;Press any key...
        int 16h

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

        mov     ah, 0
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
;CL     количество битов на один цвет в палитре. Возможные значения:
;         18 - упакованный формат RGBR (6-6-6-6)
;         24 - распакованный формат RGB (8-8-8)
;         32 - формат BMP файла, BGRA (8-8-8-8)
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

        cmp     cl, 18
        jnz     VXSetPal1
        mov     di, Read6666Color
        xor     bp, bp
        mov     ch, 0
        jmp     VXSetPalRun
VXSetPal1:
        cmp     cl, 24
        jnz     VXSetPal2
        mov     di, Read888Color
        jmp     VXSetPalRun
VXSetPal2:
        cmp     cl, 32
        jnz     VXSetPalExit
        mov     di, Read8888Color

VXSetPalRun:
        mov     bl, ah
        mov     bh, 0
        test    bx, bx
        jnz     VXSetPal3
        mov     bx, 100h
VXSetPal3:
        mov     si, dx
        cld

        cli
        mov     dx, VGA_DAC_WRITE
        out     dx, al
        mov     dx, VGA_DAC_DATA
VXSetPalLp:
        push    bx
        call    di
        out     dx, al
        mov     al, bl
        out     dx, al
        mov     al, bh
        out     dx, al
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
        lodsb
        mov     cl, 8
        sub     cl, ch
        shl     ax, cl
        or      bp, ax
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
