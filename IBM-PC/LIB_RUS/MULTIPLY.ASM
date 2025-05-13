;8-Бит Чаепитие! Лицензия: Creative Commons.
;Платформа: 8086, BIOS, CGA+.
;Инструменты: NASM(2.15).
;Модули: system.asm, screen.asm.
;Авторы: Даниил Потапов (daniilzatruda23@gmail.com) [1],
;        Александр Серов (funny.dreamy.cat@gmail.com) [2].
;Быстродействие: при умножении 1х1 - 227 тактов, и ещё меньше, если 0.
;При умножении 255х255 - 902 такта.
;Память: 61 байт.

;Задачи:

CPU 8086
        org 100h
        pushf
        ;mov al,0FFh
        ;mov ah,0FFh
        ;call near DebugMultiply
; C:    0   0   1   1   1
; D:    0   1   0   0   1
; B:    0   0   0   1   1
; R:C:  0:0 1:0 1:0 0:1 1:1



        mov ax,01003h
        int 10h
        mov ax,00F20h
        mov dl,00000011b
        call near ClearScreen
        mov bx,str_multiply
        xor ax,ax
        xor dx,dx
        call near Print
        ;jmp DemoR
;Main cycle
        mov cl,004h
        mov bp,data_debug
Demo1:  mov ax,ds:[bp]
        mov dx,[bin_pos_xy]
        add dl,008h
        xor ch,ch
        mov bx,str_bin_8
        call near BinaryToString
        xor al,al
        call near Print
        mov ax,ds:[bp]
        xchg ah,al
        inc dh
        call near BinaryToString
        xor al,al
        call near Print
        sub dl,008h
        inc dh
        mov bx,str_spacer
        call near Print
        inc dh
        mov [bin_pos_xy],dx
        mov ax,ds:[bp]
        push bx
        push cx
        push dx
        push bp
        cmp al,ah
        jc short MulB0
        xchg al,ah
MulB0:  xor di,di                       ;di - result
        mov dl,ah                       ;si - copy
        xor dh,dh                       ;dx - adder, cx - cflag
MulB5:  xor bp,bp
        shr al,1
        jnc short MulB1
        mov bx,00001h
        xor cx,cx
        mov si,ax
MulB4:  mov ax,dx
        and ax,bx
        test ax,cx
        jnz short MulB2
        xor ax,cx
        xor cx,cx
MulB2:  xor ax,cx
        test di,ax
        jz short MulB3
        mov cx,bx
MulB3:  xor di,ax
        shl cx,1
        shl bx,1
        jnc short MulB4
        mov ax,si
        mov bp,dx
MulB1:  call near PrintBin
        shl dx,1
        test al,al
        jnz short MulB5
        mov ax,di
        pop bp
        pop dx
        pop cx
        pop bx
        mov dx,[bin_pos_xy]
        mov dh,004h
        add dl,014h
        mov [bin_pos_xy],dx
        add bp,002h
        dec cl
        jz short DemoR
        jmp Demo1
DemoR:  xor ah,ah
        int 16h
        popf
        ret



data_debug      db 003h, 007h, 0FFh, 000h, 0AAh, 055h, 0FFh, 0FFh

str_multiply    dw 000DBh
                dw 00004h
                db " Procedure multiply 8-bit registers and save result to "
                db "16-bit register without using 'MUL' and 'ADD' instructions "
                db "of CPU. Debug data and result in hex: 003x007 = 00015; "
                db "0FFx000 = 00000; 0AAx055 = 03872; 0FFx0FF = 0FE01."

str_spacer      dw 00010h
                dw 00004h
                db 010h dup ('-')

str_bin_8       dw 00008h
                dw 00004h
                db 008h dup ('.')

str_bin_16      dw 00010h
                dw 00004h
                db 010h dup ('.')

bin_pos_xy      dw 00402h


;Extra print bp at bin pos xy, di - result
PrintBin:
        pushf
        push ax
        push bx
        push cx
        push dx
        mov ax,bp
        mov bx,str_bin_16
        mov ch,00000001b
        call near BinaryToString
        xor ax,ax
        mov dx,[bin_pos_xy]
        call near Print
        inc dh
        mov [bin_pos_xy],dx
        mov bx,str_spacer
        call near Print
        inc dh
        mov ax,di
        mov bx,str_bin_16
        call near BinaryToString
        xor ax,ax
        call near Print
        xor ah,ah
        int 16h
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret


DebugMultiply:
        pushf
        push ax
        push bx
        push dx
        push es
        mov ax,0B800h
        mov es,ax
        xor dx,dx
