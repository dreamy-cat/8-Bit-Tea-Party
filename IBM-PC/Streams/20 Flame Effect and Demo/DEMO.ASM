;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;��頭�� 20. ��䥪� ������� � �������� ��⪨� �⮣�.

;���� ��頭��, 20.11.2021.

;- ��७�� � ���������� ���楤�� � ������� ������⥪�;
;- ����� ��ப� ���������;
;- ������᪨� ��䥪� ������� � ���� ����.

;����� ��� ���祭�� ��ᥬ���� � ���⥪���� ������ Intel 8086/87.
;��᪮�쪮 �����஢����� ��䥪⮢, ᪮�쪮 �ᯥ�� � �� ᬮ���. :)
;��� ����: 01.06.2021.
;��� ��室� �஥��: 31.12.2021 �� ��� ࠭��, ��� �㤥� 㤮����.

;��饥 ���ᠭ�� � �����ଠ(���஡��� � 䠩�� 'readme.dos').

;�����ଠ: ���-ᮢ���⨬�� �� �᫮���� ���ᨨ 5.0, ॠ��� ०�� ����樨.
;������: ⮫쪮 8086(88) � ��⥬���᪨� ᮯ����� 8087.
;�᭮���� ������: 64�� ��� ���� � �⥪�(������ �������쭠�). ��⠫�� �����
;����⥫쭮 㫮���� � 512��. ��� ����᪠ �� "�殮���" ��� ���䨣�����.
;����७��� ������: �१ �ࠩ��� XMS, �� ����� 16��(�� ���饭�� ०��).
;����᪨� ������: IBM VGA, 256��, 6 ��� �� 梥�, ������ 2^18 梥⮢,
;����᪨� �-०��, 320x240x8��� �� 梥� �� ⠡���.
;��㪮��� ����: Adlib/SBPro(OPL2/OPL3), FM - ���⭠� �������.
;��ଠ� 䠩��: .COM, 64Kb, �ᯮ�짮���� �㭪樨 ���-� ��� ����� �����.

CPU 8086                                ;8087 as math. coprocessor.

%include "VGA-X.ASM"

RED_DEF_INDEX           EQU 000h        ;Indexes for default color palette.
GREEN_DEF_INDEX         EQU 040h
BLUE_DEF_INDEX          EQU 080h
BW_DEF_INDEX            EQU 0C0h

FLAME_HEIGHT            EQU 050h        ;Flame max.
FLAME_SIZE              EQU FLAME_HEIGHT * GFX_SCR_WIDTH
FLAME_SIZE_PLANE        EQU FLAME_SIZE / 4
FLAME_INTENSE           EQU 01h
FLAME_SCR_ADDR          EQU GFX_BYTES_PER_LINE * 70h
FLAME_SRC_OFFS          EQU FLAME_SIZE - GFX_SCR_WIDTH
FLAME_COLOR_MASK        EQU 0FFFFh

        org 100h                        ;PSP.
        pushf

        call near VXSetModeX            ;Init gfx.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        mov ax,0FA0Fh
        call near RandomSimple          ;Random init.



        ;call near VXSetFullDAC          ;Default palette.
        ;jmp short Start

;Set color palette for flames.

; �㭪�� ��⠭���� (������) �����筮�� 梥� � ������ �����������.
; �����砥� 梥�� � ������� �����ᮬ ���� ����������: Read, Green, Blue.
; �室:
; AL    ������ 梥�
; AH    Red
; DL    Green
; DH    Blue

; Yellow -> Orange.

;������ ���-�࠭즥��� �������
        mov al,00h
        mov ah,03Fh
        mov dl,03FH
        mov dh,00h
        mov cx,80h
PalFl2: dec al
        call near VXSetPalColor
        test cx,0001h
        jnz short PalFl1
        test dh,dh
        jz short PalFl1
        dec dh
PalFl1: loop PalFl2
        mov cx,40h
PalFl4: dec al
        call near VXSetPalColor
        test cx,0001h
        jnz short PalFl3
        dec dl
PalFl3: loop PalFl4
        mov cx,040h
PalFl6: dec al
        call near VXSetPalColor
        dec ah
        test cx,0001h
        jnz short PalFl5
        test dl,dl
        jz short PalFl5
        dec dl
