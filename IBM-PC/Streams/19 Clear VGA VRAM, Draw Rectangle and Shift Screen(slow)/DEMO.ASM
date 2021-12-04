;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;Вещание 19. Полноэкранные смещения в режиме Х и прямоугольники.

;План вещания, 18.11.2021.

;- обзор кода по выводу строки на экран в графике;
;- перенос и обновление прцоцедур в графическую библиотеку;
;- заполнение(очистка) видеобуфера адаптера по страницам;
;- рисуем прямоугольник с градиентом;
;- полноэкранные смещения, медленный метод.

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

RED_DEF_INDEX           EQU 000h        ;Indexes for default color palette.
GREEN_DEF_INDEX         EQU 040h
BLUE_DEF_INDEX          EQU 080h
BW_DEF_INDEX            EQU 0C0h

RECTS_SCREEN            EQU 040h        ;Rectangles on screen.
RECT_SIZE               EQU 08h         ;Data size.
RECT_OFFS_X             EQU 20h         ;Center and 256 pixels max.
RECT_OFFS_Y             EQU 38h         ;56 and 128 pixels max.

        org 100h                        ;PSP.
        pushf

        call near VXSetModeX            ;Init gfx.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        mov ax,0FA0Fh
        call near RandomSimple          ;Random init.
        jmp short start
        mov cx,03h
        mov ax,0101h
CWR1:   call near VXClearVRAM
        inc al
        shl ah,1
        loop CWR1
        mov cx,03h
        xor al,al
CWR2:   call near VXSetActDispPage
        mov dx,ax
        mov ah,00h
        INT 16h
        mov ax,dx
        add al,00000101b
        loop CWR2
        ;jmp short start

;1. Краткий обзор кода печати строки, всё отлично.

;2. Перемещение процедуры установки цветов по умолчанию,

;3. Тестирование процедуры очистки видео памяти адаптера.

;4. Рисование прямоугольников с градиентом, переделка.

start:  lea bx,rects_data
        mov cx,01h
        lea si,rects_color
        mov di,0004h            ;active and display page
        mov ax,0000h
RMove1: xor al,al
        call near VXSetActDispPage
        mov al,ch
        call near CreateRect
        mov word [bx],0000h
        mov word [bx + 02h],0000h
        mov word [bx + 04h],013Fh
        mov word [bx + 06h],00EFh
        mov al,01h
        mov ah,0
        call near VXDrawRect
        ;mov ax,di
        mov al,00000001b
        call near VXSetActDispPage
        mov al,01h;[si]
        mov ah,00h
        call near VXDrawRect
        add bx,RECT_SIZE
        inc si
        inc ch
        dec cl
        jnz short RMove1
        ;mov word [bx],0000h
        ;mov word [bx + 02h],0000h
        ;mov word [bx + 04h],013Fh
        ;mov word [bx + 06h],00EFh
        ;mov al,01h
        ;mov ah,01h
        ;call near VXDrawRect

;5. Полноэкранное смещение медленным методом.
        mov cx,80h          ;main cycle
        mov ah,00010001b
        mov dx,04h
        mov al,00h
        call near VXMoveScreen
        mov bl,00000001b      ;active page - 0, display page - 1
        mov dx,04h
RMove2: mov ah,00010001b
        call near VXWaitVSync
        mov di,ax
        mov al,bl
        xor al,00000101b
        call near VXSetActDispPage
        mov bl,al
        ;mov ah,00h
        ;INT 16h
        mov ax,di
        call near VXMoveScreen
        test cl,00000001h
        jnz short RMove3
        inc al
RMove3: loop RMove2
        ;call near VXSetFullDAC

Dem0:   mov ah,00h                      ;Press any key.
        int 16h
        popf
        ret

;Rectangles left-top and right-bottom pixels and color.

rects_data      dw RECTS_SCREEN * 4 dup (0000h)
rects_color     db RECTS_SCREEN dup (00h)

;Полноэкранное копирование страниц видео памяти адаптера.
;al - bits:
;0..1   source page index;
;2..3   destination page index;

VXCopyVRAM:
        pushf
        popf
        ret

;Полноэкранное смещение активной страницы вверх на количество точек и
;заполнение освободившегося пространства по правилам. Не используется смещение
;страниц адаптера и память за пределами страницы не изменяется.
;
;al - color to fill.
;ah bits:
;0..3   bits of direction left, right, up, down;
;4      fill with color all empty space;
;5..7   reserved.
;dx     size in pixels, screen size max.

VXMoveScreen:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push es
        push bp
        test dx,dx
        jz MovScrR
        mov di,GFX_SCR_ADDR
        mov es,di
        mov bx,ax
MovScr3:mov si,[vx_scr_active]
        mov di,si
        test bh,00001111b
        jz MovScrR
        test bh,00000001b              ; move left
        jz short MovScr0
        shr dx,1
        shr dx,1
        add si,dx
        cld
        mov bp,GFX_SCR_HEIGHT
MovScrD:mov cx,GFX_BYTES_PER_LINE
        sub cx,dx
MovScrB:mov al,00000001b
MovScrA:call VXSetPlanes
        mov ah,es:[si]
        mov es:[di],ah
        shl al,1
        test al,00010000b
        jz short MovScrA
        inc si
        inc di
        loop MovScrB
        test bh,00010000b
        jz short MovScrC
        mov al,00001111b
        call near VXSetPlanes
        
        mov al,bl
        mov cx,dx
        rep stosb
        add si,dx
