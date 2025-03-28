;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, BIOS, CGA+.
;�����㬥���: NASM(2.15).
;���㫨: system.asm, screen.asm, clear.asm.
;�����: ������ ��⠯�� (danilzatruda23@gmail.com) [1],
;        ����ᠭ�� ��஢ (funny.dreamy.cat@gmail.com) [2].

; ���������� ��楤��� ���⪨ ��࠭� �१ 横�� � � ��⨢��� ��࠭�.

; �����:
; - �������� ��������� � ��⮬ ���㫥� � ���ᬮ���� ����祭�� � �����;
; - �������� ����� � �뭥�� �� � ����᪨� 䠩� ��������樨.

CPU 8086
        org 00100h
        pushf
        jmp short Demo1
        push ax
        push cx
        push dx
        mov cx,010h                     ; 10h = 16 梥⮢.
        mov al,'a'                      ; ��砫�� ᨬ���.
        mov ah,00001111b                ; ���� 䮭 � �મ���� �㪢�.
        mov dl,00000011b                ; ��� � ⥪��.
ClrPrt: call near ClearScreen
        push ax
        push cx
        push dx
        mov cx,0Fh
        mov dx,0A120h
        mov ah,086h
        int 15h                         ; �������� 7A120 (500.000) �����ᥪ㭤.
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
Demo1:  mov ah,00011111b
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

;22.03.25 [1,2]: ��������� ��� ��� ��������樨 � ���஢���� ���⪨ ��࠭�.
