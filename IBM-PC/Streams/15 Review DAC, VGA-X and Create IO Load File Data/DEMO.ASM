;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;Stream 15. Set&Get Pixel and VGA-X library. Load file, Game-IDE.

;План вещания, 25.09.2021.
;- новости демодуляция, 27 ноября 2021, про форматы и конфигурации;
;  Олег, Технический менеджер музея Яндекса: olly-bfox@yandex-team.ru;
;- код библиотеки VGA: обновление процедуры установки страницы и режима;
;- команда: рассматриваем установки и получения точки в режиме Х.
;- оформляем процедуру загрузки файлов произвольной длины в память и
; проверяем установку палитры из стандартного БМП файла.
;- формат 16-ти битной строки, набросок для нашей библиотеки;
;- внешние инструменты для наших поделок. \IBM-PC\GAME-IDE;


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
%include "VGA-X.ASM"



;Program start.

        org 100h                        ;PSP.
        pushf

;1. Код библиотеки VGA, процедура установки режима, рабочий вариант(VGAX.ASM).

SetMD0: call near VXSetModeX
        mov al,00001111b
        call near VXSetPlanes

;Fill video all video pages.

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


        jmp near LoadB0

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
        mov al,01h
        call near VXDisplayPage         ;Set second page.
        mov ah,00h
        int 16h
        mov al,02h
        call near VXDisplayPage         ;Set third page.

        jmp near Dem0

;Процедура загрузки в свободную память данных файла по имени, смещению и
;заданному размеру. Формат имени файла пока что стандартный, с терминальным
;символом нуль в конце. Процедура скорее вспомогательная, для удобства.
;Проверка на ошибки есть, если что-то идет не так, то просто выходим.
;Если процедура останется, то регистры могут изменится.
;Вход:
;CX:AX  всего байт данных для загрузки, старшая и младшая часть, 32 бита;
;DS:BX  адрес строки с названием файла;
;DI:SI  позиция начала чтения данных в файле, старшая и младшая часть,
;       32 бита, файл должен быть соответствующей длины.
;ES:DX  адрес сегмента и смещения старта загрузки, даже если требуется
;       загрузить более одного сегмента, то применяем адресную арифметику,
;       адреса более 8:0000(512кб), будут не загружены с учетом последнего
;       сегмента.

IOLoadFileData:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push ds

        push ax
        mov bp,dx

        mov ah,3Dh                      ;Open file.
        mov al,00h
        mov dx,bx
        int 21h
        mov bx,ax                       ;BX = Handler.
        mov dx,bp
        pop ax
        jc short LFileD0                ;If error, file not found.

        xchg cx,di                      ;Move pointer to data array.
        xchg dx,si
        mov bp,ax
        mov ah,42h
        mov al,00h                      ;File start.
        int 21h
        jc short LFileD1
        mov ax,bp
        mov cx,di                       ;Restore size to read.
        mov dx,si

        mov di,es
        mov ds,di                       ;DS = ES
        mov si,cx                       ;SI higher part of size.

LFileD5:test si,si
        jz short LFileD2
        mov cx,8000h                    ;32kb file read chunk.
        jmp short LFileD3
LFileD2:test ax,ax
        jz short LFileD1                ;Erroor, check later.
        mov cx,ax                       ;Other part, less than 64k.
LFileD3:mov bp,ax
        mov ah,3Fh                      ;Read data.
        int 21h
        jc short LFileD1                ;Error.
        sub bp,ax
        jnc short LFileD4
        add di,0800h                    ;Add 32kb in paragraphs.
        cmp di,8000h                    ;More than 512kb.
        ja short LFileD1
        mov ds,di
        dec si                          ;Higher part.
LFileD4:mov ax,bp                       ;Lower part.
        jmp short LFileD5

LFileD1:mov ah,3Eh                      ;Close file.
        int 21h

LFileD0:pop ds
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;2. Команда: рассматриваем общие файлы и новый код, установки палитры и
;  внешние инструменты для наших поделок.

;3. Демонстрация организации памяти, с освобождением под ДОС-вызовы.

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

;5. Загрузка в видеопамять 3-картинок и вывод их напрямую из видео страниц.

LoadB0: mov cx,03h                      ;Allocate 3 segments size 76800bytes.
        lea di,memory_data
LoadB1: mov ah,48h
        mov bx,GFX_SCR_SIZE_P           ;Bitmap size in paragraphs.
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
        lea bp,palettes_rgba            ;Colors table.

LoadBF: push cx
        push si
        push di
        push es

        mov ax,[si]
        mov es,ax
        xor dx,dx                       ;offset = 0;
        mov cx,0001h                    ;CX:AX = full screen.
        mov ax,2C00h                    ;320*240=76800=1:2C00(32bits);
        xor di,di
        mov si,1078                     ;Bitmap offset.
        lea bx,bitmap_file
        call near IOLoadFileData

;Load RGBA color table from bitmap_file: RGBA = 8-8-8-0, 32 bits.

        mov ax,ds
        mov es,ax
        mov dx,bp
        xor cx,cx
        mov ax,0400h
        xor di,di
        mov si,54                       ;Palette offset in file.
        call near IOLoadFileData

        pop es
        pop di
        pop si
        pop cx
        add si,02h                      ;Next segment free for file.
        add bp,400h                     ;Next palette.
        inc byte [bitmap_file + 8]      ;Next bmp file.
        loop LoadBF

;Copy from memory to VGA all video memory pages.

        push ds
        push es

        mov dh,03h                      ;3 video pages.
        lea si,memory_data
        mov ax,GFX_SCR_ADDR
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

        ;lea dx,palettes_rgba
        ;xor ax,ax                       ;AL = 0 color index, AH = 256 colors.
        ;mov cl,00000100b                ;32 bits, RGBA.
        ;call near VXSetPalette

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
        xor ax,ax                       ;First RGB -> 18bit + 6Bit = 24bit
        mov di,100h                     ;256 colors.
SDAC0:  mov ah,ds:[si+2]
        mov bl,ds:[si+1]                ;dl -> cl
        mov bh,ds:[si+0]
        mov cl,2h                       ;8Bit color -> 6bit color.
        shr ah,cl
        shr bl,cl
        shr bh,cl
        ;mov cl,dl
        ;int 10h                        ;Was BIOS.
        call near VXSetPalColor
        inc al
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
bitmap_file     db "BMP\BMP_2.BMP",0  ;ASCIIZ...
file_handler    dw 0000h
extra_data_seg  dw 0000h
palette         db 100h * 03h dup (0)
palettes_rgba   db 100h * 04h * 03h dup (0)

;Draw standard palette to screen.

;ColorTableDraw:
;        pushf
;        push ax
;        push dx
;        push si
;        push di
;        push es
;        mov ax,GFX_SCR_ADDR
;        mov es,ax                       ;Screen.
;        xor di,di                       ;3clk
;        ;sub di,di                       ;3clk
;        mov si,di
;        cld                             ;Forward.
;        mov dx,0C8h                     ;200.
;CTabDr2:mov di,si
;        mov cx,0100h                    ;All 256 colors.
;CTabDr1:mov es:[di],al
;        inc al
;        inc di
;        loop CTabDr1
;        add si,0140h
;        dec dx
;        jnz short CTabDr2
;        pop es
;        pop di
;        pop si
;        pop dx
;        pop ax
;        popf
;        ret

;Library procedures.

%include "vx_sys.asm"
%include "vx_dac.asm"
