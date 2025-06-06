;8-��� �����⨥! ��業���: Creative Commons.
;�����ଠ: 8086, BIOS, VGA(CGA).
;�����㬥���: NASM(2.15).
;���㫨: system.asm, screen.asm, clear.asm, print.asm.
;�����: ������ ��⠯�� (daniilzatruda23@gmail.com) [1],
;        ����ᠭ�� ��஢ (funny.dreamy.cat@gmail.com) [2].
;����த���⢨�: ��।����� ����த���⢨� � ⠪��.
;������: ᪮�쪮 ���� ����� �������� ��� � �����.

; ��୮��� ⠩���, � �⥭��� ��⥬��� ������ �����.
; ���������� ࠡ��� ��� ��, ��� �������⥫��� 䠩���.
; ����������� ���������� ⠩��� �� ��࠭� �१ ���뢠���.

SCR_ADDRESS     EQU 0B800h
SCR_WIDTH       EQU 028h
SCR_LINE_BYTES  EQU 050h                ;������⢮ ���� �� �����.
SCR_SHL_1       EQU 005h                ;��୮� �襭�� �१ ��६���� � ����.
SCR_SHL_2       EQU 003h                ;�� � ������ ��砥 �१ ����⠭��.
SCR_HEIGHT      EQU 019h
SCR_BCKG_MASK   EQU 11110000b           ;���� ��� 䮭� ��ਡ��.
FONT_CHAR_W     EQU 008h                ;��ਭ� ᨬ���� � ���ᥫ��.
FONT_CHAR_SHL   EQU 004h                ;������ ᨬ����, ���� �ࠧ� � ᤢ����.
FONT_LINES      EQU 010h                ;����������� �����প� �⥯��� 2 �����.
FONT_SIZE       EQU 00100h              ;�������� � ����, �������⥫쭮.

P8086
MODEL DOS TINY
CODESEG

        ORG 00100h
Demo:   pushf
        mov ax,00001h
        int 10h
        mov ax,01003h
        int 10h
        push es
        mov ax,01130h
        mov bh,006h
        int 10h
        mov word ptr [font_address],bp
        mov ax,es
        mov word ptr [font_address + 2],ax
        pop es
        lea dx,UpdateTimer
        call InitTimer
        mov cx,01000h
Demo2:  push cx
        mov cx,0F000h
Demo1:  nop
        loop Demo1
        pop cx
        loop Demo2
        call RestoreTimer
        jmp short Demo0
        mov al,000h
        mov ah,00110001b
        mov dx,00201h
        lea bx,char_table
        call DrawChar
        inc al
        mov dx,0020Ch
        call DrawChar
Demo0:  xor ah,ah
        int 16h
        popf
        ret

UpdateTimer:
        pushf
        call [IRQ0I8_store]             ;standart irq
        cli
        push ax
        push bx
        push cx
        push es
        mov al,[timer_clocks]
        mov dx,[timer_mseconds]
        inc al
        add dx,037h
        cmp dx,[timer_ms_next]
        jna short UpdTim1
        add word ptr [timer_ms_next],003E8h
        call DrawDigits
        mov ah,[timer_digits]
        test ah,00001111b
        jnz short UpdTim2
        mov cl,004h
        shr ah,cl
        test ah,00001111b
        jnz short UpdTim3
        mov ah,00001010b
UpdTim3:dec ah
        shl ah,cl
        or ah,00001010b
UpdTim2:dec ah
        mov [timer_digits],ah
UpdTimA:cmp al,[timer_max]
        jnz short UpdTim1
        xor al,al
        xor dx,dx
        mov word ptr [timer_ms_next],003E8h
UpdTim1:mov [timer_clocks],al
        mov [timer_mseconds],dx
        pop es
        pop cx
        pop bx
        pop ax
        sti
        iret

DrawDigits:
        pushf
        push ax
        push bx
        push cx
        push dx
        mov al,[timer_digits]
        mov ah,[digits_color]
        and al,00001111b
        add al,'0'
        ;mov al,177
        ;mov ah,00100001b
        mov dx,[digits_pos_xy]
        mov cx,ds
        lds bx,[font_address]
        call DrawChar
        mov ds,cx
        mov al,[timer_digits]
        mov ah,[digits_color]
        mov cl,004h
        shr al,cl
        add al,'0'
        ;mov al,219
        ;mov ah,00100001b
        mov dx,[digits_pos_xy + 2]
        mov cx,ds
        lds bx,[font_address]
        call DrawChar
        mov ds,cx
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

RestoreTimer:
        pushf
        push ax
        push bx
        push es
        cli
        les bx,[IRQ0I8_offset]
        mov ax,word ptr [IRQ0I8_store]
        mov es:[bx],ax
        mov ax,word ptr [IRQ0I8_store + 2]
        mov es:[bx + 2],ax
        sti
        pop es
        pop bx
        pop ax
        popf
        ret



