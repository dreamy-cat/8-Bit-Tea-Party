;8-Bit Tea Party! License: Creative Commons.
;Platform: 8086, VGA, BIOS.
;Tools: NASM.
;Author: Daniil Potapov (alpha-tea).

; ��୮���, �������� � 楫�� ��� � ����������.

;TimerDelay - �㭪�� ����প� �� ��⥬���� ⠩����.
;�� - ����প� � ⨪��(18.2 � ᥪ㭤�). 

TimerDelay:
        pushf           ;���.��⨬�����, �᫨ ����.
        push bx
        push dx
        push di
        push es
        mov bx,0x0040
        mov es,bx
        mov di,0x006C
        mov bx,es:[di] ;⨪� �� ����.
TimDel0:mov dx,es:[di] ;⥪�騥 ⨪�.
        sub dx,bx      ;����塞 ������ �� ⨪��.
        cmp dx,ax      ;�� ���⨣��� �� ��ࠬ��� ����প�.
        jc short TimDel0
        pop es
        pop di
        pop dx
        pop bx
        popf
        ret
