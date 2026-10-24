; Демка для изучения ассемблера и архитектуры процессора Intel 8086/87.
; Несколько анимированных эффектов, сколько успеем и что сможем. :)
; Наша Демка 8-Битного Чаепития!
; Все материалы под лицензией - Creative Commons(BY-NC-SA).
; Дата старта: 01.06.2021, дата выхода 31.10.2026(слегка задержались)! :)
; Дополнительные материалы и история проекта в файле 'readme.txt'.

; Платформа: DOS-совместимая от условной версии 5.0, реальный режим.
; Процессор: только 8086(88) и математический сопроцессор 8087.
; Основная память: 64Кб для кода и стека.
; Графический адаптер: IBM VGA(256Кб), режим X, 320x240x8бит.
; Звуковая плата: Adlib/SB16(OPL2/OPL3).
; Формат файла: .COM, 64Kb, дополнительно сервисы DOS-а для управления памяти.

; Директивы для NASM. Команды процессора 8086 и сопроцессор 8087.

CPU 8086

; Глобальные константы и имена для Демки и её эффектов. Статичные данные
;расположены рядом с кодом самих часте ниже.

%include "vga-x.asm"                    ; Имена для графической библиотеки.

DEMO_RAND_INIT  EQU 0FA0Fh              ; Начальное псевдо-случаное значение.
DEMO_FADE_SPEED EQU 001h                ; Скорость работы эффекта затенения.
BIOS_GET_SCR    EQU 00Fh                ; Имена для вызовов БИОС-а.
BIOS_SET_SCR    EQU 000h
BIOS_READ_KEY   EQU 000h
DOS_RESIZE_MEM  EQU 04Ah                ; Имена для вызовов сервисов ДОС-а.
DOS_ALLOC_MEM   EQU 048h
DOS_FREE_MEM    EQU 049h


        org 00100h                      ; Смещение и установка IP для .COM.
        pushf                           ; Сохраняем флаги(необязательно) и
        mov ah,BIOS_GET_SCR             ;оригинальный текстовый видеорежим.
        int 10h
        mov [screen_mode],al
        mov ah,04Ah                     ; Изменение размера сегмента, и
        mov bx,01000h                   ;освободжение памяти за 64Кб кода,
        int 21h                         ;размерности в параграфах или 16 байт.

        call near VXSetModeX            ; Устанавливаем графический режим Х,
        xor al,al                       ;устанавливаем активную видео страницу 0
        call near VXSetActDispPage      ;и очищаем полностью видео буфер(256Кб)
                                        ;нуль цветом.
        xor al,al
        mov ah,00001111b
        call near VXClearVRAM           ; Загружаем шрифт из ПЗУ видео адаптера,
        call near VXLoadFontBIOS        ;стандартный VGA.
        mov ax,DEMO_RAND_INIT           ; Инициализация генератора случайных
        call near RandomSimple          ;чисел в статичной памяти.

        ;call near IntroVGAX
        ;call near VXFadeOut
        call near Plasma
        ;call near VXFadeOut
        ;call near Space3D              ; Вызов всех эффектов с переходом.
        ;call near VXFadeOut
        ;call near CosineAnimation
        ;call near VXFadeOut
        ;call near FlamesOutro
        ;call near VXFadeOut

        mov ah,BIOS_READ_KEY            ; Ожидание нажатия, временно.
        int 16h
        mov ah,BIOS_SET_SCR             ; Восстанавливем режим, флаги и выходим.
        mov al,[screen_mode]
        int 10h
        popf
        ret


; 1. Вступление и вертикальная палитра VGA адаптера по компонентам цветов и
;градиент монохромного вывода текста, с технической информацей по железу.
; Эффект выполняется в одной видео странице с задержкой по ходу луча.

INTRO_MAIN      EQU 00100h              ; Размер основного цикла анимации.
INTRO_DRAW_MAX  EQU 00080h              ; Ограничитель рисования линий.
INTRO_TITLE_X   EQU 00050h              ; Стартовые позиции текста и размер.
INTRO_TITLE_Y   EQU 00010h
INTRO_TITLE_SY  EQU 00014h              ; Размерность текста заголовка.
INTRO_TITLE_N   EQU 0000Ah              ; Новая строчка для заголовка.
INTRO_TEXT_NEXT EQU 00014h              ; Вниз.
INTRO_TEXT_X    EQU 00008h              ;Change coordinates even with space.
INTRO_TEXT_Y    EQU 000C0h              ;Дополнительный текст, мелким шрифтом.
INTRO_COLOR_1   EQU 0FFh                ;Цвет текста, заголовка.
INTRO_COLOR_2   EQU 07Fh                ;Цвет текста комментария.
INTRO_VLINE_Y1  EQU 0003Ch              ;60 - for 120.
INTRO_VLINE_Y2  EQU 000B4h              ;180.

; Добро пожаловать на Чай! Создавая игровой движок(движок игры) для реального
;режима процессора 8086, видеоадаптера ВГА и известного в 90-ые(интересного)
;режима Х, мы реализовали простые и классические алгоритмы эпохи начала
;демосцены.
; История: ВГА Моде-Х. Разрешение 320 на 240 точек и 256 цветов.
;Палитра адаптера 256К цветов, по 6 бит на компонент.

vga_intro_txt   dw 000DCh
                dw 0004h
                db 'WELCOME TO'
                db 'TEA PARTY!'
                db ' While creating game engine for 8086 CPU'
                db 'and VGA famous Mode-X our team released '
                db 'various classic effects of demoscene!   '
                db ' Resolution: 320x240 pixels, 256 colors;'
                db ' Palette: 256K and 6-bit RGB component. '

