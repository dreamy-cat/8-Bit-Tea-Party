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

; Оставшиеся задачи, без изменения формата Демонстрации или содержания:
; - проверить код на реальной ретро-платформе, не работает сопроцессор 8087,
;   возможно требуются дополнительные команды ожидания после инициализации
;   и/или сохрании/згрузке данных с поправкой на шину, пока неясно.
; - если появится возможность, то можно попробовать дополнить музыкой,
;   базовый код для OPL2 уже имеется, но возможно потребуется декодер модулей,
;   итоговое видое полностью без аудио дорожки.

; Директивы для NASM. Команды процессора 8086 и сопроцессор 8087.

CPU 8086

; Глобальные константы и имена для Демки и её эффектов. Статичные данные
;расположены рядом с кодом самих часте ниже.

%include "vga-x.asm"                    ; Имена для графической библиотеки.

DEMO_RAND_INIT  EQU 0FA0Fh              ; Начальное псевдо-случаное значение.
DEMO_FADE_SPEED EQU 001h                ; Скорость эффекта затенения 1/64 сек.
DEMO_DELAY      EQU 0001Eh              ; Задержка демонстрации на старте и в
                                        ;конце. В 1/60 кадра. Требовалось для
                                        ;редактирования видео, дополнительно.
BIOS_GET_SCR    EQU 00Fh                ; Имена для вызова функций БИОС-а.
BIOS_SET_SCR    EQU 000h
BIOS_READ_KEY   EQU 000h
DOS_RESIZE_MEM  EQU 04Ah                ; Имена для вызова сервисов ДОС-а.
DOS_ALLOC_MEM   EQU 048h
DOS_FREE_MEM    EQU 049h

        org 00100h                      ; Смещение и установка IP для .COM.
        pushf                           ; Сохраняем флаги(необязательно) и
        mov ah,BIOS_GET_SCR             ;оригинальный текстовый видеорежим.
        int 10h
        mov [screen_mode],al
        mov ah,DOS_RESIZE_MEM           ; Изменение размера сегмента, и
        mov bx,01000h                   ;освободжение памяти за 64Кб кода,
        int 21h                         ;размерности в параграфах или 16 байт.
        jc short Demo0

        call near VXSetModeX            ; Устанавливаем графический режим Х,
        xor al,al                       ;активную видео страницу 0 и очищаем
        call near VXSetActDispPage      ;полностью буфер(256Кб) нуль цветом.
        ;call near VXFadeOut
        ;mov ah,00001111b
        ;call near VXClearVRAM           ; Загружаем шрифт из ПЗУ видео адаптера,
        call near VXLoadFontBIOS        ;стандартный VGA.
        mov ax,DEMO_RAND_INIT           ; Инициализация генератора случайных
        call near RandomSimple          ;чисел в статичной памяти.
        mov cx,DEMO_DELAY
Demo1:  call near VXWaitVSync           ; Задержка в 0.5 - 1.0 секунды перед
        loop Demo1                      ;стартом, для редактирования видео.
        ;call near IntroVGAX
        ;call near VXFadeOut
        ;call near Plasma
        ;call near VXFadeOut
        ;call near Space3D              ; Вызов всех эффектов с переходом.
        ;call near VXFadeOut
        ;call near CosineAnimation
        call near VXFadeOut
        call near FlamesOutro
        ;call near VXFadeOut
        mov cx,DEMO_DELAY
Demo2:  call near VXWaitVSync
        loop Demo2
Demo0:  mov ah,BIOS_READ_KEY            ; Ожидание нажатия, временно.
        int 16h
        mov ah,BIOS_SET_SCR             ; Восстанавливем режим, флаги и выходим.
        mov al,[screen_mode]
        int 10h
        popf
        ret


; 1. Вступление и вертикальная палитра VGA адаптера по компонентам цветов и
;градиент монохромного вывода текста, с технической информацей по железу.
; Эффект выполняется в одной видео странице с задержкой по ходу луча.
; Выбранное время для реализации, примерно 10 секунд.
; Варианты: 15сек, 0120h, 10сек, 000B2h. Без учета стартовой задержка.

INTRO_MAIN      EQU 000B2h              ; Размер основного цикла анимации.
INTRO_DRAW_MAX  EQU 00080h              ; Ограничитель рисования линий.
INTRO_TITLE_X   EQU 00050h              ; Стартовые позиции заголовка и размер.
INTRO_TITLE_Y   EQU 00010h
INTRO_TITLE_SY  EQU 00014h              ; Размерность(масштаб) текста заголовка.
INTRO_TITLE_N   EQU 0000Ah              ; Новая строчка для заголовка.
INTRO_COLOR_1   EQU 0FFh                ;Цвет текста, заголовка.
INTRO_TEXT_NEXT EQU 00014h              ; Индекс перехода на текст описания.
INTRO_TEXT_X    EQU 00000h              ; Координаты текста описания эффекта
INTRO_TEXT_Y    EQU 000C0h              ;снизу обычным размером шрифта.
INTRO_COLOR_2   EQU 07Fh                ;Цвет текста описания.
INTRO_VLINE_Y1  EQU 0003Ch              ; Координаты точек для вертикальных
INTRO_VLINE_Y2  EQU 000B4h              ;линий, от 60 до 180. Длина всего 120.

; Добро пожаловать на Чай! Создавая наш движок игры для ретро-платформы
;реального процессора 8086(88), видеоадаптера ВГА и широко известного в 90-ые
;режима Mode-Х, мы реализовали классические алгоритмы демосцены той эпохи в
;палитре 256 цветов и 6-битных копомнентов Красногро-Зеленого-Синнег-Белого!

vga_intro_txt   dw 000B4h
                dw 0004h
                db 'WELCOME TO'
                db 'TEA PARTY!'
                db '  While creating a game engine for the  '
                db ' 8086 and VGA Mode-X, our team released '
                db ' a handful of classic demoscene effects '
                db '    in 256 colors and 6-bit RGB!        '

IntroVGAX:
        pushf                           ; Сохраняем все регистры и флаги.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        mov ax,00100h                   ; Очищаем 0 страницу видеобуфера,
        call near VXClearVRAM           ;назначаем её активной и заносим
        call near VXSetActDispPage      ;глобальные переменные текста.
        call near VXSetFullDAC          ; Устанавливаем палитру по умолчанию.
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
Intro7: call near VXWaitVSync           ; Печать одного символа в 3-ий кадр,
        push bx                         ;также без замедлителя, т.к. это
        push dx                         ;быстрый эффект в целом и 4 строки.
        mov bx,vga_intro_txt
        mov dx,bp
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
        jne short Intro3                ; Если переход на текст описания.
        mov byte [vx_font_color],INTRO_COLOR_2
        mov word [vx_cursor_x],INTRO_TEXT_X
        mov word [vx_cursor_y],INTRO_TEXT_Y
