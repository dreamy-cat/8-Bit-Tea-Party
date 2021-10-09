;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;План вещания:
; - стартуем проект;
; - общее описание;
; - не забыть про мат. сопроцессор;
; - пример стандартного графического режима 320х200х8бит;
; - описание и модификация до режима Х, 320х240х8бит и тестирование.

;Демка для изучения ассемблера и архитектуры процессора Intel 8086/87.
;Несколько анимированных эффектов, сколько успеем до НГ.
;Общее описание и дата выхода: (01.06.2021 - 31.12.2021).
;Платформа: ДОС-совместимая от условной версии 5.0, реальный режим.
;Процессор: только 8086(88) и математический сопроцессор 8087.
;Основная память: 64Кб для кода и стека(модель минимальная). Остальные данные
;желательно уложиться в 512Кб, на всё. Для запуска на "тяжелых" ДОС
;конфигурациях.
;Расширенная память: через драйвер XMS, не более 16Мб(не защищенный режим).
;Графический адаптер: IBM VGA, 256Кб, 6 бит на цвет, палитра 2^18 цветов,
;режим графический Х-режим, 320x240x8бит.
;Звуковая плата: Adlib/SBPro(OPL2/OPL3), FM - частотная модуляция.
;Формат файла: .COM, 64Kb, использовать функции ДОС-а для запроса памяти.

;Пожелания к взаимодействию в команде.

;Рекомендации по инструментам:

;Краткий план разработки, отправить на ГитХаБ.

; - оформить струтуру файлов и инструментов для всех;
; - добавить описания в директории или отдельно, или оставить в этом файле;
; - работа с графикой на уровне железа(себе);
; - базовые функции для работы с музыкой на железе;
; - минимум для работы с графикой, смена страниц, синхронизация по лучу, точка;

CPU 8086        ;8087 as math. coprocessor(show).

SCR_ADDR        EQU 0A000h     ;Base screen address.

;Литература:
;Michael Abrash - Graphics Programming Black Book, 1997.
;IBM Video Subsystem Manual, Draft, 1992.

;General registers.

VGA_MISC_WRITE   EQU 3C2h
VGA_MISC_READ    EQU 3CCh

;Sequencer registers.

VGA_SEQ_ADDR    EQU 3C4h        ;out dx,ax 16-bit port output.
VGA_SEQ_DATA    EQU 3C5h

;CRT controller register.

VGA_CRT_ADDR    EQU 3D4h        ;Or 3B4 for MDA, using bit selector.
VGA_CRT_DATA    EQU 3D5h

;Graphics controller registers.

VGA_GRAPH_ADDR  EQU 3CEh
VGA_GRAPH_DATA  EQU 3CFh

;Video DAC palette registers.

VGA_DAC_WRITE   EQU 3C8h
VGA_DAC_READ    EQU 3C7h
VGA_DAC_DATA    EQU 3C9h
VGA_PEL_MASK    EQU 3C6h

;VGA video memory layout. ISA 16 bit data bus, 256Kb model.
;4 maps(0..3), 64Kb each, total 256Kb(standard).
;Config: 64Kb from 0xA000 address, 32Kb from B000 or B800(other adapters).
;Planes: 4 bits for every pixel in every plane.
;Blue-Green-Red-Intensity, 16 colours.

;Program start.

        org 100h

        ;fcos
        ;fpatan

        mov ax,13h
        int 10h

;Draw rectangle to show pixel aspect ratio.

        mov ax,SCR_ADDR
        mov es,ax
        mov cx,40h
        mov di,6480h
        mov si,6480h
        cld
        mov ax,0F0Fh
r1:     mov es:[di],al
        mov es:[di+5000h],al
        mov es:[si],al
        mov es:[si + 40h],al
        inc di
        add si,140h
        loop r1


SetModeX:               ;320*240*256 colours.
        pushf           ;Save all registers in procedure.

;Разбить пиксильные планы по отдельности, снова 0..3.
;Memory mode register 04h, page 2-53.

        mov dx,VGA_SEQ_ADDR
        mov ah,00000110b        ;Using all planes and extended to 256Kb mem.
        mov al,04h
        out dx,ax

;Выберем 480 линий и селектор порта для Трубки, стр. 2-43.

        mov dx,VGA_MISC_WRITE
        mov al,11100011b        ;480lines, 640/320pix, ram and 3DA - port.
        out dx,al               ;8 bit output.

;Сброс или рестарт секвенсер.

        mov dx,VGA_SEQ_ADDR
        mov al,00h              ;Reset register.
        mov ah,00000011b        ;Reset sync and async.
        out dx,ax

;Снимем защиту от записи в регситры с индексами 0-7.

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

;Включим заполнение всех плоскостей.

        mov dx,VGA_SEQ_ADDR
        mov al,02h              ;Map mask register.
        mov ah,00001111b        ;All planes, faster 4pixel for byte.
        out dx,ax

;Простое тестирование экрана, заполняем все плоскости палитрой CGA.

        mov ax,SCR_ADDR
        mov es,ax
        xor di,di
        mov ax,0000h
        mov cx,2580h
        cld
t1:     stosw
        inc al
        inc ah
        and al,00001111b                ;CGA 16 colors, 0..15.
        and ah,00001111b
        loop t1

        mov ah,00h              ;Press any key.
        int 16h

        popf
        ret

;Table for VGA adapter parameters.

;1. Использовать данные с примера, рискованное дело. ;)
;2. Импортировать все данные из программы настройка.
;3. Считать все значение из портов и их модифицировать.
;4. Смотрим в документацию, частично есть таблицы в конце документации.

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

full_table_crt:         ;(import from tweaker).

;0x3C2
        db 00h
        db 0E3h
;0x3d4
        db 00h
        db 5Fh
        db 01h
        db 4Fh
        db 02h
        db 50h
        db 03h
        db 82h
        db 04h
        db 54h
        db 05h
        db 80h
        db 06h
        db 0Dh
        db 07h
        db 3Eh
        db 08h
        db 00h
        db 09h
        db 41h
        db 10h
        db 0EAh
        db 11h
        db 0ACh
        db 12h
        db 0DFh
        db 13h
        db 28h
        db 14h
        db 00h
        db 15h
        db 0E7h
        db 16h
        db 06h
        db 17h
        db 0E3h
;0x3C4
        db 01h
        db 01h
        db 04h
        db 06h
;0x3CE
        db 05h
        db 40h
        db 06h
        db 05h
;0x3C0
        db 10h
        db 41h
        db 13h
        db 00h
