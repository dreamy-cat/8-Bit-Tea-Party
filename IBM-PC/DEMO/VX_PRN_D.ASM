;8-Бит Чаепитие! 2021.
;Лицензия: Creative Commons.
;Платформа: 8086, VGA(256Kb).
;Инструменты: NASM.
;Модули: VGA-X, VX_SYS, VX_PRINT.
;Авторы: Данила Перов(peroff@protonmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.
;Краткая история изменений:
;ДД.ММ.ГГ, И.И.: Короткое сообщение что добавлено, удалено или исправлено.

%include "VGA-X.ASM"            ;Директива включения заголовка для NASM.

CPU 8086                        ;Поменять директивы, если другой ассемблер.

; Демонстрация функции печати графического символа в режиме X. Использует
; дефолтный системный шрифт 8x8 для печати фона и пары строк.

        org 100h                ;COM файл.

        pushf

        call near VXSetModeX

        call near LoadDefaultFont       ; загружаем системный шрифт 8x8

        ; заполняем экран цифрами от 0 до 9 в масштабе x2, в конце оставляем
        ; пустое место для надписи
        mov cx,(GFX_WIDTH/8/2) * (GFX_HEIGHT/8/2) - 13
        mov al,'0'                      ; начальный символ
        mov ah,1                        ; x2 масштаб
        mov dl,2                        ; зеленый цвет
Lp1:    call near VXPrintChar
        inc al                          ; следующий символ
        cmp al,'9'                      ; после 9 снова 0
        jna short L1
        mov al,'0'
L1:     loop Lp1

        ; выводим крупную надпись сверху
        mov si, msg1
        ; двигаем курсор
        mov word [vx_cursor_x],20
        mov word [vx_cursor_y],40
        mov ah,5                        ; x6 масштаб
        mov dl,7                        ; серый цвет
        cld
Lp2:    lodsb                           ; читаем очередной символ
        test al,al                      ; печатаем, пока не ноль
        jz short L2
        call near VXPrintChar
        jmp short Lp2
L2:
        ; выводим подпись справа внизу
        mov si,msg2
        ; двигаем курсор
        mov word [vx_cursor_x],120
        mov word [vx_cursor_y],226
        mov ah,0                        ; x1 масштаб
        mov dl,5                        ; фиолетовый цвет
Lp3:    lodsb                           ; читаем очередной символ
        test al,al                      ; печатаем, пока не ноль
        jz short L3
        call near VXPrintChar
        jmp short Lp3
L3:

        mov ah,00h
        int 16h

        popf
        ret

msg1    db "Hello World!", 0
msg2    db "8-Bit Tea Party rulezz!", 0

%include "VX_SYS.ASM"                   ;Библиотечные процедуры.
%include "VX_PRINT.ASM"