Intro3: cmp bp,INTRO_MAIN
        jne Intro4                      ; Замыкаем основной цикл.
        pop bp                          ; Восстанавливаем регистры и флаги.
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
; Длительность эффекта в итоге 25 секунд, скорость текста сколько возможно.
; Варинаты: 25с, 001E0h; 30с, 00240h; быстрый 20c, 00170h.

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
PLASMA_WIDTH_MASK       EQU 01FFh       ; 2^roundup(log2(PLASMA_WIDTH)) - 1.
PLASMA_HEIGHT_MASK      EQU 003Fh       ; 2^roundup(log2(PLASMA_HEIGHT)) - 1.
PLASMA_OFFS_SIZE        EQU 008h        ; Размеры таблиц смещения 4 слова.
PLASMA_LOOP_COUNT       EQU 001E0h      ; Общий цикл для всего эффекта.
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
        cmp al,020h                     ; Заполнили первые 32 цвета.
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
        fstcw word [ctrl_reg_pls]
        mov ax,[ctrl_reg_pls]           ; В аккумулятор напрямую нельзя.
; Рrecision Соntrol = 00b - single precision(точность чуть быстрее).
; Rounding Control = 00b - round to nearest value(округление к ближайший).
        and ah,11110000b                ; Или напрямую в память.
        mov [ctrl_reg_pls],ax           ; И снова через память, т.к. 8087.
        fldcw [ctrl_reg_pls]            ; Округление 32 бита.

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
        jb short Plasma3                ; загадочных (-2), то параметр в -1.
        mov word [plasma_h + si],0FFFFh
Plasma3:
        add ax,[plasma_h + si]          ; К текущей координате Х прибавляем
        mov [plasma_x + si],ax          ;смещение или X[i] += H[i] ;)
        mov ax,[plasma_y + si]          ; Уже пред-умноженное значение Y.
        cmp ax,001h * PLASMA_WIDTH      ; Почему-то сравнением с шириной плазмы
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
        mov ds,ax                       ;нас занят таблицей функции.
        mov ah,001h                     ; Маска битового плана в AH.
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
        call near VXPrintString         ;в обеих. Печатаем следующий символ.
        test bp,00001h                  ; Т.к. странцы 2.
        jz short PlasmaB                ; Переход в случае четного.
        add word [vx_cursor_x],cx
        cmp word [vx_cursor_x],GFX_SCR_WIDTH
        jc short PlasmaB                ; Конец экрана.
        mov word [vx_cursor_x],00000h
        add word [vx_cursor_y],cx       ; 8 или 16 смещените по вертикали.
PlasmaB:pop cx
        xor cl,00000101b                ; Смена видео страниц.
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
plasma_txt      dw 00028h + 000C8h
                dw 00004h
                db '  90S SCENE PLASMA  '
                db ' SINUS DATA ON 8087 '
                db ' A classic 90s demoscene plasma effect  '
                db '  calculated using a sine formula with  '
                db '  quadratic dynimic surface functions.  '
                db ' Powered by 8087 and a 20KB sine table. '
                db '  Fell the warmth in the snowy winter!  '

plasma_A        dd 5.0                  ; Коэфиценты для основной формулы.
plasma_B        dd 25.0
ctrl_reg_pls    dw 00000h               ; Регистр управления 8087.
plasma_temp     dw 1 dup (0)            ; Временная переменная и таблицы
plasma_x        dw 4 dup (0)            ;смещений по 8 байт для плазмы.
plasma_y        dw 4 dup (0)
plasma_h        dw 4 dup (0)
plasma_v        dw 4 dup (0)


; 3. Минимальный 3Д космос по направлениям движения часовой стрелки и вперед.
; Элементарное трехмерное пространство наполненное цветными звездами с
;применением двух видео страниц и вертикальной синхронизацией.
; Кто "Опасный" в Элите?! :)
; Видеобуффер в 256 килобайт содержит четыре битовых плана с простыми трюками
;аппаратного ускорения.
; Структура режима Х: Три видеостраницы по 75 и 31 свободных килобайта.
; Общая длительность формируется из направлений(1-2) и их длительности.
; Итоговый вариант: 25 секунд, примерно 00Ch напрвлений, длительность 00074h.
; Варианты: 20с, 00Ch, 0060h; 25сек(полные) 00Сh, 00078h.

CENTER_3D_X     EQU 1000h               ; Центр проекции координат в виртуальном
CENTER_3D_Y     EQU 1000h               ;пространстве.
SPACE_DIRS      EQU 00Ch                ; Количество направлений движений и
SPACE_MAIN      EQU 0074h               ;длина общего цикла, текст отдельно.
SPACE_STARS     EQU 0FFh                ; Звёзд в пространстве до 255.
SPACE_TEXT_OFFS EQU 00780h              ; Смещение в странице снизу текста.
SPACE_TEXT_X    EQU 00000h              ; Координаты начала вывода текста.
SPACE_TEXT_Y    EQU 000C0h
SPACE_COLOR     EQU 07Fh                ; Синий или голубой цвет текста.
SPACE_COLORS    EQU 0FFh                ; Маска для цветов звезд, полный набор.
SPACE_STAR_SIZE EQU 008h                ; Размер структуры данных для звёзд.
SPACE_VMASK     EQU 000C0h              ; Маска для фона и текста на экране.
SPACE_MASK_X    EQU 01FFFh              ; Маски для горизонтальной и
SPACE_MASK_Y    EQU 01FFFh              ;вертикальной позиции звезды.
SPACE_MASK_Z    EQU 0007Fh              ; Маска для глубины звезды по оси Z.
SPACE_OFFS      EQU 00080h              ; Смещение по координатам XY.
SPACE_SPEED     EQU -002h               ; Скорость полёта или смещения по оси Z.

Space3D:
        pushf                           ; Сохраняем регистры и флаги на стек.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es
        mov ax,GFX_SCR_ADDR
        mov es,ax
        cld
        mov ax,00300h                   ; Очищаем 2 страницы и устанавливаем
        call near VXClearVRAM           ;регистр ES и флаг направления чтобы
        xor ax,ax                       ;не исполнять в основном цикле.
        xor dx,dx                       ; Формируем полную палитру для звёзд,
SpPal1: call near VXSetPalColor         ;начиная с нулевого, полностью черного.
        inc al
        inc ah                          ; Первые 64 цвета, обычный набор из
        inc dl                          ;градаций белого. Все компоненты растут
        inc dh                          ;равномерно.
        cmp al,040h
        jnz short SpPal1
        xor ah,ah                       ; Снова очищаем компоненты цветов.
        xor dx,dx
SpPal2: call near VXSetPalColor
        inc dh                          ; Вторые 64 цвета, смешиваем только
        inc dl                          ;зеленый и синий компоненты, получаем
        inc al                          ;ярко голубой или циан.
        cmp al,080h
        jnz short SpPal2
        xor ah,ah                       ; Очищаем компоненты цветов.
        xor dx,dx
SpPal3: call near VXSetPalColor
        inc ah                          ; Следующие 64 цвета, смешиваем только
        inc dl                          ;красный и зеленый цвета, получаем ярко
        inc al                          ;желтый цвет.
        cmp al,0C0h
        jnz short SpPal3
        xor ah,ah                       ; Последняя очистка компонетов цветов.
        xor dx,dx
SpPal4: call near VXSetPalColor
        inc ah                          ; Опять смешиваем все компоненты цветов,
        inc dl                          ;хм, не совсем понятно, возможно для
        inc dh                          ;удобства вывода или более красивой и
        inc al                          ;удобной генерации звёзд.
        jnz short SpPal4                ; Устанавливаем параметры вывода текста.
        mov word [vx_cursor_x],SPACE_TEXT_X
        mov word [vx_cursor_y],SPACE_TEXT_Y
        mov byte [vx_font_color],SPACE_COLOR
        xor al,al                       ; Для удобства оформляем создание звезд
        mov ah,SPACE_STARS              ;в отдельную процедуру и первый вызов
        call near CreateStars3D         ;генерирует полный набор данных.
        mov di,stars_move
        mov bh,SPACE_DIRS               ; Количество направлений полета.
        mov bl,00000001b                ; Выбор активной страницы.
        xor bp,bp                       ; Смещение текста.
Space2: mov cx,SPACE_MAIN               ; Начало основного цикла Космоса.
Space1: push cx
        call near VXWaitVSync           ; Начало переключения отображения
        mov al,bl                       ;активного кадра.
        call near VXSetActDispPage
        push cx                         ; Очистка видеобуфера активной страницы
        push di                         ;со смещением и вычетом для текста.
        xor ah,ah
        and al,00000011b
        mov dx,GFX_PAGE_SIZE_B          ; Вычисление смещения по странице.
        mov cx,GFX_PAGE_SIZE_W - SPACE_TEXT_OFFS
        mul dx
        mov di,ax                       ; DI - адрес назначения или можно
        mov al,00001111b                ;применить вызов новой процедуры.
        call near VXSetPlanes
        xor ax,ax
        rep stosw                       ; Очистка всех планов сразу.
        pop di
        pop cx
        call near MoveSpace3D           ; Смещение звёзд в таблице и отрисовка
        ;call near DrawSpace3D          ;точек в активную страницу.
        push bx                         ;
        push cx
        mov cx,SPACE_STARS              ; Производительности достаточно.
        mov bx,stars_xyz
DrS3D1A:mov al,[bx + 006h]
        call near VXSetPixel3D          ; Ставим 3Д точку и переходим далее.
        add bx,SPACE_STAR_SIZE
        loop DrS3D1A
        pop cx
        pop bx
        xor bl,00000101b                ; Переключаем видео страницы.
        pop cx
        push bx                         ; Печать символа строки без переноса.
        push ax
        mov bx,space_3D_txt
        mov al,001h                     ; Печать по одному символу.
        mov ah,00000000b
        mov dx,bp
        call near VXPrintString
        test cx,00002h                  ; Замедлитель на каждый 4-ый кадр.
        jz short Space3
        test cx,0001h                   ; Базовый замедлитель на четность.
        jz short Space3
        inc bp                          ; Увеличиваем смещение текста.
        add word [vx_cursor_x],008h
        cmp word [vx_cursor_x],GFX_SCR_WIDTH
        jnz short Space3
        mov word [vx_cursor_x],SPACE_TEXT_X
        add word [vx_cursor_y],008h     ; Следующая строка по вертикали.
Space3: pop ax
        pop bx
        loop Space1                     ; Замыкание основного цикла.
        add di,0006h                    ; Следующее направление движения.
        dec bh
        jnz Space2
        pop es                          ; Восстанавливаем регистры и выходим.
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

; Движение или смещение точек в пространстве по таблице направлений.
; DS:DI - moving directions with words.

MoveSpace3D:
        pushf                           ; Сохраняем только необходимые регистры.
        push ax
        push bx
        push cx
        push di
        mov bx,stars_xyz                ; Адрес полной таблицы звёзд в BX.
        xor cl,cl                       ; Странный код... ;)
        xor ch,ch
MovS3D1:mov ax,[bx]                     ; Загружаем координату X звезды и
        add ax,[di]                     ;проверяем, если она покинула пределы,
        cmp ax,SPACE_MASK_X             ;то создаем новую звезду.
        jnc short MovS3D2
        mov [bx],ax                     ; Аналогично другие координаты.
        mov ax,[bx + 002h]
        add ax,[di + 002h]              ; Добавляем координату Y.
        cmp ax,SPACE_MASK_Y
        jnc short MovS3D2
        mov [bx + 002h],ax
        mov ax,[bx + 004h]
        add ax,[di + 004h]              ; Добавляем координату Z.
        cmp ax,SPACE_MASK_Z
        jnc short MovS3D2
        mov [bx + 004h],ax
        jmp short MovS3D3
MovS3D2:mov al,ch                       ; Добавляем звезду с индексом равным
        mov ah,001h                     ;выбывшей за пределы пространства.
        call near CreateStars3D
MovS3D3:add bx,SPACE_STAR_SIZE          ; Смещение структуры данных типа звёзда
        inc ch                          ;в байтах и переходим на следующую.
        cmp ch,SPACE_STARS
        jnz short MovS3D1               ; Замыкаем цикл по всем звёздам,
        pop di                          ;восстанавливаем регистры и выходим.
        pop cx
        pop bx
        pop ax
        popf
        ret

; Установка точки в 3Д пространстве, вынести процедуру в библиотеку!
; Вход:
;AL     цвет точки по таблице;
;BX     адрес координат (X,Y,Z), в словах.
; Выход: измененный видеобуфер активной страницы.

