;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;Stream 14. Memory. Mode-X, VGA library: DAC, VSync and Load VGA Pages.

;План вещания:
;0. Новости Демодуляция, 27 ноября 2021.
;1. Код библиотеки VGA, процедура установки режима, рабочий вариант.
;2. Команда: рассматриваем общие файлы и новый код, установки палитры и
;  внешние инструменты для наших поделок. \IBM-PC\GAME-IDE\...
;3. Демонстрация организации памяти, с освобождением под ДОС-вызовы.
;4. Синхронизация по лучу, смена видео-страниц и выбор плоскости(вспом).
;5. Загрузка в видеопамять 3-картинок и вывод их напрямую из видео страниц.

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

CPU 8086        ;8087 as math. coprocessor.

%include "GLOBAL.ASM"
%include "VGAX.ASM"

;Program start.

        org 100h                        ;PSP.
        pushf

;1. Код библиотеки VGA, процедура установки режима, рабочий вариант(VGAX.ASM).

SetMD0: call near VXSetModeX
        mov al,00001111b
        call near VXSetPlanes

;Fill video all video pages.

        jmp near LoadB0

        mov ax,SCR_GFX_ADDR
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
        mov al,01h
        call near VXDisplayPage         ;Set second page.
        mov ah,00h
        int 16h
        mov al,02h
        call near VXDisplayPage         ;Set third page.

        jmp near Dem0

;2. Команда: рассматриваем общие файлы и новый код, установки палитры и
;  внешние инструменты для наших поделок.

;3. Демонстрация организации памяти, с освобождением под ДОС-вызовы.

;Memory allocation, so small, or using linker.

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
        jmp near Dem0

;4. Синхронизация по лучу, смена видео-страниц и выбор плоскости(вспом).
;Сказать про драйвера на всякий случай и настройки ДОСБокса.
;Параметры: фуллдабл=истина, ВСИНК для ДОСБокс включен.

VGASync:mov cx,0300h
        mov ax,SCR_GFX_ADDR
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

;5. Загрузка в видеопамять 3-картинок и вывод их напрямую из видео страниц.

LoadB0: mov ah,4Ah                      ;Resize memory segment.
        mov bx,1000h                    ;16 bytes multiply 4k = 64kb.
        int 21h

        mov cx,03h                      ;Allocate 3 segments size 76800bytes.
        lea di,memory_data
LoadB1: mov ah,48h
        mov bx,SCR_GFX_SIZE_PAR         ;Bitmap size in paragraphs.
        int 21h
        jc LoadBR
        mov ds:[di],ax
        add di,2h                       ;Next memory segment.
        inc ch
        mov [memory_segs],ch            ;Increase counter.
        dec cl
        jnz short LoadB1

;Load pixel array from BMP file to free memory using DOS int.

        mov cx,3h                       ;Load all 3 files.
        lea si,memory_data              ;Segments of free blocks.
        lea di,palettes_rgba            ;Colors table.
LoadBF: push cx
        mov ah,3Dh                      ;Open file.
        mov al,00h
        lea dx,bitmap_file
        int 21h
        mov [file_handler],ax

        mov bx,[file_handler]           ;Move pointer to data array.
        mov ah,42h
        xor cx,cx                       ;
        mov dx,1078                     ;Bitmap start pixels.
        mov al,00h
        int 21h

        mov bp,ds                       ;Read file.
        mov ax,[si]                     ;Free segment from DOS.
        mov ds,ax
        mov ah,3Fh                      ;Read.
        mov cx,09600h                   ;320*240 / 2.
        xor dx,dx
        int 21h
        mov ax,ds                       ;Seg.Address ariphmetic.
        add ax,960h                     ;Next part of file, more than 64kb.
        mov ds,ax
        mov ah,3Fh                      ;Read other part of file.
        mov cx,09600h                   ;320*240 / 2.
        xor dx,dx
        int 21h
        mov ds,bp                       ;Restore DS.
;Load RGBA color table from bitmap_file: RGBA = 8-8-8-0, 32 bits.

        xor cx,cx
        mov dx,36h                      ;First color 54 bytes offset.
        mov ah,42h
        mov al,0h
        int 21h

        mov bx,[file_handler]           ;Load to data.
        mov ah,3Fh
        mov cx,400h                     ;256 colors * 4 bytes(RGBA).
        mov dx,di
        int 21h

        mov bx,[file_handler]           ;Close file.
        mov ah,3Eh
        int 21h

        pop cx
        add si,02h                      ;Next segment free for file.
        add di,400h                     ;Next palette.
        inc byte [bitmap_file + 8]      ;Next bmp file.
        loop LoadBF