IntroVGAX:
        pushf                           ; Сохраняем все регистры и флаги.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        call near VXSetFullDAC          ; Устанавливаем палитру по умолчанию,
        mov ax,00100h                   ;и все компоненты. Очищаем 0 страницу
        call near VXClearVRAM           ;видеобуфера, назначаем её активной и
        call near VXSetActDispPage      ;заносим глобальные переменные текста.
        mov word [vx_cursor_x],INTRO_TITLE_X
        mov word [vx_cursor_y],INTRO_TITLE_Y
        mov byte [vx_font_color],INTRO_COLOR_1
        mov dx,GFX_SCR_WIDTH            ; Вычисляем координаты левого и правого
        shr dx,1                        ;старта вывода линий, относительно
        mov ax,GFX_RGB_COLORS           ;центра, т.е. 320/2 +- РГБ*2, т.к.
        shl ax,1                        ;градиента цветов у нас всего 64*4 это
        mov si,dx                       ;256 и соответственно от центра +- 128.
        sub si,ax
        mov di,dx
        add di,ax
        dec di                          ; SI, DI - координаты вывода X1, X2.
        xor bp,bp                       ; BP - смещение в тексте для печати.
        mov bx,0FF00h                   ; Основной индекс цвета BL, BH - цвета.
Intro4: call near VXWaitVSync           ; Начало кадра рисования линий.
        cmp bp,INTRO_DRAW_MAX
        jae short Intro6
        ;test bp,00001h
        ;jnz short Intro7

        mov al,bl
        add bl,002h                     ; Т.к. идем через одну линию, то
        mov dx,si                       ;изменения сразу +2 по цвету и
        add si,00002h                   ;координатам слева и справа.
        mov cx,INTRO_VLINE_Y1
Intro0: call near VXSetPixel            ; Рисуем первую вертикальную линию.
        inc cx
        cmp cx,INTRO_VLINE_Y2
        jnz short Intro0
Intro6: call near VXWaitVSync
        cmp bp,INTRO_DRAW_MAX           ; Второй кадр в основном цикле.
        jae short Intro7
        mov al,bh
        sub bh,002h
        mov dx,di
        sub di,00002h
        mov cx,INTRO_VLINE_Y1
Intro1: call near VXSetPixel            ; Рисуем вторую вертикальную линию.
        inc cx
        cmp cx,INTRO_VLINE_Y2
        jnz short Intro1

Intro7: call near VXWaitVSync           ; Печать одного символа в кадр.
        push bx
        push dx
        mov bx,vga_intro_txt
        mov dx,bp
        ;shl dx,1                       ; Смещение печатаемого символ 1:1.
        ;jc short ...
        mov al,001h
        mov ah,11000001b                ; Установка масштаба печати.
        cmp dx,INTRO_TEXT_NEXT
        jc short Intro2
        mov ah,11000000b
Intro2: call near VXPrintString         ; Печать символа и восстановление
        pop dx                          ;параметров для отрисовки.
        pop bx
        inc bp
        cmp bp,INTRO_TITLE_N
        jne short Intro5                ; Если переход вторую строчку.
        mov word [vx_cursor_x],INTRO_TITLE_X
        add word [vx_cursor_y],INTRO_TITLE_SY
        jmp short Intro5
Intro5: cmp bp,INTRO_TEXT_NEXT
        jne short Intro3
        mov byte [vx_font_color],INTRO_COLOR_2
        mov word [vx_cursor_x],INTRO_TEXT_X
        mov word [vx_cursor_y],INTRO_TEXT_Y
Intro3: cmp bp,INTRO_MAIN
        jne Intro4

        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret


; 2. Плазма или четвёртое агрегатное состояние вещества. :)
; Второй вариант эффекта Плазмы. Цвета с оттенком зеленого-желтого.
; Кадров примерно 30, высота 64 точки. Параметры для функции: 5.0 и 25.0.
; Чуть по ощущениям больше секций появилось в картинке и чуть быстрее меняется.
; Общее время демонстрации эффекта примерно 30 секунд, это уже близко к цели,
;печать примерно 6 строк описания успевает. Но кадров всё еще также. :)