DemMul1:mov ax,dx
        ;call near MultiplyBit
        mov bx,ax
        mov ax,dx
        mul ah
        cmp ax,bx
        jz short DemMul0
        mov byte es:[0281h],0FFh
DemMul0:inc dx
        jnz short DemMul1
        pop es
        pop dx
        pop bx
        pop ax
        popf
        ret


; 8 битовое умножение двух чисел без использования инструкций процессора
;умножения и сложения только битовые команды. Классический метод столбиком.
;Входные данные обязательны к обновлению, компактный код без дополнительного
;сумматора, числа предполагаются беззнаковыми.
; Вход:
;AL,AH  8-битные целочисленные множители;
; Выход:
;AX     16-ти битный результат.
Multiply:
        pushf
        push bx
        push cx
        push dx
        push si                         ;di push
        push di
        cmp al,ah
        jnc short Mult0
        xchg al,ah
Mult0:  xor dx,dx                      ;result
        mov bx,ax                      ;dx - factors
        xor bh,bh
Mult4:  test ah,ah
        jz short Mult1
        shr ah,1                       ;cf
        jnc short Mult2
        mov si,dx                      ;dx - result
        mov cx,bx                      ;cx - adder
Mult3:  mov di,si                      ;di - copy
        xor di,cx                      ;di add copy of adder (cx)
        and si,cx                      ;dx - carry flag
        shl si,1                       ;dx - part result
        mov cx,si                      ;cx - carry flag
        mov si,di
        jnz short Mult3
        mov dx,si                      ;bx - result
Mult2:  shl bx,1
        jnz short Mult4
Mult1:  mov ax,dx
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        popf
        ret

; Процедура преобразования целочисленных данных в бинарное или двоичное
;текстовое представление в формате нашей строки с учетом флагов и размерностей.
; Символы 0 и 1 сохраняются в память по всей длине, в первой версии без учета и
;контроля допустимой длины строки, всё управление на стороне вызова. Проверяется
;только актуальная длина и символы перезаписываются как есть.
; Вход:
;AL     8 бит, целое число без знака;
;AX     16 бит, целое число без знака;
;AX:DX  32 бита, целое число без знака;
;DS:BX  адрес строки назначения;
;CH     биты флагов:
;0..1   размерность операнда в битах, 00: 8 - 11:64 бита;
;2      выравнивание в строке 0 - слева или 1 - справа;
;3      0 - вывод прямой слева старший к правому младшему разряду или обратный;
;4      1 - выводить только значимые разряды или 0 - все с учетом размерности;
;5..7   резерв. 3,4 бит дополнительно, может прямо на вещании сделаем.
;Выход: экран видеобуфера(страницы), все регистры остаются как есть.

BinaryToString:
        pushf                           ;Сохраняем регистр флагов и остальные
        push ax                         ;используемые регистры AX,CX,DX,SI,DI.
        push cx
        push dx
        push si
        push di
        mov cl,ch                       ;Проверяем на допустимость размерность
        and cl,00000011b                ;входных данных, 64 бита не реализовано.
        cmp cl,00000011b
        je short BinStr0
        mov di,ax                       ;Копируем AX и вычисляем количство бит
        mov ax,00008h                   ;для вывода, путем смещения числа 8
        shl ax,cl                       ;влево на младшие 2 бита флагов в CH.
        mov cl,al                       ;CL теперь 8-битный размер строки.
        mov si,ax                       ;SI 16-битный размер для удобства.
        mov ax,di                       ;Восстанавливаем число в AX.
        test ch,00000100b               ;Выравнивание вывода слева или справа.
        jnz short BinStr1
        mov di,[bx + STR_TEXT_OFFS]
        add di,si                       ;Выравнивание смещения в строку слева.
        jmp short BinStr2
BinStr1:mov di,[bx + STR_TEXT_OFFS]
        add di,[bx + STR_LEN_OFFS]      ;Выравнивание смещения в строку справа.
BinStr2:dec di                          ;[DI-1] смещение на первую позицию.
        clc                             ;Сбрасываем флаг переноса для сдвигов.
        test ch,00001000b               ;Проверяем порядок извлечения бит:
        jnz short BinStr4               ;от младших к старшим или наоборот.
        rcr dx,1
        rcr ax,1                        ;Возможно в следующей версии применить
        jmp short BinStr9               ;отдельную процедуру реверса бит.
BinStr4:mov si,cx                       ;Сохраняем флаги и анализируем данные.
        and ch,00000011b                ;Возможна оптимизация через реверс.
        jnz short BinStr5
        rcl al,1                        ;8-ми битное число.
        jmp short BinStrA
BinStr5:cmp ch,00000001b
        jnz short BinStr6
        rcl ax,1                        ;16-ти битное число.
        jmp short BinStrA
