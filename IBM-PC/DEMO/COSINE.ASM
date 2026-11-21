; 8-Бит Чаепитие! Лицензия: Creative Commons(BY-NC-SA).
; Платформа: 8086, VGA(256Kb+), BIOS.
; Авторы: Александр Серов (alexander.serov@protonmail.com) [1],
;         Даниил Потапов (alphatea48.proton.me [2],
;         Данила Перов (peroff@protonmail.com) [3].

; Первая версия нашего эффекта анимации косинуса, осень 2021. Нет динамики
;амплитуды по вертикали, но полный градиент в 64 точки. Выравненное смещение
;слева направо в 314 точек или число Пи(3.14) с делителем 0.01. Также на месте
;центральная часть графика ярко-белым цветом. Используется одна видео-страница.
; В финальной версии эффект модифицирован, эта версия оставлена для истории и
;её можно собрать абсолютно также как и основную Демку, процедуры одинаковы.

CPU 8086                                ; 8087 автоматически! :)

%include "vga-x.asm"

BIOS_GET_SCR    EQU 00Fh                ; Имена для вызова функций BIOS.
BIOS_SET_SCR    EQU 000h
BIOS_READ_KEY   EQU 000h

        org 00100h                      ; Смещение и установка IP для .COM.
        pushf                           ; Сохраняем флаги(необязательно) и
        mov ah,BIOS_GET_SCR             ;оригинальный текстовый видеорежим.
        int 010h
        mov [screen_mode],al
        call near VXSetModeX            ; Устанавливаем графический режим Х,
        xor al,al                       ;активную видео страницу 0 и очищаем
        call near VXSetActDispPage      ;полностью буфер(256Кб) нуль цветом.
        mov ah,00001111b
        call near VXClearVRAM           ; Загружаем шрифт из ПЗУ видео адаптера,
        call near VXLoadFontBIOS        ;стандартный VGA.
        call near AnimatedCosine
Demo0:  mov ah,BIOS_READ_KEY            ; Ожидание нажатия, временно.
        int 016h
        mov ah,BIOS_SET_SCR             ; Восстанавливем режим, флаги и выходим.
        mov al,[screen_mode]
        int 010h
        popf
        ret


; Косинус с градиентом в реальном времени на математическом сопроцессоре 8087.
; Анимация тригонометрической функции косинус и стандратной палитры цветов
;рассчитывается по классической формуле через тангенс с учетом знака. Шаг,
;амплитуда и градиент от времени анимации настраиваемые, но не используются
;в данной версии. Оставлене только горизонтальное смещение через шаг.
; Точность вычислений: 32-битная плавающая точка, округление к ближайшему.

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
;       jbe short DrSC1                 ; ST0 <= SRC (pi/2)
;       fcom dword [pi_64]              ;
;       fstsw word [fpu_state]
;       mov ax,[fpu_state]
;       sahf
;       ja short DrSC1                  ; ST0 > PI * 3/2.

; Биты флагов используемые для сравнения чисел, Зубков стр 74. ;)
;Операнды:        C3:     C2:   C0:     Слова для сравнения бит или маска:
;ST(0) > SRC      0       0     0       00000h
;ST(0) < SRC      0       0     1       00100h
;ST(0) = SRC      1       0     0       04000h
;Несравнимо:      1       1     1       04500h

COS_MAIN        EQU 001A0h              ; Основной цикл анимации. Время! :)
COS_OFFS_X      EQU 00003h              ; Стартовые координаты эффект, точек и
COS_OFFS_Y      EQU 00078h              ;общие ширина и высота косинуса, всего.
COS_HEIGHT      EQU 00040h              ; Значение 314 для лучшего смещения
COS_WIDTH       EQU 0013Bh              ;числа Пи с шагом 00.1 или можно экран.
COS_GREEN       EQU 040h                ; Индекс двух цветов градиента из
COS_BLUE        EQU 080h                ;нашей стандапртной палитры и также
COS_WHITE       EQU 0C0h                ;белый цвет для текста и самого графика.
COS_TITLE_X     EQU 00000h              ; Смещения или координаты вывода для
COS_TITLE_Y     EQU 00018h              ;заголовка и основного текста описания.
COS_COLOR_1     EQU 0007Fh              ; Также их цвета и размерности.
COS_TEXT_X      EQU 00000h
COS_TEXT_Y      EQU 000B0h
COS_COLOR_2     EQU 000FFh              ; Размер заголовка в символах и цвет
COS_TEXT_NEXT   EQU 00028h              ;основного текста.