; Формула в коде: Table[y,x] = Round(sin(sqrt(sqr(x)+sqr(y))/A)*B);
; Базовый вариант формулы от времени анимации и растояния:
; Value = sin(x + time) + cos(x + time) + sin(distance + time).
; И перед кажым слагаемым возможны коэфициенты для картинки.
; 1. color = offset + factor * sin(x / parameter) - прямой вариант.
; 2. color = sin((x + y) / parameter - угол наклона.
; 3. sqrt(x*x + y*y) - смещение относительно центра;
;    color = sin(sqrt(x - width/f)^2 + (y - height/f)^2)

PLASMA_WIDTH            EQU 00140h      ; Размеры плазмы в точках, центр
PLASMA_HEIGHT           EQU 00040h      ;вычисляется от высоты.
PLASMA_LEFT             EQU 000h        ; Отлично, есть окно отображения.
PLASMA_TOP              EQU (GFX_SCR_HEIGHT - PLASMA_HEIGHT) / 2
; "Уплотнение" потока по маске, регулировка в основном по вертикали.
PLASMA_WIDTH_MASK       EQU 01FFh       ; 2^roundup(log2(PLASMA_WIDTH)) - 1
PLASMA_HEIGHT_MASK      EQU 003Fh       ; 2^roundup(log2(PLASMA_HEIGHT)) - 1
PLASMA_OFFS_SIZE        EQU 008h        ; Размеры таблиц смещения 4 слова.
PLASMA_LOOP_COUNT       EQU 280h        ; Общий цикл для всего эффекта.
PLASMA_TEXT_X           EQU PLASMA_LEFT ; Вывод текста.
PLASMA_TEXT_Y1          EQU 00018h      ; Без формул подгоняем координаты сами.
PLASMA_TEXT_Y2          EQU 000A8h
PLASMA_TEXT_COLOR1      EQU 07Fh        ; Вывод технического описания возможен
PLASMA_TEXT_COLOR2      EQU 07Fh        ;другим цветом.

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
        mov ah,03Fh                     ; Красный = 63, т.е. максимум.
        mov dl,al
        shl dl,1                        ; Зеленый = индекс * 2.
        xor dh,dh                       ; Синий оставляем равным 0.
        call near VXSetPalColor
        inc al
        cmp al,020h                     ;Заполнили первые 32 цвета.
        jb short PlasmaPalLp1
PlasmaPalLp2:
        mov ah,03Fh                     ; Заполняем вторую часть из 64 цветов.
        sub ah,al
        shl ah,1                        ; Красный = (63 - индекс) * 2.
        mov dl,03Fh                     ; Зеленый = 63.
        xor dh,dh                       ; Синий = 0.
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

; Выделение памяти для таблицы, размер / 16 + 1 для гарантии, в параграфах.
        mov ah,DOS_ALLOC_MEM
        mov bx,(PLASMA_WIDTH * PLASMA_HEIGHT / 16) + 1
        int 21h
        jnc short Plasma0               ; Если всё ок, то выполняем, иначе
        jmp near PlasmaR                ;выделение памяти не удалось выходим.
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
; Взять на заметку, знак числа можно менять командой.
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
PlasmaNextX:                            ; X[i] = Random(PLASMA_WIDTH)
        xor ax,ax
        call near RandomSimple
        and ax,PLASMA_WIDTH_MASK        ; Общая маска по ширине, не совсем ясно.
        cmp ax,PLASMA_WIDTH
        jae short PlasmaNextX           ; Перебор далее по координате Х.
        mov [plasma_x + si],ax
PlasmaNextY:
        xor ax,ax                       ; Y[i] = Random(PLASMA HEIGHT * WIDTH)
        call near RandomSimple
        and ax,PLASMA_HEIGHT_MASK       ; Аналогично по высоте и координате Y.
        cmp ax,PLASMA_HEIGHT
        jae short PlasmaNextY
        mov dx,PLASMA_WIDTH
        mul dx                          ; Площадь или просто фактор, 32 бита.
        mov [plasma_y + si],ax
        inc si                          ; Следующие значения в памяти, или
        inc si                          ;можно применить add si,00002h.
        cmp si,PLASMA_OFFS_SIZE
        jb short PlasmaLp3

; Заполянем массивы H и V по горизонтали и вертикали случайными параметрами.
        xor ax,ax
        call near RandomSimple
        mov dx,ax                       ; DX - случайное число.
        xor si,si
PlasmaLp4:
        mov ax,0001h                    ; h[i] = +1/-1 (случайный)
        shr dx,1                        ; AX в итоге случайный знак.
        jc short PlasmaStoreH
        neg ax                          ; Смена знака.
PlasmaStoreH:
        mov [plasma_h + si],ax
        ; H[i] = +PLASMA_WIDTH/-PLASMA_WIDTH (случайно)
        mov ax,00001h * PLASMA_WIDTH     ; Не совсем понятно, но оставляем!
        shr dx,1
        jc short PlasmaStoreV
        neg ax                          ; Также меняем знак, дополнением до 2.
PlasmaStoreV:
        mov [plasma_v + si],ax
        inc si
        inc si
        cmp si,PLASMA_OFFS_SIZE         ; Размер таблицы 4 слова или 8 байт.
        jb short PlasmaLp4

; Установка текстового курсора и цвета вывода.
        mov word [vx_cursor_x],PLASMA_TEXT_X
        mov word [vx_cursor_y],PLASMA_TEXT_Y1
        mov byte [vx_font_color],PLASMA_TEXT_COLOR1
        mov cl,00000001b                ; Страницы 0 -видима, 1 - актвна.
        xor bp,bp
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
        mov [plasma_x + si],ax          ;смещение или X[i] += H[i] ;)
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
        mov [plasma_y + si],ax          ; Y[i] += V[i]
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
        mov ax,GFX_SCR_ADDR             ; DS - указывает на экран, т.к. ES у
        mov ds,ax                       ;нас занят таблицей.
        mov ah,001h                     ; Маска битового пала в AH.
        xor cx,cx                       ; CX - смещение в таблице.
PlasmaLpPlane:
        mov al,02h                      ; Устанавливаем битовый план.
        mov dx,VGA_SEQUENCER_ADDR
        out dx,ax                       ; CS - данные остались в сегменте кода.
        mov si,(PLASMA_TOP * GFX_SCR_WIDTH + PLASMA_LEFT) / 4
        add si,cs:[vx_scr_active]       ; SI смещение в видеопамяти.
PlasmaLpX:
        xor dx,dx                       ; Смещение Y умноженного на ширину.
PlasmaLpY:
        xor al,al                       ; Отрисовка одного пикселя.
        xor bp,bp                       ; Стартовый индекс I = 0.
; Директива цикла NASM, число повторений 3, текущий адрес "$" для смещения в
;сгенерированном коде, требуется, т.к. будет скомпилирован участок полностью.
%rep 3
        mov di,dx                       ; Предаварительно умноженное Y.
        sub di,cs:[plasma_y + bp]       ; Y' = Y - Y[i]
        jns short $+4;Plasma6           ; Y' = abs(Y - Y[i])
        neg di
;Plasma6:
        mov bx,cx                       ; Следующая координата Х.
        sub bx,cs:[plasma_x + bp]       ; X' = X - X[i]
        jns short $+4;Plasma7           ; X' = abs(X - X[i])
        neg bx
;Plasma7:                               ; Ключевая формула следующего цвета.
        add al,es:[di+bx]               ; Цвет += Таблица[Y', X'],
        add bp,00002h                   ;i++, BP + 2 - смещение сразу.
%endrep
; Окончание цикла NASM и директивы REP, все смещения по цветам прибавлены.
; Вот тут не совсем понятно, почти код аналогичен, но не попал в REP.
        mov di,dx                       ; Предаварительно умноженное Y.
        sub di,cs:[plasma_y + bp]       ; Y' = Y - Y[i]
        jns short $+4;Plasma6           ; Y' = abs(Y - Y[i])
        neg di
