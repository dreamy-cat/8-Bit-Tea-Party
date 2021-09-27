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

; Set VGA palette
;
; Input:
;   AL = first color
;   AH = count of colors to be set
;   CL = input data format and reserve:
;     bit 0: packed format RGBR (6-6-6-6)
;         1: unpacked format RGB (8-8-8)
;         2: BMP file format, BGRA (8-8-8-8)
;         3..7: reserve
;   DS:DX = color table address

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
        test    cl, 00000001b
        jz      SetPal1
        ; packed format
        mov     di, ReadPackedClr ; decoder func
        xor     bp, bp          ; bit buffer
        mov     ch, 0           ; number of bits in buffer
        jmp     near SetPal3
SetPal1:
        test    cl, 00000010b
        jz      SetPal2
        ; unpacked format
        mov     di, ReadUnpckdClr ; decoder func
        ; no registers used by decoder
        jmp     near SetPal3
SetPal2:
        test    cl, 00000100b
        jz      SetPalExit
        ; BMP format
        mov     di, ReadBMPClr ; decoder fun
; no registers used by decoder - russian.

SetPal3:
        mov     bl, ah          ; number of colors
        mov     bh, 0
        test    bx, bx
        jnz     SetPal4
        mov     bx, 100h        ; 0 means 256 colors
SetPal4:
        cld
        cli                     ; interrupts off
        mov     si, dx          ; color table
        mov     dx, VGA_DAC_WRITE
        out     dx, al          ; write first color to DAC
        mov     dx, VGA_DAC_DATA
SetPalLp:
        push    bx              ; save counter
        ; call decoder function
        ; it should read bytes from input stream, parse one color entry and
        ; return:
        ;   al = r
        ;   bl = g
        ;   bh = b
        call    di              ;Danger code! :)
        out     dx, al          ; write r
        mov     al, bl
        out     dx, al          ; write g
        mov     al, bh
        out     dx, al          ; write b
        pop     bx              ; restore counter

        dec     bx              ; counter--
        jnz     SetPalLp
        sti                     ; interrupts on

SetPalExit:
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

ReadPackedClr:
        ; decode packed format
        ; read from bit buffer three 6-bit values
        push    dx
        mov     dl, 0           ; component index: 0 = r, 1 = g, 2 = b
ReadPackedLp:
        ; ensure that bit buffer contains at least 6 bits ready to read,
        ; read more data from input stream to the buffer if needed
        cmp     ch, 6           ; are there at least 6 bits?
        jae     ReadPacked1
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
ReadPacked1:
        ; get 6 bits from bit buffer to AL
        mov     ax, bp          ; AX = bit buffer = ddddddxx xxxxxxxx
        mov     cl, 6
        shl     bp, cl          ; remove 6 bits from buffer
        sub     ch, cl          ; bits -= 6
        rol     ax, cl          ; xxxxxxxx xxdddddd
        and     al, 00111111b   ; 00dddddd

        cmp     dl, 0
        jnz     ReadPacked2
        mov     bh, al          ; bh = r (temp)
        jmp     short ReadPacked4
ReadPacked2:
        cmp     dl, 1
        jnz     ReadPacked3
        mov     bl, al          ; bl = g
        jmp     short ReadPacked4
ReadPacked3:
        xchg    bh, al          ; al = r, bh = b
ReadPacked4:
        inc     dl              ; next color component
        cmp     dl, 3
        jb      ReadPackedLp

        pop     dx
        ret

ReadUnpckdClr:
        ; decode unpacked format
        ; just read 3 bytes
        lodsw                   ; g r
        mov     bl, ah          ; bl = g
        mov     bh, al          ; bh = r (temp)
        lodsb                   ; b
        xchg    bh, al          ; al = r, bh = b
        ret

ReadBMPClr:
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

;Переделать немного регистры, в AX:DX.

; Input:
;   AL = color
;   AH = r
;   BL = g              ;BX -> DL and DH.
;   BH = b

VXSetPalColor:
;Сохраняем флаги, всегда.
        pushf
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
        sti                       ;Neponal.
        pop     dx
        pop     ax
        popf
        ret

; Get one color of the palette

;Доделать, оформить.

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
        mov ax,GFX_SCR_ADDR
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