AnimatedCosine:
        pushf                           ; Сохраняем флаги и регистры.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        call near VXSetFullDAC          ; Устанавливаем нашу полную палитру и
        mov ax,0FFC0h                   ;отдельно белый цвет для оптимизации
        mov dx,0FFFFh                   ;вывод градиента вних и также параметры
        call near VXSetPalColor         ;для вывода заголовка эффекта.
        mov word [vx_cursor_x],COS_TITLE_X
        mov word [vx_cursor_y],COS_TITLE_Y
        mov byte [vx_font_color],COS_COLOR_1
        finit                           ; Инициализируем сопроцессор 8087,
        fstcw word [fpu_control]        ;загружаем регистр управления CR и
        and word [fpu_control],0F0FFh   ;включаем точность в 32 бита, округление
        fldcw [fpu_control]             ;к ближайщему целому.
        mov bp,COS_MAIN                 ; Счётчик основного цика анимации и
        xor dx,dx                       ;смещение в тексте.
DrSCC:  push dx
        mov cx,COS_WIDTH                ; Здесь была какая-то ошибка... :)
        xor bx,bx                       ; CX - общая ширина функции косинуса.
        mov di,scr_y_cos_tab
DrSC0:  fld dword [value_x]             ; Начало вычислений таблицы значений
        fptan                           ;функции и сохранение кооординат [DI].
        fincstp
DrSC2:  fst ST1
        fmul ST0,ST1                    ; tg^2
        fld1
        fadd ST0,ST1                    ; (tg^2 + 1)
        fld1
        fdiv ST0,ST1                    ; 1 / (tg^2 + 1)
        fsqrt
        fld dword [value_x]             ; Координата X, как смещение графика.
        fcom dword [pi_12]
; Сохраняем регистр SWR сопроцессора в память, чтобы потом считать в AX.
; На старших моделях FPU можно сразу сделать fstsw ax, для 80287.
        fstsw word [fpu_state]
        mov ax,[fpu_state]
; Загружаем флаги из регистра AH, флаги C0, C2, C3 из FPU при этом попадают
; в CF, PF, ZF соответственно. После этого можно использовать привычные
; условные переходы, предполагая, что fcom всегда сравнивает ST0 с операндом,
; то есть фактически имеет вид: fcom ST0, argument
        sahf
        jbe short DrSC1                 ; ST0 <= (PI * 1/2).
        fcom dword [pi_64]              ; Сравниваем с PI * 3/2.
        fstsw word [fpu_state]
        mov ax,[fpu_state]
        sahf                            ; Сохраняем флаги в AH.
        ja short DrSC1                  ; ST0 > (PI * 3/2).
DrSC4:  fincstp                         ; Удаляем позицию X, остается Y и
        fchs                            ;меняем знак числа, если требуется.
        jmp short DrSCB
DrSC1:  fincstp                         ; Умножаем значение на размерность
DrSCB:  fimul word [screen_size_y]      ;графика, целочисленно и округляем.
        frndint
        fistp word [di]                 ; Сохраняем значение в таблицу и
        add di,00002h                   ;переходим на следующее значение.
        fld dword [value_x]
        fadd dword [step_x]             ; Добавляем шаг и сравниваем с 2 * PI
        fcom dword [pi_84]              ;или полным циклом функции косинуса.
        fstsw word [fpu_state]
        mov ax,[fpu_state]              ; Анализируем регистр состояния SR и
        test ax,04000h                  ;если больше или равно, то устанавливаем
        jnz short DrSCA1                ;значение X в нуль.
        test ax,00500h
        jnz short DrSCA                 ; Если не одно из условий не выполнено.
DrSCA1: fincstp                         ; Т.к. этот вариант косинуса замыкается
        fldz                            ;полностью и точка в точку, то просто 0.
DrSCA:  fstp dword [value_x]            ; Следующая координата X в таблице.
        loop DrSC0
        mov si,scr_y_cos_tab            ; SI таблица данных, DI ширина-счётчик.
        mov di,COS_WIDTH
        mov dx,COS_OFFS_X
        call near VXWaitVSync           ; Начало отрисовки кадра графика.
DrSC3:  mov cx,COS_OFFS_Y               ; BH, счетчик градиента, CX = Y.
        sub cx,[si]                     ; Или добавляем смещение по Y.
        mov bh,COS_OFFS_Y - COS_HEIGHT / 002h
        mov ah,cl                       ; Сохраняем временно координату Y.
        mov al,COS_BLUE                 ; Последний(яркий) синий цвет палитры.