;Plasma6:
        mov bx,cx                       ; X
        sub bx,cs:[plasma_x + bp]       ; X' = X - X[i]
        jns short $+4;Plasma7           ; X' = abs(X - X[i])
        neg bx
;Plasma7:
        add al,es:[di+bx]               ; Цвет += Таблица[Y', X'].
        ; color = abs(color) + 1
        jns short Plasma8
        neg al                          ; Разница в знаке, или прибавляем или
Plasma8:inc al                          ;меняем знак на противоположный.

; Установка пикселя с оптимизацией по планам в режиме VGA-X.
        mov ds:[si],al
        add si,GFX_BYTES_PER_LINE       ; Следующий пиксель в колонке(столбце).
        add dx,1 * PLASMA_WIDTH         ; Предумноженное Y++.
        cmp dx,PLASMA_HEIGHT * PLASMA_WIDTH
        jb PlasmaLpY                    ; Средний переход.
        sub si,GFX_BYTES_PER_LINE * PLASMA_HEIGHT - 1
        add cx,4                        ; На следующий столбец.
        cmp cx,PLASMA_WIDTH             ; Координата Х += 4, план сохранен.
        jb PlasmaLpX

; Переключаемся на следующий план, если по ширине достигли предела.
        sub cx,PLASMA_WIDTH - 1         ; X = X - PLASMA_WIDTH + 1 = 0,1,2,3
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
        call near VXPrintString         ; Печатаем следующий символ.
        test bp,00001h                  ; Т.к. странцы 2.
        jz short PlasmaB                ; Переход в случае четного.
        add word [vx_cursor_x],cx
        cmp word [vx_cursor_x],GFX_SCR_WIDTH
        jc short PlasmaB                ; Конец экрана.
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
PlasmaC:mov ah,DOS_FREE_MEM
        int 21h
PlasmaR:pop es                          ; Восстанавлваем регистры и выходим.
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
                db '  90S SCENE PLASMA  '
                db ' SINUS DATA ON 8087 '
                db '|   A classic of the 90s demoscene !   |'
                db '|This warm plasma effect, is calculated|'
                db '|  using a sine formula with qudratic  |'
                db '|   surface coordinates. The dynamic   |'
                db '| function data utilizes the 8087 math |'
                db '|   coprocessor, drawing to both VRAM  |'
                db '|  pages of VGA Mode-X. Feel the cozy  |'
                db '|   colors during the snowy winter !   |'
plasma_A        dd 5.0                  ; Коэфиценты для основной формулы.
plasma_B        dd 25.0
;control_reg     dw 00000h               ; Регистр 8087, вынести в общий.
plasma_temp     dw 1 dup (0)            ; Временная переменная и таблицы
plasma_x        dw 4 dup (0)            ;смещений по 8 байт для плазмы.
plasma_y        dw 4 dup (0)
plasma_h        dw 4 dup (0)
plasma_v        dw 4 dup (0)


;Минимальный 3Д космос по направлениям движения и вперед.


CENTER_3D_X     EQU 1000h               ;Center of projection coordinates.
CENTER_3D_Y     EQU 1000h

SPACE_3D_TIMER  EQU 0310h
SPACE_STARS     EQU 0FFh                ;Stars in space, max 255.
SPACE_TXT_OFFS  EQU 00780h              ;1920 words minus bottom vpage.
SPACE_TXT_SX    EQU 00000h              ;Start text.
SPACE_TXT_SY    EQU 000C0h
SPACE_TXT_COLOR EQU 07Fh                ;Blue or bright blue.
SPACE_COLORS    EQU 0FFh                ;All blue/white colors.
SPACE_STAR_SIZE EQU 08h                 ;Mask for stars depth/delay.
SPACE_VMASK     EQU 00C0h               ;Mask for text on screen.
SPACE_MASK_X    EQU 1FFFh               ;Mask for horizontal star position.
SPACE_MASK_Y    EQU 1FFFh               ;Mask for vertical star position.
SPACE_MASK_Z    EQU 00FFh               ;Mask for star depth.
SPACE_MULT      EQU 0080h               ;Factor for XY.


;3 words with parameters X,Y,Z and reserved word.

stars_xyz:      dw 4 * SPACE_STARS dup (0000h)   ;In every direction.

stars_move:     dw 0h, 0h, -03h
                dw 0h, SPACE_MULT, 0h
                dw -SPACE_MULT, SPACE_MULT, 0h
                dw -SPACE_MULT, 0h, 0h
                dw -SPACE_MULT, -SPACE_MULT, 0h
                dw 0h, -SPACE_MULT, 0h
                dw SPACE_MULT, -SPACE_MULT, 0h
                dw SPACE_MULT, 0h, 0h
                dw SPACE_MULT, SPACE_MULT, 0h

; Элементарное трехмерное пространство наполненное звездами с применением
;двух видео страниц и вертикальной синхронизацией.
; Кто "Опасный" в Элите?! :)
;Видеобуффер в 256 килобайт содержит четыре битовых плана с
;простыми трюками аппаратного ускорения.
; Структура режима Х: Три видеостраницы по 75 и 31 свободных килобайта.
;

space_3D_txt    dw 00F0h
                dw 0004h
                db ' Elementary 3D Space, filled with stars '
                db 'and using both video pages with V-Sync. '
                db ' Who is the Dangerous in Elite?! :)     '
                db ' VRAM is 256Kb contains four bit-planes '
                db 'with some hardware acceleration tricks. '
                db ' Mode-X: 3 pages of 75Kb and 31Kb free. '

Space3D:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp

        xor ax,ax
        xor dx,dx
SpPal1: call near VXSetPalColor
        inc al
        inc ah
        inc dl
        inc dh
        cmp al,040h
        jnz short SpPal1
        xor ah,ah
        xor dx,dx
SpPal2: call near VXSetPalColor
        inc dh
        inc dl
        inc al
        cmp al,080h
        jnz short SpPal2
        xor ah,ah
        xor dx,dx
