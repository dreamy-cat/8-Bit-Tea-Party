;Welcome to 8-Bit Tea Party!
;
;Assembler, Intel 8086/8087, IBM PC.
;
;Grabbag (Duke Nukem Theme).
;Composed by Lee Jackson.

;Процессор Intel 8086\8088, 5 Мгц.
;Разрядность АЛУ: 16 бит.
;Шина данных: 16 бит.
;Шина адреса: 20 бит, 1 Мбайт.
;Реальный режим адресации, DOS 5.0.
;Основная память: 640 Кбайт.
;Системная память: 384 Кбайт.

;Основные регистры процессора 8086.
;AX[ah,al] основной аккумулятор;
;BX[bh,bl] база, смещение данных;
;CX[ch,cl] счётчик для комманд;
;DX[dh,dl] данные, порты ввода-вывода,"часть аккумулятора".
;SI        индекс источника, 16 бит.
;DI        индекс приёмника, 16 бит.
;BP        база, смещение стека.
;SP        указатель вершины стека.
;CS:IP     адрес сегмента кода.
;DS:[offs] сегмент данных.
;ES:[offs] сегмент данных, дополнительно.
;SS:SP     сегмент стека, с вершиной.
;IP        указатель на текущую комманду.

;Регистр флагов, 16 бит, флаги:
;CF        флаг переноса;
;ZF        флаг нуля.
;OF        флаг переполнения.
;SF        флаг знака.
;AF        вспомогательное переполнение.
;PF        признак чётности.
;Младшая часть регистра флага AF.

;Регистр   сегмент   замена
;  IP        CS        -
;  SP        SS        -
;BP+SI[DI]   SS     CS,DS,ES
;  BX        DS     CS,SS,ES
;SI,DI[base] DS     CS,SS,ES
;SI -> DI   DS,ES      -
;Модели памяти:
;tiny
;small
;compact
;medium
;large
;flat



CPU 8086        ;только команды процессора 8086.

;Глобальные константы.

SCR_BUFF_ADDR      equ 0xB800
SCR_SIZE_WIDTH     equ 0x0028
SCR_SIZE_HEIGHT    equ 0x0019
SCR_BUFF_SIZE_B    equ 0x0FA0
SCR_BUFF_SIZE_W    equ 0x03E8

;Константы для работы с загружаемым глобальным шрифтом.

FONT_CHAR_SIZE    equ 0x60         ;Размер шрифта в символах.
FONT_CHAR_BYTE    equ 0x08         ;Размер одного символа в байтах.
FONT_WIDTH_PIX    equ 0x08         ;Размер шрифта в точках по горизонтали.
FONT_HEIGHT_PIX   equ 0x08         ;Размер шрифта в точках по вертикали.
FONT_WIDTH_BYTE   equ 0x01         ;Ширина шрифта в байтах на линию.
FONT_FIRST_CHAR   equ 0x20         ;Первый символ шрифта, обычно пробел.

;Константы для строкового типа.
STRING_LEN      equ 0x0000         ;Смещение размера строки, слова.
STRING_OFFS     equ 0x0002         ;Смещение (смещение от смещения) текста строки (слово).

;Структура типа строки, базовый вариант. Пока что без структуры.
;Смещение:      Поле структуры:
;+0x0000        длинна строки, только текст;
;+0х0002        смещение по которому начинается непосредтственный текст;
;[+0x0002]      сам текст, в байтах, заданной длинны.
;string_example       dw 0x000C
;text_offs            dw 0x0008
;reserver             db 0x04 dup (0) - для примера.
;Пример резервирования для доработки или вариации функции печати.
;string_text          db 'Hello World!'


        org 100h
        pushf
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push bp
        push es
        push ds
