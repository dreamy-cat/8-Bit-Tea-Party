;Small Demo by 8-Bit Tea Party, 2021.

; Платформа: ДОС-совместимая от условной версии 5.0, реальный режим адресации.
; Процессор: только 8086(88) и математический сопроцессор 8087.
; Основная память: 64Кб для кода и стека(модель минимальная). Остальные данные
;желательно уложить в 512Кб. Для запуска на "тяжелых" ДОС конфигурациях.
; Расширенная память: через драйвер XMS, не более 16Мб(не защищенный режим).
; Графический адаптер: IBM VGA, 256Кб, 6 бит на цвет, палитра 2^18 цветов,
;графический Х-режим, 320x240x8бит на цвет по таблице.
; Звуковая плата: Adlib/SBPro(OPL2/OPL3), FM - частотная модуляция.
; Формат файла: .COM, 64Kb, использовать функции ДОС-а для запроса памяти.

CPU 8086                                ;8087 as math. coprocessor.

;Глобальные константы для демонстрации и их настройки.

DEMO_RAND_INIT  EQU 0FA0Fh              ;Инициализация генератора на старте.
DEMO_FADE_SPEED EQU 001h                ;Скорость работы эффекта появления и
                                        ;ухода экрана. Вычитание из 64
                                        ;интенсивности всех цветов.

        org 00100h
        pushf
        mov ah,0Fh                      ; Сохраняем оригинальный видеорежим.
        int 10h
        mov [prev_video_mode],al
        mov ah,4Ah                      ; Изменение размера сегмента, и
        mov bx,1000h                    ;освободжение памяти за 64Кб кода,
        int 21h                         ;размерности в параграфах, 16 байт.
        jnc short Demo0
        jmp near DemoR
Demo0:  call near VXSetModeX            ; Инициализация графики и страниц.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        xor al,al
        ;mov al,90h
        mov ah,00001111b
        call near VXClearVRAM
        call near VXLoadFontBIOS        ; Инициализация шрифта из ПЗУ.
        mov ax,DEMO_RAND_INIT
        call near RandomSimple          ; Инициализация генератора.
        ;call near VXSetFullDAC

; Тестирование только эффекта плазмы, остальные эффекты отдельно.
        call near Plasma
        ;call near ScreenFadeOut
        jmp short DemoR
DemoR:  xor ah,ah                       ; Ожидание клавиши и восстанавливаем
        int 16h                         ;оригинальный видеорежим.
        xor ah,ah
        mov al,[prev_video_mode]
        int 10h
        popf
        ret

; Процедура для демки. Гашением экрана через палитру и синхронизацией по лучу.

ScreenFadeOut:
        pushf
        push ax
        push cx
        push dx
        mov ax,0040h
        mov cl,DEMO_FADE_SPEED
        div cl
        mov cl,al
SFadeO5:call near VXWaitVSync           ;Add extra sync if needed.
        xor al,al
SFadeO4:call near VXGetPalColor
        cmp ah,DEMO_FADE_SPEED
        jbe short SFadeO1
        sub ah,DEMO_FADE_SPEED
        jmp short SFadeO6
SFadeO1:xor ah,ah
SFadeO6:cmp dl,DEMO_FADE_SPEED
        jbe short SFadeO2
        sub dl,DEMO_FADE_SPEED
        jmp short SFadeO7
SFadeO2:xor dl,dl
SFadeO7:cmp dh,DEMO_FADE_SPEED
        jbe short SFadeO3
        sub dh,DEMO_FADE_SPEED
        jmp short SFadeO8
SFadeO3:xor dh,dh
SFadeO8:call near VXSetPalColor
        inc al
        jnz short SFadeO4
        dec cl
        jnz short SFadeO5
        pop dx
        pop cx
        pop ax
        popf
        ret

;5. Плазма или четвёртое агрегатное состояние вещества. :)
; ! После выделения памяти, уточнить размеры выделяемого блока.
; Т.е. ограничения, только если в экран не влезли в 64Кб, но не обязательно.
; Т.к. блок памяти ДОС-ом выделяется непрерывно.
; В релизе возможно динамическое выделение уберем, т.к. НАСМ отрабатывает
; неясно.

