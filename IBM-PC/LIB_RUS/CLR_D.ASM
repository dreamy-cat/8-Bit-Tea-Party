;8-Бит Чаепитие! Лицензия: Creative Commons.
;Платформа: 8086, BIOS, CGA+.
;Инструменты: NASM(2.15).
;Модули: system.asm, screen.asm, clear.asm.
;Авторы: Даниил Потапов (danilzatruda23@gmail.com) [1],
;        Александр Серов (funny.dreamy.cat@gmail.com) [2].
;Быстродействие: примерно тактов, в/не зависимости от входных параметров.
;Память: байт всего кода и сколько статичных/внешних прямых данных.

;Демонстрация процедуры очистки экрана.

CPU 8086
        org 100h
        pushf
        push ax
        push cx
        push dx
        mov cx,010h             ; 10h = 16 цветов.
        mov al,'a'              ; Начальный символ.
        mov ah,00001111b        ; Чёрный фон и яркокрасные буквы.
        mov dl,00000011b        ; Фон и текст.
ClrPrt: call near ClearScreen
        push ax
        push cx
        push dx
        mov cx,0Fh
        mov dx,0A120h
        mov ah,086h
        int 15h                 ; Ожидание 7A120 (500.000) миллисекунд.
        pop dx
        pop cx
        pop ax
        inc al
        mov bh,ah
        mov bl,cl
        mov cl,4
        shr bh,cl
        inc bh
        shl bh,cl
        and ah,00001111b
        dec ah
        or bh,ah
        mov ah,bh
        mov cl,bl
        loop ClrPrt
        pop dx
        pop cx
        pop ax
        jmp Demo0
        mov ah,00011111b
        mov al,02Eh
        mov dl,00000010b
        call near ClearScreen
        mov bx,ax
        xor ah,ah
        int 16h
        mov ax,bx
        mov dl,00000001b
        call near ClearScreen
        mov bx,ax
        xor ah,ah
        int 16h
        mov ax,bx
        mov [scr_cursor_x],al
        mov [scr_cursor_y],ah
        mov dl,00000100b
        mov ax,00001h
        call near ClearScreen
        mov al,[scr_cursor_x]
        mov ah,[scr_cursor_y]
Demo0:  xor ah,ah
        int 16h
        popf
        ret

%include "clear.asm"

