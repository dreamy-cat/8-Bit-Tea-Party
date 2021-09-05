;8-Bit Tea Party! 2021
;License: Creative Commons.
;Platform: CPU 8086\87, GPU VGA, REAL MODE, DOS.
;Tools: NASM.
;Author: Daniil Potapov (alpha-tea).

CPU 8086

%include "VGA-X.asm"

;Тестирование или отладка функций отрисовки линий.
        org 100h
        pushf
        mov ax,13h      ;set gfx
        int 10h

        mov ax,GFX_SCR_ADDR
        mov es,ax
        ;mov al,0
        mov di,320 * 20 + 101
        mov byte es:[di],67h
        mov al,1
        mov ah,1
        mov bx,0
        mov cx,0
        mov si,320
        mov di,200
        call near VXDrawRect
        mov ah,00h      ;press any key.
        int 16h

        popf
        ret

;Процедура рисования прямоугольника с заливкой и градиентомж по цветам.
;Input
;al - color
;ah - diff for color.
;bx,cx - координаты верхнего левого угла.
;si,di - size of rectangle
VXDrawRect:              ; Использовать функцию вывода точки.
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        add bx,si
        cmp bx,320
        jg VXRect0
        add cx,di
        cmp cx,200
        jg VXRect0
        sub bx,si
        sub cx,di
        mov dx,GFX_SCR_ADDR
        mov es,dx
VXRect1:mov bp,bx       ; draw x
        push si
VXRect2:push ax
        mov dx,cx
        mov ax,320
        mul dx
        add ax,bp
        mov dx,ax       ;dx = offset
        pop ax
        push di
        mov di,dx
        mov es:[di],al
        pop di
        inc bp
        dec si
        jnz VXRect2
        add al,ah
        inc cx
        pop si
        dec di
        jnz VXRect1
VXRect0:pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;Процедура рисования горизонтальной линии по цвету с градиентом.
;input
;al - color
;ah - diff of color
;bx,cx - first point
;si,di - last point

DrawHorizontalLine:
        pushf
        
        popf
        ret

;Процедура рисования вертикальной линии по цвету с градиентом.
;input
;al - color
;ah - diff of color
;bx,cx - first point
;si,di - last point

DrawVerticalLine:
        pushf
        
        popf
        ret

;Процедура установки тучки с заданными координатами и цветом.
;Простая проверка.
;input
;al     pixel color
;ah     index of page(empty but not used)
;dx     x coordinte (0..319)
;cx     y coordinate (0..199)
;output: video buffer.

VSetPixel:
        pushf
        
        popf
        ret
          