VXSetPixel3D:
        pushf                           ; Сохраняем флаги и регистры.
        push ax
        push cx
        push dx
        push si
        push bp
        mov bp,ax                       ; Почему-то регистр BP, а не DI.
        mov si,[bx + 004h]              ; Загружаем координату Z и если она
        test si,si                      ;нуль, то отсекаем т.к. камера условно
        jz short SPix3D0                ;в нуле, смещения выше. На 0 не делим!
        xor dx,dx
        mov ax,[bx]                     ; Загружаем координату X и вычитаем
        sub ax,CENTER_3D_X              ;условный центра пространства.
        jnc short SPix3D1               ; DIV AX:DX(32) / SI(16).
        not dx                          ; Расширяем бит знака на DX, старшую
        idiv si                         ;и делим на глубину Z.
        jmp short SPix3D2               ; Если деление не потребовало знака,
SPix3D1:div si                          ;то в DX просто остается 0.
SPix3D2:add ax,GFX_SCR_WIDTH / 2        ; Добавляем условный центр, т.е.
        mov cx,ax                       ;координату отрицательна, то точка
        xor dx,dx                       ;устанавливается левее, иначе - правее.
        mov ax,[bx + 002h]
        sub ax,CENTER_3D_Y              ; Аналогично рассчитываем координату по
        jnc short SPix3D3               ;вертикали Y, деление равнозначное.
        not dx
        idiv si
        jmp short SPix3D4
SPix3D3:div si
SPix3D4:add ax,GFX_SCR_HEIGHT / 2
        cmp ax,SPACE_VMASK              ; Грязный трюк для отсечения места для
        jnc short SPix3D0               ;текста! Здесь оставить как есть! :)
        xchg cx,ax
        mov dx,ax                       ; Заполняем регистры для установки
        mov ax,bp                       ;обычного 2Д пикселя на экране.
        xor ah,ah                       ; AL - требуется только цвет.
        call near VXSetPixel
SPix3D0:pop bp                          ; Восстанавливаем регистры и выходим.
        pop si
        pop dx
        pop cx
        pop ax
        popf
        ret

; Процедура создания звезд(ы), т.е. генерация координат с учетом параметров,
;все данные сохраняются в таблицу звёзд ниже.
; Вход:
;AL     стартовый индекс звезды;
;AH     количество звёзд для генерации или 1 для одной.

CreateStars3D:
        pushf                           ; Сохраняем флаги и регистры.
        push ax
        push bx
        push cx
        push di
        xor cx,cx
        xchg ch,ah                      ; CH сохраним счётчик, т.к. AX нужен.
        lea di,stars_xyz                ; Расчитываем смещение в таблице звёзд.
        mov cl,003h                     ; Умножение на 8, с резервом вынести в
        shl ax,cl                       ;константу для корректности.
        add di,ax                       ; Смещаемся на нужную структуру.
        mov cl,ch
CrStar2:xor ax,ax                       ; Вызываем генератор случайных чисел и
        call near RandomSimple          ;применяем маску по размерности X.
        and ax,SPACE_MASK_X
CrStar0:mov [di],ax                     ; Сохраняем координату.
        xor ax,ax
        call near RandomSimple          ; Аналогично действуем для остальных
        and ax,SPACE_MASK_Y             ;координат Y и Z, сохраняя в таблицу.
        mov [di + 002h],ax
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_Z
        test ax,ax                      ; Дополнительная заглушка чтобы лишний
        jnz short CrStar3               ;раз не вызывать генератор, просто 1.
        inc ax
CrStar3:mov [di + 004h],ax
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_COLORS             ; Маска, включая даже темные точки.
        mov [di + 006h],ax
        add di,SPACE_STAR_SIZE          ; Смещаемся на следующую структру
        inc ch                          ;звезды, увеличиваем индекс, уменьшаем
        dec cl                          ;счётчик и замыкаем основной цикл.
        jnz short CrStar2
        pop di                          ; Восстанавливаем регистры и выходим.
        pop cx
        pop bx
        pop ax
        popf
        ret

; Формат звезды: координаты пространства(X,Y,Z) и индекс цвета, всего 4 слова.
stars_xyz:      db SPACE_STAR_SIZE * SPACE_STARS dup (000h)
; Таблица направлений движения, по смещениям координат и скорости.
stars_move:     dw 00000h, 00000h, SPACE_SPEED
                dw 00000h, 00000h, SPACE_SPEED
                dw 00000h, SPACE_OFFS, SPACE_SPEED
                dw -SPACE_OFFS, SPACE_OFFS, SPACE_SPEED
                dw -SPACE_OFFS, 00000h, SPACE_SPEED
                dw -SPACE_OFFS, -SPACE_OFFS, SPACE_SPEED
                dw 00000h, -SPACE_OFFS, SPACE_SPEED
                dw SPACE_OFFS, -SPACE_OFFS, SPACE_SPEED
                dw SPACE_OFFS, 00000h, SPACE_SPEED
                dw SPACE_OFFS, SPACE_OFFS, SPACE_SPEED
                dw 00000h, 00000h, SPACE_SPEED
                dw 00000h, 00000h, SPACE_SPEED

space_3D_txt    dw 00F0h
                dw 0004h
                db ' Elementary 3D Space and endless stars! '
                db '   Flying clockwise through a bright,   '
                db ' randomized starfield at warp velocity. '
                db ' In 3D Pixel we use a dirty code trick! '
                db '  VGA VRAM: 150RB, 2 pages and V-Sync.  '
                db '       Who is Dangerous in Elite?       '


; 4. Анимация косинуса с использованием математического сопроцессора.

; Косинус с градиентом в реальном времени на математическом сопроцессоре 8087.
; Анимация тригонометрической функции косинус и стандартной палитры цвета
;рассчитывается по классической формуле через тангенс с учетом знака. Шаг,
;амплитуда и градиент зависит от времени анимации, настраиваемая по вкусу.
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

; Флаги сравнения значения на вершине тека 8087 и аргумента, сразу слова.
;Операнды:        C3:     C2:   C0:     Слово для сравнения по битам и маске.
;ST(0) > SRC      0       0     0       00000h
;ST(0) < SRC      0       0     1       00100h
;ST(0) = SRC      1       0     0       04000h
;Несравнимо:      1       1     1       04500h
; Базовый вариант эффекта: почти 20 секунд, основной цикл 00230h, чуть короче.
;Варианты: 002BCh, 001A0h. Полный без затенения: 00238h.