PalFl5: loop PalFl6
;Print title on screen.

        call near VXLoadFontBIOS

;��楤�� ���� ����᪮� ��ப� �� ��࠭ � ०��� �, �� ���न��⠬.
;����� �ᯮ���� �������� ��ࠬ���� ��-㬮�砭��: ������, ���� � �.�.
;�� ��室� �� �।��� ��࠭�, ��室�� ��.
;�室:
;AH     ����:
;0..3   ����⠡�஢���� ��� ᨬ�����, 1..16;
;4      १�� (�ᯮ�짮���� �ࠤ���� �� - ���)
;5      ������ �� ������ ᨬ����, ��������� �������� ���न���� � ���,
;       �⮡� 㫮������ � ���� ����;
;6      ��⠭�������� �뢮� �� ���⨦���� ���� ��ਧ��⠫쭮�� �뢮��;
;7      ��७���� ��� ��� �������� ���न���� ����;
;AL     ���� �� ������⢮ ᨬ����� ��� ����, �᫨ 0, � ����� �� ����
;       ��ப�, ��� ���� �� ��������� ��࠭.
;DS:BX  ���� ��ப�;
;DX     ᬥ饭�� � ��ப�, ᨬ��� � ���ண� �㦭� ��稭��� ������.
;��室: ��������� ���������� � ��⨢��� ��࠭�� � �᫨ ���� 5 ��� 7, � �
;       �����.


        mov ah,01100010b
        mov al,04h
        lea bx,title_string
        xor dx,dx
        mov word [vx_cursor_x],0060h
        mov word [vx_cursor_y],0030h
        mov byte [vx_font_color],040h
        mov cx,05h
PrtT1:  call near VXPrintString
        inc dx
        loop PrtT1
        xor ah,00100000b
        xor al,al
        mov word [vx_cursor_x],0010h
        mov word [vx_cursor_y],0050h
        mov byte [vx_font_color],040h
        call near VXPrintString
        ;jmp Dem0

;Flame effect without procedures, to release version.

Start:  mov ax,GFX_SCR_ADDR
        mov es,ax
        cld
        mov bp,4000h                    ;Main cycle.
FlameA: mov di,FLAME_SCR_ADDR
        lea si,flame_data
        mov bx,di
        mov dx,si
        add si,FLAME_SIZE

;��ନ�㥬 �����-���筨� ����, ᠬ�� ������ � ����.
Flame0: dec si
        dec si
        xor ax,ax
        call near RandomSimple
        and ax,FLAME_COLOR_MASK
        ;mov word ds:[si],0FFFFh
        mov [si],ax
        cmp si,flame_data + FLAME_SRC_OFFS
        ja short Flame0

;�⮡ࠦ��� ���� ����ﭨ �� ��࠭.
        call near VXWaitVSync
        mov al,00000001b
Flame2: mov di,bx
        mov si,dx
        call near VXSetPlanes
        mov cx,FLAME_SIZE_PLANE
Flame1: movsb
        add si,0003h
        loop Flame1
        inc dx
        shl al,1
        test al,00010000b
        jz short Flame2

;������塞 ���� ������� ��� ��� ���ᥫ�� �஬� ��室��� �����.
        sub dx,0004h
        mov si,dx
        mov di,si
        xor dx,dx
        mov ax,dx
        add si,GFX_SCR_WIDTH
        mov bl,FLAME_HEIGHT - 1

Flame3: mov dl,[si]
        mov al,[si + 01h]
        add dx,ax
        shr dx,1
        jz short Flame4
        dec dl
Flame4: mov [di],dl
        ;mov byte [di],07Fh
        mov cx,GFX_SCR_WIDTH - 02h
Flame5: inc si
        inc di

;�ࠢ��� �������, ������ �� �����...
        xor dh,dh
        mov dl,[di]
        mov al,[si]
        add dx,ax
        mov al,[si + 01h]
        add dx,ax
        mov al,[si - 01h]
        add dx,ax
        shr dx,1
        shr dx,1
        test dl,dl
        jz short Flame6
        dec dl
Flame6: ;mov byte [di],0DFh
        mov [di],dl
        loop Flame5
        inc si
        inc di
        xor dh,dh
        mov dl,[si]
        mov al,[si - 01h]
        add dx,ax
        shr dx,1
        jz short Flame7
        dec dl
