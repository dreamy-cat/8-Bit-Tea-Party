;8-Bit Tea Party!
;License: Creative Commons.

CPU 8086

;��������� 8-����� �ᥫ, ��� �ᯮ�짮����� ������� MUL.
;��楤�� � �᭮���� ��� ��ࠧ���⥫��� 楫��, �.�. �ࠪ�筥� �ᯮ�짢���
;���஥���� � ������ �������.

;��⨬����� �� ࠧ����, ᪮��� ��� ࠧ���� ���� �� ������.

Mul8:
         pushf          ;������� �ᯮ�짮��� DX ��� ������ ���� ����.,
         push cx        ;����� ᪮॥ �ᥣ� �㤥� �ᯮ짮���� ���-� �����.
         push dx
         xor dx,dx      ;��⨬����� �� ࠧ����, ᪮��� ��� ࠧ���� ����.
         mov cl,08h
         mov ch,ah
         xor ah,ah              ;�஢�ઠ �����⥫�� �� 0.

Mul81:   shl dx, 1              ;�������� ��� ࠢ�� १����.
         shl ch, 1
         jnc short Mul82
         ;add dl,al             ;���ᮡ ��� ����襣� ������⢠ ���.
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