SpPal3: call near VXSetPalColor
        inc ah
        inc dl
        inc al
        cmp al,0C0h
        jnz short SpPal3
        xor ah,ah
        xor dx,dx
SpPal4: call near VXSetPalColor
        inc ah
        inc dl
        inc dh
        inc al
        jnz short SpPal4

        mov word [vx_cursor_x],SPACE_TXT_SX
        mov word [vx_cursor_y],SPACE_TXT_SY
        mov byte [vx_font_color],SPACE_TXT_COLOR

        xor al,al
        mov ah,SPACE_STARS
        call near CreateStars3D

        lea di,stars_move
        mov bh,01h
        mov bl,00000001b                        ;Active screen.
        xor bp,bp                               ;String offset.
Space2: mov cx,SPACE_3D_TIMER                   ; main cycle
Space1: push cx
        mov ah,00h
        ;int 16h
        call near VXWaitVSync
        mov al,bl
        call near VXSetActDispPage
        push cx
        push di
        push es
        mov cx,GFX_SCR_ADDR
        mov es,cx
        xor ah,ah
        and al,00000011b
        mov dx,GFX_PAGE_SIZE_B
        mov cx,GFX_PAGE_SIZE_W - SPACE_TXT_OFFS
        mul dx
        mov di,ax
        mov al,00001111b
        call near VXSetPlanes
        xor ax,ax
        cld
        rep stosw
        pop es
        pop di
        pop cx
        call near MoveSpace3D
        call near DrawSpace3D
        xor bl,00000101b                        ;Change pages.
        pop cx

;Press any key for debug.
        push ax
        mov ah,00h
        ;int 16h
        pop ax

        push bx                                 ;
        push ax
        lea bx,space_3D_txt
        mov ah,01100000b
        mov dx,bp
        call near VXPrintString
        sub word [vx_cursor_x],08h
        test cx,0001h
        jnz short Space3
        add word [vx_cursor_x],08h
        inc bp
Space3: pop ax
        pop bx
        loop Space1                             ;Main cycle.

        add di,0006h
        dec bh
        jnz short Space2

        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;DS:DI - moving directions with words.

MoveSpace3D:
        pushf
        push ax
        push bx
        push cx
        push di

        lea bx,stars_xyz
        xor cl,cl
        xor ch,ch
MovS3D1:mov ax,[bx]
        add ax,[di]                     ;Add X.
        ;jc short MovS3D2
        cmp ax,SPACE_MASK_X             ;2D projection coordinate, not do.
        jnc short MovS3D2
        mov [bx],ax
        mov ax,[bx+02h]
        add ax,[di+02h]                 ;Add Y.
        ;jc short MovS3D2
        cmp ax,SPACE_MASK_Y             ;2D projection coordinate, not do.
        jnc short MovS3D2
        mov [bx+02h],ax
        mov ax,[bx+04h]
        add ax,[di+04h]                 ;Add Z.
        cmp ax,SPACE_MASK_Z
        jnc short MovS3D2
        mov [bx+04h],ax
        jmp short MovS3D3
MovS3D2:mov al,ch                       ;Store.
        mov ah,01h
        call near CreateStars3D
MovS3D3:add bx,SPACE_STAR_SIZE
        inc ch
        cmp ch,SPACE_STARS
        jnz short MovS3D1

        pop di
        pop cx
        pop bx
        pop ax
        popf
        ret

DrawSpace3D:
        pushf
        push ax
        push bx
        push cx
        mov cx,SPACE_STARS
        lea bx, stars_xyz
DrS3D1: mov al,[bx+06h]
        call near VXSetPixel3D
        add bx,SPACE_STAR_SIZE
        loop DrS3D1
        pop cx
        pop bx
        pop ax
        popf
        ret

;Set pixel 3D. AL - color, BX - address of coordinates(X,Y,Z).

VXSetPixel3D:
        pushf
        push ax
        push cx
        push dx
        push bp
        push si

        mov bp,ax
        mov si,[bx+04h]                 ;Z parameter.
        test si,si
        jz short SPix3D0
        xor dx,dx
        mov ax,[bx]                     ;Coordinate x.
        sub ax,CENTER_3D_X
        jnc short SPix3D1
        not dx                          ;Negative.
        idiv si
        jmp short SPix3D2
SPix3D1:div si                          ;Unsigned.
SPix3D2:add ax,GFX_SCR_WIDTH / 2
        mov cx,ax                       ;X position.
        xor dx,dx
        mov ax,[bx+02h]                 ;Y
        sub ax,CENTER_3D_Y
        jnc short SPix3D3
        not dx
        idiv si
        jmp short SPix3D4
SPix3D3:div si
SPix3D4:add ax,GFX_SCR_HEIGHT / 2

        cmp ax,SPACE_VMASK              ;Dirty trick for text, remove in lib!
        jnc short SPix3D0

        xchg cx,ax                      ;Position Y
        mov dx,ax
        mov ax,bp
        xor ah,ah                       ;Al - color.
        call near VXSetPixel

SPix3D0:pop si
        pop bp
        pop dx
        pop cx
        pop ax
        popf
        ret

;al - star index
;ah - counter

CreateStars3D:
        pushf
        push ax
        push bx
        push cx
        push di
        xor cx,cx
        xchg ch,ah
        lea di,stars_xyz
        mov cl,03h
        shl ax,cl
        add di,ax                       ;Star X.
        mov cl,ch
CrStar2:xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_X
CrStar0:mov [di],ax                     ;Store X.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_Y
        mov [di+02h],ax                 ;Store Y.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_Z
        test ax,ax
        jnz short CrStar3
        inc ax
CrStar3:mov [di+04h],ax                 ;Store Z.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_COLORS
        ;add ax,0010h                   ;Was removed from release.
        mov [di+06h],ax
        add di,SPACE_STAR_SIZE
        inc ch
        dec cl
        jnz short CrStar2
        pop di
        pop cx
        pop bx
        pop ax
        popf
        ret


