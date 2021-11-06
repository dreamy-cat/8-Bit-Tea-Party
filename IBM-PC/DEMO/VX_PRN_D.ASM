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

        call near VXLoadFontBIOS        ; загружаем системный шрифт 8x8

        ; заполняем экран цифрами от 0 до 9 в масштабе x2, в конце оставляем
        ; пустое место для надписи
        mov cx,(GFX_SCR_WIDTH/8/2) * (GFX_SCR_HEIGHT/8/2) - 13
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
        mov word [vx_cursor_x],20       ; двигаем курсор
        mov word [vx_cursor_y],40
        mov byte [vx_font_color],7      ; серый цвет

        mov ah,5                        ; x6 масштаб
        mov al,0                        ; печать до конца строки
        xor dx,dx                       ; с первого символа
        mov bx,msg1                     ; адрес строки (структуры)
        call near VXPrintString         ; вызываем функцию печати

        ; выводим подпись справа внизу (посимвольно)
        mov word [vx_cursor_x],120      ; двигаем курсор
        mov word [vx_cursor_y],226
        mov byte [vx_font_color],5      ; фиолетовый цвет

        mov ah,00100000b                ; x1 масштаб, посимвольный вывод
        mov al,0                        ; печать до конца строки
        xor dx,dx                       ; начинаем с первого символа
        mov bx,msg2                     ; адрес строки (структуры)
        mov cx,msg2TextEnd - msg2Text   ; число символов в строке
Lp2:    ; цикл печати символов
        call near VXPrintString         ; вызываем функцию печати
        inc dx                          ; переходим к следующему символу
        loop Lp2

        mov ah,00h
        int 16h

        popf
        ret

msg1            dw msg1TextEnd - msg1Text
                dw msg1Text - msg1
msg1Text        db "Hello World!"
msg1TextEnd:

msg2            dw msg2TextEnd - msg2Text
                dw msg2Text - msg2
                db 1                    ; некоторые дополнительные данные
                dw 2
                dd 3
msg2Text        db "8-Bit Tea Party rulezz!"
msg2TextEnd:

%include "VX_SYS.ASM"                   ;Библиотечные процедуры.
%include "VX_PRINT.ASM"
