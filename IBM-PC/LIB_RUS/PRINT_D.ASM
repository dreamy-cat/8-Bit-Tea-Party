;8-Бит Чаепитие! Лицензия: Creative Commons.
;Платформа: 8086, BIOS, CGA+.
;Инструменты: NASM(2.15).
;Модули: system.asm, screen.asm.
;Авторы: Даниил Потапов (danilzatruda23@gmail.com) [1],
;        Александр Серов (funny.dreamy.cat@gmail.com) [2].

; Задачи на следующую версию:
; - обновить код с условием сборки по модулям;
; - обновить переменные координат в тестах с учетом глобальных данных;
; - дополнить еще возможные сценарии тестирования;

CPU 8086

        org 00100h
        pushf
        mov ax,00F20h
        mov dl,00000111b
        call near ClearScreen

; Тестирование угловых координат без переноса и текст должен вмещаться.

Demo1:  mov al,00000010b                ;Запрет переноса, только строка.
        lea bx,string_chars
        mov dx,00008h
        call near Print
        xor dx,dx
        lea bx,string_one
        call near Print
        mov dx,0004Fh                   ;Внешние переменные.
        call near Print
        mov dx,01800h
        call near Print
        mov dx,0184Fh
        call near Print
        xor ah,ah
        int 16h
        ;jmp short Demo0

; Тестирование полной строки во весь экран и заполнением полного буфер.

Demo2:  xor al,al
        xor dx,dx
        lea bx,string_full
        call near Print
        xor ah,ah
        int 16h
        ;jmp short Demo0

; Тестирование строк с выводом индекса на каждой линии, с ограничением.

Demo3:  mov cl,[scr_height]
        lea bx,string_line
        xor dx,dx
        mov si,[bx + STR_TEXT_OFFS]
Demo32: call near Print
        inc byte [bx + si + 001h]
        cmp byte [bx + si + 001h],03Ah
        jne short Demo31
        mov byte [bx + si + 001h], 030h
        inc byte [bx + si]
Demo31: inc dh
        dec cl
        jnz short Demo32
        xor ah,ah
        int 16h
        ;jmp short Demo0

; Тестирование строки которая не вмещается в экран, но выводится постранично.

Demo4:  mov al,00000100b
        xor dx,dx
        lea bx,string_page
        call near Print
        xor ah,ah
        int 16h
        ;jmp short Demo0

; Тестирование строки которая не помещается в экран и не выводиться совсем.

Demo5:  mov si,01234h                   ;Для проверки регистров до/после вызова,
        mov di,05678h                   ;только для отладчика.
        xor al,al
        lea bx,string_header
        xor dx,dx
        call near Print
        xor ah,ah
        int 16h
        xor al,al
        lea bx,string_long
        call near Print

Demo0:  xor ah,ah
        int 16h
        popf
        ret

string_chars    dw 00033h
                dw 00004h
                db "Print exact one char 'A' in every corner of screen."
string_one      dw 00001h
                dw 00004h
                db 'A'
string_line     dw 00050h
                dw 00004h
                db "00 This line is a full line using flag 'only line'."
                db 050h dup ('_')
string_full     dw 007D0h
                dw 00004h
                db "Print string as is but length is equal to buffer size!"
                db 007D0h dup ('.')
string_page     dw 007D1h
                dw 00004h
                db "Print string as page, length is more than buffer size."
                db 007D1h dup ('-')
string_header   dw 000A7h
                dw 00004h
                db "Print string as is, length is more than buffer size. "
                db "So if this string overwritten, then error in procedure. "
                db "Press any key to try print very long string without pages."
string_long     dw 007D1h
                dw 00004h
                db 007D1h dup ('*')

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

%include "print.asm"

;29.03.25 [1,2]: Демонстрация базового функционала процедуры печати на вещании.
