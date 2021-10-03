;8-Бит Чаепитие! 2021.
;Лицензия: Creative Commons.
;Платформа: 8086, VGA(256Kb).
;Инструменты: NASM.
;Модули: VGA-X,...
;Авторы: Данила Перов(peroff@protonmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.
;Краткая история изменений:
;ДД.ММ.ГГ, И.И.: Короткое сообщение что добавлено, удалено или исправлено.

%include "VGA-X.ASM"            ;Директива включения заголовка для NASM.

;Полный комплект, при условии если всё ок, то до 13-20 ноября.
;Базовый вариант, через недельку-две-три, буква.

;Процедуры печати в экранную память режима Х, нашего 16-ти битного формата
;строк. Смотри файл string.asm для подробного описания формата.
;Использует дополнительно пару глобальных параметров: шрифт по умолчанию и
;текущие позиции вывода для удобства вызовов. Для старта можно взять пока
;системный шрифт ВГА адаптера. Его можно получить при вызове функции.
;Шрифт минимально черно-белый размеры были по умолчанию 8*8.


;Глобальные переменные и константы, когда будет доделано, то скинем их в
;общий файл библиотеки режима Х.


vx_cursor_x     dw 0000h        ;Левая точка позиции курсора, 0..319.
vx_cursor_y     dw 0000h        ;Верхняя точка позиции курсора, 0..239.
vx_font_addr    dd 00000000h    ;Полный адрес шрифта, смещение и сегмент.
vx_font_first_c db 00h          ;Код первого символа в шрифте.
vx_font_chars   db 00h          ;Количество символов в шрифте, 0 = 256.
vx_font_char_b  db 00h          ;Количество байт на один символ.
vx_font_width   db 00h          ;Ширина символа в точках.
vx_font_height  db 00h          ;Высота символа в линиях.

;Если потребуются вспомогательные процедуры работы со шрифтом, то добавляй
;временно прямо сюда, если что подумаем позже об отдельном файле. VXFontLoad.


;Дополнительно, только если уже ниже процедуры реализованы.
;Всё по аналогии, только с учетом вывода в окно.
;Параметры пока подумаем, но главное, что бы вывод шел с ограничением
;относительно логического окна, а не экрана и плюс с разными дополнительными
;возможностями.

VXPrintStrWin:
        pushf
        popf
        ret


;Процедура печати грфической строки на экран в режиме Х, по координатам.
;Печать использует глобальные параметры по-умолчанию: позиция, шрифт и т.д.
;При выходе за пределы экрана, выходим тихо.
;Вход:
;AH     биты:
;0..2   масштабирование для символов, 1..8(сначала просто масштаб 1х);
;4      резерв
;5      печатать по одному символу, запомнить состояние и выйти, чтобы
;       уложится в один кадр;
;6      останавливать вывод при достижении конца горизонтального вывода;
;7      переносить или нет глобальные координаты печати;
;DS:BX  адрес строки;
;Выход: измененный видеобуффер в активной странице и если бит 7, то и курсор.

VXPrintString:
        pushf
        popf
        ret


;Процедура печати графического символа на экран в режим Х, по координатам.
;Пока что использовать шрифт и позицию глобальную, параметры шрифта так-же.
;После исполнения сдвгаем позицию слева направо на размер шрифта, если не
;влезает вправо, то переносим на слдующую строку, так же по размеру шрифта
;по вертикали.
;Вход:
;AL     символ для вывода;
;AH     биты:
;  0..3   масштабирование для символа, 1..16(сначала просто масштаб 1х);
;  4..7   резерв, здесь можно стиль вывода будет сделать, задержку,
;         маску и т.д.
;DL     цвет символа
;Выход: измененный видеобуффер в активной странице.

VXPrintChar:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        cld

        mov bh,ah
        mov bl,dl

        mov cl,[vx_font_first_c]
        cmp al,cl
        jnb short P0
        jmp near Exit
P0:     mov dl,[vx_font_chars]
        add dl,cl
        dec dl                          ; last code
        cmp al,dl
        jna short P00
        jmp near Exit

P00:    mov si,[vx_font_addr + 2]
        sub al,cl
        mov dl,[vx_font_char_b]
        mul dl
        add si,ax

        mov ch,bh
        and ch,00001111b
        inc ch

        mov di,[vx_cursor_x]
        mov al,[vx_font_width]
        mul ch
        add ax,di
        cmp ax,GFX_WIDTH
        jna short P50
        jmp near Exit
P50:    mov dx,[vx_cursor_y]
        mov al,[vx_font_height]
        mul ch
        add ax,dx
        cmp ax,GFX_HEIGHT
        jna short P51
        jmp near Exit
P51:    mov ax,dx
        mov dx,GFX_BYTES_PER_LINE
        mul dx
        shr di,1
        shr di,1
        add di,ax
        add di,[vx_scr_active]

        mov al,ch
        mov dl,GFX_BYTES_PER_LINE
        mul dl
        mov bp,ax

        mov ch,[vx_font_height]
        mov cl,[vx_font_width]
        mov dl,cl
        and cl,00000011b
        mov dh,00000001b
        shl dh,cl                       ; planes mask backup

        push ds
        push es
        mov ax,[vx_font_addr]
        mov ds,ax
        mov ax,GFX_SCR_ADDR
        mov es,ax

        mov ah, 0                       ; bits in buffer

; for y := 1 to font_height do ...
;   for x := 1 to font_width do ...
;     for n1 := 1 to scale do ...
;       if pixels[x] then
;         for n2 := 1 to scale do ...
;           drawPixel()
P4:     ; new line
        mov cl,dl;cs:[vx_font_width]       ; rework CS
        push di
        push dx                         ; dh - mask, dl - free
P3:     ; new pixel
        test ah,ah
        jnz short P1
        lodsb
        mov ah,8
P1:
        mov dl,bh
        and dl,00001111b
        inc dl
        ;next horz block
P11:    test al,10000000b
        jz short P10

        push ax
        push dx                         ; ?
        mov ah,dh
        mov al,02h
        mov dx,VGA_SEQUENCER_ADDR
        out dx,ax
        mov ax,di
        mov dl,bh
        and dl,00001111b
        inc dl
P30:    mov byte es:[di],bl             ; color
        add di,GFX_BYTES_PER_LINE
        dec dl
        jnz short P30
        mov di,ax
        pop dx
        pop ax

P10:    shl dh,1
        cmp dh,00001000b
        jna P5
        mov dh,00000001b
        inc di
P5:     dec dl
        jnz short P11

        shl al,1
        dec ah
        dec cl
        jnz short P3

        pop dx
        pop di
        add di,bp

        dec ch
        jnz short P4

        pop es
        pop ds

        mov ch,bh
        and ch,00001111b
        inc ch

        mov dx,[vx_cursor_x]
        mov al,[vx_font_width]
        mul ch
        add dx,ax
        mov [vx_cursor_x],dx
        add dx,ax
        cmp dx,GFX_WIDTH
        jna short P40
        mov dx,[vx_cursor_y]
        mov al,[vx_font_height]
        mul ch
        add dx,ax
        mov [vx_cursor_y],dx
        xor ax,ax
        mov [vx_cursor_x],ax
P40:

Exit:   pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret
