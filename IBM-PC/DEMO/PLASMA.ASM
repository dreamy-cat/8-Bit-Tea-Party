;Release version of demo with all effects and libraries.

;Small Demo by 8-Bit Tea Party, 2021.

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

;Глобальные константы для демонстрации и их настройки.


DEMO_RAND_INIT  EQU 0FA0Fh              ;Инициализация генератора на старте.
DEMO_FADE_SPEED EQU 001h                ;Скорость работы эффекта появления и
                                        ;ухода экрана. Вычитание из 64
                                        ;интенсивности всех цветов.

        org 100h                        ;PSP.
        pushf
        mov ah,0Fh                      ; get current mode
        int 10h
        mov [prev_video_mode],al

        ; resize program segment
        mov ah,4Ah                      ;Resize memory segment.
        mov bx,1000h                    ;16 bytes multiply 4k = 64kb.
        int 21h
        jnc short Demo0
        jmp near DemoR
Demo0:
        call near VXSetModeX            ;Init gfx, set pages and clear VRAM.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        xor al,al
        ;mov al,90h
        mov ah,00001111b
        call near VXClearVRAM

        call near VXLoadFontBIOS        ;Init default font.
        mov ax,DEMO_RAND_INIT
        call near RandomSimple          ;Random init.

        ;call near VXSetFullDAC

;Testing Intro.

        call near Plasma
        ;call near ScreenFadeOut
        ;call near MoveRectangles
        jmp short DemoR

DemoWait:
        mov ah,00h                      ;Press any key.
        int 16h
DemoR:  ; restore video mode
        mov ah,0
        mov al,[prev_video_mode]
        int 10h
        popf
        ret

;Процедура для демки. Гашением экрана через палитру и синхронизацией по лучу.

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

PLASMA_LEFT             EQU 000h         ; Отлично, есть окно отображения.
PLASMA_WIDTH            EQU GFX_SCR_WIDTH
PLASMA_HEIGHT           EQU 040h ;
PLASMA_TOP              EQU (GFX_SCR_HEIGHT - PLASMA_HEIGHT) / 2
; "Уплотнение" потока по маске, регулировка в основном по вертикали.
PLASMA_WIDTH_MASK       EQU 01FFh       ; 2^roundup(log2(PLASMA_WIDTH)) - 1
PLASMA_HEIGHT_MASK      EQU 003Fh       ; 2^roundup(log2(PLASMA_HEIGHT)) - 1
PLASMA_LOOP_COUNT       EQU 1A0h        ;Общий цикл для всего эффекта.
PLASMA_TEXT_X           EQU PLASMA_LEFT ; Вывод текста.
PLASMA_TEXT_Y           EQU 0B0h ;PLASMA_TOP + PLASMA_HEIGHT + 5
PLASMA_TEXT_COLOR       EQU 03Fh

plasma_txt      dw plasma_txt_e - plasma_txt_b
                dw 0004h
; ! Добавить заголовок эффекта крупно вверху с градиентом.
plasma_txt_b    db 'This effect using the coprocessor for   '
                db 'table initialization. Heavily optimized '
                db 'but still resource intensive.           '
                db 'Feel the warmth of our plasma, born in  '
                db 'the snowy winter 2021-2022! :)'
plasma_txt_e:

plasma_A        dd 5.0
plasma_B        dd 15.0
control_reg     dw 0000h

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
        mov ax,0300h                    ; Очистка видео-страниц 0 и 1.
        call near VXClearVRAM
; Инициализация палитры цветов, возможно немного оптизировтаь цикл.
        xor ax,ax                       ; Иницициализация 0 цвета, индекс 0 и
        xor dx,dx                       ;компоненты RGB также равняются 0.
        call near VXSetPalColor
        inc al
PlasmaPalLp1:
        mov ah,63                       ; Red = 63.
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
        mov dl,63                       ; Green = 63.
        xor dh,dh                       ; Blue = 0.
        call near VXSetPalColor
        inc al
        cmp al,040h                     ; До 64-го.
        jb short PlasmaPalLp2

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
        and ah,11110000b
        ;and [control_reg], byte 11110000b
        mov [control_reg],ax            ; И снова через память, ок 8087.
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
; can't use fstsw ax on 8087 :(
; But if we have 80287 - yes we can! :)
        fstsw word [plasma_temp]
        fincstp                         ; pi | sin
        fincstp                         ; sin
        mov ax,[plasma_temp]
        test ah,00000010b               ; test C1 flag, C1 = low bit(arg/pi)
        jz short Plasma1
        fchs                            ; -sin
        ; ! Взять на заметку, знак числа можно менять командой.
Plasma1:
        fld dword [plasma_B]
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
PlasmaNextX:                    ; x[i] = Random(PLASMA_WIDTH)
        xor ax,ax
        call near RandomSimple
        and ax,PLASMA_WIDTH_MASK        ; Общая маска по ширине, не совсем ясно.
        cmp ax,PLASMA_WIDTH
        jae short PlasmaNextX           ; Перебор далее по координате Х.
        mov [plasma_x + si],ax

PlasmaNextY:    ; y[i] = Random(PLASMA_HEIGHT) * PLASMA_WIDTH
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
        cmp si,4*2
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
        cmp si,4*2                      ; Размер таблицы 8 слов или 16 байт.
        jb short PlasmaLp4

; Установка текстового курсора и цвета вывода, добавить сверху!
        mov word [vx_cursor_x],PLASMA_TEXT_X
        mov word [vx_cursor_y],PLASMA_TEXT_Y
        mov byte [vx_font_color],PLASMA_TEXT_COLOR

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
        cmp si,4*2                      ;в отдельный параметр.
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
        add si,cs:[vx_scr_active]       ; si = screen offset
PlasmaLpX:
        xor dx,dx                       ; table y multiplied by PLASMA_WIDTH
PlasmaLpY:
        ; process one pixel
        xor al,al                       ; color
        mov bp,0                        ; i
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
;Plasma7:                               ; Ключевпая формула следующего цвета.
        add al,es:[di+bx]               ; color += Table[y', x']
        add bp,2                        ; i++, BP + 2 - смещение сразу.
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
        add si,GFX_BYTES_PER_LINE       ; next pixel in column
        add dx,1 * PLASMA_WIDTH         ; premultiplied y++
        cmp dx,PLASMA_HEIGHT * PLASMA_WIDTH
        jb  PlasmaLpY

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

        lea bx,plasma_txt               ; Вывод текста снизу.
        mov ax,8001h
        mov dx,bp
        shr dx,1
        jnc short Plasma9
        sub word [vx_cursor_x],08h
Plasma9:call near VXPrintString        ;Печатаем следующий символ.

        xor cl,00000101b                ; Смена видео странцы активно и
        ;call near WasKeyPressed        ;отображаемой.
        jc short PlasmaBreak
        inc bp                          ; Замыкание главного цикла.
        cmp bp,PLASMA_LOOP_COUNT
        jae short PlasmaBreak
        jmp near PlasmaMainLp           ; Переход.

PlasmaBreak:
; Освобождаем таблицу плазмы как динамической памяти, регистр ES корректен.
        mov ah,49h
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

%include "vga_sys.asm"
%include "dac.asm"
%include "pixel.asm"
%include "random.asm"
%include "print.asm"
%include "lines.asm"

; === Uninitialized data ===
section .bss                            ; NASM is strange

prev_video_mode resb 1

; Plasma
plasma_temp     resw 1
plasma_x        resw 4
plasma_y        resw 4
plasma_h        resw 4
plasma_v        resw 4