Flame7: ;mov byte [di],03Fh
        mov [di],dl
        inc si
        inc di
        dec bl
        jnz Flame3



        dec bp
        jnz FlameA
Dem0:   mov ah,00h                      ;Press any key.
        int 16h
        popf
        ret

title_string    dw 0010h
                dw 0004h
                db '8-BIT Tea Party!'

;�������࠭��� ����஢���� ��࠭�� ����� ����� ������.
;al - bits:
;0..1   mode write to page as VGA;
;0..1   source page index;
;2..3   destination page index;

VXCopyPage:
        pushf
        push ax

        mov ah,al
        and al,00000011b

        pop ax
        popf
        ret

flame_data      db FLAME_SIZE dup (00h)

;Other code.

DrawSTDColors:
        pushf
        push ax
        push cx
        push dx
        push di
        push es
        mov ax,0A000h
        mov es,ax
        xor di,di
        xor al,al
        mov cx,0100h
tf2:    mov dx,00C8h
        push di
tf1:    mov es:[di],al
        add di,0140h
        dec dx
        jnz short tf1
        inc al
        pop di
        inc di
        loop tf2
        pop es
        pop di
        pop dx
        pop cx
        pop ax
        popf
        ret

FillVRAM:
        mov ax,GFX_SCR_ADDR
        mov es,ax
        xor di,di
        mov ax,0000h
        mov cx,2580h           ;Both pages 0 and 1.
        cld
SetMD1: stosw
        inc al
        inc ah
        and al,00001111b                ;CGA 16 colors, 0..15.
        and ah,00001111b
        loop SetMD1
        mov ax,000Fh
        mov cx,2580h                    ;Second page.
        cld
SetMD2: stosw
        inc al
        and al,00001111b                ;CGA 16 colors, 0..15.
        loop SetMD2
        mov ax,000Fh
        mov cx,2580h                    ;Second page.
        cld
SetMD3: stosw
        inc ah
        and ah,00001111b                ;CGA 16 colors, 0..15.
        loop SetMD3

        mov ah,00h
        int 16h
        mov al,04h
        call near VXSetActDispPage      ;Set second page.
        mov ah,00h
        int 16h
        mov al,04h
        add al,04h
        call near VXSetActDispPage      ;Set third page.

        jmp near Dem0

;3. ���������� �࣠����樨 �����, � �᢮��������� ��� ���-�맮��.

Mem:    mov ah,48h
        mov bx,0FFFFh
        int 21h
        mov ah,4Ah                     ;Resize memory segment.
        mov bx,1000h                   ;16 bytes multiply 4k = 64kb.
        ;mov es,ax                     ;ES - default.
        int 21h
        mov ah,48h                     ;Memory maximum.
        mov bx,0FFFFh
        int 21h
        mov ah,48h                     ;Allocate memory for BMP data.
        mov cx,12C0h                   ;4800 par, for screen 76800.
        int 21h
        push es
        mov es,ax
        mov ah,49h                     ;Free allocated memory block.
        int 21h
        pop es

;Memory allocation, so small, or using linker.

;4. ����஭����� �� ����, ᬥ�� �����-��࠭�� � �롮� ���᪮��(�ᯮ�).
;������� �� �ࠩ��� �� ��直� ��砩 � ����ன�� �������.
;��ࠬ����: �㫫����=��⨭�, ����� ��� ������� ����祭.

VGASync:mov cx,0300h
        mov ax,GFX_SCR_ADDR
        mov es,ax
        cld
Wait1:  mov ax,0101h            ;Blue color.
        call near VXWaitVSync
        push cx
        xor di,di
        mov cx,2580h            ;Full page.
        rep stosw
        mov cx,0F000h
Wait2:  nop                     ;Empty command.
        nop
        nop
        loop Wait2
        mov ax,0202h
        xor di,di
        mov cx,2580h
        rep stosw
        pop cx
        loop Wait1

        jmp near Dem0

;Draw standard palette to screen for debug.

;ColorTableDraw:
        pushf
        popf
        ret

;Library procedures.

%include "vx_sys.asm"
%include "vx_pixel.asm"
%include "vx_dac.asm"
%include "rnd_s.asm"
%include "vx_lines.asm"
%include "vx_print.asm"
