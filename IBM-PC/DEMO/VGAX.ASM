;8-Bit Tea Party! 2021.
;License: Creative Commons.

;Names and constants for VGA Mode-X library, use for all procedures in code.
;Do not define any data, variables or code.

;Имена и константы относящиеся к библиотеке VGA Mode-X, все процедуры.
;Не определяем переменные, данные или код, которые имеют не нулевой размер.
;Подробнее о ригистрах, индексах и данных можно посмотреть в документации.

;VGA video memory layout. ISA 16 bit data bus, 256Kb model.
;4 maps(0..3), 64Kb each, total 256Kb(standard).
;Config: 64Kb from 0xA000 address, 4 planes.
;Planes: 2 bits for every pixel in every plane, total 8bit.
;Colors: 256 table, RGB(6-6-6) bits, from 18bits total 256K colors.

;VGA I/O registers, as standard on 1992.

;General registers.

VGA_MISC_WRITE          EQU 3C2h        ;
VGA_MISC_READ           EQU 3CCh        ;
VGA_INPUT_STATUS_1      EQU 3DAh        ;Input status register 1, using VSync.

;Sequencer registers.

VGA_SEQ_ADDR            EQU 3C4h        ;out dx,ax 16-bit port output.
VGA_SEQ_DATA            EQU 3C5h        ;

;CRT controller register.

VGA_CRT_ADDR            EQU 3D4h        ;Or 3B4 for MDA, using bit selector.
VGA_CRT_DATA            EQU 3D5h

;Graphics controller registers.

VGA_GRAPH_ADDR          EQU 3CEh
VGA_GRAPH_DATA          EQU 3CFh

;Video DAC palette registers.

VGA_DAC_WRITE           EQU 3C8h
VGA_DAC_READ            EQU 3C7h
VGA_DAC_DATA            EQU 3C9h
VGA_PEL_MASK            EQU 3C6h

;Other constants using in library.

VGA_PLANES_MASK         EQU 00001111b   ;Маска для всех планов VGA.

;Global constants, may be later wiil move to GLOBAL.ASM
;Общие константы связанные с графикой, пока оставим здесь, но возможно что
;в будущем перенесем в файл глобальный для всех проектов.
;Используем глобальные настройки экрана на сейчас, позже возможна структура.

SCR_GFX_ADDR            EQU 0A000h      ;Сегментный адрес графического экрана.
SCR_GFX_PLANE_SIZE      EQU 04B00h      ;Размер Х-плана в байтах, 19200.
SCR_GFX_WIDTH           EQU 0140h       ;320 точек по ширине.
SCR_GFX_HEIGHT          EQU 00F0h       ;240 точек по высоте.
SCR_GFX_COLORS          EQU 0100h       ;256 цветов по таблице.
SCR_GFX_BPP             EQU 08h         ;Количество бит на точку.
SCR_GFX_BPC             EQU 06h         ;Количество бит на компонент цвета.