BinStr6:rcl ax,1                        ;32-х битное число.
        rcl dx,1
BinStrA:mov cx,si                       ;Восстановим флаги и счетчик.
BinStr9:jc short BinStr7                ;Анализируем флаг переноса и сохраняем
        mov [bx + di],byte '0'          ;заданное значение.
        jmp short BinStr8               ;Посчитать такты и оптимизировать
BinStr7:mov [bx + di],byte '1'          ;без одного перехода.
BinStr8:dec cl                          ;Уменьшаем основной битовый счетчик и
        jnz short BinStr2               ;переходим к следующему символу.
BinStr0:pop di
        pop si
        pop dx
        pop cx
        pop ax                          ;Восстанавливаем все используемые
        popf                            ;общие регистры, флаги и возвращаем
        ret                             ;управление в код вызова.


; Процедура расширенной печати в стандартный текстовый экран, параметры режима
;располагаются в отдельном файле или в системном заголовке. Формат строки
;уже используем наш, а не стандартный. Выход за пределы буфера или страницы не
;допускается. Отсчет координат стандартный из верхнего левого угла (0, 0),
;смещение +00000h от начального адреса. Контроль корректности строки на
;стороне вызова. Позиция курсора верна и возвращается обновленной.
; Вход:
;AL     биты(флаги) управления:
;0      0 - используются координаты DL-DH или 1 - системного(своего) курсора;
;1      1 - перенос символов на следующую строку запрещён;
;2      1 - строка должна быть напечатана в пределах буфера т.е. постранично;
;3-7    пока что резерв;
;DL     координата по горизонтали в символах, без учета атрибутов;
;DH     координата по вертикали в символах;
;DS:BX  адрес структуры строки;
; Выход:
;AX     количество выведенных символов на экран(в следующую версию).

Print:
        pushf                           ;Сохраняем состояние флагов и активных
        push ax                         ;регистров AX, BX, CX, DX, как и
        push bx                         ;указатель структуры строки.
        push cx
        push dx
        test al,00000001b               ;Проверяем: использовать наш системный
        jz short Print1                 ;курсор или координаты в DL:DH.
        mov dl,[scr_cursor_x]           ;Устанавливаем горизонтальную и
        mov dh,[scr_cursor_y]           ;вертикальную позицию нашего курсора.
Print1: cmp dl,[scr_width]              ;Проверяем, не выходят ли координаты за пределы.
        jnc short Print0                ;пределы размеров экрана и если выходят,
        cmp dh,[scr_height]             ;то завершаем процедуру.
        jnc short Print0
        mov cx,ax                       ;Запоминаем режим печати.
        xor ax,ax                       ;Готовим AX для расчета смещения адреса.
        mov al,dh                       ;Берем вертикальную позицию и
        mul byte [scr_width]            ;рассчитываем смещение по ширине строк.
        xor dh,dh                       ;Обнуляем для сложения смещений.
        add ax,dx                       ;Формируем полный адрес в словах.
        mov dx,di                       ;Сохраняем начальные значение DI.
        mov di,ax                       ;Устанавливаем адрес вывода в буфере.
        test cl,00000010b               ;Проверяем режим построчного вывода и
        jnz short Print2                ;если да, то выводим строку как есть.
        test cl,00000100b               ;Проверяем режим постраничного вывода и
        jnz short Print2                ;если не активен, то проверяем влезет ли
        add ax,[bx + STR_LEN_OFFS]      ;исходная строка во весь экран.
        cmp ax,[scr_size_word]          ;Если строка выходит за предел буфера
        jnbe short Print5               ;экрана, то отменяем вывод совсем.
Print2: mov cx,es                       ;Сохраняем исходный регистр ES и
        mov ax,SCR_ADDRESS              ;устанавливаем сегментный регистр на
        mov es,ax                       ;начало видеобуфера экрана(страницы).
        mov ax,si                       ;Запоминаем исходный регистр SI.
        mov si,bx                       ;Переназначаем указатель SI на строку и
        add si,[bx + STR_TEXT_OFFS]     ;переходим к началу самого текста.
        mov bx,[bx + STR_LEN_OFFS]      ;Извлекаем длину строки в символах.
        cld                             ;Устанавливаем флаг прямого направления.
        shl di,1                        ;Переводим смещение из слов в байты.
Print3: movsb                           ;Копируем символ в видеобуфер.
        inc di                          ;Смещаем назначение на следующий символ.
        cmp di,[scr_size_byte]          ;Контроль выхода за предел буфера.
        jz short Print4                 ;Если достигнут предел, завершаем вывод.
        dec bx                          ;Уменьшаем счетчик символов в строке и
        jnz short Print3                ;продолжаем, если символы еще доступны.
