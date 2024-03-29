;8-Bit Tea Party!
;License: Creative Commons.

;���� �� ��騩 䠩� ����� � ���஢����� � ࠡ�⮩ � �����ன ������.
;����� 㦥 ࠧ����� �� 䠩� ��������樨 � �����।�⢥��� �� 䠩� ��楤���.

CPU 8086                                ;�������� �ਥ�⨢�, �᫨ ��㣮� ��.

;���᮪ ��������� �� �ࠢ��:
;1. ��������� ��।����� ������� �맮��� � ��楤��, ����� ���᪨� ��� �
;横���� � ���� �� ⨯� �������.
;2. ������� ��⪨ � ����⥫쭮 ������.
;3. ��易⥫쭮 �������� ���஡�� �������ਨ � ��� ��楤���, ����� ��
;���᪮� ��� ������᪮�. ����� �ᯮ�짮���� �������ਨ �� ��� ��ப�. ���
;���� ���� ��������ਨ ����⥫��, �ᮡ���� � ��� �맮��.
;4. ��楤��� �����/�⥭�� �⤥�쭮�� 梥�, �뭥�� � ��ନ��.
;5. ��୮��� ��楤��� ��⠭���� �窨 �� ���न��⠬.

;�ᯮ��㥬 ���� ����⠭��, ����� ����� � ��᫥ �� ��७�ᥬ � ��������
;䠩� ���� ���� � ��������� ������⥪� ०��� �.

SCR_GFX_ADDR            EQU 0A000H      ;�������� ���� ����᪮�� ��࠭�.

;Video DAC palette registers.

VGA_DAC_WRITE           EQU 3C8h
VGA_DAC_READ            EQU 3C7h
VGA_DAC_DATA            EQU 3C9h
VGA_PEL_MASK            EQU 3C6h

        org 100h

        pushf
        mov ax,13h                      ;13h standard video mode.
        int 10h

        mov     di, palette_rgb_6
        xor     ax, ax
        xor     cx, cx
        mov     si, 100h

        mov     bl, 0           ;������� ��� ��砫� 横�� � ��� ��ࠬ����.
        mov     bh, 0           ;�������� - �⢥��� �� �, ��⪮.
        mov     dl, 0
Lp1:
; rrrrrrgg ggggbbbb bbrrrrrr ggggggbb bbbbrrrr rrgggggg bbbbbbrr rrrrgggg
; ggbbbbbb
        mov     al, bl
        mov     cl, 2
        shl     al, cl
        mov     cl, 8
        sub     cl, ch          ;�� ᮢᥬ �᭮ ��祬 ������ 8 - 0.
        shr     ah, cl          ;�� - ����।����
        shl     ax, cl
        add     ch, 6           ;�����᪨� ����.
        cmp     ch, 8           ;�ᯮ�짮���� 横�� ��� ��ࠬ���� ᤢ���.
        jb short Lbl1           ;�� ������ ����� ����.
        mov     [di], ah        ;���࠭塞 ⠡����.
        inc     di
        mov     cl, 8           ;8 ࠧ, �������� ����� ᪮��஢��� ���.
        shl     ax, cl          ;��祬 ᤢ����� ������ 16 ���.
        sub     ch, cl          ;�᫨ ����� ���� ������.

Lbl1:   mov     al, bh          ;����� ���� �ਬ����� ��⮪ ����, ���,
        mov     cl, 2           ;� �ਬ����� ���� ��騩 横�, ���������.
        shl     al, cl
        mov     cl, 8
        sub     cl, ch
        shr     ah, cl
        shl     ax, cl
        add     ch, 6
        cmp     ch, 8
        jb      Lbl2
        mov     [di], ah
        inc     di
        mov     cl, 8
        shl     ax, cl
        sub     ch, cl

Lbl2:   mov     al, dl
        mov     cl, 2
        shl     al, cl
        mov     cl, 8
        sub     cl, ch
        shr     ah, cl
        shl     ax, cl
        add     ch, 6
        cmp     ch, 8
        jb      Lbl3
        mov     [di], ah
        inc     di
        mov     cl, 8
        shl     ax, cl
        sub     ch, cl

Lbl3:   mov     bp, si          ;���࠭塞 �� � �ᯮ��㥬 ��.
        and     bp, 11000000b   ;�����뢠�� ��᪨ � �� ��� ������.

        cmp     bp, 11000000b   ;�� �������樨 ��⠫��� ��������.
        jnz     Lbl4
        inc     bl
        and     bl, 00111111b