;Разрабатываем и тестируем библиотечные процедуры, по отдельности.
;1) Написать процедуру демонстрации тестирования(демонстрации) строки;
;Напечатать возможные варианты последовательно, через паузу;
;2) Печать строку состоящую из одного символа, во весь буфер экрана, символы разные.
;Печать одной строки во весь буфер экрана, сгенерировать её;
;3) Печать строки длинной на один символ больше всего буфера(доп. написать комментарий на экран);
;Напечатать 25 строк, в длинну и ширину экрана сверху вниз, слева на право, длинна каждой 40.
;Напечатать строку длинной 2 симола, в последный элемент буфера(доп. комментарий).
;Произвольная строка, чтобы сработал перенос.
;4(доп.)) Процедура побитовового умножение операндов различной разрядности с выводом на экран.
;Разрядность операндов от 8 до 32 бит(пока без знака), с учётом переноса в старшие 64 бита.


;Процедура тестирования и демонстрации конвертации бинарника.
;Обязательно максимальные и минимальные числа всех разрядов, всех типов.
;Протестировать решётку, 01010101, 10101010; Протестировать интервала для каждого типа.

        ;call near PrintStringDemo
        ;call near BinaryToStringDemo
        mov al,' '
        mov ah,00011111b
        mov bl,00000011b
        call near ClearTextScreen


;1) Simple addr.
        mov ax,0xF8B2
        mov dx,0x0003
        xor bx,bx ;low 16-bit
        xor cx,cx ;high 16-bit
        or dx,dx
        jz short Mult1
Mult1:  or ax,ax
        jz short Mult2
        xor di,di
Mult3:  add bx,ax
        adc cx,di
        dec dx
        jnz short Mult3
Mult2:  mov ax,bx
        mov dx,cx

;2) CPU mult, 80-100 clk
        mov ax,0x0005
        mov dx,0x0003
        mul dx

;3) shifts with data and add.
;a * b = a * (b1 + b2) = a * b1 + a * b2.
        mov al,0xEF
        mov ah,0x50  ; 80 = 64 + 16.
        xor ah,ah
        xor bx,bx
        mov dx,ax
;effective address = base + index + disp.
;mov ax,es:[bx+si*4+0x01]
        mov cl,0x06
        shl ax,cl
        add bx,ax
        mov ax,dx
        mov cl,0x04
        shl ax,cl
        add ax,bx
;4) column mult, 16-bit.

Mult4:  lea bx,str_mul_col
        mov ax,0x0101
        call near PrintTextString
        lea bx,str_mul_1
        mov ax,0x0201
        call near PrintTextString
        lea bx,str_mul_2
        mov ax,0x0301
        call near PrintTextString
        mov ax,0xF5B0
        lea bx,str_bin_word
        mov ch,00000010b
        call near BinaryToString
        mov ax,0x0211
        call near PrintTextString
        mov ax,0xCBEF
        lea bx,str_bin_word
        mov ch,00000010b
        call near BinaryToString
        mov ax,0x0311
        call near PrintTextString
        mov ax,0x0401
        lea bx,str_del
        call near PrintTextString
        mov dx,0xF5B0   ;num fix
        mov ax,0xCBEF   ;num role
        xor si,si       ;low 16-bit
        xor di,di       ;high 16-bit
        xor bp,bp       ; -1 clk.
        lea bx,str_bin_dword
        mov cx,0x0010
Mult6:  add si,si       ;or use shifts
        adc di,di
        shl ax,0x01
        jnc short Mult5
        add si,dx
        adc di,bp
Mult5:  push ax
        push cx
        push dx
        mov ax,si
        mov dx,di
        mov ch,00000100b
        call near BinaryToString
        mov ah,0x15
        sub ah,cl
        mov al,0x01
        call near PrintTextString
        mov ax,0x0001
        call near TimerDelay
        pop dx
        pop cx
        pop ax
        loop Mult6
        mov ax,0x1501
        lea bx,str_del
        call near PrintTextString
        lea bx,str_bin_dword
        mov ax,0x1601
        call near PrintTextString
        pop ds
        pop es
        pop bp
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

BitsMultiply:
        pushf
        push ax
        push bx
        push cx
        push dx
BitMul1:test ch,00000001b   ;8-bits
        jz BitMul2


BitMul2:test ch,00000010b   ;16-bits
        jz BitMul3