; Формула в коде: Table[y,x] = Round(sin(sqrt(sqr(x)+sqr(y))/A)*B);
; Базовый вариант формулы от времени анимации и растояния:
; Value = sin(x + time) + cos(x + time) + sin(distance + time).
; И перед кажым слагаемым возможны коэфициенты для картинки.
; 1. color = offset + factor * sin(x / parameter) - прямой вариант.
; 2. color = sin((x + y) / parameter - угол наклона.
; 3. sqrt(x*x + y*y) - смещение относительно центра;
;    color = sin(sqrt(x - width/f)^2 + (y - height/f)^2)

; По кругам 6-6.5.

PLASMA_WIDTH            EQU GFX_SCR_WIDTH
PLASMA_HEIGHT           EQU 050h ;
PLASMA_LEFT             EQU 000h         ; Отлично, есть окно отображения.
PLASMA_TOP              EQU (GFX_SCR_HEIGHT - PLASMA_HEIGHT) / 2
; "Уплотнение" потока по маске, регулировка в основном по вертикали.
PLASMA_WIDTH_MASK       EQU 01FFh       ; 2^roundup(log2(PLASMA_WIDTH)) - 1
PLASMA_HEIGHT_MASK      EQU 003Fh       ; 2^roundup(log2(PLASMA_HEIGHT)) - 1
PLASMA_OFFS_SIZE        EQU 008h        ; Размеры таблиц смещения 4 слова.
PLASMA_LOOP_COUNT       EQU 2F0h        ; Общий цикл для всего эффекта.
PLASMA_TEXT_X           EQU PLASMA_LEFT ; Вывод текста.
PLASMA_TEXT_Y1          EQU 00018h      ; Без формул подгоняем координаты сами.
PLASMA_TEXT_Y2          EQU 000A8h
PLASMA_TEXT_COLOR1      EQU 07Fh        ; Вывод технического описания возможен
PLASMA_TEXT_COLOR2      EQU 020h        ;другим цветом.

Plasma:
        pushf                           ; Сохраняем все регистры на стек.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es
        cld                             ; Флаг направления, для заполнения.
        mov ax,00300h                   ; Очистка видео-страниц 0 и 1.
        call near VXClearVRAM
; Инициализация палитры цветов, возможно немного оптизировтаь цикл.
        xor ax,ax                       ; Иницициализация 0 цвета, индекс 0 и
        xor dx,dx                       ;компоненты RGB также равняются 0.
        call near VXSetPalColor
        inc al
PlasmaPalLp1:
        mov ah,03Fh                     ; Red = 63.
        mov dl,al
        shl dl,1                        ; Green = index * 2.
        xor dh,dh                       ; Blue = 0.
        call near VXSetPalColor
        inc al
        cmp al,020h                     ;Заполнили первые 32 цвета.
        jb short PlasmaPalLp1
PlasmaPalLp2:
        mov ah,03Fh                     ; Заполняем вторую часть из 64 цветов.
        sub ah,al
        shl ah,1                        ; Red = (63-index) * 2.
        mov dl,03Fh                     ; Green = 63.
        xor dh,dh                       ; Blue = 0.
        call near VXSetPalColor
        inc al
        cmp al,040h                     ; До 64-го.
        jb short PlasmaPalLp2
; Дополнительная палитра, если что прямо здесь.
        mov ax,03F40h                   ; Индекс цвета 64 стартовый и красный,
        mov dx,00000h                   ;зеленый и синие компоненты.
PlsPal3:call near VXSetPalColor         ; RY:03F40:0000; add dl,4.
        inc al                          ; YG:03F40:0000; dec ah, inc dl.
        test al,00000001b               ; RW:03F40:0000: add dl,4; add dh,4
        jnz short PlsPal4               ; Каждый второй цвет смещаем.
        ;dec ah
        ;inc dl
        test al,00000011b               ; Каждый 4-й цвет смещаем.
        jnz short PlsPal4
        ;add dh,004h
        add dl,004h
PlsPal4:cmp al,080h                     ; Максимум 32-16 градиентов.
        jne short PlsPal3

; Выделение памяти для таблицы, размер / 16 + 1 для гарантии.
        mov ah,48h
        mov bx,(PLASMA_WIDTH * PLASMA_HEIGHT / 16) + 1
        int 21h
        jnc short Plasma0               ; Напоминаем о коротких переходах.
        jmp near PlasmaR
Plasma0:
        mov es,ax                       ; ES - теперь таблица плазмы.
; Инициализация математического сопроцессора 8087 :) Проверить на железе!
        finit
        fstcw word [control_reg]
        mov ax,[control_reg]            ; В аккумулятор напрямую нельзя.