;Copy from memory to VGA all video memory pages.
        push ds
        push es

        mov dh,03h                      ;3 video pages.
        lea si,memory_data
        mov ax,SCR_GFX_ADDR
        mov es,ax
        xor di,di                       ;Offset of 0 page.

Out4:   mov dl,02h                      ;Part of segments in memory block.
        mov ax,[si]
        mov bp,ds
        mov ds,ax
Out3:   mov cx,2580h
        xor bx,bx
Out2:   mov al,00000001b
Out1:   call near VXSetPlanes           ;Move all 4 planes.
        mov ah,ds:[bx]
        mov es:[di],ah
        inc bx                          ;Next pixel.
        shl al,1                        ;Next plane.
        cmp al,00010000b
        jne short Out1
        inc di
        loop Out2
        mov ax,ds
        add ax,0960h                    ;Next part.
        mov ds,ax
        dec dl
        jnz short Out3
        mov ds,bp                       ;Restore data segment.
        add si,2h                       ;Next memory segment.
        dec dh
        jnz short Out4
        pop es
        pop ds

        ;jmp short LoadBR

;Using BIOS setup DAC and change VGA page.

        mov al,00h
        lea si,palettes_rgba
SDAC1:  call near VXDisplayPage
        push ax
        mov ah,00h                      ;Press any key.
        int 16h
        pop ax
        push ax
        mov ax,1010h
        xor bx,bx                       ;First RGB -> 18bit + 6Bit = 24bit
        mov di,100h                     ;256 colors.
SDAC0:  mov dh,ds:[si+2]
        mov ch,ds:[si+1]                ;dl -> cl
        mov dl,ds:[si+0]
        mov cl,2h                       ;8Bit color -> 6bit color.
        shr ch,cl
        shr dl,cl
        shr dh,cl
        mov cl,dl
        int 10h
        inc bx
        add si,04h                      ;Next table color.
        dec di
        jnz short SDAC0
        mov ah,00h                      ;Any key.
        int 16h
        pop ax
        inc al                          ;Next video page.
        cmp al,03h
        jne short SDAC1

LoadBR: push es
        mov cl,[memory_segs]
        xor ch,ch
        lea si,memory_data
FMem1:  mov ax,[si]
        mov es,ax
        mov ah,49h                      ;Free block memory.
        int 21h
        add si,02h
        loop FMem1
        pop es

Dem0:   mov ah,00h                      ;Press any key...
        int 16h
        popf
        ret

memory_segs:    db 00h             ;Total allocated segments.
memory_data:    dw 4 dup (0)       ;4 segments allocated max.
bitmap_file     db "BMP\BMP_6.BMP",0  ;ASCIIZ...
file_handler    dw 0000h
extra_data_seg  dw 0000h
palette         db 100h * 03h dup (0)
palettes_rgba   db 100h * 04h * 03h dup (0)

;Procedure set display page, al - 0..2 - page index;(see doc)

VXDisplayPage:
        pushf
        push ax
        push dx
        cmp al,SCR_GFX_ALL_PAGES
        jnc short DispPg0
        xor ah,ah
        mov dx,SCR_GFX_PLANE_SIZE
        mul dx                          ;AH High 8-bit of 16bit screen offs.
        mov dx,VGA_CRT_ADDR
        mov al,VGA_START_HIGH_ADDR
        out dx,ax
DispPg0:pop dx
        pop ax
        popf
        ret

;Procedure wait for vertical Sync, VGA.

VXWaitVSync:
        pushf
        push ax
        push dx
        mov dx,VGA_INPUT_STATUS_1
WaitV1: in al,dx                 ;if we in vsync signal. (Abrash)
        and al,00001000b         ;for DAC read.
        jnz short WaitV1
WaitV2: in al,dx
        and al,00001000b
        jz short WaitV2
        pop dx
        pop ax
        popf
        ret

;Set planes for write in VGA X-MODE.
;al - bits 0..3 if set, then ready to write.

VXSetPlanes:
        pushf
        push ax
        push dx
        mov dx,VGA_SEQUENCER_ADDR
        xchg ah,al
        and ah,00001111b                ;Mask for 4 planes.
        mov al,02h
        out dx,ax                       ;16 bit out.
        pop dx
        pop ax
        popf
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

;Library procedures.

%include "vx_set_x.asm"
