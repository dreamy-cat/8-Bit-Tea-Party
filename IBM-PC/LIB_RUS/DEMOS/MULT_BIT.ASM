;8-Bit Tea Party!
;License: Creative Commons.

;��࠭�祭�� ��� ������ �� �������, ���祢� ��࠭�祭�� ��� ��楤���.

CPU 8086

         org 100h       ;��ଠ� ᢮����� ��� ��������樨, �� ������ �室.
         pushf          ;�������⥫쭮, �᫨ �㤥� ��������� �����.

;� ������ ����� �࣠�������� ���⮩ �뢮� ⠡���� 㬭������, � ⥪�⢮�
;०���, �⮡� �� ��뢠�� ��譨� ࠧ �⫠�稪.

         popf
         ret

;���⮢� ����� ����� �뫨 �� ��頭��, ����� ᢮����� ��������.

example_data    dw 0000, 00FFh, 0FF00h, 0FFFFh, 00F03h

%include "mul.asm"      ;���� ����祭��, ��� �᫨ �� ����砥��� � �����
                        ;���� ������� 䠩� ��楤��� ��אַ �.


;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, CGA+ 16Kb, BIOS.
;�����㬥���: NASM(2.15.05).
;���㫨: MULT_BIT.ASM.
;�����: .

; ���������� 8-16-� ��⭮�� 㬭������, .

; ��࠭�祭�� ��� ������ �� �������, ���祢� ��࠭�祭�� ��� ��楤���.

CPU 8086

         org 100h       ;��ଠ� ᢮����� ��� ��������樨, �� ������ �室.
         pushf          ;�������⥫쭮, �᫨ �㤥� ��������� �����.

         lea si,example_data
         mov cx,0005h
MulD1:   mov ax,[si]
         mov dx,ax
         call near Mul8
         test dh,dh             ;0 - if both zero.
         jz short MulD2
         div dh                 ;test
MulD2:   inc si
         inc si
         loop MulD1

         popf
         ret

examples db 00, 00, 00, 0FFh, ;...
         dw 0FF00h, 0FFFFh    ;...

%include "..\mult_bit.asm"      ;����� ��⠢��� � � ��砫� ����.
