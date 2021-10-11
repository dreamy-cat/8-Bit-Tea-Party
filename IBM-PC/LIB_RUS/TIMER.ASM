;8-Bit Tea Party! 2021
;License: Creative Commons.
;Platform: CPU 8086\87, GPU VGA, REAL MODE, DOS.
;Tools: NASM.
;Author: Daniil Potapov (alpha-tea).

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