BitMul3:test ch,00000100b   ;32-bits
        jz BitMul0

BitMul0:pop dx
        pop cx
        pop bx
        pop ax
        popf

;Процедура побитовового умножение операндов различной разрядности с выводом на экран.
;Вход
;al     8-bit data;
;ax     16-bit data;
;ax:dx  32-bit data;
;ch     control bits:
;0..2   data type to convert, 8, 16, 32 bits.
;Выход
;al     8-bit data;
;ax     16-bit data;
;ax:dx  32-bit data;
;ch     add bits:
;0..2   data type to convert, 8, 16, 32 bits.
;Реализовать хотя бы три способа умножения:
;через сложение, не используя оператор умножения
;простое умножение, используя команду процессора, кроме 32-бит.
;в случае совпадения чисел по степеням 2-и, реализовать с помощью сдвигов.
;умножение побитовое в столбик для большик операндов тоже.


BinaryToStringDemo:
        pushf
        mov ah,00011111b
        mov al,' '
        mov bl,00000011b
        call near ClearTextScreen
        lea bx,str_bin_byte
        mov ax,0x0101
        call near PrintTextString
        mov cl, 0x04
        lea si,bytes_data
        mov ch,00000001b
BitDem1:mov al,[si]
        call near BinaryToString
        mov ax,0x0601
        sub ah,cl
        call near PrintTextString
        mov al,'_'
        call near ClearString
        xor ch,00001000b
        inc si
        dec cl
        jnz short BitDem1
        lea bx,str_bin_word
        mov ax,0x0701
        call near PrintTextString
        mov cl, 0x04
        lea si,words_data
        mov ch,00000010b
BitDem2:mov ax,[si]
        call near BinaryToString
        mov ax,0x0C01
        sub ah,cl
        call near PrintTextString
        mov al,'_'
        call near ClearString
        xor ch,00001000b
        inc si
        inc si
        dec cl
        jnz short BitDem2
        lea bx,str_bin_dword
        mov ax,0x0D01
        call near PrintTextString
        mov cl, 0x04
        lea si,dwords_data
        mov ch,00000100b
BitDem3:mov ax,[si]
        mov dx,[si+0x02]
        call near BinaryToString
        mov ax,0x1201
        sub ah,cl
        call near PrintTextString
        mov al,'_'
        call near ClearString
        xor ch,00001000b
        add si,0x0004
        dec cl
        jnz short BitDem3


        popf
        ret

str_bin_byte dw 0x0008, 0x0004
             db '__8-Bit:'
bytes_data db 0000000b, 00001010b, 11111111b, 00000001b

str_bin_word dw 0x0010, 0x0004
             db '_________16-Bit:'
words_data dw 0xFA50, 0x05AF, 0xFFFF, 0x0000

str_bin_dword dw 0x0020, 0x0004
             db 25 dup "_"
             db '32-bit:'
dwords_data dd 0xFFAA5500, 0x0055AAFF, 0xFFFFFFFF, 0x00000000


str_mul_col dw 0x001C, 0x0004
            db 'Multiply 16-bits to 32-bits: '
str_mul_1   dw 0x0010, 0x0004
            db 'Multiplier fix: '
str_mul_2   dw 0x0010, 0x0004
            db 'Multiplier rol: '
str_del     dw 0x0020, 0x0004
            db 32 dup '-'
;Процедура очистки базового варианта строки (заполнение).
;Вход
;al  :symbol to fill
;ds:bx :addr string
;Выход
;ds:bx :addr string

ClearString:
        pushf
        push cx
        push di
        push es
        mov di,ds
        mov es,di
        mov cx,[bx+STRING_LEN]
        mov di,bx
        add di,[bx+STRING_OFFS]
        cld
        rep stosb
        pop es
        pop di
        pop cx
        popf
        ret