; Рrecision Соntrol = 00b - single precision(точность чуть быстрее).
; Rounding Control = 00b - round to nearest value(округление к ближайший).
        and ah,11110000b                ; Или напрямую в память.
        mov [control_reg],ax            ; И снова через память, т.к. 8087.
        fldcw [control_reg]             ; Округление 32 бита.

; Инициализация таблицы плазмы.
        xor di,di                       ; ES:DI адрес таблицы.
        xor dx,dx                       ; DX = координата Y.
PlasmaLp1:
        xor cx,cx                       ; CX = координта X.
PlasmaLp2:
; Формула: Table[y,x] = Round(sin(sqrt(sqr(x)+sqr(y))/A)*B);
; Справа состояние стека(8087), можно дополнительно проверить через отладчик.
        mov [plasma_temp],cx            ; Координата целое X через память.
        fild word [plasma_temp]         ; x
        fmul ST0,ST0                    ; x^2
        mov [plasma_temp],dx            ; Координата Y - аналогично.
        fild word [plasma_temp]         ; y | x^2
        fmul ST0,ST0                    ; y^2 | x^2
        faddp ST1,ST0                   ; x^2 + y^2
        fsqrt                           ; sqrt(x^2 + y^2) - вершина.
        fld dword [plasma_A]            ; A | sqrt(x^2+y^2)
        fdivp ST1,ST0                   ; sqrt(x^2+y^2) / A

; Вычисление синуса через тангенс, состояние стека в комментариях.
        fld ST0                         ; arg | arg
        fptan                           ; 1 | tg | arg
        fld ST1                         ; tg | 1 | tg | arg
        fmul ST0,ST0                    ; tg^2 | 1 | tg | arg
        faddp ST1,ST0                   ; 1 + tg^2 | tg | arg
        fsqrt                           ; sqrt(1 + tg^2) | tg | arg
        fdivp ST1,ST0                   ; tg / sqrt(1 + tg^2) | arg
        fabs                            ; sin = abs(tg / sqrt(1 + tg^2)) | arg
        fxch                            ; arg | sin
        fldpi                           ; pi | arg | sin
        fxch                            ; arg | pi | sin
        fprem                           ; mod(arg / pi) | pi | sin
; Can't use fstsw AX on 8087 :(
; But if we have 80287 - yes we can! :)
        fstsw word [plasma_temp]
        fincstp                         ; pi | sin
        fincstp                         ; sin
        mov ax,[plasma_temp]
        test ah,00000010b               ; test C1 flag, C1 = low bit(arg/pi)
        jz short Plasma1
        fchs                            ; -sin
        ; ! Взять на заметку, знак числа можно менять командой.
Plasma1:fld dword [plasma_B]
        fmulp ST1,ST0                   ; sin * B
        frndint                         ; Округляем итоговый результат и
        fistp word [plasma_temp]        ;выталкиваем его в память.
        mov al,[plasma_temp]            ; signed word -> signed byte
        stosb                           ; table[y,x] = value.
; Увеличиваем координаты и замыкаем цикл.
        inc cx                          ; x++
        cmp cx,PLASMA_WIDTH
        jb short PlasmaLp2
        inc dx                          ; y++
        cmp dx,PLASMA_HEIGHT
        jb short PlasmaLp1

; Заполнение первыми случайными значениями массивов X[] и Y[].
        xor si,si
