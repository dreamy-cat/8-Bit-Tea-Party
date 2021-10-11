;Welcome to 8-Bit Tea Party!
;
;Assembler, Intel 8086/8088, IBM PC.
;
;Grabbag (Duke Nukem Theme).
;Composed by Lee Jackson.

;Процессор Intel 8086\8088, 5 Мгц.
;Разрядность АЛУ: 16 бит.
;Шина данных: 16 бит.
;Шина адреса: 20 бит, 1 Мбайт.
;Рельный режим адресации, DOS 5.0.
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
SCR_SIZE_WIDTH     equ 0x0050;0x0028
SCR_SIZE_HEIGHT    equ 0x0032
SCR_BUFF_SIZE_B    equ 0x0FA0
SCR_BUFF_SIZE_W    equ 0x07D0;0x03E8 * 2 - SCR_SIZE_WIDTH

;Константы для работы с загружаемым глобальным шрифтом.

FONT_CHAR_SIZE    equ 0x60         ;Размер шрифта в символах.
FONT_CHAR_BYTE    equ 0x08         ;Размер одного символа в байтах.
FONT_WIDTH_PIX    equ 0x08         ;Размер шрифта в точках по горизонтали.
FONT_HEIGHT_PIX   equ 0x08         ;Размер шрифта в точках по вертикали.
FONT_WIDTH_BYTE   equ 0x01         ;Ширина шрифта в байтах на линию.
FONT_FIRST_CHAR   equ 0x20         ;Первый символ шрифта, обычно пробел.

        ;Начало программы.
        org 0x100
        push ax
        push bx
        push cx
        push dx
        ;jmp return
;Вещание №6. Строковые инструкции и команды передачи управления.
        jmp near Main0
;rep,repe,repz,repne,repnz - префикс повторения.
        lea si,[string_src] ;ES=DS,default
        lea di,[string_dst]
        ;mov ax,seg string_src
        ;mov ds,ax если требуется доп.сегменты.
        push cs
        pop es
        mov ax,ds:[si]
        mov ax,[si]    ; nasm не оптимизирует при -о0
        mov bx,es:[di]

;movs(mov string dst:src).
;Перемещение байт или слов.
        ;rep movs string_src,string_dst - nasm не определяет автоматически
        mov cx,0x0002
        rep movsb    ; 9(rep)+17/rep+2 trans,clk
        mov ax,[si-0x02]
        mov bx,[di-0x02]
        mov cx,0x0001
        rep movsw    ; 9(rep)+17/rep+2 trans,clk
        mov ax,[si-0x02]
        mov bx,[di-0x02]
;cmps src,dst - сравнение строк.
        lea si,string_src
        lea di,string_dst
        mov ax,ds:[si]
        mov bx,es:[di]
        mov cx,0x0002
        repe cmpsb    ;9(rep)+22/rep+2 trans,clk
        mov ah,ds:[si]
        mov al,es:[di]
        lea si,string_src
        lea di,string_dst
        mov cx,0x0005
        mov ax,0x0708
        mov es:[di],ax
        repnz cmpsw
        mov ax,[si-0x02]
        mov bx,es:[di-0x02]
;scas dst - сканирование строки на аккумулятор.
        mov ax,0x0403
        xor bx,bx
        lea di,string_dst
        mov cx,0x0007
        repnz scasb    ;al=0x03
        mov bl,es:[di-0x01]
        mov cx,0x0003
        lea di,string_dst
        repnz scasw      ;9(rep)+15/rep+1 trans,clk
        mov bx,es:[di-0x02]

;stos dst - сохранение строки.(из аккумулятора)
        lea di,string_dst
        mov al,0x12
        mov cx,0x0002    ;al - byte
        rep stosb        ;9(rep)+11/rep+1 trans,clk
        mov bl,[di-0x01]
        mov ah,0x34
        lea di,string_dst
        stosw            ;11 clk
        mov bx,es:[di-0x02]
;lods src - загрузка в аккумулятор из строки.
        lea si,string_src
        mov cx,0x0002
        rep lodsb    ;9(rep)+13/rep+1 trans,clk
        lodsw        ;al,ax - result.;scas dst - сканирование строки на аккумулятор.
;Инструкции передачи управления
;jmp - простой безусловный переход. 15 clk.

        xor dl,dl
        ;jmp far Main1 только если несколько сегментов кода.
        jmp short Main1
        jmp near Main1   ;nasm не оптимизирует переходи при -о0
        jmp Main1
        nop             ;3 clk