;Процедура конвертации числа в базовый вариант строки, в двоичной форме;
;Длинна строки должна быть больше или равна полю данных, иначе выход. Команду деления использовать нельзя.
;Input:
;al     8-bit data;
;ax     16-bit data;
;ax:dx  32-bit data;
;ds:bx  addr of string structure;
;ch     control bits:
;0..2   data type to convert, 8, 16, 32 bits.
;3      fill empty chars with zeroes to left.
;4..7   reserved.

BinaryToString:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
;check string length
        mov di,bx
        mov bh,ch
        mov cl,0x03   ;умножение на 8
        and ch,00000111b
        shl ch,cl
        ;mov bl,ch  ;bl - bits counter
        mov cl,ch
        xor ch,ch
        cmp cx,[di]
        ja short BinToS0
        mov ch,bh
        mov bx,di
        mov di,[bx+STRING_OFFS]
        add di,[bx+STRING_LEN]
BinToS3:dec di     ;cl - bits counter
        test ch,00000001b   ;8-bit data
        jz short BinToS6
        or al,al
        jz short BinToS4
        shr al,1
        jc short BinToS1
        jmp short BinToS8
BinToS6:test ch,00000010b   ;16-bit data
        jz short BinToS7
        or ax,ax
        jz short BinToS4
        shr ax,1
        jc short BinToS1
        jmp short BinToS8
BinToS7:test ch,00000100b
        jz short BinToS0
        mov si,ax
        or ax,dx
        jz short BinToS4
        mov ax,si
        shr dx,1
        rcr ax,1
        jc short BinToS1
BinToS8:mov ds:[bx+di], byte '0'
;Или использовать команду stob, совет от Данилы(CourierR)
        jmp short BinToS2
BinToS1:mov ds:[bx+di], byte '1'
BinToS2:dec cl
        jnz short BinToS3
BinToS4:or cl,cl
        jz short BinToS0
        test ch,00001000b
        jnz short BinToS0
BinToS5:mov ds:[bx+di], byte '0'
        dec di
        dec cl
        jnz short BinToS5
BinToS0:pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;Написать процедуру демонстрации
;тестирования(демонстрации) строки;
PrintStringDemo:
        pushf
        push ax
        push bx
        push cx
        push dx
        push di
        mov ah,00011111b
        mov al,' '
        mov bl,00000011b
        call near ClearTextScreen
        jmp short TestPr8
;1) Вывод строки единичной длинны во все позиции.
TestPr1:lea bx,str_single
        xor ax,ax
        mov cx,SCR_BUFF_SIZE_W
        mov di,bx
        add di,[bx+STRING_OFFS]
TestPr3:call near PrintTextString
        inc al
        cmp al,SCR_SIZE_WIDTH
        jne short TestPr2
        inc ah
        xor al,al
TestPr2:mov dx,ax
        mov ax,0x0001
        call near TimerDelay
        mov ax,dx
        inc byte ds:[di]
        loop TestPr3
;2)Составная строка длинной 10 на 4.
TestPr4:lea bx,str_part
        mov ch,SCR_SIZE_HEIGHT
        xor ax,ax
TestPr7:mov cl,0x04
TestPr6:call near PrintTextString
        mov dx,ax
        mov ax,0x0001
        call near TimerDelay
        mov ax,dx
        add al,0x0A
        cmp al,SCR_SIZE_WIDTH
        jna short TestPr5
        inc ah
        xor al,al
TestPr5:dec cl
        jnz short TestPr6
        dec ch
        jnz short TestPr7
;3)Печать строки по диагонали, с умешьшением длинны и переносом.
TestPr8:lea bx,str_long
        xor ax,ax
        mov cx,SCR_SIZE_HEIGHT
TestPr9:call near PrintTextString
        mov dx,ax
        mov ax,0x0001
        call near TimerDelay
        mov ax,dx
        dec word ds:[bx]
        ;dec word ds:[bx]
        inc al
        inc al
        inc ah
        loop TestPr9
        pop  di
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        popf
        ret

str_single dw 0x0001, 0x0004
           db '!'
str_part   dw 0x000A, 0x0004
           db '0123456789'
str_long   dw SCR_SIZE_WIDTH, 0x0004
           db SCR_SIZE_WIDTH dup '.'
