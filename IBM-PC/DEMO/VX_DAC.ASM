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

        ; fill packed 6-6-6-6 palette
        mov     di, palette_rgb_6
        xor     ax, ax          ; bit buffer for output stream
        xor     cx, cx          ; ch = number of bits in buffer
                                ; Example:
                                ;   AX = rrrrrr00 00000000
                                ;   CH = 6
        mov     si, 100h        ; counter of colors

        mov     bl, 0           ; current R
        mov     bh, 0           ; current G
        mov     dl, 0           ; current B
Lp1:
        mov     al, bl          ; add R to bit buffer: xxxx???? 00rrrrrr
        mov     cl, 2
        shl     al, cl          ; move to left byte side: xxxx???? rrrrrr00
        mov     cl, 8
        sub     cl, ch          ; 8-CH = free bits in AH
        shr     ah, cl          ; move data to right edge: 0000xxxx rrrrrr00
        shl     ax, cl          ; move data with R to buffer begin:
                                ;   xxxxrrrr rr000000
        add     ch, 6           ; bits += 6
        cmp     ch, 8           ; is there at least one full byte?
        jb      Lbl1
        mov     [di], ah        ; yes, write it to the palette
        inc     di
        mov     cl, 8
        shl     ax, cl          ; remove from buffer
        sub     ch, cl          ; bits -= 8

Lbl1:   mov     al, bh          ; add G to bit buffer
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

Lbl2:   mov     al, dl          ; add B to bit buffer
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
        and     bp, 11000000b   ; bp = number of quarter of palette

        cmp     bp, 11000000b   ; red - only in 1st part
        jnz     Lbl4
        inc     bl              ; r++
        and     bl, 00111111b
Lbl4:
        cmp     bp, 10000000b   ; green - in 2nd and 4th parts
        jnz     Lbl5
        inc     bh              ; g++
        and     bh, 00111111b
Lbl5:   cmp     bp, 00000000b
        jnz     Lbl6
        inc     bh              ; g++
        and     bh, 00111111b
Lbl6:
        cmp     bp, 01000000b   ; blue - in 3rd and 4th parts
        ja      Lbl7
        inc     dl              ; b++
        and     dl, 00111111b
Lbl7:
        dec     si              ; counter--
        jnz     Lp1

        mov     al, 0           ; first color
        mov     ah, 0           ; all 256 colors
        mov     cl, 18          ; packed format
        mov     dx, palette_rgb_6
        call    VXSetPalette

        call near ColorTableDraw

        mov ah,00h                      ;Press any key...
        int 16h

        ; fill unpacked 8-8-8 palette
        mov     di, palette_rgb_8
        mov     cx, 64          ; first 64 colors
        mov     bl, 0
Lp2:    mov     al, bl          ; r = counter
        stosb
        mov     al, 0           ; g = 0
        stosb
        mov     al, 0           ; b = 0
        stosb
        inc     bl
        loop    Lp2
        mov     cx, 64          ; next 64 colors
        mov     bl, 0
Lp3:    mov     al, 0           ; r = 0
        stosb
        mov     al, bl          ; g = counter
        stosb
        mov     al, 0           ; b = 0
        stosb
        inc     bl
        loop    Lp3
        mov     cx, 64          ; next 64 colors
        mov     bl, 0
Lp4:    mov     al, bl          ; r = counter
        stosb
        mov     al, bl          ; g = counter
        stosb
        mov     al, 0           ; b = 0
        stosb
        inc     bl
        loop    Lp4
        mov     cx, 64          ; next 64 colors
        mov     bl, 0