MovScrC:dec bp
        jnz short MovScrD
        xor bh,00000001b
        jmp short MovScr3
MovScr0:test bh,00000010b
        jz short MovScr1
MovScr1:test bh,00000100b       ;move up, es:si -> es:di
        jz short MovScr2
        mov ax,dx
        mov cx,dx
        mov dx,GFX_BYTES_PER_LINE
        mul dx                          ;64k MAX
        add si,ax
        mov ax,GFX_SCR_HEIGHT
        sub ax,cx
        mov cx,GFX_BYTES_PER_LINE
        mul cx
        xchg ax,cx
        mov dx,GFX_PAGE_SIZE_B
MovScr5:mov al,00000001b
MovScr4:call VXSetPlanes
        mov ah,es:[si]
        mov es:[di],ah
        shl al,1
        test al,00010000b
        jz short MovScr4
        inc si
        inc di
        dec dx
        loop MovScr5
        test bh,00010000b
        jz short MovScr6
        mov al,00001111b
        call VXSetPlanes
        cld
        mov al,bl
        mov cx,dx
        rep stosb
MovScr6:xor bh,00000100b
        jmp MovScr3
MovScr2:test bh,00001000b               ;mov down
        jz MovScr3
        mov ax,GFX_SCR_HEIGHT
        sub ax,dx
        mov dx,GFX_BYTES_PER_LINE
        mul dx
        mov cx,GFX_PAGE_SIZE_B
        add si,ax
        add di,cx
        mov dx,cx
        mov cx,ax
MovScr8:dec si
        dec di
        mov al,00000001b
MovScr7:call VXSetPlanes
        mov ah,es:[si]
        mov es:[di],ah
        shl al,1
        test al,00010000b
        jz short MovScr7
        dec dx
        loop MovScr8
        test bh,00010000b
        jz short MovScr9
        mov al,00001111b
        call near VXSetPlanes
        std
        dec di
        mov al,bl
        mov cx,dx
        rep stosb
MovScr9:xor bh,00001000b
        jmp MovScr3
MovScrR:pop bp
        pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;al - index.

CreateRect:
        pushf
        push ax
        push bx
        push dx
        push si
        push di
        lea di,rects_data
        lea si,rects_color
        xor ah,ah
        add si,ax
        shl ax,1
        shl ax,1
        shl ax,1
        add di,ax
        xor dx,dx
        xor ax,ax
        call near RandomSimple
        xor dh,dh
        mov dl,ah
        add dx,RECT_OFFS_X
        mov [di],dx
        mov dl,al
        xor dh,dh
        add dx,RECT_OFFS_X
        cmp dx,[di]
        jnc short CrRect1
        xchg dx,[di]
CrRect1:mov [di + 04h],dx
        xor ax,ax
        call near RandomSimple
        and ax,7F7Fh
        add al,RECT_OFFS_Y
        add ah,RECT_OFFS_Y
        mov dl,al
        xor dh,dh
        mov [di + 02h],dx
        mov dl,ah
        xor dh,dh
        cmp dl,[di + 02h]
        jnc short CrRect2
        xchg dl,[di + 02h]
CrRect2:mov [di + 06h],dx
        xor ax,ax
        call near RandomSimple
        mov [si],al
        pop di
        pop si
        pop dx
        pop bx
        pop ax
        popf
        ret

;Процедура очистки всей страницы экрана в режиме Х. Простая проверка на ноль.
;Желательно не использовать вызовы дополнительных процедур.
;Вход:
;AL     индекс цвета для очистки всего экрана, 0..255;
;AH     биты:
;0..2   каждый бит если установлен, то очистить соответствующую страницу;
;3      заполнить-ли оставшийся хвост от 256Кб, 31744 байта;
;4..7   резерв.
;Выход: заполненная видеопамять VGA.

VXClearVRAM:
        pushf
        push ax
        push bx
        push cx
        push dx
        push es
        mov dx,GFX_SCR_ADDR
        mov es,dx
        mov dh,ah
        mov dl,dh
        and dx,0000100000000111b
        mov ah,al
        mov al,00001111b
        call near VXSetPlanes
        xor di,di
        cld
ClVRAM3:shr dl,1
        jnc short ClVRAM1
        mov cx,GFX_PLANE_SIZE_W
        rep stosw
        jmp short ClVRAM2
ClVRAM1:add di,GFX_PLANE_SIZE_B
ClVRAM2:test dl,dl
        jnz short ClVRAM3
        test dh,dh
        jz short ClVRAM4
        mov cx,di
        neg cx
        rep stosw
ClVRAM4:pop es
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;Other code.

DrawSTDColors:
        pushf
        push ax
        push cx
        push dx
        push di
        push es
        mov ax,0A000h
        mov es,ax
        xor di,di
        xor al,al
        mov cx,0100h
tf2:    mov dx,00C8h
        push di
tf1:    mov es:[di],al
        add di,0140h
        dec dx
        jnz short tf1
        inc al
        pop di
        inc di
        loop tf2
        pop es
        pop di
        pop dx
        pop cx
        pop ax
        popf
        ret

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
%include "vx_dac.asm"
%include "rnd_s.asm"
%include "vx_lines.asm"

