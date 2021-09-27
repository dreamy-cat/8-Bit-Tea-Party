;8-Бит Чаепитие! 2021.
;Лицензия: Creative Commons.
;Платформа: 8086, VGA(256Kb).
;Инструменты: NASM.
;Модули: VGA-X, VX_SYS, VX_DAC.
;Авторы: Данила Перов(peroff@protonmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.
;Краткая история изменений:
;ДД.ММ.ГГ, И.И.: Короткое сообщение что добавлено, удалено или исправлено.

%include "VGA-X.ASM"            ;Директива включения заголовка для NASM.

CPU 8086                        ;Поменять дриективы, если другой асссемблер.

;Описание демонстрации и использования процедур для работы с палитрой.
;Побольше доступных комментариев для тех, кто будет читать исходник.

        org 100h

        pushf
        mov ax,13h                      ;13h standard video mode.
        int 10h                         ;Уже использовать режим Х.

        ; fill packed 6-6-6-6 palette
        mov     di, palette_rgb_6
        xor     ax, ax          ; bit buffer for output stream
        mov     ch, 0           ; ch = number of bits in buffer
                                ; Example:
                                ;   AX = rrrrrr00 00000000
                                ;   CH = 6
        mov     si, 100h        ; counter of colors

        mov     bl, 0           ; current R
        mov     bh, 0           ; current G
        mov     dl, 0           ; current B

Lp1:
        mov     dh, 0           ; component index: 0 = R, 1 = G, 2 = B
CompLp:
        cmp     dh, 0
        jnz     CheckG
        mov     al, bl          ; add R to bit buffer: xxxx???? 00rrrrrr
        jmp     near AddToBuf
CheckG: cmp     dh, 1
        jnz     SetB
        mov     al, bh          ; add G to bit buffer: xxxx???? 00gggggg
        jmp     near AddToBuf
SetB:   mov     al, dl          ; add B to bit buffer: xxxx???? 00bbbbbb
AddToBuf:
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
        mov     ah, al          ; remove byte from buffer: rr000000 00000000
        sub     ch, 8           ; bits -= 8

Lbl1:   inc     dh              ; next color component
        cmp     dh, 3
        jb      CompLp

Lbl3:   cmp     si, 100h/4*3    ; red - only in 1st part
        jbe     Lbl4
        inc     bl              ; r++
        and     bl, 00111111b

Lbl4:   cmp     si, 100h/4*1    ; green - in 2nd and 4th parts
        ja      Lbl5
        inc     bh              ; g++
        and     bh, 00111111b
        jmp     near Lbl6
Lbl5:   cmp     si, 100h/4*3
        ja      Lbl6
        cmp     si, 100h/4*2
        jbe     Lbl6
        inc     bh              ; g++
        and     bh, 00111111b

Lbl6:   cmp     si, 100h/4*2    ; blue - in 3rd and 4th parts
        ja      Lbl7
        inc     dl              ; b++
        and     dl, 00111111b

Lbl7:   dec     si              ; counter--
        jnz     Lp1             ; next color

        ; do set new palette
        mov     al, 0           ; first color
        mov     ah, 0           ; all 256 colors
        mov     cl, 1           ; packed format
        mov     dx, palette_rgb_6
        call    near VXSetPalette

        call    near ColorTableDraw

        mov ah,00h                      ;Press any key...
        int 16h

        ; fill unpacked 8-8-8 palette
        mov     di, palette_rgb_8
        cld
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

        ; do set new palette
        mov     al, 0           ; first color
        mov     ah, 0           ; all 256 colors
        mov     cl, 2           ; unpacked format
        mov     dx, palette_rgb_8
        call    near VXSetPalette

        call    near ColorTableDraw

        mov     ah, 0
        int     16h
        popf
        ret

;Примеры данных для подачи на вход процедуры установки палитры.

palette_rgb_8   db 100h * 03h dup (0)   ;24бит * 256 цветов = 768 байт.
palette_rgb_6   db 240h dup (0)         ;18бит * 256 цветов = 576 байт.

%include "VX_DAC.ASM"           ;Процедуры по работе с VGA, DAC.