Lp5:    mov     al, bl          ; r = counter
        stosb
        mov     al, 0           ; g = 0
        stosb
        mov     al, bl          ; b = counter
        stosb
        inc     bl
        loop    Lp5

        mov     al, 0           ; first color
        mov     ah, 0           ; all 256 colors
        mov     cl, 24          ; unpacked format
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

        ; analyze format and set up it's decoder func
        cmp     cl, 18
        jnz     VXSetPal1
        ; packed format
        mov     di, Read6666Color ; decoder func
        xor     bp, bp          ; bit buffer
        mov     ch, 0           ; number of bits in buffer
        jmp     VXSetPalRun
VXSetPal1:
        cmp     cl, 24
        jnz     VXSetPal2
        ; unpacked format
        mov     di, Read888Color ; decoder func
        ; no registers used by decoder
        jmp     VXSetPalRun
VXSetPal2:
        cmp     cl, 32
        jnz     VXSetPalExit
        ; BMP format
        mov     di, Read8888Color ; decoder func
        ; no registers used by decoder

VXSetPalRun:
        mov     bl, ah          ; number of colors
        mov     bh, 0
        test    bx, bx
        jnz     VXSetPal3
        mov     bx, 100h        ; 0 means 256 colors
VXSetPal3:
        mov     si, dx
        cld

        cli                     ; interrupts off
        mov     dx, VGA_DAC_WRITE
        out     dx, al          ; write first color to DAC
        mov     dx, VGA_DAC_DATA
VXSetPalLp:
        push    bx              ; save counter
        ; call decoder function
        ; it should read bytes from input stream, parse one color entry and
        ; return:
        ;   al = r
        ;   bl = g
        ;   bh = b
        call    di
        out     dx, al          ; write r
        mov     al, bl
        out     dx, al          ; write g
        mov     al, bh
        out     dx, al          ; write b
        pop     bx              ; restore counter

        dec     bx              ; counter--
        jnz     VXSetPalLp
        sti                     ; interrupts on

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
        ; decode packed format
        ; read from bit buffer three 6-bit values
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        mov     bh, al          ; bh = r (temp)
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        mov     bl, al          ; bl = g
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        xchg    bh, al          ; al = r, bh = b
        ret

Read6666ColNeed6Bits:
        ; ensure that bit buffer contains at least 6 bits ready to read
        ; read more data from input stream to the buffer if needed
        cmp     ch, 6           ; are there at least 6 bits?
        jae     Read6666ColNeed6BitsExit
        mov     ah, 0           ; no, we need more data
        lodsb                   ; load new byte to AX (00000000 dddddddd)
        mov     cl, 8
        sub     cl, ch          ; 8-CH = number of free bits in high byte
                                ; Example:
                                ;   BP = xx000000 00000000
                                ;   CH = used = 2, CL = free = 6
        shl     ax, cl          ; AX = 00dddddd dd000000
        or      bp, ax          ; bit buffer = BP = xxdddddd dd000000
        add     ch, 8           ; bits += 8
Read6666ColNeed6BitsExit:
        ret

Read6666ColGet6Bits:
        ; get 6 bits from bit buffer to AL
        mov     ax, bp          ; AX = bit buffer = ddddddxx xxxxxxxx
        mov     cl, 6
        shl     bp, cl          ; remove 6 bits from buffer
        sub     ch, cl          ; bits -= 6
        rol     ax, cl          ; xxxxxxxx xxdddddd
        and     al, 00111111b   ; 00dddddd
        ret

Read888Color:
        ; decode unpacked format
        ; just read 3 bytes
        lodsw                   ; g r
        mov     bl, ah          ; bl = g
        mov     bh, al          ; bh = r (temp)
        lodsb                   ; b
        xchg    bh, al          ; al = r, bh = b
        ret

Read8888Color:
        ; decode BMP format
        ; read 3 bytes and skip 4th. BGRA!, not rgba
        lodsw                   ; g b
        mov     cl, 2
        shr     ah, cl          ; 8 bit value to 6 bit
        shr     al, cl
        mov     bl, ah          ; g
        mov     bh, al          ; b
        lodsb
        shr     al, cl          ; r
        inc     si              ; skip alpha
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