COS_MAIN        EQU 00230h              ; Общий таймер для выравниваия времени.
COS_CENTER_Y    EQU 078h                ; 120 для режима X, центр экрана.
COS_HEIGHT      EQU 032h                ; Общая высота косинуса(для расчетов).
COS_GRAD_SIZE   EQU 0000Ah              ; Размер градиента общий, в обе стороны.
COS_GRAD_OFFS   EQU 005h                ; Изменение градиента, т.е. скорость.
COS_WIDTH       EQU GFX_SCR_WIDTH       ; График по ширине экрана или 314, 2PI.
COS_RED         EQU 03Fh                ; Стартовые индекс основных цветов в
COS_GREEN       EQU 07Fh                ;нашей стандартной палитре.
COS_BLUE        EQU 0BFh
COS_TITLE_X     EQU 00000h              ; Позиции и цвета вывода заголовка на
COS_TITLE_Y     EQU 00018h              ;экране и затем общий текст описания.
COS_COLOR_1     EQU 0007Fh
COS_TEXT_NEXT   EQU 028h                ; Смещение в строке на начало текста.
COS_TEXT_X      EQU 00000h
COS_TEXT_Y      EQU 000C0h
COS_COLOR_2     EQU 000FFh

CosineAnimation:
        pushf                           ; Сохранение регистров в стек.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es
        mov ax,00300h
        call near VXClearVRAM           ; Очищаем 2 видео страницы, полностью,
        mov ax,GFX_SCR_ADDR             ;устанавливаем ES на начало буфера и
        mov es,ax                       ;очищаем флаг направления.
        cld
        call near VXSetFullDAC          ; Инициализация полной стандратной
        xor ax,ax                       ;палитры цветов VGA, как в Intro.
        call near VXSetActDispPage      ; Используем только 0-ю видеостраницу.
        mov word [vx_cursor_x],COS_TITLE_X
        mov word [vx_cursor_y],COS_TITLE_Y
        mov byte [vx_font_color],COS_COLOR_1
        finit                           ; Инициализация 8087, глобальная правка.
        fstcw word [control_reg]        ; Сохраняем регистр управления CR в
        and word [control_reg],0F0FFh   ;память, маскируем только округление до
        fldcw [control_reg]             ;ближайшего целого, точность 32 бита.

; Основной цикл анимации, сначала вывод текста, расчет и после уже отрисовка.
        mov bp,COS_MAIN                 ; Основной счётчик анимации косинуса.
        xor si,si                       ; Смещение в тексте.
; Печать с ожиданием сигнала, и по возможности максимальные вычисления.
DrSCI:  call near VXWaitVSync           ; Первый кадр, печать символа текста,
        mov cx,00010h                   ;т.к. таблицу косинуса еще расчитать.
        mov bx,anim_cos_txt             ; CX размерность заголовка или текста.
        mov al,001h
        mov ah,01000001b
        cmp si,COS_TEXT_NEXT
        jc short DrSCP1
        mov cx,00008h                   ; Если заголовок уже выведен, то
        mov ah,01000000b                ;уменьшаем масштаб выводимого символа.
        jnz short DrSCP1
DrSCP1: mov dx,si
        call near VXPrintString
        test bp,00001h                  ; Задержка для смещения в тексте, для
        jz short DrSCC                  ;снижения скорости его вывода.
        inc si
        cmp si,COS_TEXT_NEXT
        jnz short DrSCP2
        mov byte [vx_font_color],COS_COLOR_2
        mov word [vx_cursor_x],COS_TEXT_X
        mov word [vx_cursor_y],COS_TEXT_Y
        jmp short DrSCC
DrSCP2: add word [vx_cursor_x],cx       ; Измнения расчет координат вручную.
        cmp word [vx_cursor_x],GFX_SCR_WIDTH
        jnz short DrSCC
        mov word [vx_cursor_x],COS_TEXT_X
        add word [vx_cursor_y],cx       ; Перенос на следующую строку.

; Расчет текущего состояния косинуса и обновление целочисленные таблицы.
DrSCC:  mov cx,GFX_SCR_WIDTH            ; Здесь была какая-то ошибка, но она
        mov di,cos_table                ;так и осталась не отмеченной! :)
DrSC0:  fld dword [cos_x]               ; Рисование полного косинуса шириной CX.
        fptan                           ; Состояние стеку 8087: ST0 = 1.
        fincstp                         ; Вершина стека ST0.
DrSC2:  fst ST1                         ; Сохраняем тангенс ST1 в ST0.
        fmul ST0,ST1                    ; Вычисляем квадрат: tg^2 = ST0 * ST1.
        fdecstp                         ; Было ST7 = 1 или можно FLD 1.
        fadd ST0,ST1                    ; Добавляем: (tg^2 + 1), ST0 + ST1.
        fld1                            ; Сохраняем на вершину: ST0 = 1.
        fdiv ST0,ST1                    ; Деление: 1/(tg^2 + 1), ST0 / ST1.
        fsqrt                           ; Вычисляем корень квадратный.
        fld dword [cos_x]               ; Сохраняем значение X и проверяем знак.
        fcom dword [pi_24]
        fstenv [fpu_data]               ; C0,C1 == 0, ST0 > X, (таблица выше).
        test word [fpu_data + 002h],00500h
        jnz short DrSC1                 ; Если знак менять не нужно, 1/2 PI.
        fcom dword [pi_64]
        fstenv [fpu_data]
        test word [fpu_data + 002h],00500h
        jz short DrSC1                  ; Сравнение на 3/2 PI.
        fincstp                         ; Увеличиваем вершину стека.
        fchs                            ; *-1! Работает! :)
        jmp short DrSCB
DrSC1:  fincstp                         ; Вершина на косеканс, умножаем на
DrSCB:  fmul dword [cos_y]              ;размер по вертикали, округляем до
        frndint                         ;ближайшего целого и сохраняем в
        fistp word [di]                 ;таблицу целых Y, увеличиваем индекс.
        add di,00002h
        fld dword [cos_x]               ; Смещение по координате Х, на шаг и
        fadd dword [cos_x_step]         ;сравниваем с полным 2 PI, если период
        fcom dword [pi_84]              ;больше или равен, то тогда вычитаем.
        fstenv [fpu_data]
        mov ax,[fpu_data + 002h]        ; Проверка на равность, скорее всего
        test ax,04000h                  ;это не работает, т.к. нет точного
        jnz short DrSCA1                ;соответствия.
        test ax,00500h
        jnz short DrSCA                 ; Проверка на больше.
