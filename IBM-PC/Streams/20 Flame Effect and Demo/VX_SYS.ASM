;8-Бит Чаепитие! 2021.
;Лицензия: Creative Commons.
;Платформа: 8086, VGA(256Kb), BIOS.
;Инструменты: NASM(2.15.05).
;Модули: VGA-X.
;Авторы: Александр Серов(funny.dreamy.cat@gmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.
;Краткая история изменений:
;20.11.21, А.С.: Добавлена процедура заполнения видеопамяти адаптера.
;02.10.21, А.С.: Смена отображаемой и активной страницы теперь одновременно.
;25.09.21, А.С.: Небольшие правки по оформлению.
;04.09.21, А.С.: Смена видео страниц и синхронизация обратного хода луча:
;                SetDisplayPage, WaitVSync. Загрузка файла в режиме Х.
;28.08.21, А.С.: Загрузка файла в видеопамять и настройка палитры через
;                BIOS, стандартный видеорежим 320x200x256.
;07.08.21, А.С.: Установка режима Х и простое тестирование видеопамяти.
;                Первая версия SetModeX и дополнительно SetModeXFull.

;

;System procedures for VGA Mode-X, hardware level ports.
;See documentation: IBM VGA XGA Technical Reference, 1992.

;File with all parameters to CRT Controller of VGA adapter.
;Using to setup Mode-X, 320 horizontal, 240 vertical, 256 colors.
;Format: PORT 0x3C2...
;INDEX register VGA, first DB, see doc for VGA.
;DATA, use AX register and OUT DX,AX command.
;Tweaker by Robert Schmidt.

;Файл со всеми параметрами для контроллера электронно-лучевой трубки, при
;настройке режима Х, адаптера VGA, размеры 320*200 точек и 256 цветов.
;Формат: порты: 0x3C2 и т.д.
;Индекс регистра адаптера в первой строке.
;Данные - параметр для записи в порт.
;Удобней всего использовать AX аккумулятор и команду OUT DX,AX.

;VGA video memory layout. ISA 16 bit data bus, 256Kb model.
;4 maps(0..3), 64Kb each, total 256Kb(standard).
;Config: 64Kb from 0xA000 address, 32Kb from B000 or B800(other adapters).
;Planes: 4 bits for every pixel in every plane.
;Blue-Green-Red-Intensity, 16 colors.

;List of procedures in alphabetical order, without prefix 'VX'.

;DisplayPage            Set video page to display from 0 to 2.
;SetModeX               Setup Mode-X, 320x240 pixels and 256 colors.
;SetPlanes              Set plane mask to write 8 bit color, bits from 0 to 3.
;WaitVSync              Await vertical synchronization signal from CRT.

;Список процедур в алфавитном порядке, без префикса 'VX' и краткое описание.

;DisplayPage            Смена отображаемой страницы(смещения) экрана.
;SetModeX               Установка видеорежима Х, 320х240х256 с плоскостями.
;SetPlanes              Разрешение на запись в слои видеопамяти адаптера VGA.
;WaitVSync              Ожидание сигнала от ЭЛТ, о начале обратного хода луча.

;TODO:
;Copy from/to main memory to VGA video memory.
;Clear page(s).

;Library start, include source files with names.


%include "VGA-X.ASM"    ;NASM, include header of library.


;Global data for all VGA-X procedures, using memory.
;Глобальные переменные для библиотеки, занимает память, видна глобально.

vx_scr_active   dw 0000h        ;Смещение активной страницы
vx_scr_display  dw 0000h        ;Смещение отображаемой страницы на экране.

;Procedures in alphabetical order.
;Процедуры библиотеки в алфавитном порядке.

;Procedure set display page, al - 0..2 - page index;(see doc)
;Процедура установки активной страницы(смещения) в памяти и страницы
;отображения экрана из памяти. Проверка на допустимость выполняется для
;активной и отображаемой страницы одновременно.
;Вход:
;AL     биты:
;0..1   номер активной страницы, 0..2;
;2..3   номер отображаемой страницы, 0..2;
;4..7   резерв;
;Выход: установка .

VXSetActDispPage:
        pushf
        push ax
        push dx
        mov ah,al                       ;
        and al,00000011b
        cmp al,GFX_ALL_PAGES
        jnc short SAcDiP0
        mov al,ah
        shr al,1
        shr al,1
        cmp al,GFX_ALL_PAGES
        jnc short SAcDiP0
        mov al,ah                       ;
        xor ah,ah
        push ax
        and al,00000011b
        mov dx,GFX_PAGE_SIZE_B
        mul dx                          ;AH High 8-bit of 16bit screen offs.
        mov [vx_scr_active],ax          ;Save screen offset to global.
        pop ax
        shr al,1
        shr al,1
        mov dx,GFX_PAGE_SIZE_B
        mul dx
        mov [vx_scr_display],ax
        mov dx,VGA_CRT_ADDR             ;
        mov al,VGA_START_HIGH_ADDR
        out dx,ax
SAcDiP0:pop dx
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
        pop ax
        popf
        ret


; Установка видео-режима 'Mode-Х', разрешением 320 240 точек и 256 цветов по таблице.
;Краткая версия процедуры, в основе вещания и книги М.Абраша.
;Меняются только те параметры, которые необходимы, остальное подтягивается
;с использованием стандартного режима 13h. Используем пока этот вариант, но
;возможны некоторые неявные моменты, поэтому быть внимательным при оталадке.
;Входны данные: используются глобальные константы параметров экрана.
;Выход: установленный видео режим X 320*240*256.

VXSetModeX:
        pushf
        push ax
        push cx
        push dx
        push si

;Установим стандартный режим 13H и будем модифицировать только необходимое.

        mov ax,13h
        int 10h

;Разбить пиксильные планы по отдельности, снова 0..3, регистр 04, док. 2-53.

        mov dx,VGA_SEQUENCER_ADDR
        mov ah,00000110b        ;Using all planes and extended to 256Kb mem.
        mov al,04h
        out dx,ax

;Выберем 480 линий и селектор порта для ЭЛТ, док. 2-43.

        mov dx,VGA_MISC_WRITE
        mov al,11100011b        ;480lines, 640/320pix, ram and 3DA - port.
        out dx,al               ;8 bit output.

;Сброс или рестарт секвенсера, необязательно, но лучше подстарховаться.

        mov dx,VGA_SEQUENCER_ADDR
        mov al,00h              ;Reset register.
        mov ah,00000011b        ;Reset sync and async.
        out dx,ax

;Снимем защиту от записи в регситры с индексами 0-7, док.

        mov dx,VGA_CRT_ADDR
        mov al,11h              ;Vertical retrace end, register.
        out dx,al
        inc dx
        in al,dx                ;Input from port current value.
        and al,01111111b        ;Remove protection
        out dx,al

;Установка параметров ЭЛТ по таблице. Осторожно, опасно для реального железа!
;Страницы 2-55, док.

        mov dx,VGA_CRT_ADDR
        lea si,vga_crt_mode_x
        mov cx,0Ah              ;May be variable.
        cld
SetMX1: lodsw                   ;Load parameter in table.
        out dx,ax
        loop SetMX1

        pop si
        pop dx
        pop cx
        pop ax
        popf
        ret

;Table for VGA adapter parameters.

vga_crt_mode_x:         ;[bits]

        db 06h          ;Vertical total lines, 10-bit minus 2.
        db 00001101b    ;[0..7] lower 8-bit of total lines.

        db 07h          ;Overflow, bits for extra indexes.
        db 00111110b    ;[0,5] - total lines, as 8,9-bits.
                        ;[2,7] - 8,9 bits regiser 10h, vertical retrace start.
                        ;[1,6] - 8,9 bits register 12h, vertical display-en;
                        ;[3] - 8-bit register 15h, vertical blank, ON.
                        ;[4] line compare register 18h, ON.

        db 09h          ;Maximum scan lines.
        db 01000001b    ;[7] no double, [6] 9th bit line compare ON,
                        ;[5] start vertical blanking 9-bit off,
                        ;[0..4] - character lines row = 1.
        db 10h          ;Vertical retrace start.
        db 11101010b    ;[0..7] lower 8-bit from 9-bit retrace position, 234.

        db 11h          ;Vertical retrace end.
        db 10101100b    ;[7] protect registers 0-7 for write;
                        ;[6] refresh cycle, page 2-70.
                        ;[5] enable vertical interrupt, IRQ2.
                        ;[4] clear interrupt bit, flip-flop after.
                        ;[3..0] vertical retrace end, compare with start.

        db 12h          ;Vertical display-enable end,
        db 11011111b    ;[0..7] 8-bit position of 10-bit lines minus 1, 479.

        db 14h          ;Underline location, double word mode, count by 4.
        db 00h          ;clear all.

        db 15h          ;Start vertical blank,
        db 11100111b    ;[0..7] 8-bit position of 10-bit, minus 1, 487.
                        ;horizontal scan lines, counter.

        db 16h          ;End vertical blanking,
        db 06h          ;[0..7] 8-bit position horizontal line count plus
                        ;Start Vertical blanking, minus 1, 487+6-1 = 492.

        db 17h          ;CRT mode control, page 2-74.
        db 11100011b    ;[7] hardware reset;
                        ;[6] word/byte addressing, using byte mode ON;
                        ;[5] address wrap field, CGA compatibility, ON;
                        ;[4] -
                        ;[3] count by 2, 0 - clock char, 1 - div 2;
                        ;[2] horizontal retrace select, counter or 1- div 2;
                        ;if 1, than 10-bit max 1024 lines, can be 2048 lines.
                        ;[1] select row scan, 1 - bit 14 address counter is
                        ;source.
                        ;[0] select the source of bit 13 multiplexier,
                        ;1 - bit 13 address counter as source, 0 row count;
                        ;CGA 640x200 pixels, example.

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

;Procedure wait for vertical Sync, VGA.
;Процедура ожидания сигнала от модуля ЭЛТ на возникновения обратного хода луча, с
;небольшой подстраховкой, если мы уже наткнулись на сигнал(Абраш).
;Вход:  ничего на вход.
;Выход: блокирует ожиданием выполнение основного кода, до прихода сигнала.

VXWaitVSync:
        pushf
        push ax
        push dx
        mov dx,VGA_INPUT_STATUS_1
WaitV1: in al,dx                 ;if we in vsync signal. (Abrash)
        and al,00001000b         ;for DAC read.
        jnz short WaitV1
WaitV2: in al,dx                 ;Do faster version.
        and al,00001000b
        jz short WaitV2
        pop dx
        pop ax
        popf
        ret


; Функция установки (замены) одиночного цвета в палитре видеоадаптера.
; Назначает цвету с заданным индексом новые компоненты: Read, Green, Blue.
; Вход:
; AL    индекс цвета
; AH    Red
; DL    Green
; DH    Blue
; VXSetPalColor:

;Set all possible VGA colors of each componet RGB in 6 bits colors(0..63).

VXSetFullDAC:
        pushf
        push ax
        push dx
        xor ax,ax
        xor dx,dx
SetFD0: call near VXSetPalColor
        cmp al,40h
        jnc short SetFD1
        inc ah            ;next red
        and ah,00111111b
        jmp short SetFD4
SetFD1: cmp al,80h
        jnc short SetFD2
        inc dl            ;next green
        and dl,00111111b
        jmp short SetFD4
SetFD2: cmp al,0C0h
        jnc short SetFD3
        inc dh            ;next blue
        and dh,00111111b
        jmp short SetFD4
SetFD3: inc ah
        inc dl
        inc dh
SetFD4: inc al
        test al,al
        jnz  short SetFD0
        pop dx
        pop ax
        popf
        ret



;Процедура установки режима Х, с учетом всех параметров адаптера, которые
;требуются для установки. Правильность работы пока под вопросом, используем
;более краткий вариант VXSetModeX процедуру, но это оставляем для теста
;железа и в идеале после использовать именно её, чтобы не было проблем с
;разными конфигурациями адаптеров.

VXSetModeXFull:
        pushf
        push ax
        push cx
        push dx
        push si
        push di

        mov ax,13h                      ;Set anyway, may be because palette.
        int 10h

        lea di,data_x_ports
        mov dx,[di]                     ;1 data byte.
        lea si,data_x_misc
        mov ax,ds:[si+1]
        out dx,al
        add si,02h
        add di,02h

        mov dx,VGA_CRT_ADDR
        mov al,11h                      ;Vertical retrace end, register.
        out dx,al
        inc dx
        in al,dx                        ;Input from port current value.
        and al,01111111b                ;Remove protection
        out dx,al

        mov dx,[di]
        mov cx,12h                      ;18 registers.
t2:     mov ax,[si]
        out dx,ax
        inc si
        inc si
        loop t2

        add di,02h
        mov dx,[di]                     ;3C4.
        mov cx,02h
t3:     mov ax,[si]
        out dx,ax
        inc si
        inc si
        loop t3

        add di,02h
        mov dx,[di]                     ;3CE
        mov cx,02h
t4:     mov ax,[si]
        out dx,ax
        inc si
        inc si
        loop t4

        add di,02h
        mov dx,[di]                     ;3C0
        mov cx,02h                      ;Every byte to port.
t5:     mov ax,[si]
        or al,20h
        out dx,al
        mov al,ah
        out dx,al
        inc si
        inc si
        loop t5

        pop di
        pop si
        pop dx
        pop cx
        pop ax
        popf
        ret

mode_x_data:    ;All values for VGA ports.

;I/O Ports.
data_x_ports:   dw 03C2h, 03D4h, 03C4h, 03CEh, 03C0h

;03C2           Miscellaneous:Input Status Register 0.
data_x_misc:    db 00h, 0E3h

;03D4           CRT Controller Registers.
data_x_crt:     db 00h, 5Fh
                db 01h, 4Fh
                db 02h, 50h
                db 03h, 82h
                db 04h, 54h
                db 05h, 80h
                db 06h, 0Dh
                db 07h, 3Eh
                db 08h, 00h
                db 09h, 41h
                db 10h, 0EAh
                db 11h, 0ACh
                db 12h, 0DFh
                db 13h, 28h
                db 14h, 00h
                db 15h, 0E7h
                db 16h, 06h
                db 17h, 0E3h

;03C4           Sequencer Registers.
data_x_seq:     db 01h, 01h             ;01 - or zero.
                db 04h, 06h

;03CE           Graphics Controller Registers.
data_x_graph:   db 05h, 40h
                db 06h, 05h

;03C0           Attribute Controller Registers.
data_x_attrib:  db 10h, 41h
                db 13h, 00h