Main1:  inc dl
        mov [addr_offs],word Main2
        ;jmp near [addr_offs]  ;18+EA+1 trans,clk
        mov [addr_segm],cs
        jmp far [addr_offs]   ;24+EA+2 trans,clk
        nop
Main2:  inc dl
        lea bx,Main3
        jmp bx        ;11 clk.
        nop
Main3:  inc dl
;Инструкции условного перехода.
        mov ax,0x0201  ;carry flag
        cmp al,ah
        jc short Main4
        nop
Main4:  inc dl         ;zero flag
        mov bx,0x0102
        cmp ax,bx
        jnz short Main5
        nop
Main5:  inc dl         ;sign flag
        mov al,-0x03
        dec al
        js short Main6
        nop
Main6:  inc dl         ;flag overflow
        mov al,-0x60
        sub al,0x40
        jo short Main7
        nop
Main7:  inc dl         ;carry or zero flag
        mov ax,0x0102
        cmp al,ah
        jnbe short Main8
        nop
Main8:  inc dl
        jmp return
;loop short-label - цикл, переход относительный от -128 до +127.
;loope\loopz - пока равно\пока ноль, если флаг нуля установлен.
;jcxz short label. Выполняет переход если cx = 0.
        xor ax,ax
        mov cx,0x0003
Main9:  inc ax
        loop Main9      ; 17(jmp) clk or 5 clk if no.
        mov cx,0x0005
MainA:  dec ax
        loopnz MainA    ; 18(jmp) or 7 clk.
        xor cx,cx
        jcxz MainB
        nop
MainB:  mov cx,0x0003
        mov ax,0x0005
        cmp cx,0x0003
MainC:  cmp ax,0x0005
        loopz MainC
;int interrupt\into\iret
;call procedure-name - вызов процедуры.
        mov ax,0x0012
        ;call far TimerDelay
        call near TimerDelay
        mov [addr_offs],word TimerDelay
        call near [addr_offs]
        mov bx,TimerDelay
        call bx
;Инструкции управления процессором и флагами.
        stc ;set carry flag
        clc ;clear carry flag
        cmc ;complement carry flag
        std ;set direction flag
        cld ;clear direction flag
        sti ;set interrupt-enable flag
        cli ;clear interrupt-enable flag
;Инструкции внешней синхронизации.
        hlt ;Ожидаем прерывание или сброс.
;wait - ожидает сигнала test
;lock - префикс, блокировки шины даных.(работет при нескольких процессорах 8086)
;esc  - предоставляет внешнему процессору команды и операнд.
;nop  - ничего, 3 такта.

;Наша программа вещаний №6.
        mov cx,SCR_BUFF_SIZE_B
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        xor ax,ax        ;first ASCII char
        mov di,ax        ; + 6 clk.
MainD:  stosb
        inc al
        inc di
        loop MainD
        mov al,0x21
        mov ah,01000001b
        mov bl,00000010b
        xor ah,ah
        mov cx,0x0003
MainE:  call near ClearTextScreen
        inc ah
        mov dx,ax
        mov ax,0x0002
        call near TimerDelay
        mov ax,dx
        loop MainE
        mov al,0x20
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
        mov ax,0x0A05
        lea bx,string_test
        call near PrintTextString
        mov ax,0x0300
        lea bx,str_tab_bases
        call near PrintTextString

        lea bx,str_conv
        lea si,bases_tab
        mov dx,0x0004
        mov di,0x0500   ;print at

MainF:  mov al,[num_conv_8]
        ;mov ax,[num_conv_16]
        mov cl,ds:[si]
        shl cl,0x01
        shl cl,0x01
        ;or cl,00000001b ; for 16-bit
        inc si
        call near BinToString
        mov ax,di
        call near PrintTextString
        add di,0x000A
        dec dx
        jnz short MainF

        mov al,0x20
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
        lea si,char_test
        mov di,0x00A1
        mov dx,0x00A0
        mov bx,0x02
        call near DrawCharBuffer
        ;call near ShiftBuffUp;Left
;Вещание №9.
        mov al,0x20
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen

        lea si,str_8btp
        mov cx,[si]
        ;main cycle
        add si,ds:[si+0x02]
        lea bx,font_8btp
MainI:  mov al,[si]
        lea di,line_buffer
        ;or al,10000000b
        mov ah,00000000b
        call near DrawCharBuffer
        mov dh,FONT_WIDTH_PIX
        push cx
        push si

;cycle shift char
MainH:  push es
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        mov di,SCR_SIZE_WIDTH * 5 * 2 - 0x02
        lea si,line_buffer
        mov cl,FONT_HEIGHT_PIX * 2