;3. Анимация косинуса с использованием математического сопроцессора.

COS_TIMER       EQU 000D0h              ;Общий таймер для выравниваия времени.
;COS_CENTER_Y    EQU 078h                ;120 для режима X, центр экрана.
COS_OFFS_Y       EQU 00078h              ;Center for COS graphics.
COS_HEIGHT      EQU 040h
COS_WIDTH       EQU 00140h    ; 0013Bh              ;314 pixels for better PI. +1 for st.
                                        ;13A - is correct value.
RED_INDEX       EQU 000h                ;Indexes for default color palette.
GREEN_INDEX     EQU 040h                ;Start component.
BLUE_INDEX      EQU 080h
MATH_TXT_SX     EQU 00000h
MATH_TXT_SY     EQU 00018h
MATH_TXT_X1     EQU 00000h
MATH_TXT_Y1     EQU 000B0h
MATH_TXT_NEXT   EQU 026h                ;Upper part of text lenght.
MATH_TXT_COL1   EQU 0007Fh
MATH_TXT_COL2   EQU 000FFh

control_reg     dw 00000h
value_x         dd 0.00
cos_x           dd 0.1                 ;Full 2PI.
cos_x_step      dd +0.00005
cos_x_min       dd 0.1
cos_x_max       dd 0.2
cos_y           dd 04.0               ;Height of cosine.
cos_y_int       dw 00004h
cos_y_step      dd +1.0
cos_y_min       dd 4.0
cos_y_max       dd 16.0               ;Size of draw cos in pixels.
fpu_data        dw 10h dup (0)
cos_table       dw GFX_SCR_WIDTH dup (00000h)
offset_x_anim   dd 0.04                 ;Offset X for every frame.
anim_accel      dd 0.01
sign_neg        dd -1.0
pi_00           dd 0.00
pi_14           dd 0.79
pi_24           dd 1.57
pi_34           dd 2.36
pi_44           dd 3.14
pi_54           dd 3.93
pi_64           dd 4.71
pi_74           dd 5.50
pi_84           dd 6.28                 ;May be plus 1 or equal.

anim_cos_txt    dw 00CAh
                dw 0004h
                db '  REALTIME MATH ON  '
                db '  8087 COPROCESSOR'            ;Add space to config.
                db ' Color animation of trigonometric cosine'
                db 'using slow formula of tangent and '
                db 'square root, but fully on mathematical  '
                db 'coprocessor. 8086 became an artist...:) '
                db '                                        '
                ;db ' Precision: 32-bit single, real.        '

; Косинус с градиентом в реальном времени на математическом сопроцессоре 8087.
;Анимация тригонометрической функции косинус и стандартной палитры цвета
;рассчитывается по классической формуле через тангенс с учетом знака. Шаг,
;амплитуда и градиент от времени анимации настраиваемая.
; Точность вычислений: 32-битная, реальная, округление к ближайшему целому.

; Комментарий от Данилы и чуть более быстрый вариант первой версии (80287).
;Сохраняем регистр SWR сопроцессора в память, чтобы потом считать в AX.
;На старших моделях FPU можно сразу сделать fstsw ax
;       fstsw word [fpu_state]
;       mov ax,[fpu_state]
; Загружаем флаги из регистра AH, флаги C0, C2, C3 из FPU при этом попадают
;в CF, PF, ZF соответственно. После этого можно использовать привычные
;условные переходы, предполагая, что fcom всегда сравнивает ST0 с операндом,
;то есть фактически имеет вид: fcom ST0, argument
;       sahf
;       jbe short DrSC1                 ; ST0 <= Src (pi/2)
;       fcom dword [pi_64]              ;
;       fstsw word [fpu_state]
;       mov ax,[fpu_state]
;       sahf
;       ja short DrSC1                  ; ST0 > Src (pi*6/4)

;Flags bits using compare.
;Operands:        C3:     C2:   C0:     Word to compare bit or mask:
;ST(0) > SRC      0       0     0       00000h
;ST(0) < SRC      0       0     1       00100h
;ST(0) = SRC      1       0     0       04000h
;Incomparable     1       1     1       04500h

CosineAnimation:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp

        call near VXSetFullDAC
        xor ax,ax
        call near VXSetActDispPage      ;Using one page.
        mov word [vx_cursor_x],MATH_TXT_SX
        mov word [vx_cursor_y],MATH_TXT_SY
        mov byte [vx_font_color],MATH_TXT_COL1

        finit                           ;Init 8087.
        fstcw word [control_reg]        ;CR to memory, with await.
        and word [control_reg],0F0FFh   ;Reset all masks, trunc only save res.
        fldcw [control_reg]             ;Round to near and 32-bits float.
        mov bp,00102h ;ANIM_COS_TIMER           ;Animation cycle or debug.
        xor si,si                       ;Text offset.

DrSCC:  mov cx,GFX_SCR_WIDTH            ;Fix bug or leave as is. :)
        mov di,cos_table

DrSC0:  fld dword [value_x]             ;Draw full cosinus using CX counter.
        fptan                           ;Top after, ST0 is 1.
        fincstp                         ;Stack top to ST0.
DrSC2:  fst ST1                         ;Save tan ST1 to ST0.
        fmul ST0,ST1                    ;tg^2 ST0 * ST1.
        fdecstp                         ;Was ST7 = 1 or use fld1.
        fadd ST0,ST1                    ;(tg^2 + 1), ST0 + ST1.
        fld1                            ;ST0 = 1.
        fdiv ST0,ST1                    ;1 / (tg^2 + 1), ST0 / ST1.
        fsqrt
        fld dword [value_x]             ;Store position x and check for sign.
        fcom dword [pi_24]
        fstenv [fpu_data]               ;C0,C1 == 0 for ST0 > DATA, 8,10 bits.
        test word [fpu_data + 002h],00500h
        jnz short DrSC1                 ;Page 73.
        fcom dword [pi_64]
        fstenv [fpu_data]
        test word [fpu_data + 002h],00500h
        jz short DrSC1
        fincstp                         ;Remove X position, store neg.
        fld dword [sign_neg]
        fmul ST0,ST1                    ;Change sign of result cosec.
        jmp short DrSCB
