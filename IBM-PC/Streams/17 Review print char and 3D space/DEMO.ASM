;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;Вещание 17. Точка в пространстве и процедура печати символа.

;План вещания, 01.11.2021.

;- оформление процедуры генератора случайных чисел и демонстрации вызова.
;- ревью кода печати символа в графическом режиме(Данила Перов).
;- установка точки в пространстве и эффект космоса.

;Демка для изучения ассемблера и архитектуры процессора Intel 8086/87.
;Несколько анимированных эффектов, сколько успеем и что сможем. :)
;Дата старта: 01.06.2021.
;Дата выхода проекта: 31.12.2021 ну или раньше, как будет удобней.

;Общее описание и платформа(подробнее в файле 'readme.dos').

;Платформа: ДОС-совместимая от условной версии 5.0, реальный режим адресации.
;Процессор: только 8086(88) и математический сопроцессор 8087.
;Основная память: 64Кб для кода и стека(модель минимальная). Остальные данные
;желательно уложить в 512Кб. Для запуска на "тяжелых" ДОС конфигурациях.
;Расширенная память: через драйвер XMS, не более 16Мб(не защищенный режим).
;Графический адаптер: IBM VGA, 256Кб, 6 бит на цвет, палитра 2^18 цветов,
;графический Х-режим, 320x240x8бит на цвет по таблице.
;Звуковая плата: Adlib/SBPro(OPL2/OPL3), FM - частотная модуляция.
;Формат файла: .COM, 64Kb, использовать функции ДОС-а для запроса памяти.

CPU 8086                                ;8087 as math. coprocessor.

%include "VGA-X.ASM"

;Эффект космоса с полным 3Д.

CENTER_3D_X     EQU 1000h               ;Center of projection coordinates.
CENTER_3D_Y     EQU 1000h

SPACE_STARS     EQU 0FFh                ;Stars in space, max 255.
SPACE_COLORS    EQU 00Fh                ;All standard and colors.
STAR_SIZE_B     EQU 08h                 ;Mask for stars depth/delay.
SPACE_MASK_X    EQU 1FFFh               ;Mask for horizontal star position.
SPACE_MASK_Y    EQU 1FFFh               ;Mask for vertical star position.
SPACE_MASK_Z    EQU 00FFh               ;Mask for star depth.
SPACE_MULT      EQU 0080h               ;Factor for XY.

;Move space with stars to diff ways.

        org 100h                        ;PSP.
        pushf
        call near VXSetModeX            ;Init gfx.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        lea si,stars_xyz                ;Check data.


        mov ax,0FA0Fh
        call near RandomSimple          ;Random init.
        xor al,al
        mov ah,SPACE_STARS

        call near CreateStars3D
        ;mov al,0Fh
        ;call near DrawSpace3D
        ;jmp near Dem0

        lea di,stars_move
        mov bh,01h
        mov bl,00000001b                ;Active screen.
Space2: mov cx,1000h                            ; main cycle
Space1: push cx
        mov ah,00h
        ;int 16h
        call near VXWaitVSync
        mov al,bl
        call near VXSetActDispPage
        push cx
        push di
        push es
        mov cx,GFX_SCR_ADDR
        mov es,cx
        xor ah,ah
        and al,00000011b
        mov dx,GFX_PAGE_SIZE_B
        mov cx,GFX_PAGE_SIZE_W
        mul dx
        mov di,ax
        mov al,00001111b
        call near VXSetPlanes
        xor ax,ax
        cld
        rep stosw
        pop es
        pop di
        pop cx
        call near MoveSpace3D
        call near DrawSpace3D
        xor bl,00000101b
        pop cx
        loop Space1
        add di,0006h
        dec bh
        jnz short Space2
        jmp near Dem0


Dem0:   mov ah,00h                      ;Press any key.
        int 16h
        popf
        ret

;3 words with parameters X,Y,Z and reserved word.

stars_xyz:      dw 4 * SPACE_STARS dup (0000h)   ;In every direction.

stars_move:     dw 0h, 0h, -03h
                dw 0h, SPACE_MULT, 0h
                dw -SPACE_MULT, SPACE_MULT, 0h
                dw -SPACE_MULT, 0h, 0h
                dw -SPACE_MULT, -SPACE_MULT, 0h
                dw 0h, -SPACE_MULT, 0h
                dw SPACE_MULT, -SPACE_MULT, 0h
                dw SPACE_MULT, 0h, 0h
                dw SPACE_MULT, SPACE_MULT, 0h


;DS:DI - moving directions with words.

MoveSpace3D:
        pushf
        push ax
        push bx
        push cx
        push di

        lea bx,stars_xyz
        xor cl,cl
        xor ch,ch
MovS3D1:mov ax,[bx]
        add ax,[di]                     ;Add X.
        ;jc short MovS3D2
        cmp ax,SPACE_MASK_X             ;2D projection coordinate, not do.
        jnc short MovS3D2
        mov [bx],ax
        mov ax,[bx+02h]
        add ax,[di+02h]                 ;Add Y.
        ;jc short MovS3D2
        cmp ax,SPACE_MASK_Y             ;2D projection coordinate, not do.
        jnc short MovS3D2
        mov [bx+02h],ax
        mov ax,[bx+04h]
        add ax,[di+04h]                 ;Add Z.
        cmp ax,SPACE_MASK_Z
        jnc short MovS3D2
        mov [bx+04h],ax
        jmp short MovS3D3
MovS3D2:mov al,ch                       ;Store.
        mov ah,01h
        call near CreateStars3D