DrSCA1: fsub dword [pi_84]              ; Вычитаем полный цикл, а не заносим
DrSCA:  fstp dword [cos_x]              ;ноль, т.к. накапливается погршеность.
        loop DrSC0                      ; Окончание расчета таблицы координат.

; Расчет смещения параметров косинуса на следеующий кадр анимации.
        fld dword [cos_y]               ; Изменение высоты косинуса STP = ?,
        fadd dword [cos_y_step]         ;на шаг заданный константой.
        fcom dword [cos_y_min]          ; Если Y достиг минимального значения,
        fstenv [fpu_data]               ;или меньше, слова параметров, см.выше.
        test word [fpu_data + 002h],00100h
        jnz short DrSCD
        fcom dword [cos_y_max]          ; Если Y достиг максимального значения,
        fstenv [fpu_data]               ;или больше то меняем знак шага.
        test word [fpu_data + 002h],04500h
        jnz short DrSCE
DrSCD:  fincstp                         ; Загружаем заново знаенчие шага по Y,
        fld dword [cos_y_step]          ;и меняем знак на противоположный.
        fchs
        fstp dword [cos_y_step]
DrSCE:  fld dword [cos_y]               ; Изменяем параметр Y в соответствии
        fadd dword [cos_y_step]         ;с нашим шагом или направлением,
        fst dword [cos_y]               ;возвращаем указатель на вершину и
        frndint                         ;округляем до ближайщего целого.
        fistp word [cos_y_int]          ; Сохраняем как обычное целое слово и
        jmp short DrSCDr                ;не переходим к координате X.
DrSCH:  fld dword [cos_x]               ; Динамическое смещение по координате X,
        fadd dword [cos_x_step]         ;не используем, но оставим к коде, т.к.
        fcom dword [cos_x_min]          ;графика получалась слишком хаотичной.
        fstenv [fpu_data]               ; Расчет аналогичен координате Y.
        test word [fpu_data + 002h],00100h
        jnz short DrSCF
        fcom dword [cos_x_max]
        fstenv [fpu_data]
        test word [fpu_data + 002h],04500h
        jnz short DrSCG
DrSCF:  fincstp
        fld dword [cos_x_step]
        fchs
        fstp dword [cos_x_step]
DrSCG:  fld dword [cos_x]
        fadd dword [cos_x_step]
        fstp dword [cos_x]

; Начало полной отрисовки кадра графики, сначала ожидание луча и очистка памяти.
DrSCDr: call near VXWaitVSync           ; Ожидаем луч и начинаем рисовать в
        mov dx,VGA_SEQUENCER_ADDR       ;активно странице, ES уже на буффер.
        mov ax,00F02h                   ; Не применяем вызовы наших процедур,
        out dx,ax                       ;а сразу включаем через порт все планы.
        xor ax,ax
        mov di,GFX_PAGE_SIZE_B / 003h   ; 1/3 экрана и далее еще 80 по высоте.
        mov cx,GFX_PAGE_SIZE_B / 006h   ; 002h - для 2/3, наши размеры косинуса.
        rep stosw                       ; Быстрая очистка по всем бит-планам.
        mov di,cos_table
        xor dx,dx                       ; DX - координата X или счётчик.
DrSC3:  mov al,COS_GREEN                ; Рисуем по точкам, сразу с градиентом.
        mov ah,COS_BLUE
        mov cx,COS_CENTER_Y             ; Начальное значение Y от центра.
        sub cx,[di]                     ; Вычитаем или складываем.
        ;mov bl,[cos_y_int]
        ;shl bl,1
        sub al,[cos_y_int]              ; Вычитаем сразу из индексов цвета,
        sub ah,[cos_y_int]              ;размерность Y, или регистр или можно с
        xor bx,bx                       ;множителем.
DrSCT:  add cx,bx
        call near VXSetPixel            ; Ставим точку первого цвета, вверх.
DrSC4:  xchg al,ah                      ; Смена цветов вверх и вниз.
        inc bx
        sub cx,bx                       ; Вычитание смещения для координаты Y.
        call near VXSetPixel            ; Cтавим точку второго цвета, вниз.
DrSC5:  xchg al,ah
        inc bx
        sub al,COS_GRAD_OFFS            ; Изменение градиента, по константе.
        sub ah,COS_GRAD_OFFS
DrSCX:  cmp bx,COS_GRAD_SIZE            ; Размерность градиента.
        jnz short DrSCT
DrSCU:  add di,00002h
        inc dx                          ; Следующая координата X.
        cmp dx,COS_WIDTH
        jnz short DrSC3                 ; Замыкаем цикл отрисовки.
        dec bp
        jnz DrSCI                       ; Замыкание цикла анимации.
        pop es                          ; Восстнавливаем регистры и флаги.
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

control_reg     dw 00000h               ; Сохранение регистров 8087.
cos_x           dd 0.0                  ; Текущее значение нашего параметра X.
cos_x_step      dd +0.1                 ; Шаг изменения аргумента косинусу.
cos_x_min       dd 0.1                  ; Не используется в сборке, но в коде.
cos_x_max       dd 1.0
cos_y           dd 08.0                 ; Текущая высота нашего косинуса.
cos_y_int       dw 00004h               ; Текущее значение Y, только целое!
cos_y_step      dd +1.0                 ; Шаг для Y.
cos_y_min       dd 2.0                  ; Интервал(ширина) нашего графика.
cos_y_max       dd 20.0
fpu_data        dw 10h dup (00000h)     ; Для данных FPU.
cos_table       dw GFX_SCR_WIDTH dup (00000h)
sign_neg        dd -1.0                 ; Просто -1.0 для вычислений.
pi_00           dd 0.00                 ; Табличные значения числа Пи.
pi_14           dd 0.79
pi_24           dd 1.57
pi_34           dd 2.36
pi_44           dd 3.14
pi_54           dd 3.93
pi_64           dd 4.71
pi_74           dd 5.50
pi_84           dd 6.28                 ; Полный цикл всё равно замыкается 2PI.

anim_cos_txt    dw 0118h
                dw 0004h
                db '  REAL-TIME COSINE  '
                db '  ON THE 8087 MATH  '
                db 'A colored trigonometric cosine animation'
                db '  using a slower formula with tangents  '
                db '    and square root on the 8087 FPU!    '
                db '  32-bit floating-point precision data  '
                db '   and glowing gradients in real time   '
                db '   with a few Mode-X bitplane tricks!   '