DrSC1:  fincstp                         ;To result of cosec.
DrSCB:  fmul dword [cos_y]
        frndint                         ;Convert to intger.
        fistp word [di]                 ;Save to table and next X.
        add di,00002h

        fld dword [value_x]
        fadd dword [cos_x]
        fcom dword [pi_84]              ;If period is more or equal than 2Pi.
        fstenv [fpu_data]               ;SR - second word, 14 bit, equal C3.
        mov ax,[fpu_data + 002h]
        test ax,04000h                  ;May be not the case.
        jnz short DrSCA1
        test ax,00500h
        jnz short DrSCA                 ;Add because other bits set/reset.
DrSCA1: fincstp
        fldz                            ;To zero as cycle, sub 2Pi.
DrSCA:  fstp dword [value_x]            ;Next x.
        loop DrSC0

        mov di,cos_table                ;Draw full cosinus.
        xor dx,dx
        call near VXWaitVSync           ;Starting drawing.
        cmp bp,00002h
        jnz short DrSCW
        mov al,03Fh                     ;Only cosinus without colors.
        jmp short DrSC3
DrSCW:  mov al,07Fh
DrSC3:  mov cx,COS_OFFS_Y               ;BX = Y.
        sub cx,[di]                     ;Or ADD.
        call near VXSetPixel

        ;jmp short DrSCU

; Clear part of screen or draw an 'glowing' of cos.
        ;xor al,al
        mov al,0C0h                     ;First variant only one color.
        mov ah,080h
        sub al,[cos_y_int]
        sub al,[cos_y_int]
        sub ah,[cos_y_int]
        sub ah,[cos_y_int]
        xor bx,bx
DrSCT:  inc bx
        push cx
        add cx,bx
        call near VXSetPixel
        pop cx
        push cx
        sub cx,bx
        xchg al,ah
        call near VXSetPixel
        xchg al,ah
        pop cx
        cmp al,080h
        jbe short DrSCV
        dec al
DrSCV:  cmp ah,040h
        jbe short DrSCX
        dec ah
DrSCX:  cmp bx,00040h
        jnz short DrSCT

DrSCU:  add di,00002h
        inc dx
        cmp dx,COS_WIDTH
        jnz short DrSCW

        ;jmp short DrSCH

; Dynamic height for COS.

        fld dword [cos_y]               ;STP = ?
        fadd dword [cos_y_step]
        fcom dword [cos_y_min]          ;If Y less than MIN.
        fstenv [fpu_data]               ;SR - second word, 14 bit, equal C3.
        test word [fpu_data + 002h],00100h
        jnz short DrSCD
        fcom dword [cos_y_max]          ;If Y more than MAX.
        fstenv [fpu_data]
        test word [fpu_data + 002h],04500h
        jnz short DrSCE                 ;All bits must be reset.
DrSCD:  fincstp                         ;If Y is out of range, then change
        fld dword [cos_y_step]          ;sign of step.
        fmul dword [sign_neg]
        fstp dword [cos_y_step]
DrSCE:  fld dword [cos_y]
        fadd dword [cos_y_step]
        fst dword [cos_y]               ;STP = 0?
        ;fabs
        frndint
        fistp word [cos_y_int]          ;integer.

        ;xor dx,dx
        ;mov cx,[cos_y_int]
        ;mov al,07Fh
        ;call near VXSetPixel

        jmp short DrSCI

; Dynamic step x for COS.

DrSCH:  fld dword [cos_x]
        fadd dword [cos_x_step]
        fcom dword [cos_x_min]
        fstenv [fpu_data]
        test word [fpu_data + 002h],00100h
        jnz short DrSCF
        fcom dword [cos_x_max]
        fstenv [fpu_data]
        test word [fpu_data + 002h],04500h
        jnz short DrSCG
DrSCF:  fincstp
        fld dword [cos_x_step]
        fmul dword [sign_neg]
        fstp dword [cos_x_step]
DrSCG:  fld dword [cos_x]
        fadd dword [cos_x_step]
        fstp dword [cos_x]

DrSCI:  call near VXWaitVSync           ;Print char.
        mov dx,si                       ;DX - text offset.
        mov bx,anim_cos_txt
        mov al,001h
        mov ah,11000001b
        cmp dx,MATH_TXT_NEXT
        jc short DrSCP1
        mov ah,11000000b
        jmp short DrSCP2
DrSCP1: call near VXPrintString
        inc si
        cmp si,MATH_TXT_NEXT
        jne short DrSCP2
        mov byte [vx_font_color],MATH_TXT_COL2
        mov word [vx_cursor_x],MATH_TXT_X1
        mov word [vx_cursor_y],MATH_TXT_Y1

DrSCP2: ;fldz
        ;fstp dword [value_x]
        dec bp
        jnz DrSCC

        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret


;5. Горящее пламя, авторы, ссылки и завершение.


FLAME_HEIGHT            EQU 050h        ;Flame max.
FLAME_SIZE              EQU FLAME_HEIGHT * GFX_SCR_WIDTH
FLAME_SIZE_PLANE        EQU (FLAME_SIZE / 4) - 80       ;Without random line.
FLAME_INTENSE           EQU 01h
FLAME_SCR_ADDR          EQU GFX_BYTES_PER_LINE * 50h
FLAME_SRC_OFFS          EQU FLAME_SIZE - GFX_SCR_WIDTH
FLAME_COLOR_MASK        EQU 0FFFFh
FLAME_8BTP_COLOR        EQU 07Fh
FLAME_TIMER             EQU 001A0h
FLAME_TXT_SX            EQU 00004h
FLAME_TXT_SY            EQU 00010h
FLAME_TXT_X1            EQU 00000h
FLAME_TXT_Y1            EQU 000A0h
FLAME_TXT_NEXT          EQU 00Dh           ;Upper part of text lenght.
FLAME_TXT_COL1          EQU 0007Fh
FLAME_TXT_COL2          EQU 00Fh