Lbl4:
        cmp     bp, 10000000b   ;�ࠢ����� 16-� � 8��⭮�� �᫠.
        jnz short Lbl5
        inc     bh
        and     bh, 00111111b
Lbl5:   cmp     bp, 00000000b
        jnz     Lbl6
        inc     bh
        and     bh, 00111111b
Lbl6:
        cmp     bp, 01000000b
        ja      Lbl7
        inc     dl
        and     dl, 00111111b
Lbl7:
        dec     si              ;������� ��� ����� ����讣� 横��, �������.
        jnz     Lp1

        mov     al, 0
        mov     ah, 0
        mov     cl, 18          ;���� ������� ��ࠢ��� �� ����.
        mov     dx, palette_rgb_6
        call near VXSetPalette  ;��� �맮�� ��易⥫�� � ������⥪�, ���
                                ;��������� ���饩 �������� ᥣ�.
        call near ColorTableDraw

        mov ah,00h                      ;Press any key...
        int 16h

        ;jmp near ToRet

        mov     di, palette_rgb_8
        mov     cx, 64
        mov     bl, 0
Lp2:    mov     al, bl
        stosb
        mov     al, 0
        stosb
        mov     al, 0
        stosb
        inc     bl
        loop    Lp2
        mov     cx, 64
        mov     bl, 0
Lp3:    mov     al, 0
        stosb
        mov     al, bl
        stosb
        mov     al, 0
        stosb
        inc     bl
        loop    Lp3
        mov     cx, 64
        mov     bl, 0
Lp4:    mov     al, bl
        stosb
        mov     al, bl
        stosb
        mov     al, 0
        stosb
        inc     bl
        loop    Lp4
        mov     cx, 64
        mov     bl, 0
Lp5:    mov     al, bl
        stosb
        mov     al, 0
        stosb
        mov     al, bl
        stosb
        inc     bl
        loop    Lp5

        mov     al, 0
        mov     ah, 0
        mov     cl, 24
        mov     dx, palette_rgb_8
        call    VXSetPalette

        call near ColorTableDraw

ToRet:  mov     ah, 0
        int     16h
        popf
        ret

;�ਬ��� ������ ��� ����� �� �室 ��楤��� ��⠭���� �������.

palette_rgb_8   db 100h * 03h dup (0)   ;24��� * 256 梥⮢ = 768 ����.
palette_rgb_6   db 240h dup (0)         ;18��� * 256 梥⮢ = 576 ����.

;��楤�� ��⠭���� 梥⮢�� ������� ��� ������ VGA, ०�� �, 256 梥⮢).
; ��� ��ࢮ� �७�஢�� ����� �ᯮ�짮���� �⠭����� �ଠ� RGB(8 ���), �.�.
;�� ����� ��������� �� ������ ����� � ���ᨢ� 256*3=768 ����. �᫨ ���
;��ଠ�쭮 ��ࠡ�⠫�, � 㦥 ����� ���஡����� ॠ������� ���ᨬ��쭮
;㯠������� �ଠ�: 3����(24 ���) 㯠������ �� 6��� ��⮪�� RGBR, ���
;��᫥���� 6��� 㦥 ����� ��������⮬ ᫥���饣� 梥� � ⠪��, �
;ᬥ饭��� 㦥 ���� ᫥��騥 梥� �������.
; �㭪樨 �맮�� ����-� �� �ᯮ�짮����, ������� ࠡ�⠥� � ������� � ��
;���뢠�� �� ���뢠���. �������ਨ �ਢ���������. :)
;
;�室�� ��ࠬ����:
;AL     ������ ��ࢮ�� 梥� ��� ��⠭���� � ⠡���, 0..255;
;AH     ������⢮ 梥⮢ ��� ��⠭����(0..255, �᫨ 0, � ���������, 256);
;CL     ⨯ ������� � १�ࢭ� ����:
;0      18 - 㯠������� �ଠ� RGBR (6-6-6-6);
;1      24 - �ᯠ������� �ଠ� RGB (8-8-8);
;2      32 - �ଠ� BMP 䠩��, BGRA (8-8-8-8);
;3..7   १��.
;DS:DX  ���� ⠡���� ��������⮢ 梥⮢, ⮫쪮 �� �⥭��, ����஫� ������
;       �� ��஭� �맮��.

VXSetPalette:
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp

        cmp     cl, 18                  ;18 bits check.
        jnz     VXSetPal1               ;������� ������� test.
        mov     di, Read6666Color
        xor     bp, bp
        mov     ch, 0
        jmp     VXSetPalRun