MainG:  mov ax,ds:[si]
        mov es:[di],ax
        add si,FONT_WIDTH_PIX * 2
        add di,SCR_SIZE_WIDTH * 2
        dec cl
        jnz short MainG
        pop es

        mov al,00000000b
        lea di,line_buffer
        mov cx,FONT_CHAR_BYTE * 2 * 16
        call near ShiftTextBuffer

        mov al,00010000b
        lea di,SCR_SIZE_WIDTH * 2 * 4
        mov cx,SCR_SIZE_WIDTH * 2 * 16
        call near ShiftTextBuffer

        mov ax,0x0002
        call near TimerDelay
        dec dh

        jnz short MainH
        pop si
        pop cx
        inc si
        dec cx
        jnz short MainI

;Вещание №10, смещение буфера и ANSI арт.
        mov al,'.'               ;previous Main0
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
        lea si,str_8btp
        add si,[si+0x02]
        mov al,[si]
        or al,10000000b
        lea bx,font_8btp
        xor ah,ah
        mov di,0x01A8
        call near DrawCharBuffer      ;Main cycle
        mov dl,0x04
        mov dh,00000001b              ;Shift type
MainK:  mov cl,0x05                   ;Shift one direction
MainJ:  push cx
        mov ax,0x0007
        call near TimerDelay
        xor bx,bx
        mov al,dh
        or al,00010000b
        xor di,di
        mov cx,SCR_SIZE_WIDTH * 25
        call near ShiftTextBuffer
        pop cx
        dec cl
        jnz short MainJ
        shl dh,1
        dec dl
        jnz short MainK
        jmp return


;Вертикальный скролл.
        mov al,' '
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
;Инициализация начальный переменных.
        lea si,str_8btp
        add si,[si+0x02]
        mov cx,0x0011
MainN:  push cx
;Печатаем пять символов в буфер строки.
        mov ah,00000001b
        lea di,scr_buffer
        ;xor di,di           ;debug
        lea bx,font_8btp
        mov cx,0x0005
MainL:  mov al,ds:[si]
        ;or al,10000000b
        call near DrawCharBuffer
        inc si
        add di,FONT_WIDTH_PIX * 2
        loop MainL
        push si
;Проверим вывод в буфер, скопировав его на экран.
        ;lea si,scr_buffer
        ;lea di,0x0140
        ;mov cx,SCR_SIZE_WIDTH * 16
        ;mov ax,SCR_BUFF_ADDR
        ;mov es,ax
        ;cld
        ;rep movsw

;Сдвиг экрана вверх полностью.
        mov dl,0x10
MainM:  mov al,00000100b
        or al,00010000b     ;screen
        mov cx,SCR_BUFF_SIZE_W
        xor di,di
        call near ShiftTextBuffer
;Копируем верхнюю строку их буфера в нижнюю строку экрана.
        push si
        push di
        push es
        lea si,scr_buffer
        mov di,SCR_BUFF_SIZE_B
        sub di,SCR_SIZE_WIDTH * 2
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        mov cx,SCR_SIZE_WIDTH
        cld
        rep movsw
        pop es
        pop di
        pop si

;Смещаем вверх содержимое буфера.
        mov al,00000100b
        lea di,scr_buffer
        mov cx,LINE_SIZE_W
        call near ShiftTextBuffer

        mov ax,0x0001
        call near TimerDelay
        dec dl
        jnz short MainM
        pop si
        pop cx
        loop MainN
        jmp return
Main0:
;Выводим графику АНСИ.
        mov cx,0x0078
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        lea si,ansi_art
        mov al,' '
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
MainO:  push cx
        mov di,SCR_SIZE_WIDTH * 2 * 49
        mov cx,SCR_SIZE_WIDTH
        cld
        rep movsw
        xor di,di       ;Смещение арта вверх.
        mov al,00010100b
        mov cx,0x0FA0
        call near ShiftTextBuffer
        mov ax,0x0005
        call near TimerDelay
        pop cx
        loop MainO
        jmp return

ansi_art    incbin "ansi_art.bin"

;Данные для вещания 8, бегущая строка и вертикального скролла.

LINE_SIZE_W     equ SCR_SIZE_WIDTH * 16     ;Размер строки.
LINE_SIZE_B     equ SCR_SIZE_WIDTH * 2 * 16 ; in bytes.

str_8btp        dw 0x0055, 0x0005               ;Line to running.
                db 00011111b                    ;color
                db 'Welcome to 8-Bit Tea Party! ';Text line to show/debug.
                db 'Hello to all our friends and followers!                    '