back_rect       dw 0000h, 009Fh, 013Fh, 00EFh   ;Background for text.

flame_outro_txt dw 01AAh
                dw 0004h
                db '    8-BIT    '
                db '  TEA PARTY  '            ;Add space to config.
                db '   Classic flame using fast shifts...   '
                db ' Create special for Demodulation 2021,  '
                db '          by 8-Bit Tea Party!           '
                db '    Thanks for watching and good Tea!   '
                db '                                        '
                db '  Code: Alexander Serov, Danila Peroff  '
                db '           and Danya Potapov.           '
                db '      Organizer: Dmitry Galashin.       '
                db ' Thanks to our friends: Andrew, Vasily, '
                db 'Vovan, Eugene, Konstantin, Roman and...!'


;Классика пламени с быстрыми сдвигами и арифметкой.

FlamesOutro:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es

;Print title on screen.

        mov ah,10000010b
        mov al,FLAME_TXT_NEXT
        lea bx,flame_outro_txt
        xor dx,dx
        mov word [vx_cursor_x],FLAME_TXT_SX
        mov word [vx_cursor_y],FLAME_TXT_SY
        mov byte [vx_font_color],FLAME_8BTP_COLOR
        call near VXPrintString
        add dl,al
        mov word [vx_cursor_x],FLAME_TXT_SX
        call near VXPrintString

;Draw background for text.

        lea bx,back_rect
        mov al,FLAME_8BTP_COLOR
        mov ah,-01h
        call near VXDrawRect

;Set color palette for flames, from yellow to orange.

        mov al,00h                      ;Создаём жёлто-ораньжевую палитру.
        mov ah,03Fh
        mov dl,03FH
        mov dh,00h
        mov cx,80h
PalFl2: dec al
        call near VXSetPalColor
        test cx,0001h
        jnz short PalFl1
        test dh,dh
        jz short PalFl1
        dec dh
PalFl1: loop PalFl2
        mov cx,40h
PalFl4: dec al
        call near VXSetPalColor
        test cx,0001h
        jnz short PalFl3
        dec dl
PalFl3: loop PalFl4
        mov cx,040h
PalFl6: dec al
        call near VXSetPalColor
        dec ah
        test cx,0001h
        jnz short PalFl5
        test dl,dl
        jz short PalFl5
        dec dl
PalFl5: loop PalFl6

;Flame effect without procedures, to release version.

Start:  mov ax,GFX_SCR_ADDR
        mov es,ax
        cld
        mov bp,FLAME_TIMER              ;Main cycle.
        mov dx,1Ah

        mov word [vx_cursor_x],FLAME_TXT_X1
        mov word [vx_cursor_y],FLAME_TXT_Y1
        mov byte [vx_font_color],FLAME_TXT_COL2

FlameA: push dx
        mov di,FLAME_SCR_ADDR
        lea si,flame_data
        mov bx,di
        mov dx,si
        add si,FLAME_SIZE

;Формируем линию-источник огня, самая нижняя в буфере.
Flame0: dec si
        dec si
        xor ax,ax
        call near RandomSimple
        and ax,FLAME_COLOR_MASK
        ;mov word ds:[si],0FFFFh
        mov [si],ax
        cmp si,flame_data + FLAME_SRC_OFFS
        ja short Flame0

;Отображаем буфер пламяни на экран.
        call near VXWaitVSync
        mov al,00000001b
Flame2: mov di,bx
        mov si,dx
        call near VXSetPlanes
        mov cx,FLAME_SIZE_PLANE
Flame1: movsb
        add si,0003h
        loop Flame1
        inc dx
        shl al,1
        test al,00010000b
        jz short Flame2

;Обновляем буфер пламени для всех пикселей кроме исходной линии.
        sub dx,0004h
        mov si,dx
        mov di,si
        xor dx,dx
        mov ax,dx
        add si,GFX_SCR_WIDTH
        mov bl,FLAME_HEIGHT - 1

Flame3: mov dl,[si]
        mov al,[si + 01h]
        add dx,ax
        shr dx,1
        jz short Flame4
        dec dl
Flame4: mov [di],dl
        ;mov byte [di],07Fh
        mov cx,GFX_SCR_WIDTH - 02h
Flame5: inc si
        inc di

;Правило пламени, менять по вкусу...
        xor dh,dh
        mov dl,[di]
        mov al,[si]
        add dx,ax
        mov al,[si + 01h]
        add dx,ax
        mov al,[si - 01h]
        add dx,ax
        shr dx,1
        shr dx,1
        test dl,dl
        jz short Flame6
        dec dl
Flame6: ;mov byte [di],0DFh
        mov [di],dl
        loop Flame5
        inc si
        inc di
        xor dh,dh
        mov dl,[si]
        mov al,[si - 01h]
        add dx,ax
        shr dx,1
        jz short Flame7
        dec dl
Flame7: ;mov byte [di],03Fh
        mov [di],dl
        inc si
        inc di
        dec bl
        jnz Flame3

        pop dx
        push bx                                 ;
        push ax
        lea bx,flame_outro_txt
        mov al,01h
        mov ah,10000000b
        call near VXPrintString
        inc dx
        pop ax
        pop bx

        dec bp
        jnz FlameA

Dem0:   pop es
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

; Процедура гашения экрана через палитру и синхронизацией по лучу.
;! Возможно стоит оформить процедуру как библиотечную.

VXFadeOut:
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

screen_mode     db 000h

%include "vga_sys.asm"
%include "dac.asm"
%include "pixel.asm"
%include "random.asm"
%include "print_g.asm"
%include "lines.asm"
;%include "fm_opl.asm"

;To speed up assembly, remove.
flame_data       db 000h
;flame_data      db FLAME_SIZE dup (0)