; 5. Горящее пламя, наша команда, приветы под горячий Чай и завершение Демки! :)
; Классический эффект "Пламя" с быстрыми сдвигами и арифметикой, без тяжелых
;вычислений или математического сопроцессора. Основной цикл анимации также без
;вызова процедур очистки или установки пикселя, данные напрямую в видеобуффер.
; Цветовая палитра не вынесена в константы, по умолчанию желто-оранжевая,
;старшая часть просто ярко желтая для генератора, младшая половина со снижением.
; Итоговый вариант: 20с, 00230h; 25с 002D0h, 15с 001A0.

FLAME_TIMER             EQU 00230h      ; Основной цикл анимации пламени.
FLAME_HEIGHT            EQU 050h        ; Общая выосота пламени.
; Размеры области памяти и смещения на экране размещения пламени, для ускорения.
FLAME_SIZE              EQU FLAME_HEIGHT * GFX_SCR_WIDTH
FLAME_SIZE_PLANE        EQU (FLAME_SIZE / 4) - GFX_BYTES_PER_LINE
FLAME_SCR_ADDR          EQU GFX_BYTES_PER_LINE * (GFX_SCR_HEIGHT / 003h)
FLAME_SRC_OFFS          EQU FLAME_SIZE - GFX_SCR_WIDTH
FLAME_COLOR_MASK        EQU 0FFFFh      ; Маска для цветов, полная палитра.
FLAME_TITLE_X           EQU 00034h      ; Координаты заголовка в точках и
FLAME_TITLE_Y           EQU 00010h      ;индекс цвета отображения.
FLAME_TITLE_COLOR       EQU 07Fh
FLAME_TITLE_LINE        EQU 018h        ; Следующая линия заголовка.
FLAME_TEXT_X            EQU 00000h      ; Координаты и текста описания эффекта
FLAME_TEXT_Y            EQU 000A0h      ;и наша команда.
FLAME_TEXT_NEXT         EQU 012h        ; Смещение основного текста.
FLAME_TEXT_COLOR        EQU 010h        ; Цвет близкий к темному, для контраста.

FlamesOutro:
        pushf                           ; Сохраняем регистры и флаги на стек.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es
        mov ax,00100h                   ; Очищаем только 0-ю видеостраницу.
        call near VXClearVRAM
        mov ah,10000010b                ; Выводим заголовк сразу полностью, в
        mov al,FLAME_TEXT_NEXT / 002h   ;тёмный экран, компоненты всех цветов
        mov bx,flame_outro_txt          ;пока что нулевые, но индексы верные.
        xor dx,dx
        mov word [vx_cursor_x],FLAME_TITLE_X
        mov word [vx_cursor_y],FLAME_TITLE_Y
        mov byte [vx_font_color],FLAME_TITLE_COLOR
        call near VXPrintString         ; Печать заголовка с переносом на
        add dl,al                       ;следующую строку в тексте.
        mov word [vx_cursor_x],FLAME_TITLE_X
        add word [vx_cursor_y],FLAME_TITLE_LINE
        call near VXPrintString
        mov bx,back_rect                ; Рисуем фоновый прямоугольник с
        mov al,FLAME_TITLE_COLOR        ;градиентом для вывода текста описания.
        mov ah,-001h
        call near VXDrawRect
        call near VXWaitVSync           ; Быстрое отображение заголовка и фона.
        mov al,000h                     ; Создаём жёлто-оранжевую палитру на
        mov ah,03Fh                     ;последние 128 индексов и устанавливаем
        mov dl,03FH                     ;компоненты красного и зеленого на
        mov dh,000h                     ;максимум, а счётчик в CX.
        mov cx,00080h
PalFl2: dec al                          ; Уменьшаем индекс сразу на последние
        call near VXSetPalColor         ;цвета и заполянем ярко желтым цветом
        test cx,00001h                  ;для генерации линии пламени.
        jnz short PalFl1
        test dh,dh
        jz short PalFl1
        dec dh
PalFl1: loop PalFl2
        mov cx,00040h
PalFl4: dec al                          ; Формируем индексы 64-127, уменьшаем
        call near VXSetPalColor         ;интенсивность зеленого компонента на
        test cx,00001h                  ;каждую четную интерацию индекса.
        jnz short PalFl3
        dec dl
PalFl3: loop PalFl4
        mov cx,00040h
PalFl6: dec al                          ; Формируем индексы 0-63, уменьшаем
        call near VXSetPalColor         ;интенсивность уже красного цвета и
        dec ah                          ;оставшегося зеленого чтобы в итоне
        test cx,00001h                  ;0 индекс стал черным.
        jnz short PalFl5
        test dl,dl
        jz short PalFl5
        dec dl
PalFl5: loop PalFl6
        mov ax,GFX_SCR_ADDR             ; Начало эффекта пламени, устанавливаем
        mov es,ax                       ;адрес экрана на ES и флаг направления.
        cld
        mov bp,FLAME_TIMER              ; Таймер основного цикла и установка
        mov dx,FLAME_TEXT_NEXT          ;параметров печать описания.
        mov word [vx_cursor_x],FLAME_TEXT_X
        mov word [vx_cursor_y],FLAME_TEXT_Y
        mov byte [vx_font_color],FLAME_TEXT_COLOR
FlameA: push dx                         ; Основной цикл, SI буфер источника или
        mov di,FLAME_SCR_ADDR           ;данных пламени и DI смещение на экране.
        mov si,flame_data
        mov bx,di                       ; Сохраняем регистры и сдвигаем SI на
        mov dx,si                       ;конец буфера данных.
        add si,FLAME_SIZE
Flame0: dec si                          ; Формируем линию-источник огня, самая
        dec si                          ;нижняя линия на экране.
        xor ax,ax
        call near RandomSimple          ; Генератор сразу двух точек, с маской.
        and ax,FLAME_COLOR_MASK
        mov [si],ax
        cmp si,flame_data + FLAME_SRC_OFFS
        ja short Flame0
        call near VXWaitVSync           ; Начало отрисовка кадра пламени по
        mov al,00000001b                ;планам, через каждый 4-й пиксель.
Flame2: mov di,bx
        mov si,dx
        call near VXSetPlanes
        mov cx,FLAME_SIZE_PLANE