line_buffer     dw FONT_CHAR_BYTE * 16 dup (0)  ;Words, chars + attributes.
scr_buffer      dw SCR_SIZE_WIDTH * 16 dup (0)  ;Дополнительный буфер 16*80*2.
font_8btp      incbin "8btp.fnt"               ;Наш шрифт на 96 символов.

;Рисование символа атрибутами текстового режима и символами в заданый буфер
;или экран. Для отображения точки используется слово полностью, 16 бит.
;Для отладки и демонстрации увеличиваем цвета чернил от 0 до 15.
;Двойное сканирование применяется по умолчанию т.е на каждую линию шрифта,
;выводится 2 линии атрибутов.
;Вход:
;al:bit         экономим для вещания, позже доработать.
;0..6           код символа АСКИ для рисования.
;7              бит управлением буфером: 0=ds:[di], 1=0xB800:[di] - экран
;               либо в буфер с даными ds:[di], либо на экран в es:[di]
;ah             цвет атрибута для рисования, стандартный.
;bx             адрес шрифта, простая бинарная таблица по размеру шрифта.
;di             адрес буфера экрана или области памяти (смещение).
;dx             дополнительно, смещение на следующую строку буфера памяти.
;Выход:         в буфер экрана или памяти.

DrawCharBuffer:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push es  ;Настраеваем сегментный регистр.
        mov cx,ds
        test al,10000000b
        jz short DrChr1
        mov cx,SCR_BUFF_ADDR
DrChr1: mov es,cx
;Расчитывает адрес шрифта и букв в шрифте.
        mov dx,ax
        xor ah,ah
        and al,01111111b   ;bit mask
        sub al,FONT_FIRST_CHAR
        mov ch,FONT_CHAR_BYTE
        mul ch
        add bx,ax       ;better using offset index.
        ;lea bx,char_test
;Рисуем символ в атрибутах и символах.
        cld
        mov ax,dx
        and al,01111111b
        ;moval,0xDB     ;Сплошной ASCII
        mov ch,FONT_HEIGHT_PIX * 2
        mov si,di         ;save start line
DrChr6: mov dh,[bx]
        mov di,si
        mov cl,FONT_WIDTH_PIX
DrChr3: mov es:[di],word 0x0000
        shl dh,0x01
        jnc short DrChr2
        mov es:[di],ax
DrChr2: inc di    ;add di,0x02
        inc di    ;use stosw
        dec cl
        jnz short DrChr3
        test dl,10000000b
        jz short DrChr4
        add si,SCR_SIZE_WIDTH * 2
        jmp short DrChr5
DrChr4: add si,SCR_SIZE_WIDTH * 2;FONT_WIDTH_PIX * 2
DrChr5: inc ah    ;next color
        dec ch
        jz short DrChr0
        test ch,00000001b
        jnz short DrChr6
        inc bx    ;double lines
        jmp short DrChr6
DrChr0: pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;Смещение текстового буфера экрана или памяти по направлениям на 1.
;Вход:
;al:bit         комбинация битов может быть любой и будет исполнена.
;0              смещение влево;
;1              смещение вправо;
;2              смещение вверх;
;3              смещение вниз;
;4              бит управлением буфером: 0=ds:[di], 1=0xB800:[di] - экран
;               либо в буфер с даными ds:[di], либо на экран в es:[di]
;di             смещение в буфере, чётное.
;cx             размер окна полного буфера (в словах).
;dx             смещение буфера, реализовать дополнительно.
;Проверить входные данные на допустимостью
ShiftTextBuffer:
        pushf
        push ax
        push bx
        push cx
        push si
        push di
        push bp
        push ds
        push es
        test al,00010000b
        jz short ShTBuf1
        mov si,SCR_BUFF_ADDR
        mov ds,si
ShTBuf1:mov si,ds      ;or use jump
        mov es,si
        and al,00001111b

        mov bx,di                ;bx - buffer offset.
        mov bp,cx                ;bp - counter.
        shr al,0x01                     ;test al,00000001b
        jc short ShTBuf2         ;left
ShTBuf6:mov di,bx                ;restore parameters.
        mov cx,bp
        shr al,0x01
        jc short ShTBuf3         ;right
ShTBuf7:mov di,bx                ;restore parameters.
        mov cx,bp
        shr al,0x01
        jc short ShTBuf4         ;up
ShTBuf8:mov di,bx                ;restore parameters.
        mov cx,bp
        shr al,0x01
        jc short ShTBuf5         ;down
        jmp short ShTBuf0        ;return


ShTBuf2:mov si,di
        inc si             ;Shift left.
        inc si
        dec cx
        cld
        rep movsw
        jmp short ShTBuf6