Print4: mov es,cx                       ;Восстанавливаем исходные регистры
        mov si,ax                       ;ES, SI, DI путем копирования.
Print5: mov di,dx
Print0: pop dx                          ;Восстанавливаем общие регистры, флаги
        pop cx                          ;и возвращаем управление.
        pop bx
        pop ax
        popf
        ret

; Процедура очистки текстового буфера экрана. Все параметры режима являются
;внешними переменными. Переменные вынести в системный файл. Дополнительно,
;возможен сброс координат нашего курсора.
; Вход:
;AH     атрибут символа по формату текстового экрана;
;AL     символ для заполнения, стандартный ASCII;
;DL     битовые флаги дополнительных настроек:
;0      использовать ли символы для заполнения экрана;
;1      использовать ли атрибут при очистки экрана;
;2      сбросить в нули или в начало координат(0,0) наш курсор.
;3-7    резерв.
; Выход: заполнение буфера экрана с учетом настроек(первая страница).

ClearScreen:
        pushf                           ;Сохраняем регистр флагов в стек, а
        push cx                         ;также используемые регистры СХ,DI,ES.
        push di
        push es
        mov cx,[scr_size_word]          ;Загружаем в СХ размер экрана в словах.
        mov di,SCR_ADDRESS              ;Загружаем в ES:DI адрес видеобуфера
        mov es,di                       ;экрана. В ES сегментный адрес, а
        xor di,di                       ;в DI нулевое смещение начала экрана.
        cld                             ;Сбрасываем флаг направления DF(+1).
        test dl,00000001b               ;Бит 0, заполнять-ли экран символами,
        jz short ClrScr1                ;если нет, то проверяем флаг атрибутов.
ClrScr2:stosb                           ;Записываем символ из AL в видеобуфер.
        inc di                          ;Пропускаем байт атрибута, смещение
        loop ClrScr2                    ;на следующий символ и повторяем цикл.
        mov cx,[scr_size_word]          ;Снова в CX размер экрана в словах и
        xor di,di                       ;устанавливаем смещение DI в начало.
ClrScr1:test dl,00000010b               ;Бит 1, заполнять-ли экран атрибутами,
        jz short ClrScr3                ;если нет, то к проверке сброса курсора.
        xchg al,ah                      ;AL содержит атрибут, а AH - символ.
ClrScr4:inc di                          ;Пропускаем символ, увеличивая DI на 1.
        stosb                           ;Записываем байт из AL в видеобуфер и
        loop ClrScr4                    ;повторяем цикл заполения видеобуфера.
        xchg al,ah                      ;Восстанавливаем исходное значение AX.
ClrScr3:test dl,00000100b               ;Проверяем бит сброса курсора в DL.
        jz short ClrScr0
        xor cl,cl                       ;Если бит установлен, то сбрасываем наш
        mov [scr_cursor_x],cl           ;курсор в начальные координаты X:Y(0,0).
        mov [scr_cursor_y],cl
ClrScr0:pop es                          ;Восстанавливаем регистры ES, DI, CX из
        pop di                          ;стека. Также регистр флагов и
        pop cx                          ;возвращаем управление в код вызова.
        popf
        ret

; Глобальные данные с предустановками временно в этом файле, после в system.asm.

SCR_ADDRESS             EQU 0B800H      ;Адрес буфера экрана CGA+.
SCR_SIZE_BYTE           EQU 00FA0H      ;Размер экрана(страницы) в байтах.
SCR_SIZE_WORD           EQU 007D0H      ;Размер экрана(страницы) в словах.
SCR_WIDTH               EQU 050H        ;Ширина экрана 80 символов, режим 1.
SCR_HEIGHT              EQU 019H        ;Высота экрана 25 символов, режимы 1,3.

STR_LEN_SIZE            EQU 002H        ;Количество байт для размера строки.
STR_LEN_OFFS            EQU 00000H      ;Смещение длины строки от начала адреса.
STR_TEXT_OFFS           EQU 00002H      ;Смещение текста от начала адреса.
STR_TEXT_MAX            EQU -00004H     ;Максимальная длина текста в строке.

scr_cursor_x    db 000h
scr_cursor_y    db 000h
scr_size_word   dw SCR_SIZE_WORD
scr_size_byte   dw SCR_SIZE_BYTE
scr_width       db SCR_WIDTH
scr_height      db SCR_HEIGHT

;13.05.25: Вторая версия, и демонстрация с выводом в столбик готова.
;02.05.25: Первая версия, и тестирование готово.
;27.04.25: Обсуждение черновика. Первая рабочая версия.