;ds:dx - ���� ��襣� ��ࠡ��稪� ���뢠��� � ⥪�饬 ᥣ����.
InitTimer:
        pushf
        push ax
        push bx
        push es
        cli
        les bx,[IRQ0I8_offset]
        mov ax,es:[bx]
        mov word ptr [IRQ0I8_store],ax
        mov ax,es:[bx + 2]
        mov word ptr [IRQ0I8_store + 2],ax
        mov es:[bx],dx
        mov es:[bx + 2],ds
        les ax,es:[bx]

        sti
        pop es
        pop bx
        pop ax
        popf
        ret


IRQ0I8_offset   dd 000000020h           ; irq0 interrupt 8, timer
IRQ0I8_store    dd 000000000h           ; previous interrupt procedure
font_address    dd 000000000h
digits_pos_xy   dw 00416h,0040Ah
digits_color    db 00100001b
digits_bckg     db 00000000b
timer_digits    db 011h                 ; bcd digits
timer_clocks    db 000h
timer_max       db 0C8h
timer_mseconds  dw 00000h
timer_ms_next   dw 003E8h



; �᫮���� ⠡��� ᨬ�����. ����� ᨬ��� 8*16 �祪, �.�. �� 16 ����.
char_table      dw 008h dup (0101010110101010b)
                dw 008h dup (1010101001010101b)

; ��ᮢ���� ᨬ���� �� ��࠭� ��ਡ�⠬� 䮭�, �.�. ����� 1 ��� - ��ਡ�� 䮭�,
;ࠧ��� ��࠭� ����� ����⠭⠬�. ��������� �ਬ����� ��⮢� ᤢ���, � ��
;������� 㬭������. �஢�ઠ �����⨬��� � ��⮬ ࠧ��஢ ᨬ����;
;�᫨ ��� � ���� ����, ⮣�� ��㥬 梥�, �᫨ ���, � ��㥬 ���� 䮭.
;�� ��ன ���ᨨ ��।����� ��, 䮭 �� �㫥 ����� ॣ���஬.
; �室:
;AL     ��� ᨬ���� � ⠡���;
;AH     䫠�� ��⮢:
;0      1 - ����祭 �ࠤ����, �.�. ������ ����� ��� +1 � 梥�� 䮭�.
;3..7   4 ��� 梥� ���⮢��� 䮭� � �ࠤ���⮬ ��� ������ 䮭�.
;DS:BX  ⠡��� ����, �⠭����� �ଠ� �࠭���� �����஬, VGA ������.
;DL,DH  ���न���� (X,Y) �뢮�� ������ ���孥�� 㣫� ᨬ����, � �।���� ��࠭�.
; ��室: ��������� ��������� ��࠭�.

DrawChar:               ;DrwChr[0..A]
        pushf
        push ax
        push bx
        push cx
        push dx
        push es
        push di
        push si
;Check sizes.
        mov cx,SCR_ADDRESS
        mov es,cx
        mov di,ax                       ;di = ax
        mov si,bx
        mov bl,dh
        xor bh,bh
        mov cl,SCR_SHL_1                ;5 * 40 = 5 * (32 + 8)
        shl bx,cl
        mov al,dh
        xor ah,ah
        mov cl,SCR_SHL_2
        shl ax,cl
        add ax,bx
        xor dh,dh
        add ax,dx                       ; add x
        shl ax,1
        xchg di,ax                      ;di offset screen
        inc di
        cld
        mov dx,di
        mov bl,al
        xor bh,bh
        mov cl,FONT_CHAR_SHL
        shl bx,cl
        add si,bx
        mov bl,ah
        and bl,SCR_BCKG_MASK            ;background
        mov ch,FONT_LINES
DrwChr6:mov cl,FONT_CHAR_W
DrwChr3:lodsb
DrwChr4:mov bh,es:[di]
        and bh,SCR_BCKG_MASK
        shl al,1                        ;font next bit
        jc short DrwChr1
        xor bh,bh
        jmp short DrwChrA
DrwChr1:or bh,bl                        ;fix later
DrwChrA:mov es:[di],bh
        add di,2
        dec cl
        jz short DrwChr2
        test cl,00000111b               ;next byte, to next version
        jz short DrwChr3
        jmp short DrwChr4
DrwChr2:test ah,00000001b
        jz short DrwChr5
        mov cl,004h
        shr bl,cl
        inc bl
        shl bl,cl
DrwChr5:add dx,SCR_LINE_BYTES
        mov di,dx
        dec ch
        jnz short DrwChr6
DrwChr0:pop si
        pop di
        pop es
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;TimerDelay - �㭪�� ����প� �� ��⥬���� ⠩����.
;�� - ����প� � ⨪��(18.2 � ᥪ㭤�).

TimerDelay:
        pushf                           ;���.��⨬�����, �᫨ ����.
        push bx
        push dx
        push di
        push es
        mov bx,00040h
        mov es,bx
        mov di,0006Ch
        mov bx,es:[di]                  ;⨪� �� ����.
TimDel0:mov dx,es:[di]                  ;⥪�騥 ⨪�.
        sub dx,bx                       ;����塞 ������ �� ⨪��.
        cmp dx,ax                       ;�� ���⨣��� �� ��ࠬ��� ����প�.
        jc short TimDel0
        pop es
        pop di
        pop dx
        pop bx
        popf
        ret

END Demo