ShTBuf3:dec cx
        add di,cx                   ;Shift right.
        add di,cx
        mov si,di
        dec si
        dec si
        std
        rep movsw
        jmp short ShTBuf7
ShTBuf4:mov si,di
        add si,SCR_SIZE_WIDTH * 2          ;Shift up.
        sub cx,SCR_SIZE_WIDTH
        cld
        rep movsw
        jmp short ShTBuf8
ShTBuf5:dec cx
        add di,cx                          ;Shift down.
        add di,cx
        sub cx,SCR_SIZE_WIDTH
        mov si,di
        sub si,SCR_SIZE_WIDTH * 2
        std
        rep movsw
ShTBuf0:pop es
        pop ds
        pop bp
        pop di
        pop si
        pop cx
        pop bx
        pop ax
        popf
        ret

;DrawCharBuffer:
;        pushf
;        push di
;        push si
;        push es
;        mov ax,SCR_BUFF_ADDR
;        mov es,ax
;        mov ch,0x08
;        cld
;        mov ah,00001111b
;DrChr3: mov al,[si]
;        push di
;        mov cl,0x08
;DrChr2: shl al,0x01
;        jnc short DrChr1
;        mov es:[di],ah
;DrChr1: inc di
;        inc di
;        dec cl
;        jnz short DrChr2
;        pop di
;        add di,dx
;        inc si
;        ;mov cl,0x04   берём следующий цвет.
;        ;shr ah,cl
;        ;inc ah
;        ;shl ah,cl
;        add ah,00010000b
;        dec ch
;        jnz short DrChr3
;        pop es
;        pop di
;        pop di
;        popf
;        ret

char_test db 11111111b
          db 10000001b
          db 10000001b
          db 10000001b
          db 10000001b
          db 10000001b
          db 10000001b
          db 11111111b
          db 10101010b
          db 10101010b



;Числа и таблица системы счислений для перевода из числа в строку.
bases_tab        db 0x10, 0x0A, 0x08, 0x02
num_conv_8       db 0xAA, -0x55
num_conv_16      dw 0xAA55, -0x55AA
num_conv_32      dd 0x0155AAFF
str_conv         dw 0x0008, 0x0004
str_conv_text    db '........'
str_tab_bases    dw 0x0050, 0x0004
str_tab_text     db 'Convert 8,16-bit numbers to strings.    '
                 db 'Hex:      Dec:      Oct:      Bin:      '

;Процедура преобразования числа в строку.
;Вход:
;al   8-bit number type.
;ax   16-bit number type.
;dx:ax 32-bit number type.
;bx   string structure address.
;cl:bit      parameters.
;0..1        data type, 32 and 64 bits, later...
;2..6        number base format.
;7           signed or unsigned number, later...
;ch:reserve
;Выход:
;bx    строка вывода заполнена текстом.
;Проверка на длину строки и допустимость разрядности.
;Строка приёмник находится в сегменте данных.

;Учесть обработку знака и отрицательного числа.
;Реализовать поддержку 32 битного числа для конвертиции.

MIN_NUMBER_BASE equ 0x02
MAX_NUMBER_BASE equ 0x10

num_base_table db '0123456789ABCDEF'

BinToString:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
;Проверка на допустимость, длина строки > 0
        xor di,di
        cmp di,ds:[bx]
        jz short BinToS0
        mov si,bx ;ds:si - dest. string.
;Проверка на допустимость системы счисления.
        mov bx,ax
        mov al,cl
        mov ah,cl
        and ah,00000011b
        cmp ah,0x02     ;add types later
        jnc short BinToS0
        mov cl,0x02
        and al,01111100b
        shr al,cl       ;optimize...
        cmp al,MIN_NUMBER_BASE
        jc short BinToS0
        cmp al,MAX_NUMBER_BASE
        jnbe short BinToS0
        xchg bx,ax  ;bl:base, bh:type
        mov cx,bx   ;save for sign
        mov di,si
        add di,[si]     ;end of string.
        add di,[si+0x02]
        dec di
        lea bx,num_base_table
        std          ;right to left.
        add si,[si+0x02]    ;text start.
        or ch,ch
        jnz short BinToS2
BinToS1:xor ah,ah       ;8-bit divider
        div cl          ;ax/cl
        xchg ah,al      ;al-remainder
        xlat            ;al to digit
        stosb
        cmp di,si
        jc short BinToS0
        xchg ah,al
        or al,al
        jnz short BinToS1
        jmp short BinToS0
BinToS2:xor ch,ch    ;16-bit number
BinToS3:xor dx,dx
        div cx
        xchg ax,dx
        xlat
        stosb
        cmp di,si
        jz short BinToS0
        xchg ax,dx
        or ax,ax
        jnz short BinToS3
