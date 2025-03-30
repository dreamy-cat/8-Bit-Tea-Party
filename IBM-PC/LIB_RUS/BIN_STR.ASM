;8-Бит Чаепитие! Лицензия: Creative Commons.
;Платформа: 8086, BIOS, CGA+.
;Инструменты: NASM(2.15).
;Модули: system.asm, screen.asm.
;Авторы: Даниил Потапов (danilzatruda23@gmail.com) [1],
;        Александр Серов (funny.dreamy.cat@gmail.com) [2].
;Быстродействие: примерно тактов, в/не зависимости от входных параметров.
;Память: байт всего кода и сколько статичных/внешних прямых данных.

; Демонстрация и тестирование преобразования данных в бинарное или двоичное
;представление строкового формата.

; Процедура преобразования целочисленных данных в бинарное или двоичное
;текстовое представ4ление в формате нашей строки с учетом флагов и размерностей.
; Символы 0 и 1 сохраняются в память по всей длине, в первой версии без учета и
;контроля допустимой длины строки, всё управление на стороне вызова. Проверяется
;только актуальная длина и символы перезаписываются как есть.
CPU 8086
        org 100h
        pushf
        mov ax,00F20h
        mov dl,00000011b
        call near ClearScreen
;Вывод всех 12 возможных комбинаций с преобразованием с учётом всех флагов.
        mov ch,00000000b
        xor dx,dx
        cld
        mov si,00004h

Demo6:  cmp si,00004h
        jnz short Demo1
        lea bx,str_debug
        xor al,al
        call near Print
        add dh,002h
        lea bx,str_forward
        call near Print
        inc dh
Demo1:  cmp si,00002h
        jnz short Demo2
        inc dh
        lea bx,str_backward
        call near Print
        or ch,00001000b
        inc dh
Demo2:  mov cl,003h
        lea bx,bin_string
Demo3:  mov di,dx
        mov ax,0FEDCh
        mov dx,00F0Ah
        call near BinaryToString
        mov dx,di
        xor al,al
        call near Print
        inc dh
        inc ch
        dec cl
        jnz short Demo3
        cmp si,00004h
        jz short Demo4
        cmp si,00003h
        jz short Demo4
        cmp si,00002h
        jnz short Demo5
Demo4:  mov di,bx
        mov bx,cx
        mov al,'.'
        mov cx,[di + STR_LEN_OFFS]
        add di,[di + STR_TEXT_OFFS]
        rep stosb
        mov cx,bx
        xor ch,00000111b
Demo5:  dec si
        jnz short Demo6
Demo0:  xor ah,ah
        int 16h
        popf
        ret


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
;5..7   резерв. 2,3,4 бит дополнительно, может прямо на вещании сделаем.

BinaryToString:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        mov cl,ch
        and cl,00000011b
        cmp cl,00000011b
        jz short BinStr0                ; 64 bits not work
        mov di,ax
        mov ax,00008h
        shl ax,cl
        mov cl,al                       ; cl bits
        mov si,ax                       ; si - 16 bit size
        mov ax,di
        test ch,00000100b
        jnz short BinStr4               ; to right
        mov di,[bx + STR_TEXT_OFFS]
        add di,si                       ; if left
        jmp short BinStr3
BinStr4:mov di,[bx + STR_TEXT_OFFS]
        add di,[bx + STR_LEN_OFFS]      ; if right
BinStr3:dec di
        clc
        test ch,00001000b               ; or reverse bit  !optimize code
        jnz short BinStr5
        rcr dx,1
        rcr ax,1
        jmp short BinStrA
BinStr5:mov si,cx
        and ch,00000011b
        jnz short BinStr6
        rcl al,1
        jmp short BinStrB
BinStr6:cmp ch,00000001b
        jnz short BinStr7
        rcl ax,1
        jmp short BinStrB
BinStr7:rcl ax,1
        rcl dx,1
BinStrB:mov cx,si
BinStrA:jc short BinStr1
        mov [bx + di], byte '0'
        jmp short BinStr2
BinStr1:mov [bx + di], byte '1'
BinStr2:dec cl
        jnz short BinStr3
BinStr0:pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

bin_string     dw 00020h
               dw 00004h
               db 00020h dup ('.')

str_debug      dw 00033h
               dw 00004h
               db "Print binary integers 00F0Ah and 0FEDCh with flags."

str_forward    dw 00035h
               dw 00004h
               db "Print binary left-right and right-left, bits forward."

str_backward   dw 00036h
               dw 00004h
               db "Print binary left-right and right-left, bits backward."

;30.03.25, [1,2]: Первая версия преобразования числа в двоичную строку и демка.


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
;внешними переменными. Переменные вынести в системный файл.
; Дополнительно, возможен сброс координат нашего курсора.
; Вход:
;AH     атрибут символа по формату текстового экрана;
;AL     символ для заполнения, стандартный ASCII;
;DL     битовые поля(флаги) дополнительных настроек:
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

%include "screen.asm"