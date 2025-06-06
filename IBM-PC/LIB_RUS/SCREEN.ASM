;��⠭���� � ����⠭������� ⥪�⮢��� ०��� ��࠭�.

CPU 8086

;       org 100h
;       pushf
;       mov al,001h
;       call near SetupScreen
;       mov bl,[scr_width]
;       mov bh,[scr_height]
;       xor ah,ah
;       int 16h
;       call near RestoreScreen
;       xor ah,ah
;       int 16h
;       popf
;       ret

scr_store_mode  db 0FFh
scr_active_mode db 003h
scr_width       db SCR_WIDTH
scr_height      db SCR_HEIGHT
scr_size_word   dw SCR_SIZE_WORD
scr_cursor_x    db 000h
scr_cursor_y    db 000h
scr_size_byte   dw SCR_SIZE_BYTE  ; ࠧ��� ����� ��࠭� � �����, �᫨ 㤮���� ��� ���᫥���.

; ��⠭���� ०��� ⥪�⮢��� ��࠭�, �����⨬� ०��� �⤥�쭮.
; AL - ०�� ���� ��� � ����.

SetupScreen:
            pushf
            push ax
            push bx
            mov bx,ax
            mov ah,00Fh
            int 10h
            mov [scr_store_mode],al
            mov al,bl
            mov [scr_active_mode],al
            xor ah,ah
            int 10h
            mov [scr_width],byte SCR_WIDTH
            mov [scr_height],byte SCR_HEIGHT
            pop bx
            pop ax
            popf
            ret


; ����⠭������� ०��� �⠭���⭮�� ��࠭�, ��᫥ �맮�� ��楤��� ��⠭����.

RestoreScreen:
        pushf
        push ax
        mov al,[scr_store_mode]
        xor ah,ah
        int 10h
        pop ax
        popf
        ret


%include "system.asm"