;Процедура печати строки в текстовый буфер.
;Формат строки минимальный см.выше.
;Используем глобальные константы экрана.
;Вход.
;al позиция по горизонтали без ограничений.
;ah позиция по вертикали, предел только буфер.
;ds:bx      адрес  базовой структуры строки.
;Проверка на допустимость только в пределах буфера.

PrintTextString:
        pushf
        push ax
        push cx
        push dx
        push si
        push di
        push es

        mov dx,ax   ;Вычисляем смещение по координатам.
        mov al,dh
        mov cl,SCR_SIZE_WIDTH
        mul cl
        xor dh,dh
        add ax,dx
        ;shl ax,1       ; 90-100 clk.

;Расчёт адреса смещения по координатам, методами сдвигов.
;Работает только для вещаний на 40 символов по горизонтали.
        ;mov dx,ax
        ;xchg al,ah
        ;xor ah,ah
        ;mov cl,0x03     ;char+atr*2 = 2 bytes
        ;shl ax,cl       ; 8+4*4 clk.
        ;mov di,ax
        ;mov cl,0x02
        ;shl ax,cl
        ;add di,ax       ; y вычислен
        ;xor dh,dh
        ;shl dx,0x01
        ;add di,dx
        ;mov ax,di ; 80 clk.

        mov dx,SCR_BUFF_SIZE_W
        cmp ax,dx;проверяем на переполнение буфера.
        ja short PrTxtS0  ;мануал стр.2-46

;Проверка на длинну строки. Если возможно, допечатываем хвост.

        mov cx,ds:[bx]
        jcxz PrTxtS0 ; Возможно медленней
        mov di,ax
        shl di,0x01
        sub dx,ax    ; compare word
        cmp dx,cx
        jnc PrTxtS1
        mov cx,dx    ;Новая длина строки, склько поместится.

;Непосредственно выводим строчку.
PrTxtS1:mov si,bx
        add si,ds:[bx+0x02]  ;si текст строки.
        mov ax,SCR_BUFF_ADDR
        mov es,ax
PrTxtS2:movsb
        inc di
        loop PrTxtS2
PrTxtS0:pop es
        pop di
        pop si
        pop dx
        pop cx
        pop ax
        popf
        ret


;TimerDelay - функция задержки по системному таймеру.
;ах - задержка в тиках(18.2 в секунду).

TimerDelay:
        pushf           ;Доп.оптимизация, если убрать.
        push bx
        push dx
        push di
        push es
        mov bx,0x0040
        mov es,bx
        mov di,0x006C
        mov bx,es:[di] ;тики при старте.
TimDel0:mov dx,es:[di] ;текущие тики.
        sub dx,bx      ;вычисляем дельту по тикам.
        cmp dx,ax      ;не достигнут ли параметр задержки.
        jc short TimDel0
        pop es
        pop di
        pop dx
        pop bx
        popf
        ret

;Непосредственно сам текст и массив, контроль за памятью на стороне вызова.
;Процедура очистки текстового буфера экрана.
;ah   атрибут символа по формату текстового экрана.
;al   символ для заполнения.
;bl   битовые поля.
;0    использовать ли символы для заполнения.
;1    использовать ли атрибут при очистки ДА/НЕТ.
;2-7  резерв.

ClearTextScreen:
        pushf
        push cx
        push di
        push es
        mov cx,SCR_BUFF_SIZE_W
        mov di,SCR_BUFF_ADDR
        mov es,di
        xor di,di
        cld
        test bl,00000001b       ;5 clk
        jz ClTxtS2
        ;if (!(bl & 0x01)) go to ClTxtS0
ClTxtS1:stosb
        inc di
        loop ClTxtS1
        mov cx,SCR_BUFF_SIZE_W
        xor di,di
ClTxtS2:test bl,00000010b
        jz ClTxtS0
        xchg al,ah
        inc di
ClTxtS3:stosb
        inc di
        loop ClTxtS3
ClTxtS0:pop es
        pop di
        pop cx
        popf
        ret
