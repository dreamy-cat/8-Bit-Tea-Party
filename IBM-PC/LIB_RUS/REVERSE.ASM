; Процедура реверса или изменения порядка бит в регистрах на обратный, т.е.
;самый младший бит становится старшим и наоборот. Содержимое регистров не имеет
;значения. 64 бита не поддерживается, флаги без изменений.
; Вход:
;AL     8 бит;
;AX     16 бит;
;AX:DX  32 бита;
;CH     биты флагов:
;0..1   размерность операнда в битах, 00: 8 - 11:64 бита;
; Выход: изменение регистров данных.
CPU 8086
        org 100h
        pushf
        mov ax,00F20h
        mov dl,00000011b
        call near ClearScreen
        xor al,al
        mov bx,str_reverse
        xor dx,dx
        call near Print
        mov cl,00Eh
        mov bp,00500h
        lea si,debug_byte
        lea bx,str_reverse
        cld
Demo4:  cmp cl,06h
        jbe short Demo1
        jnz short DemoA
        add bp,00100h
DemoA:  lodsb                           ; 8 bit
        mov ch,00000000b
        jmp short Demo2
Demo1:  jnz short DemoB
        add bp,00100h
DemoB:  cmp cl,001h
        jbe short Demo3
        lodsw                           ; 16 bit
        mov ch,00000001b
        jmp short Demo2
Demo3:  jnz short DemoC
        add bp,00100h
DemoC:  lodsw                           ; 32 bits
        mov dx,[si]
        add si,02h
        mov ch,00000010b
Demo2:  lea bx,str_binary
        mov di,cx
        mov cl,08h
        xchg cl,ch
        shl ch,cl
        xchg ch,cl
        xor ch,ch
        mov [bx],cx
        mov cx,di
        call near BinaryToString
        push ax
        push dx
        mov dx,bp
        xor al,al
        call near Print
        add bp,[bx]
        add bp,00004h
        pop dx
        pop ax
        call near ReverseBits
        call near BinaryToString
        push ax
        push dx
        mov dx,bp
        xor al,al
        call near Print
        sub bp,[bx]
        sub bp,00004h
        add bp,00100h
        pop dx
        pop ax
        dec cl
        ;cmp cl,05h
        jnz short Demo4
Demo0:  xor ah,ah
        int 16h
        popf
        ret


debug_byte      db 000h, 0FFh, 001h, 080h, 081h, 055h, 0AAh, 05Ah
debug_word      dw 00000h, 0FFFFh, 08001h, 05185h, 055AAh
debug_dword     dd 0FA518A50h

str_reverse     dw 00128h
                dw 00004h
                db " Procedure reverse bits in registers AL,AX and AX:DX. "
                db "Using masks and logicals instructions for 8-bit data. "
                db "Or using cycle rols with carry flag for 16-32 bits. "
                db "Bytes for debug: 000h, 0FFh, 001h, 080h, 081h, 055h, "
                db "0AAh, 05Ah. Words: 00000h, 0FFFFh, 08001h, 05185h, 055AAh. "
                db "Double word: 0FA518A50h."

str_binary      dw 00020h
                dw 00004h
                db 020h dup ('.')

;8 bit переделать по одному биту.
ReverseBits:
        pushf                           ; Сохраняем флаги.
        push bx                         ; Сохраняем регистры.
        push cx
        push si
        push di
        mov cl, ch                      ; Копируем флаги размера.
        and cl, 00000011b               ; Оставляем только значимые биты размера.
        cmp cl, 00000011b               ; Проверяем на 64-битный режим.
        jz short RevBit0                ; Если да, переходим к завершению.
        mov ch, 008h                    ; Загружаем базовое значение для расчета размера
        shl ch,cl                       ; Сдвигаем 8 влево на CL (0:8, 1:16, 2:32 бит).
        xchg ch,cl                      ; Теперь CL = размер в битах, CH = исходные флаги.
        test ch,ch                      ; Проверяем режим обработки (8 бит или 16/32).
        jnz short RevBit1               ; Если не 8 бит, переходим к обработке 16/32 бит.
        mov bl,10000000b                ; Маска для старшего бита.