PlasmaLp3:
PlasmaNextX:                            ; x[i] = Random(PLASMA_WIDTH)
        xor ax,ax
        call near RandomSimple
        and ax,PLASMA_WIDTH_MASK        ; Общая маска по ширине, не совсем ясно.
        cmp ax,PLASMA_WIDTH
        jae short PlasmaNextX           ; Перебор далее по координате Х.
        mov [plasma_x + si],ax

PlasmaNextY:            ; y[i] = Random(PLASMA_HEIGHT) * PLASMA_WIDTH
        xor ax,ax
        call near RandomSimple
        and ax,PLASMA_HEIGHT_MASK       ; Аналогично по высоте и координате Y.
        cmp ax,PLASMA_HEIGHT
        jae short PlasmaNextY
        mov dx,PLASMA_WIDTH
        mul dx                          ; Площадь или просто фактор, 32 бита.
        mov [plasma_y + si],ax
        inc si                          ; Следующие значения в памяти.
        inc si
        cmp si,PLASMA_OFFS_SIZE
        jb short PlasmaLp3

; Заполянем массивы H и V по горизонтали и вертикали случайными параметрами.
        xor ax,ax
        call near RandomSimple
        mov dx,ax                       ; DX - случайное число.
        xor si,si
PlasmaLp4:
        mov ax,0001h                    ; h[i] = +1/-1 (random)
        shr dx,1                        ; AX в итоге случайный знак.
        jc short PlasmaStoreH
        neg ax                          ; Смена знака.
PlasmaStoreH:
        mov [plasma_h + si],ax
        ; h[i] = +PLASMA_WIDTH/-PLASMA_WIDTH (random)
        mov ax,0001h * PLASMA_WIDTH     ; Не совсем понятно, но оставляем!
        shr dx,1
        jc short PlasmaStoreV
        neg ax                          ; Также меняем знак, дополнение до 2.
PlasmaStoreV:
        mov [plasma_v + si],ax
        inc si
        inc si
        cmp si,PLASMA_OFFS_SIZE         ; Размер таблицы 4 слова или 8 байт.
        jb short PlasmaLp4

; Установка текстового курсора и цвета вывода, добавить сверху!
        mov word [vx_cursor_x],PLASMA_TEXT_X
        mov word [vx_cursor_y],PLASMA_TEXT_Y1
        mov byte [vx_font_color],PLASMA_TEXT_COLOR1
        mov cl,00000001b                ; video pages: 0 - visible, 1 - active
        xor bp,bp                       ; main loop counter
; Основной цикл эффекта плазмы, счетчик цикла в BP, 2 странцы с синхронизацией.
PlasmaMainLp:
        push cx
        push bp
        mov al,cl                       ; Установка активной страницы и видимой.
        call near VXSetActDispPage
        call near VXWaitVSync
        xor si,si                       ; Смещение в массивах параметров.
PlasmaLp6:
        mov ax,[plasma_x + si]          ; Проверяем координату Х на 1 и если
        cmp ax,1                        ;равно или меньше, увеличиваем
        ja short Plasma2                ;переменную по горизонтали + смещение.
        mov word [plasma_h + si],0001h
Plasma2:
        cmp ax,PLASMA_WIDTH - 2         ; Если достигли максимальной ширины и
        jb short Plasma3                ; загадочных (-2), то параметр -1.
        mov word [plasma_h + si],0FFFFh ; -1
Plasma3:
        add ax,[plasma_h + si]          ; К текущей координате Х прибавляем
        mov [plasma_x + si],ax          ; смещение или x[i] += h[i] ;)
        mov ax,[plasma_y + si]          ; Уже пред-умноженное значение Y.
        cmp ax,1 * PLASMA_WIDTH         ; Почему-то сравнением с шириной плазмы
        ja short Plasma4                ;и с фактором 1, возможно проба/отладка.
        mov word [plasma_v + si],0001h * PLASMA_WIDTH
; Заполняем если меньше или равно - шириной, или проверяем на площадь.
Plasma4:
        cmp ax,(PLASMA_HEIGHT - 2) * PLASMA_WIDTH
        jb short Plasma5
        mov word [plasma_v + si], -1 * PLASMA_WIDTH