MovS3D3:add bx,STAR_SIZE_B
        inc ch
        cmp ch,SPACE_STARS
        jnz short MovS3D1

        pop di
        pop cx
        pop bx
        pop ax
        popf
        ret

DrawSpace3D:
        pushf
        push ax
        push bx
        push cx
        mov cx,SPACE_STARS
        lea bx, stars_xyz
DrS3D1: mov al,[bx+06h]
        call near VXSetPixel3D
        add bx,STAR_SIZE_B
        loop DrS3D1
        pop cx
        pop bx
        pop ax
        popf
        ret

;Set pixel 3D. AL - color, BX - address of coordinates(X,Y,Z).

VXSetPixel3D:
        pushf
        push ax
        push cx
        push dx
        push bp
        push si

        mov bp,ax
        mov si,[bx+04h]                 ;Z parameter.
        test si,si
        jz short SPix3D0
        xor dx,dx
        mov ax,[bx]                     ;Coordinate x.
        sub ax,CENTER_3D_X
        jnc short SPix3D1
        not dx                          ;Negative.
        idiv si
        jmp short SPix3D2
SPix3D1:div si                          ;Unsigned.
SPix3D2:add ax,GFX_SCR_WIDTH / 2
        mov cx,ax                       ;X position.
        xor dx,dx
        mov ax,[bx+02h]                 ;Y
        sub ax,CENTER_3D_Y
        jnc short SPix3D3
        not dx
        idiv si
        jmp short SPix3D4
SPix3D3:div si
SPix3D4:add ax,GFX_SCR_HEIGHT / 2
        xchg cx,ax                      ;Position Y
        mov dx,ax
        mov ax,bp
        xor ah,ah                       ;Al - color.
        call near VXSetPixel

SPix3D0:pop si
        pop bp
        pop dx
        pop cx
        pop ax
        popf
        ret

;al - star index
;ah - counter

CreateStars3D:
        pushf
        push ax
        push bx
        push cx
        push di
        xor cx,cx
        xchg ch,ah
        lea di,stars_xyz
        mov cl,03h
        shl ax,cl
        add di,ax                       ;Star X.
        mov cl,ch
CrStar2:xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_X
CrStar0:mov [di],ax                     ;Store X.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_Y
        mov [di+02h],ax                 ;Store Y.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_Z
        test ax,ax
        jnz short CrStar3
        inc ax
CrStar3:mov [di+04h],ax                 ;Store Z.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_COLORS
        add ax,0010h
        mov [di+06h],ax
        add di,STAR_SIZE_B
        inc ch
        dec cl
        jnz short CrStar2
        pop di
        pop cx
        pop bx
        pop ax
        popf
        ret

;Other code.

FillVRAM:
        mov ax,GFX_SCR_ADDR
        mov es,ax
        xor di,di
        mov ax,0000h
        mov cx,2580h           ;Both pages 0 and 1.
        cld
SetMD1: stosw
        inc al
        inc ah
        and al,00001111b                ;CGA 16 colors, 0..15.
        and ah,00001111b
        loop SetMD1
        mov ax,000Fh
        mov cx,2580h                    ;Second page.
        cld
SetMD2: stosw
        inc al
        and al,00001111b                ;CGA 16 colors, 0..15.
        loop SetMD2
        mov ax,000Fh
        mov cx,2580h                    ;Second page.
        cld
SetMD3: stosw
        inc ah
        and ah,00001111b                ;CGA 16 colors, 0..15.
        loop SetMD3

        mov ah,00h
        int 16h
        mov al,04h
        call near VXSetActDispPage      ;Set second page.
        mov ah,00h
        int 16h
        mov al,04h
        add al,04h
        call near VXSetActDispPage      ;Set third page.

        jmp near Dem0

;3. Демонстрация организации памяти, с освобождением под ДОС-вызовы.

Mem:    mov ah,48h
        mov bx,0FFFFh
        int 21h
        mov ah,4Ah                     ;Resize memory segment.
        mov bx,1000h                   ;16 bytes multiply 4k = 64kb.
        ;mov es,ax                     ;ES - default.
        int 21h
        mov ah,48h                     ;Memory maximum.
        mov bx,0FFFFh
        int 21h
        mov ah,48h                     ;Allocate memory for BMP data.
        mov cx,12C0h                   ;4800 par, for screen 76800.
        int 21h
        push es
        mov es,ax
        mov ah,49h                     ;Free allocated memory block.
        int 21h
        pop es

;Memory allocation, so small, or using linker.

;4. Синхронизация по лучу, смена видео-страниц и выбор плоскости(вспом).
;Сказать про драйвера на всякий случай и настройки ДОСБокса.
;Параметры: фуллдабл=истина, ВСИНК для ДОСБокс включен.

VGASync:mov cx,0300h
        mov ax,GFX_SCR_ADDR
        mov es,ax
        cld
Wait1:  mov ax,0101h            ;Blue color.
        call near VXWaitVSync
        push cx
        xor di,di
        mov cx,2580h            ;Full page.
        rep stosw
        mov cx,0F000h
Wait2:  nop                     ;Empty command.
        nop
        nop
        loop Wait2
        mov ax,0202h
        xor di,di
        mov cx,2580h
        rep stosw
        pop cx
        loop Wait1

        jmp near Dem0

;Draw standard palette to screen for debug.

;ColorTableDraw:
        pushf
        popf
        ret

;Library procedures.

%include "vx_sys.asm"
%include "vx_pixel.asm"
%include "rnd_s.asm"