DrSC7:  cmp cl,bh                       ; Начинаем отрисовку градиента вниз,
        jc short DrSC6                  ;до предела смещения - половина высоты.
        call near VXSetPixel
        dec al                          ; Уменьшаем интенсивность цвета и
        dec cx                          ;параметр цикла по координате Y.
        jmp short DrSC7
DrSC6:  mov cl,ah                       ; Координата Y, BH - высота градиента.
        mov bh,COS_OFFS_Y + COS_HEIGHT / 002h
        mov al,COS_WHITE                ; Первый белый цвет(вместо синего).
DrSC8:  cmp cl,bh                       ; Начинаем отрисовку градиента вниз,
        jnc short DrSC9                 ;до предела смещения - половина высота.
        call near VXSetPixel
        inc cx                          ; Аналогично как и верх.
        dec al
        jmp short DrSC8
DrSC9:  inc dx
        add si,00002h                   ; Увеличиваем координату X и следующее
        dec di                          ;значение в таблице данных функции, а
        jnz short DrSC3                 ;в DI для ускорения и это счётчик.
        fld dword [start_x]             ; Смещаеся по функции через значение
        fadd dword [offset_x_anim]      ;шага для координаты X.
        fcom dword [pi_84]
        fstsw word [fpu_state]
        mov ax,[fpu_state]
        test ax,04000h
        jnz short DrSCD1
        test ax,00500h
        jnz short DrSCD                 ; Аналогично предыдущей проверке.
DrSCD1: fincstp
        fldz                            ; Сбрасываем параметр X нуль.
DrSCD:  fst dword [start_x]
        fstp dword [value_x]            ; Переходим к следующему значению X.
        pop dx
        mov bx,anim_cos_txt             ; Печатем один символа заголвка или
        mov al,01h                      ;основного текста описания эффекта.
        mov ah,11000001b
        cmp dx,COS_TEXT_NEXT
        jc short DrSCP1
        mov ah,11000000b
DrSCP1: call near VXPrintString
        inc dx                          ; Увеличиваем смещение в тексте и
        cmp dx,COS_TEXT_NEXT            ;устанавливаем параметры печати.
        jne short DrSCP2
        mov byte [vx_font_color],COS_COLOR_2
        mov word [vx_cursor_x],COS_TEXT_X
        mov word [vx_cursor_y],COS_TEXT_Y
DrSCP2: dec bp                          ; Уменьшаем основной счётчик цикла
        jnz DrSCC                       ;анимации и если не нуль, то продолжаем.
DrSCR:  pop bp
        pop di                          ; Восстанавливаем флаги, регистры и
        pop si                          ;выходим из процедуры.
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

; Данные для эффекта анимации косинуса, только необходимое.
fpu_control     dw 00000h               ; Регистр управления CR, FPU.
fpu_state       dw 00000h               ; Регистр состояния SR, FPU.
start_x         dd 0.00                 ; Начальное, текущее и шаг значения
value_x         dd 0.00                 ;функции косинуса, координата X.
step_x          dd 0.02
offset_x_anim   dd 0.04                 ; Смещение или скорость анимации кадра.
screen_size_y   dw COS_HEIGHT / 002h    ; Высота, только для FPU.
pi_00           dd 0.00                 ; Таблица стандартных значений для
pi_14           dd 0.79                 ;числа Pi, от 0 до 2 * PI.
pi_12           dd 1.57
pi_34           dd 2.36
pi_44           dd 3.14
pi_54           dd 3.93
pi_64           dd 4.71
pi_74           dd 5.50
pi_84           dd 6.28
; Общая таблица значений функции, т.е. координаты Y в словах.
scr_y_cos_tab   dw COS_WIDTH dup (00000h)

anim_cos_txt    dw 000F0h
                dw 00004h
                db '  REALTIME MATH ON  '
                db '  8087 COPROCESSOR  '
                db '  Animation of colored trigonometric    '
                db '      cosine function in real time      '
                db '      via tangent on the 8087 FPU.      '
                db '    Precision:32-bit floating point.    '
                db '          8-Bit Tea Party 2026          '

%include "vga_sys.asm"                  ; Включение необходимых графических
%include "pixel.asm"                    ;процедур для эффекта.
%include "dac.asm"
%include "print_g.asm"

screen_mode     db 000h                 ; Ихсодный видеорежим для выхода.

;2026-11-20 [1]: Правки, дополнения, комментарии и эффект теперь отдельно.
;2021-12-22 [3]: Небольшие правки и ускорения анимация от Данила(вер. Гамма).
;2021-11-07 [1,2]: Первая версия рисованя Косинуса, но эффект без анимации.