BinToS0:pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;Формат нащей 16-и битной строки.
string_test   dw 0x000C ;Длинна строки.
text_offs    dw 0x0008 ;Смещение по которому начинается непосредтственный текст.
reserver       db 0x04 dup (0)
;Пример резервирования для доработки или вариации функции печати.
string_text  db 'Hello World!'

;Процедура печати строки в текстовый буфер.
;Формат строки минимальный см.выше.
;Используем глобальные константы экрана.
;Вход.
;al позиция по горизонтали без ограничений.
;ah позиция по вертикали, предел только буфер.
;ds:bx      адрес структуры строки.
;Проверка на допустимость только в пределах буфера.

PrintTextString:
        pushf
        push ax
        push cx
        push dx
        push si
        push di
        push es

        ;mov dx,ax   ;Вычисляем смещение по координатам.
        ;mov al,dh
        ;mov cl,SCR_SIZE_WIDTH
        ;mul cl
        ;xor dh,dh
        ;add ax,dx
        ;shl ax,1       ; 90-100 clk.


;Расчёт адреса смещения по координатам, методами сдвигов.
        mov dx,ax
        xchg al,ah
        xor ah,ah
        mov cl,0x03     ;char+atr*2 = 2 bytes
        shl ax,cl       ; 8+4*4 clk.
        mov di,ax
        mov cl,0x02
        shl ax,cl
        add di,ax       ; y вычислен
        xor dh,dh
        ;shl dx,0x01
        add di,dx
        mov ax,di ; 80 clk.

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

string_src   db 0x01, 0x02, 0x03, 0x04
string_dst   db 0x05, 0x06, 0x07, 0x08

;Вещание №5. Инструкции арифметики и флаги.
      ;Вычитание:
        mov ax,0x0000
        mov bx,0x0000
        mov al,0x28
        mov ah,0x31
;sub dst,src - вычитание.
        sub  ah,al       ;reg:reg, 3 clk;
        sub ah,[byte_b] ;reg:mem, 16 clk+EA;
        sub al,0x22     ;acc(reg):imm, 4 clk;
        sub [byte_b],al
        mov al,[byte_b]
        sub byte [byte_b],0x01 ;mem:imm, 17 clk+EA;
        mov al,[byte_b]
;sbb dst,src - вычитание с заёмом флага CF.
        mov ax,0x1001
        mov bx,0x0503
        sub al,bl
        sbb ah,bh       ;Ожидаем результат 0AFE(-2);
;dec dst - декремент приёмника на 1.
        dec al       ;reg8  3 clk, 2 bytes;
        dec ax       ;reg16 2 clk, 1 bytes;
        mov al,[byte_a]
        dec byte [byte_a]       ;15 clk+EA
        mov al,[byte_a]
;neg dst - формирует отрицательное число.
        mov al,0x01
        neg al     ;2 clk
        mov ah,[byte_b]
        neg byte [byte_b]       ;16 clk+EA
        mov ah,[byte_b]
        mov al,0x00
        neg al     ;CF=0;
;cmp dst,src - сравнение.
        mov ax,0x0102
        cmp al,ah               ;reg:reg, 3 clk;
        cmp ax,0x0001           ;reg:imm, 4 clk;
        cmp byte [byte_a],0x01       ;mem:imm, 10 clk+EA;
        cmp al,[byte_a]         ;reg:mem. 9 clk+EA;
;aas,das - выравнивание для вычитания и обратно.
      ;Умножение:
;mul src - умножение без знака.
;imul src - умножение со знаком.
        mov al,0x02
        mov bl,0x03
        mul bl     ;70-77 clk, 2 bytes;
        mov bx,0x1000
        mul bx     ;118-133 clk
        mov al,0x01
        mul byte [byte_b]       ;76-83+EA
        mov ax,0x1000
        mul word [word_a];124-139+EA
        mov al,-0x05
        mov bl,0x02
        imul bl
      ;Деление:
;div src - целочисленное деление без знака.
;idiv src - целочисленное деление со знаком.
        mov ax,0x0100
        mov bl,0x10
        div bl     ;al - результат, ah - остаток. 80-90 clk.
        div byte [byte_b]
        mov dx,0x0001
        mov bx,0xAAAA
        div bx       ;144-162 clk
        mov dx,0x0001
        div word [word_d]
        ;idiv аналогичен imul.
        ;mov bl,0x01    ;коварный ход от Данилы в комментариях)))
        mov bx,0x0001   ;следим за размерностью операндов.
        mov ax,0x0200
        mov dx,0x0000
        ;div bl         ;операнд назначения должен вмещать частное от деления.
        div bx