; Если меньше, то добавляем, иначе меняем вертикальный знак.
Plasma5:
        add ax,[plasma_v + si]          ; Вертикальная координата Y и смещение.
        mov [plasma_y + si],ax          ; y[i] += v[i]
        inc si                          ; Обрабатываем следующие смещения в
        inc si                          ;таблице, размер возможно стоило в
        cmp si,PLASMA_OFFS_SIZE         ;в отдельный параметр.
        jb short PlasmaLp6

; Отличная подсказка, что именно происходит, но можно просто общую формулу
;сложения с индексами, плюс возможно уже слегка изменен, но 4 смещения.
;  for (y=0; y<200; y++)
;    for (x=0; x<320; x++)
;      Screen[y,x] = abs(
;        Table[abs(x-x[0]), abs(y-y[0])] +
;        Table[abs(x-x[1]), abs(y-y[1])] +
;        Table[abs(x-x[2]), abs(y-y[2])] +
;        Table[abs(x-x[3]), abs(y-y[3])]
;      ) + 1;

; Код отрисовки в экран напрямую, не через процедуру установки пикселя, код
;во многом похож. Хм, действительно вывод условно, "спрайта" стоит сделать в
;библиотеку или даже не спрайта, а простого множества точек иными словами.
;Оптимизировать или дополнить процедуру SetPixel.

        push ds
        mov ax,GFX_SCR_ADDR
        mov ds,ax                       ; ds = screen
        mov ah,01h                      ; bit plane mask
        xor cx,cx                       ; table x
PlasmaLpPlane:
        ; set bit plane
        mov al,02h
        mov dx,VGA_SEQUENCER_ADDR
        out dx,ax                       ; CS - данные остались в сегменте кода.
        mov si,(PLASMA_TOP * GFX_SCR_WIDTH + PLASMA_LEFT) / 4
        add si,cs:[vx_scr_active]       ; SI смещение в видеопамяти.
PlasmaLpX:
        xor dx,dx                       ; table y multiplied by PLASMA_WIDTH
PlasmaLpY:
        xor al,al                       ; Отрисовка одного пикселя.
        xor bp,bp                       ; Стартовый индекс i = 0.
; Директива цикла NASM, число повторений 3, текущий адрес "$" для смещения в
;сгенерированном коде, требуется, т.к. будет скомпилирован участок полностью.
%rep 3
        mov di,dx                       ; premultiplied y
        sub di,cs:[plasma_y + bp]       ; y' = y - y[i]
        jns short $+4;Plasma6           ; y' = abs(y - y[i])
        neg di
;Plasma6:
        mov bx,cx                       ; Следующая координата Х.
        sub bx,cs:[plasma_x + bp]       ; x' = x - x[i]
        jns short $+4;Plasma7           ; x' = abs(x - x[i])
        neg bx
;Plasma7:                               ; Ключевая формула следующего цвета.
        add al,es:[di+bx]               ; color += Table[y', x']
        add bp,00002h                   ; i++, BP + 2 - смещение сразу.
%endrep
; Окончание цикла NASM и директивы REP, все смещения по цветам прибавлены.
; Вот тут не совсем понятно, почти код аналогичен, но не попал в REP.
        mov di,dx                       ; premultiplied y
        sub di,cs:[plasma_y + bp]       ; y' = y - y[i]
        jns short $+4;Plasma6           ; y' = abs(y - y[i])
        neg di
;Plasma6:
        mov bx,cx                       ; x
        sub bx,cs:[plasma_x + bp]       ; x' = x - x[i]
        jns short $+4;Plasma7           ; x' = abs(x - x[i])
        neg bx
;Plasma7:
        add al,es:[di+bx]               ; color += Table[y', x']
        ; color = abs(color) + 1
        jns short Plasma8
        neg al                          ; Разница в знаке, или прибавляем или
Plasma8:inc al                          ;меняем знак на противоположный.

