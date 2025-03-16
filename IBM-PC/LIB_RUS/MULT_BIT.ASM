;8-Bit Tea Party!
;License: Creative Commons.

CPU 8086

;Умножение 8-битных чисел, без использования команды MUL.
;Процедура в основном для образовательных целей, т.к. практичней использвать
;встроенную в процессор команду.

;Оптимизация по размеру, скорости или размеру кода по интересу.

Mul8:
         pushf          ;Удобней использовтаь DX как старшую часть аккум.,
         push cx        ;которая скорее всего будет испоьзована где-то далее.
         push dx
         xor dx,dx      ;Оптимизация по размеру, скорости или размеру кода.
         mov cl,08h
         mov ch,ah
         xor ah,ah              ;Проверка множителей на 0.

Mul81:   shl dx, 1              ;Сдвигаем всё равно результат.
         shl ch, 1
         jnc short Mul82
         ;add dl,al             ;Способ для большего множества бит.
         ;adc dh,00h
         add dx,ax
Mul82:   dec cl                 ;3clk
         jnz short Mul81        ;16clk

Mul80:   mov ax,dx
         pop dx
         pop cx
         popf
         ret                    ;Mul8.
                                                        ;   * * *
;Multiplication, NO mul !!! 8 bit                       ;  * A_V *
;factor1 al, factor2 ah, result ax                      ;   * * *
;start                                                  ;

Multiply8bit:
         pushf
         
;Source file MY01.ASM:

         push ax        ;when you do a subroutine, do not forget
                        ;to comment the lines with ax, al, ah
         push bx
         push cx
         push dx
         pushf

         mov al, 0FAh   ;250 decimal
         mov ah, 064h   ;100 decimal

         xor bx, bx
         xor dx, dx
         mov bl, ah
         mov cx, 08h

r1:      shr al, 1
         jnc s1
         add dx, bx

s1:      shl bx, 1
         loop r1
         mov ax, dx     ;061A8h = 25000 decimal

         popf
         pop dx
         pop cx
         pop bx

         pop ax

         ret


         popf
         ret