;cbw al, cwd ax - конвертирует байт в слово или слово в двойное слово.
        mov al,-0x05
        cbw         ; 2 clk; оптимизация
        cwd         ; 5 clk;
;Логические операции:
;not dst - отрицание, логическое НЕ.
        mov al,0x0F
        not al          ;3 clk
        mov ah,[byte_a]
        not byte [byte_a] ;16 clk+EA
        mov ah,[byte_a]
;and dst,src - логическое И.
        mov al,0xAA
        mov ah,0x0F
        and al,ah       ;reg:reg, 3 clk
        and al,0x03     ;acc:imm, 4 clk
        and [byte_a],ah ;mem:reg, 16 clk+EA
        mov bh,[byte_a]
        and byte [byte_a],0xFF ;mem:imm, 17 clk+EA
        mov bh,[byte_a]
;or dst,src - логическое ИЛИ.
        mov dl,0xAA
        mov dh,0x0F
        or  dl,dh       ;reg:reg, 3 clk
        or  al,0x03     ;acc:imm, 4 clk
        or  [byte_a],dh ;mem:reg, 16 clk+EA
        mov bh,[byte_a]
        or  byte [byte_a],0xFF ;mem:imm, 17 clk+EA
        mov bh,[byte_a]
;xor dst,src - логическое ИСК.ИЛИ.
        mov dl,0xAA
        mov dh,0x0F
        xor dl,dh       ;reg:reg, 3 clk
        xor al,0x03     ;acc:imm, 4 clk
        xor [byte_a],dh ;mem:reg, 16 clk+EA
        mov bh,[byte_a]
        xor byte [byte_a],0xFF ;mem:imm, 17 clk+EA
        mov bh,[byte_a]
;test dst,src - логическое И без сохранения результата.
        mov dl,0xAA
        mov dh,0x0F
        test dl,dh       ;reg:reg, 3 clk
        test al,0x03     ;acc:imm, 4 clk
        test [byte_a],dh ;mem:reg, 9 clk+EA
        mov bh,[byte_a]
        test byte [byte_a],0xFF ;mem:imm, 11 clk+EA
        mov bh,[byte_a]
;Битовые сдвиги.
;sal, shl: dst,counter - сдвиг влево
        mov cl,0x04    ;кол-во сдвигов.
        mov ax,0x0101
        sal ah,1       ;2 clk
        shl al,1
        sal al,cl    ;8 clk + 4 на бит
        shl byte [byte_a],cl ;20 clk+EA+4 на бит
        mov al,[byte_a]
        sal byte [byte_b],1    ;15 clk+EA
        mov al,[byte_b]
;sar, shr: dst,counter - сдвиг вправо
        mov cl,0x04    ;кол-во сдвигов.
        mov ah,-0x05
        mov al,0x80
        shr al,cl    ;8 clk + 4 на бит
        sar ah,cl
        sar byte [byte_a],cl ;20 clk+EA+4 на бит
        mov al,[byte_a]
;Ротация битов.
;rol\ror dst,counter - ротация влево,вправо.
;rcl\rcr dst,counter - ротация бит вдево,вправо с флагом переноса.
        mov cl,0x04    ;кол-во сдвигов.
        mov ah,0x01
        mov al,0x80
        rol al,cl    ;8 clk + 4 на бит
        rol ah,1
        ror ah,1
        ror al,cl
        ror byte [byte_a],cl ;20 clk+EA+4 на бит
        mov al,[byte_a]
        mov ah,0x07
        mov al,0xE0
        mov cl,0x02
        rcr ah,cl
        rcl al,cl
        rcr al,cl
        rcl ah,cl
        rcl byte [byte_a],cl
        mov al,[byte_a]
;Вещание №4. Инструкции арифметики и флаги.

      ;Сложение:
        mov dl,0x34
        mov dh,0x12
        add dl,dh  ;reg:reg, 3 clk;
        add dl,byte [byte_a] ;reg:mem, 9 clk+EA;
        add dl,0x03     ;reg:imm, 4 clk;
        mov al,[byte_a]
        add [byte_a],dl ;mem:reg, 9 clk+EA;
        mov al,byte [byte_a]
        mov ah,0x00    ;add 16 bit, using 8 bit operands;
        mov al,0x81
        mov bl,0xA9
        mov bh,0x0A
        add al,bl      ;флаг переноса включен
        adc ah,bh      ;используем флаг переноса
        pushf
        mov ah,0x00
        sahf       ;обнулим флаги.
        mov al,-0x50
        mov ah,-0x40
        add ah,al  ;флаг переполнения влючен и установлен флаг знака
        popf
        mov al,[byte_a]
        inc al         ;увеличение на 1, 3 такта.
        inc dx         ;2 такта
        inc byte [byte_a]   ;15+ЕА тактов
        add ax,word [byte_a]
        mov al,[byte_a]
