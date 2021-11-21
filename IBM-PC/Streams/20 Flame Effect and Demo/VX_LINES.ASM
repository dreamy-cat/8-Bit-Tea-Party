;8-Бит Чаепитие! 2021.
;Лицензия: Creative Commons.
;Платформа: 8086, VGA(256Kb), BIOS.
;Инструменты: NASM(2.15.05).
;Модули: VGA-X, VX_SYS, VX_PIXEL.
;Авторы: Даниил Потапов (daniilzatruda23@gmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.
;Краткая история изменений:
;18.11.2021, Д.П.: Координаты прямоугольника передаются через адрес таблицы.
;09.10.2021, Д.П.: Таблица цветов и настройка режима Х.

CPU 8086

%include "VGA-X.asm"

;Тестирование или отладка функций отрисовки линий.
        org 100h
        pushf
        call near VXSetModeX
        mov al,00001111b
        call near VXSetPlanes
        xor ax,ax
        call near VXSetActDispPage
        mov al,0
        mov ah,0
        mov bx,0
        mov cx,0
        mov si,20
        mov di,20
RecTab0:mov bx,0
        mov si,20
RecTab1:call near VXDrawRect
        add bx,20
        add si,20
        inc al
        cmp si,320
        jbe RecTab1
        add cx,20
        add di,20
        cmp di,240
        jbe RecTab0
        mov ah,00h      ;press any key.
        int 16h

        popf
        ret

;Процедура рисования прямоугольника с заливкой и градиентомж по цветам.
;Input
;al - color
;ah - diff for color.
;bx - адрес координат углов. (верхний левый - правый нижний)

VXDrawRect:              ; Использовать функцию вывода точки.
        pushf
        push ax
        push cx
        push dx
        cmp word [bx + 00h],GFX_SCR_WIDTH
        jnc short VXRectR
        cmp word [bx + 02h],GFX_SCR_HEIGHT
        jnc short VXRectR
        cmp word [bx + 04h],GFX_SCR_WIDTH
        jnc short VXRectR
        cmp word [bx + 06h],GFX_SCR_HEIGHT
        jnc short VXRectR
        mov cx,[bx + 02h]       ;draw x
VXRect2:mov dx,[bx + 00h]
VXRect1:call near VXSetPixel
        inc dx
        cmp dx,[bx + 04h]
        jna short VXRect1
        add al,ah
        inc cx
        cmp cx,[bx + 06h]
        jna short VXRect2
VXRectR:pop dx
        pop cx
        pop ax
        popf
        ret

;Процедура рисования горизонтальной линии по цвету с градиентом.
;input
;al - color
;ah - diff of color
;bx,cx - first point
;si    - last point

DrawHorizontalLine:
        pushf
        push ax
        push cx
        push dx
        push bx
        push si
        push es
        cmp dx,GFX_SCR_WIDTH
        jnc short HorLin0
        cmp cx,GFX_SCR_HEIGHT
        jnc short HorLin0
        mov dx,bx
HorLin1:call near VXSetPixel
        inc dx
        add al,ah
        cmp dx,si
        jne HorLin1
HorLin0:pop es
        pop si
        pop bx
        pop dx
        pop cx
        pop ax
        popf
        ret


;Процедура рисования вертикальной линии по цвету с градиентом.
;input
;al - color
;ah - diff of color
;bx,cx - first point
;   di - last point

DrawVerticalLine:
        pushf
        pushf
        push ax
        push cx
        push dx
        push bx
        push di
        cmp dx,GFX_SCR_WIDTH
        jnc short VerLin0
        cmp cx,GFX_SCR_HEIGHT
        jnc short VerLin0
        mov dx,bx
VerLin1:call near VXSetPixel
        inc cx
        add al,ah
        cmp cx,di
        jne VerLin1
VerLin0:pop di
        pop bx
        pop dx
        pop cx
        pop ax
        popf
        ret