VXSetPal1:                              ;SetPal1:... SetPalA, B...
        cmp     cl, 24
        jnz     VXSetPal2
        mov     di, Read888Color
        jmp     VXSetPalRun             ;��楤��� ���� 㫮���� � 16 ᨬ�.
VXSetPal2:
        cmp     cl, 32
        jnz     VXSetPalExit
        mov     di, Read8888Color

VXSetPalRun:
        mov     bl, ah                  ;����஢���� ���稪� �� 256.
        mov     bh, 0
        test    bx, bx
        jnz     VXSetPal3
        mov     bx, 100h                ;�� ��室����� 16 ���.

VXSetPal3:
        mov     si, dx
        cld

        cli
        mov     dx, VGA_DAC_WRITE
        out     dx, al
        mov     dx, VGA_DAC_DATA
VXSetPalLp:
        push    bx
        call    di              ;��ᢥ��� �맮� ����⥫쭮 �ᯮ�짮����
        out     dx, al          ;⮫쪮 � ᠬ�� �ࠩ��� ��砥 � �������
        mov     al, bl          ;� 楫�� �� ������ॡ���� �맮����.
        out     dx, al          ;19 ⨪�� + 3 ����, 28 ⠪⮢ �� �����
        mov     al, bh          ;+ 5���� + 4-8 ⠪� �� �࠭���.
        out     dx, al          ;��⨢��� �ᯮ��� 横�� �᫨ ��������.
        pop     bx

        dec     bx
        jnz     VXSetPalLp
        sti

VXSetPalExit:
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

;

Read6666Color:
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        mov     bh, al
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        mov     bl, al
        call    Read6666ColNeed6Bits
        call    Read6666ColGet6Bits
        xchg    bh, al
        ret

Read6666ColNeed6Bits:
        cmp     ch, 6
        jae     Read6666ColNeed6BitsExit
        mov     ah, 0
        lodsb                           ;�����⭥� � 䫠��� ���ࠢ�����.
        mov     cl, 8
        sub     cl, ch
        shl     ax, cl                  ;����� ᬥ��� ����� �����-��ࠢ�.
        or      bp, ax                  ;������᪨� ᤢ�� �ᯮ�짮����.
        add     ch, 8
Read6666ColNeed6BitsExit:
        ret

Read6666ColGet6Bits:
        mov     ax, bp
        mov     cl, 6
        shl     bp, cl
        sub     ch, cl
        rol     ax, cl
        and     al, 00111111b
        ret

Read888Color:
        lodsw
        mov     bl, ah
        mov     bh, al
        lodsb
        xchg    bh, al
        ret

Read8888Color:
        lodsw           ; gb
        mov     cl, 2
        shr     ah, cl
        shr     al, cl
        mov     bl, ah
        mov     bh, al
        lodsb           ; r
        shr     al, cl
        inc     si      ; a
        ret

; Set one color of the palette

; Input:
;   AL = color
;   AH = r
;   BL = g
;   BH = b
VXSetPalColor:
        push    ax
        push    dx
        cli
        mov     dx, VGA_DAC_WRITE
        out     dx, al          ; color
        mov     dx, VGA_DAC_DATA
        mov     al, ah
        out     dx, al          ; r
        mov     al, bl
        out     dx, al          ; g
        mov     al, bh
        out     dx, al          ; b
        sti
        pop     dx
        pop     ax
        ret

; Get one color of the palette

; Input:
;   AL = color
; Output:
;   AH => r
;   BL => g
;   BH => b
VXGetPalColor:
        push    cx
        push    dx
        mov     cl, al          ; save color
        cli
        mov     dx, VGA_DAC_READ
        out     dx, al          ; color
        mov     dx, VGA_DAC_DATA
        in      al, dx          ; r
        mov     ah, al
        in      al, dx          ; g
        mov     bl, al
        in      al, dx          ; b
        mov     bh, al
        sti
        mov     al, cl          ; restore color
        pop     dx
        pop     cx
        ret

;Draw standard palette to screen.

ColorTableDraw:
        pushf
        push ax
        push dx
        push si
        push di
        push es
        mov ax,SCR_GFX_ADDR
        mov es,ax                       ;Screen.
        xor di,di                       ;3clk
        ;sub di,di                       ;3clk
        mov si,di
        cld                             ;Forward.
        mov dx,0C8h                     ;200.
CTabDr2:mov di,si
        mov cx,0100h                    ;All 256 colors.
CTabDr1:mov es:[di],al
        inc al
        inc di
        loop CTabDr1
        add si,0140h
        dec dx
        jnz short CTabDr2
        pop es
        pop di
        pop si
        pop dx
        pop ax
        popf
        ret