;BCD - двоично-десятичный код, в каждом полубайте хранится цифра от 0 до 9.
;пример: 74 = 0111 0100 - двоичный вид(битовое представление)
        mov al,0x30
        aaa        ;из упакованного в десятичное число
        add al,0x05
        daa        ;из двоичного в упакованное.
        jmp return

;Вещание №3.
;Архитектура 8086, типы адресации и инструкции перемещения данных.
;Комманды общего назначения.
        mov al,0x01  ;immed, 4 clk
        mov ah,al    ;reg:reg, 2 clk
        mov ax,[word_c] ;10 clk
        mov dl,[byte_a] ;8 clk+EA
        mov [word_c],word 0xABCD ;10 clk+EA
        mov bx,[addr_segm]
        mov es,bx
        mov es,[addr_segm]  ;8 clk+EA
        push cs             ;11 clk
        push word [addr_segm];17 clk
        pushf
        lahf    ;load flag to ah
        sahf    ;store ah to flag
        popf
        pop bx
        pop ax
        xchg ax,bx   ;acc-reg, 3 clk
        xchg dx,[word_b]; reg-mem, 17 clk+EA
        xchg bx,dx      ;reg-reg, 4 clk
        mov al,0x03
        lea bx,bytes_t
        xlat
;Вычисление эффективного адреса объекта.
        lea si,[bytes_t]    ;2 clk+EA
        mov al,[si+3]
        les di,ds:[words_t]
        mov [addr_offs],si
        mov ax,ds
        mov [addr_segm],ax
        lds bx,ds:[addr_offs]
        mov al,[bx]
;
        jmp return
byte_a      db 0x01
byte_b      db 0x02
word_d      dw 0x0104
word_b      dw 0x1A2B
word_c      dw 0x3C4D
addr_offs   dw 0x0505
addr_segm   dw 0x6060
bytes_t     db 0x01, 0x02, 0x03, 0x04
words_t     dw 0x1A1B, 0x2C2D, 0x3E4F

;Вещание №2.
;Архитектура 8086, типы адрессации и инструкции перемещения данных.
;Методы и типы аресации данных.

        mov dx,0x0101;Непосредственная адресация.
        mov ax,dx    ;Регистровая адресация, 2 такта.
        mov bx,ds:[bytes_table]     ;Прамая адресация из памяти, 8 тактов.
        mov ax,ds:0x0100
        mov bx,bytes_table
        mov dh,[bx]       ;ds сегмент по умолчанию.
        mov dl,ds:[bx+2]  ;база + смещение
        mov di,0x003
lab_1:  mov cl,es:[di]
        mov bp,words_table
        mov ax,cs:[bp+di] ;Изменение сегмента + 2 такта, база + индекс.
        ;База + индекс + смещение, ооочень долго по тактам.
        mov ax,ds:[bp+di+1] ;Для базы только регистры: BX, BP, SI, DI.
;Переходим к общим инструкция перемещения данных
        jmp return

bytes_table     db 0x01, 0x02, 0x03, 0x04
words_table     dw 0x1A1B, 0x2C2D, 0x3E4F


;Вещание №1. Архитектура 8086 и программа "Привет Мир!", с БИОСом и буфером.
        ;Установим курсор в позицию.
        mov ah,02h
        mov bh,0x00
        mov dx,0x0A08
        int 10h

        ;Печатаем отдельный символ.
        mov cx,0x05
        mov ah,0x0A
        mov al,0x43
        xor bh,bh
        int 10h

        ;Печатаем строку с БИОСом
        mov ax,0x1300
        xor bh,bh
        mov bl,00011111b
        mov cx,0x000C
        mov bp,string
        int 10h

        ;Вывод строки в буффер экрана.
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        mov di,0x0100
        mov si,string
        mov bh,00101111b
Prt_1:  mov bl,ds:[si]
        or bl,bl
        jz Prt_2
        mov es:[di],bx
        inc si
        add di,0x02
        jmp Prt_1
Prt_2:  mov ah,0x09
        mov dx,string
        push cs
        pop ds
        int 21h
return:

        pop dx
        pop cx
        pop bx
        pop ax
        ret


string  db 'Hello World!&', 0
word_a  dw 0x1111
dword_b dd 0x11111111
reserv  db 32 dup (0)
