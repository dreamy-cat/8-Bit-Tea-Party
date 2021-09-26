;8-Bit Tea Party! 2021.
;License: Creative Commons.
;Platform: 8086, VGA(256Kb).
;Tools: NASM(2.15.05).
;Authors: Alexander Serov(funny.dreamy.cat@gmail.com);
;         Danila Peroff.

;Global names, constants and structures for VGA Mode-X graphics library,
;use for all procedures and data in code, no memory allocated.
;Do not define any data, variables or code.

;Глобальные имена, константы и структуры графической библиотеки VGA Mode-X.
;Не определяем переменные, данные или код, которые имеют не нулевой размер.
;Подробнее о ригистрах, индексах и данных можно посмотреть в документации.

;VGA library for Mode-X, 320*240*256 colours with pixel's planes.
;Warning! Using library on real hardware is not recommended and can damage
;your monitor/adapter. Tested only in DOSBox. :)

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

VGA_SEQUENCER_ADDR      EQU 3C4h        ;out dx,ax 16-bit port output.
VGA_SEQUENCER_DATA      EQU 3C5h        ;

;CRT controller register.

VGA_CRT_ADDR            EQU 3D4h        ;Or 3B4 for MDA, using bit selector.
VGA_CRT_DATA            EQU 3D5h
VGA_START_HIGH_ADDR     EQU 00Ch        ;High 8-bit of address regen. buffer.
VGA_START_LOW_ADDR      EQU 00Dh        ;Low 8-bit of address regen. buffer.

;Graphics controller registers.

VGA_GRAPHICS_ADDR       EQU 3CEh
VGA_GRAPHICS_DATA       EQU 3CFh

;Video DAC palette registers.

VGA_DAC_WRITE           EQU 3C8h
VGA_DAC_READ            EQU 3C7h
VGA_DAC_DATA            EQU 3C9h
VGA_PEL_MASK            EQU 3C6h

;Other constants using in library.

VGA_PLANES_MASK         EQU 00001111b   ;Маска для всех планов VGA.

;Global constants and names for Mode-X graphics library.
;Общие константы связанные с графикой, пока оставим здесь, но возможно что
;в будущем перенесем в файл глобальный для всех проектов.
;Используем глобальные настройки экрана на сейчас, позже возможна структура.

GFX_SCR_ADDR            EQU 0A000h      ;Сегментный адрес графического экрана.
GFX_SCR_SIZE_B          EQU 000012C00h  ;Размер экрана в байтах, 76800.
GFX_SCR_SIZE_W          EQU 09600h      ;Размер экрана в словах, 38400.
GFX_SCR_SIZE_P          EQU 012C0h      ;Размер экрана в параграфах, 4800.
GFX_PLANE_SIZE_B        EQU 04B00h      ;Размер Х-плана в байтах, 19200.
GFX_PLANE_SIZE_W        EQU 02580h      ;Размер Х-плана в словах, 9600.
GFX_PLANE_SIZE_P        EQU 004B0h      ;Размер Х-плана в параграфах, 1200.
GFX_ALL_PAGES           EQU 003h        ;Всего страниц в режиме Х.
GFX_PAGE_SIZE_B         EQU 04B00h      ;Размер страницы в байтах, 19200.
GFX_PAGE_SIZE_W         EQU 02580h      ;Размер страницы в словах, 9600.
GFX_PAGE_SIZE_P         EQU 004B0h      ;Размер страницы в параграфах, 1200.
GFX_PAGE_0_OFFS         EQU 00000h      ;Смещение нулевой страницы.
GFX_PAGE_1_OFFS         EQU 04B00h      ;Первая страницы для режима 320*240.
GFX_PAGE_2_OFFS         EQU 09600h      ;Вторая страница для режима 320*240.
GFX_WIDTH               EQU 00140h      ;320 точек по ширине, слово.
GFX_HEIGHT              EQU 000F0h      ;240 точек по высоте, слово.
GFX_COLORS              EQU 00100h      ;256 цветов по таблице.
GFX_BPP                 EQU 008h        ;Количество бит на точку.
GFX_BPC                 EQU 006h        ;Количество бит на компонент цвета.
GFX_BYTES_PER_LINE      EQU 050h        ;Байт на каждую строчку пикселей.