; Установка пикселя с оптимизацией по планам в режиме VGA-X.

        mov ds:[si],al
        add si,GFX_BYTES_PER_LINE       ; Следующий пиксель в колонке(столбце).
        add dx,1 * PLASMA_WIDTH         ; premultiplied y++
        cmp dx,PLASMA_HEIGHT * PLASMA_WIDTH
        jb PlasmaLpY
        sub si,GFX_BYTES_PER_LINE * PLASMA_HEIGHT - 1 ; first in next column
        add cx,4                        ; Координата Х += 4, план сохранен.
        cmp cx,PLASMA_WIDTH
        jb PlasmaLpX

; Переключаемся на следующий план, если по ширине достигли предела.
        sub cx,PLASMA_WIDTH - 1         ; x = x - PLASMA_WIDTH + 1 = 0,1,2,3
        shl ah,1                        ; Смещение бит, следующий план.
        test ah,00010000b
        jz PlasmaLpPlane                ; Замкнули цикл и восстановили данные.
        pop ds
        pop bp
        pop cx

; Вывод текста в обе страницы, и с учетом такта анимации.
        push cx
        lea bx,plasma_txt               ; Вывод текста сверху и снизу.
        mov cx,00008h                   ; 8 или 16 точек смещения.
        mov ax,00001h                   ; Флаги нашей печати, по одному.
        cmp bp,00050h
        jnc short PlasmaA
        or ah,001h                      ; Изменяем масштаб вывода.
        shl cx,1
PlasmaA:mov dx,bp                       ; Смещение в тексте.
        shr dx,1                        ; Т.к. страницы две и текст должен быть
        call near VXPrintString        ;Печатаем следующий символ.
        test bp,00001h                 ; Т.к. странцы 2.
        jz short PlasmaB                ; Переход в случае четного.
        add word [vx_cursor_x],cx
        cmp word [vx_cursor_x],GFX_SCR_WIDTH               ; Конец экрана.
        jc short PlasmaB
        mov word [vx_cursor_x],00000h
        add word [vx_cursor_y],cx       ; 8 или 16 смещените по вертикали.
PlasmaB:pop cx
        xor cl,00000101b                ; Смена видео странцы активной и
        ;call near WasKeyPressed        ;отображаемой.
        ;jc short PlasmaB
        inc bp                          ; Замыкание главного цикла + 1.
        cmp bp,00050h                   ; Смещаем курсор в описание ниже.
        jne short Plasma9
        mov word [vx_cursor_x],00000h
        mov word [vx_cursor_y],PLASMA_TEXT_Y2
        mov word [vx_font_color],PLASMA_TEXT_COLOR2
Plasma9:cmp bp,PLASMA_LOOP_COUNT
        jae short PlasmaC               ; Выход по окончанию счетчика.
        jmp near PlasmaMainLp           ; Замыкание цикла анимации.

; Освобождаем таблицу плазмы как динамической памяти, регистр ES корректен.
PlasmaC:mov ah,49h
        int 21h

PlasmaR:pop es
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

; Данные для эффекта плазмы, основная таблица в динамической памяти.
plasma_txt      dw 00028h + 00140h
                dw 00004h
                db '  90S SCENE', 0B1h, 'PLASMA |'
                db ' SINUS DATA ON 8087 '
                db '1This effect using the coprocessor for |'
                db '2table initialization.Heavily optimized|'
                db '3but still resource intensive.         |'
                db '4Feel the warmth of our plasma, born in|'
                db '5the snowy winter 2021-2022! :)        |'
                db '6 some text, of... effect.             |'
                db '7 debug data text ____                 |'
                db '8 8th string                           |'
plasma_A        dd 6.5                  ; Коэфиценты для основной формулы.
plasma_B        dd 15.0
control_reg     dw 00000h               ; Регистр 8087, вынести в общий.
plasma_temp     dw 1 dup (0)            ; Временная переменная и таблицы
plasma_x        dw 4 dup (0)            ;смещений по 8 байт для плазмы.
plasma_y        dw 4 dup (0)
plasma_h        dw 4 dup (0)
plasma_v        dw 4 dup (0)

prev_video_mode db 0

%include "vga_sys.asm"
%include "dac.asm"
%include "pixel.asm"
%include "random.asm"
%include "print_g.asm"
%include "lines.asm"