RevBit2:dec cl                          ; Уменьшаем счетчик битов.
        mov bh,al                       ; Копируем текущее значение AL.
        and bh,bl                       ; Изолируем значение по маске BL.
        not bl                          ; Инвертируем маску.
        and al,bl                       ; Сбрасываем бит в AL.
        not bl                          ; Восстанавливаем исходную маску.
        shr bh,cl                       ; Сдвигаем бит в младшую позицию.
        shr bl,cl                       ; Готовим маску для младшего бита.
        mov ch,al                       ; Копируем AL для работы с младшим битом.
        and ch,bl                       ; Изолируем младший бит.
        shl ch,cl                       ; Сдвигаем младший бит в старшую позицию.
        not bl                          ; Инвертируем маску для сброса младшего бита.
        and al,bl                       ; Сбрасываем младший бит в AL.
        not bl                          ; Восстанавливаем маску.
        or al,bh                        ; Устанавливаем старший бит в младшую позицию.
        or al,ch                        ; Устанавливаем младший бит в старшую позицию.
        dec cl                          ; Уменьшаем счетчик для следующей пары битов.
        shl bl,cl                       ; Сдвигаем маску для следующего бита.
        test cl,cl                      ; Проверяем, завершена ли обработка.
        jnz short RevBit2               ; Повторяем, если биты остались.
        jmp short RevBit0               ; Переходим к завершению.
RevBit1:cmp ch,00000001b                ; Проверяем, 16-битный ли режим.
        jnz short RevBit3               ; Если нет, переходим к 32-битному режиму.
        xor bx, bx                      ; Обнуляем BX для хранения результата.
        shr cl,1                        ; Делим размер на 2.
RevBit4:clc                             ; Сбрасываем флаг переноса.
        rcl ah,1                        ; Вращаем старший байт (AH) через CF.
        rcr bl,1                        ; Вращаем CF в старший бит BL.
        rcl al,1                        ; Вращаем младший байт (AL) через CF.
        rcr bh,1                        ; Вращаем CF в старший бит BH.
        dec cl                          ; Уменьшаем счетчик итераций.
        jnz short RevBit4               ; Повторяем для всех битов.
        mov ax, bx                      ; Сохраняем результат в AX.
        jmp short RevBit0               ; Переходим к завершению.
RevBit3:xor si,si                       ; Обнуляем SI для старшей части результата.
        xor di,di                       ; Обнуляем DI для младшей части результата.
        shr cl,1                        ; Делим размер на 2.
RevBit5:clc                             ; Сбрасываем флаг переноса.
        rcl dx,1                        ; Вращаем старшую часть (DX) через CF.
        rcr si,1                        ; Вращаем CF в старший бит SI.
        rcl ax,1                        ; Вращаем младшую часть (AX) через CF.
        rcr di,1                        ; Вращаем CF в старший бит DI.
        dec cl                          ; Уменьшаем счетчик итераций.
        jnz short RevBit5               ; Повторяем для всех битов.
        mov ax,si                       ; Сохраняем обращенную старшую часть в AX.
        mov dx,di                       ; Сохраняем обращенную младшую часть в DX.
RevBit0:pop di                          ; Восстанавливаем регистры
        pop si
        pop cx
        pop bx
        popf                            ; Восстанавливаем флаги.
        ret                             ; Возврат из процедуры.

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

;Глобальные константы и системные переменные, временно.

SCR_ADDRESS             EQU 0B800H      ;Адрес буфера экрана CGA+.
SCR_WIDTH               EQU 050H        ;Ширина экрана 80 символов, режим 1.
SCR_HEIGHT              EQU 019H        ;Высота экрана 25 символов, режимы 1,3.
SCR_WIDTH_BYTE          EQU 0A0H        ;Количество байт на каждую линию.
SCR_WIDTH_WORD          EQU 050H        ;Количество слов на каждую линию.
SCR_SIZE_BYTE           EQU 00FA0H      ;Размер экрана(страницы) в байтах.
SCR_SIZE_WORD           EQU 007D0H      ;Размер экрана(страницы) в словах.

STR_LEN_SIZE            EQU 002H        ;Количество байт для размера строки.
STR_LEN_OFFS            EQU 00000H      ;Смещение длины строки от начала адреса.
STR_TEXT_OFFS           EQU 00002H      ;Смещение текста от начала адреса.
STR_TEXT_MAX            EQU -00004H     ;Максимальная длина текста в строке.

scr_width       db SCR_WIDTH
scr_height      db SCR_HEIGHT
scr_size_word   dw SCR_SIZE_WORD
scr_cursor_x    db 000h
scr_cursor_y    db 000h
scr_size_byte   dw SCR_SIZE_BYTE  ; размер буффера экрана в байтах, если удобней для вычислений.
