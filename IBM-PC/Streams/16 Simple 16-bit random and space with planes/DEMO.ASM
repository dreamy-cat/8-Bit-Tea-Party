;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;Вещание 16. Генератор случайных чисел и эффект космоса.

;План вещания, 02.10.2021.

;- код библиотеки VGA: обновление процедуры установки активной страницы;
;- команда: немного обновленного кода палитры;
;- черновик эффекта космоса.

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

;Program start.

        org 100h                        ;PSP.
        pushf

;1. Код библиотеки VGA, процедура установки режима, рабочий вариант(VGAX.ASM).

SetMD0: call near VXSetModeX
        mov al,00001111b
        call near VXSetPlanes
        xor al,al
        call near VXSetActDispPage

        jmp near Space

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

;Эффект космоса с условными планами.

SPACE_STARS     EQU 0FFh                ;Stars in space, max 255.
SPACE_SPEED     EQU 08h                 ;Speed factor.
SPACE_MASK      EQU 07h                 ;Mask for stars depth/delay.

;Move space with stars to diff ways.

;Generate all stars with default palette, 1-15 colors.

Space:  mov ax,04FEh                    ;Init random.
        call near RandomSimple
        xor al,al
        mov ah,SPACE_STARS
        call near CreateStars


        mov cx,0500h ; main cycle
        mov bl,00000001b
Sp1:    push cx
        mov ah,00h
        ;int 16h
        call near VXWaitVSync
        mov al,bl
        call near VXSetActDispPage
        push cx
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
        pop cx
        ;inc word [stars_xy]
        ;inc word [stars_xy + 04h]
        mov dx,0001h
        call near MoveSpace
        mov al,0Fh
        call near DrawSpace
        xor bl,00000101b
        pop cx
        loop Sp1
        jmp near Dem0

MoveSpace:
;dx - offset
;dl - x
;dh - y
        pushf
        push ax
        push bx
        push cx
        push si
        push di
        lea si,stars_xy
        lea di,stars_delay
        lea bx,stars_z
        mov cl,SPACE_STARS
        xor ch,ch
MovSp4: mov al,[di]
        test al,al
        jz short MovSp0
        dec byte [di]
        jnz short MovSp1
MovSp0: mov ah,dl
        mov al,01h
        imul ah         ;or use flags and jumps
        add ax,[si]
        mov [si],ax
        cmp ax,GFX_SCR_WIDTH
        jc short MovSp2
        mov al,ch
        mov ah,01h
        call near CreateStars
        and word [si],000Fh
MovSp2: mov ah,dh
        mov al,01h
        imul ah
        add ax,[si + 02h]
        mov [si + 02h],ax
        cmp ax,GFX_SCR_HEIGHT
        jc short MovSp3
        mov al,ch
        mov ah,01h
        call near CreateStars
MovSp3: mov al,[bx]
        mov [di],al
MovSp1: add si,0004h
        inc di
        inc bx
        inc ch
        dec cl
        jnz short MovSp4
        pop di
        pop si
        pop cx
        pop bx
        pop ax
        popf
        ret

DrawSpace:
;al - color
        pushf
        push ax
        push bx
        push cx
        push si
        lea si,stars_xy
        mov bx,SPACE_STARS
DrSp0:  mov dx,[si]
        mov cx,[si+ 02h]
        call near VXSetPixel
        add si,0004h
        dec bx
        jnz short DrSp0
        pop si
        pop cx
        pop bx
        pop ax
        popf
        ret

CreateStars:
;al - star index
;ah - counter
        pushf
        push ax
        push bx
        push cx
        push si
        push di
        xor cx,cx
        xchg ch,ah
        lea bx,stars_delay
        lea di,stars_z
        add bx,ax
        add di,ax
        lea si,stars_xy
        mov cl,02h
        shl ax,cl
        add si,ax
        mov cl,ch
CrStar2:xor ax,ax
        call near RandomSimple
        and ax,01FFh
        cmp ax,GFX_SCR_WIDTH
        jc short CrStar0
        sub ax,0C0H
CrStar0:mov [si],ax
        and al,SPACE_MASK
        or al,00000001b         ;fix later
        mov [di],al
        mov [bx],ax     ;depth + delay
        xor ax,ax
        call near RandomSimple
        and ax,00FFh
        cmp ax,GFX_SCR_HEIGHT
        jc short CrStar1
        sub ax,0010h
CrStar1:mov [si + 02h],ax
        inc bx
        inc di
        add si,0004h
        dec cl
        jnz short CrStar2
        pop di
        pop si
        pop cx
        pop bx
        pop ax
        popf
        ret
stars_xy:       dw 2 * SPACE_STARS dup (0h)
stars_z:        db SPACE_STARS dup (0h) ;Distance.
stars_delay:    db SPACE_STARS dup (0h) ;Currnet delay for move.
move_diffs:     db 00h, 01h


random_seed:    dd 00000000h

;Return AX, if ax != 0 then init seed

RandomSimple:
        pushf
        push cx
        push dx
        test ax,ax
        jz short RndSim0
        mov [random_seed],ax
        not ax
        mov [random_seed + 02h],ax
RndSim0:mov ax,[random_seed]
        mov dx,[random_seed + 02h]
        mov cx,ax
        not cx
        xor cl,ch
        and cl,00001111b
        ror ax,cl
        ror dx,cl
        add ax,dx
        add ax,cx
        add dx,ax
        xor dx,cx
        mov [random_seed],ax
        mov [random_seed + 02h],dx
        pop dx
        pop cx
        popf
        ret


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
        cmp     dx, GFX_SCR_WIDTH
        jae     short SetPix0
        cmp     cx, GFX_SCR_HEIGHT
        jae     short SetPix0

        push es
        push    bp
        push    bx
        push    dx
        push    ax              ; must be pushed last!

        mov bp,GFX_SCR_ADDR
        mov es,bp


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
        add     bx, [vx_scr_active] ; move to active video page
        ; set byte and exit
        pop     ax
        mov     es:[bx], al
        pop     dx
        pop     bx
        pop bp
        pop es

SetPix0:popf
        ret


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
SDAC1:  call near VXSetActDispPage
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
        ;inc al                         ;Next video page.
        add al,04h
        cmp al,0Ch
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