Flame1: movsb                           ; Запись в буффер, смещение индексов с
        add si,00003h                   ;учетом автоматического +4.
        loop Flame1
        inc dx                          ; Смещение на следующий слой +1 пиксель
        shl al,1                        ;и следующий план для установки, до
        test al,00010000b               ;4-го включительно.
        jz short Flame2
        sub dx,00004h                   ; Обновляем буфер пламени для всех
        mov si,dx                       ;пикселей кроме исходной линии.
        mov di,si                       ; DX начало смещения в пикселях и
        xor dx,dx                       ;оно же уходит в SI, DI.
        mov ax,dx                       ; AX, DX = 0, для старшей части.
        add si,GFX_SCR_WIDTH            ; SI - смещение на линию и вычитание
        mov bl,FLAME_HEIGHT - 001h      ;исходной линии.
Flame3: mov dl,[si]                     ; AL, DL - две соседние точки пламени.
        mov al,[si + 001h]
        add dx,ax                       ; Складываем и нацело делим пополам
        shr dx,1                        ;через битовое смещение.
        jz short Flame4
        dec dl                          ; Если DL нуль, то снова на максимум
Flame4: mov [di],dl                     ;выкручиваем и смещаемся на следющие.
        mov cx,GFX_SCR_WIDTH - 002h     ; Основая часть линии без крайних
Flame5: inc si                          ;точек и смещаемся на следующие.
        inc di
        xor dh,dh                       ; Правило пламени, менять по вкусу...
        mov dl,[di]
        mov al,[si]
        add dx,ax                       ; Складываем текущую и следующую.
        mov al,[si + 001h]
        add dx,ax                       ; Складываем предудыдущую и следующую.
        mov al,[si - 001h]
        add dx,ax                       ; Складываем предыдущие результаты и
        shr dx,1                        ;делим всё это на 4.
        shr dx,1
        test dl,dl
        jz short Flame6
        dec dl                          ; Если нуль, то сбрасываем в максмум.
Flame6: mov [di],dl
        loop Flame5                     ; Замыкаем цикл центра линии.
        inc si
        inc di                          ; Обрабатываем крайнюю правую точку.
        xor dh,dh
        mov dl,[si]
        mov al,[si - 001h]
        add dx,ax                       ; Среднее с предыдущей, деленое пополам.
        shr dx,1
        jz short Flame7
        dec dl                          ; Сбрасываем цвет в максимум при нуле.
Flame7: mov [di],dl
        inc si
        inc di
        dec bl
        jnz short Flame3
        pop dx
        push bx                         ; Печатаем один символ общего описания
        push ax                         ;Демки и нашу команду! :)
        mov bx,flame_outro_txt
        mov al,001h
        mov ah,10000000b
        call near VXPrintString
        inc dx                          ; Следующий символ.
        pop ax
        pop bx
        dec bp                          ; Уменьшаем основной счётчик цикла и
        jnz FlameA                      ;замыкаем, пока не нуль.
Dem0:   pop es
        pop bp                          ; Восстанавливаем регистры и выходим.
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

back_rect       dw 0000h, 009Fh         ; Прямоугольник с градиетом внизу
                dw 013Fh, 00EFh         ;экрана, простые координаты углов.

flame_outro_txt dw 01A2h                ; Заголовок краткий, описание полное.
                dw 0004h
                db '  8-BIT  '
                db 'TEA PARTY'
                db '    Thank you for watching our Demo!    '
                db ' 4K lines of assembly code and hot Tea! '
                db '                                        '
                db '  Coded by Alexander Serov, Dan Peroff  '
                db '           and Danya Potapov.           '
                db '      Organized - Dmitry Galashin.      '
                db ' Thanks to our friends:Andrews, Vasily, '
                db '  Vovan, Eugene, Konstantin, Roman....  '
                db '                                        '
                db '       8-Bit Tea Party Demo, 2026       '
                db '  CPU: 8086; FPU: 8087; Memory: 64KB+;  '
                db '       VGA: Mode-X, 320x240x8bit.       '


; Процедура гашения экрана через палитру и синхронизацией по лучу.
;! Возможно стоит оформить процедуру как библиотечную.
; Скорость уменьшения компонентов цветов реализовать через регистр, причем
;возможно что лучше в сторону более медленной и/или быстрой.
; Также подумать, что у нас снижение идет не до 0, а до параметра, т.е.
;лучше может также добавить это как аргументы для процедуры.
; Чтобы можно было замделять.

VXFadeOut:
        pushf                           ; Сохраняем флаги и регистры на стек.
        push ax
        push cx
        push dx
        mov ax,00040h                   ; Всегда идем по полным 64 уровням
        mov cl,DEMO_FADE_SPEED          ;6-битной палитры цветов, константа
        div cl                          ;только скорсти. Деление 16-бит.
        mov cl,al
SFadeO5:call near VXWaitVSync           ; Можно дополнительно порегулировать
        xor al,al                       ;вызовом еще ожидания, но лучше тогда
SFadeO4:call near VXGetPalColor         ;подумать над изменением параметров.
        cmp ah,DEMO_FADE_SPEED
        jbe short SFadeO1
        sub ah,DEMO_FADE_SPEED          ; Получаем каждый цвет по индексу и
        jmp short SFadeO6               ;сравниваем все компонеты цвета с
SFadeO1:xor ah,ah                       ;нашим параметром.
SFadeO6:cmp dl,DEMO_FADE_SPEED
        jbe short SFadeO2
        sub dl,DEMO_FADE_SPEED
        jmp short SFadeO7
SFadeO2:xor dl,dl                       ; Уменьшаем все компоненты в равной
SFadeO7:cmp dh,DEMO_FADE_SPEED          ;степени и с одинаковой скоростью.
        jbe short SFadeO3
        sub dh,DEMO_FADE_SPEED
        jmp short SFadeO8
SFadeO3:xor dh,dh
SFadeO8:call near VXSetPalColor         ; Устанавливаем обновленный цвет по
        inc al                          ;компонентам и увеличиваем индекс и
        jnz short SFadeO4               ;замыкаем основной цикл по всей палитре.
        dec cl
        jnz short SFadeO5               ; Замыкаем цикл на затенение,
        pop dx                          ;восстанавливаем регистры и выходим.
        pop cx
        pop ax
        popf
        ret

screen_mode     db 000h                 ; Сохраняем режим экрана.

%include "vga_sys.asm"                  ; Файлы прямого включения исходного
%include "dac.asm"                      ;кода наших процедур. Отсутствует часть
%include "pixel.asm"                    ;с поддержкой звука OPL2.
%include "random.asm"
%include "print_g.asm"
%include "lines.asm"

; Для ускорения ассемблирования, строку поменять (убрать в итоговой версии).
flame_data       db 000h
;flame_data      db FLAME_SIZE dup (000h)
