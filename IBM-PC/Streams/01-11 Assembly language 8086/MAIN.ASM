;Welcome to 8-Bit Tea Party!
;
;Assembler, Intel 8086/8088, IBM PC.
;
;Grabbag (Duke Nukem Theme).
;Composed by Lee Jackson.

;������ Intel 8086\8088, 5 ���.
;����來���� ���: 16 ���.
;���� ������: 16 ���.
;���� ����: 20 ���, 1 �����.
;����� ०�� ����樨, DOS 5.0.
;�᭮���� ������: 640 �����.
;���⥬��� ������: 384 �����.

;�᭮��� ॣ����� ������ 8086.
;AX[ah,al] �᭮���� ��������;
;BX[bh,bl] ����, ᬥ饭�� ������;
;CX[ch,cl] ����稪 ��� �������;
;DX[dh,dl] �����, ����� �����-�뢮��,"���� ��������".
;SI        ������ ���筨��, 16 ���.
;DI        ������ ��񬭨��, 16 ���.
;BP        ����, ᬥ饭�� �⥪�.
;SP        㪠��⥫� ���設� �⥪�.
;CS:IP     ���� ᥣ���� ����.
;DS:[offs] ᥣ���� ������.
;ES:[offs] ᥣ���� ������, �������⥫쭮.
;SS:SP     ᥣ���� �⥪�, � ���設��.
;IP        㪠��⥫� �� ⥪���� ��������.

;������� 䫠���, 16 ���, 䫠��:
;CF        䫠� ��७��;
;ZF        䫠� ���.
;OF        䫠� ��९�������.
;SF        䫠� �����.
;AF        �ᯮ����⥫쭮� ��९�������.
;PF        �ਧ��� ��⭮��.
;������ ���� ॣ���� 䫠�� AF.

;�������   ᥣ����   ������
;  IP        CS        -
;  SP        SS        -
;BP+SI[DI]   SS     CS,DS,ES
;  BX        DS     CS,SS,ES
;SI,DI[base] DS     CS,SS,ES
;SI -> DI   DS,ES      -
;������ �����:
;tiny
;small
;compact
;medium
;large
;flat



CPU 8086        ;⮫쪮 ������� ������ 8086.

;�������� ����⠭��.

SCR_BUFF_ADDR      equ 0xB800
SCR_SIZE_WIDTH     equ 0x0050;0x0028
SCR_SIZE_HEIGHT    equ 0x0032
SCR_BUFF_SIZE_B    equ 0x0FA0
SCR_BUFF_SIZE_W    equ 0x07D0;0x03E8 * 2 - SCR_SIZE_WIDTH

;����⠭�� ��� ࠡ��� � ����㦠��� �������� ���⮬.

FONT_CHAR_SIZE    equ 0x60         ;������ ���� � ᨬ�����.
FONT_CHAR_BYTE    equ 0x08         ;������ ������ ᨬ���� � �����.
FONT_WIDTH_PIX    equ 0x08         ;������ ���� � �窠� �� ��ਧ��⠫�.
FONT_HEIGHT_PIX   equ 0x08         ;������ ���� � �窠� �� ���⨪���.
FONT_WIDTH_BYTE   equ 0x01         ;��ਭ� ���� � ����� �� �����.
FONT_FIRST_CHAR   equ 0x20         ;���� ᨬ��� ����, ���筮 �஡��.

        ;��砫� �ணࠬ��.
        org 0x100
        push ax
        push bx
        push cx
        push dx
        ;jmp return
;��頭�� �6. ��ப��� ������樨 � ������� ��।�� �ࠢ�����.
        jmp near Main0
;rep,repe,repz,repne,repnz - ��䨪� ����७��.
        lea si,[string_src] ;ES=DS,default
        lea di,[string_dst]
        ;mov ax,seg string_src
        ;mov ds,ax �᫨ �ॡ���� ���.ᥣ�����.
        push cs
        pop es
        mov ax,ds:[si]
        mov ax,[si]    ; nasm �� ��⨬������ �� -�0
        mov bx,es:[di]

;movs(mov string dst:src).
;��६�饭�� ���� ��� ᫮�.
        ;rep movs string_src,string_dst - nasm �� ��।���� ��⮬���᪨
        mov cx,0x0002
        rep movsb    ; 9(rep)+17/rep+2 trans,clk
        mov ax,[si-0x02]
        mov bx,[di-0x02]
        mov cx,0x0001
        rep movsw    ; 9(rep)+17/rep+2 trans,clk
        mov ax,[si-0x02]
        mov bx,[di-0x02]
;cmps src,dst - �ࠢ����� ��ப.
        lea si,string_src
        lea di,string_dst
        mov ax,ds:[si]
        mov bx,es:[di]
        mov cx,0x0002
        repe cmpsb    ;9(rep)+22/rep+2 trans,clk
        mov ah,ds:[si]
        mov al,es:[di]
        lea si,string_src
        lea di,string_dst
        mov cx,0x0005
        mov ax,0x0708
        mov es:[di],ax
        repnz cmpsw
        mov ax,[si-0x02]
        mov bx,es:[di-0x02]
;scas dst - ᪠��஢���� ��ப� �� ��������.
        mov ax,0x0403
        xor bx,bx
        lea di,string_dst
        mov cx,0x0007
        repnz scasb    ;al=0x03
        mov bl,es:[di-0x01]
        mov cx,0x0003
        lea di,string_dst
        repnz scasw      ;9(rep)+15/rep+1 trans,clk
        mov bx,es:[di-0x02]

;stos dst - ��࠭���� ��ப�.(�� ��������)
        lea di,string_dst
        mov al,0x12
        mov cx,0x0002    ;al - byte
        rep stosb        ;9(rep)+11/rep+1 trans,clk
        mov bl,[di-0x01]
        mov ah,0x34
        lea di,string_dst
        stosw            ;11 clk
        mov bx,es:[di-0x02]
;lods src - ����㧪� � �������� �� ��ப�.
        lea si,string_src
        mov cx,0x0002
        rep lodsb    ;9(rep)+13/rep+1 trans,clk
        lodsw        ;al,ax - result.;scas dst - ᪠��஢���� ��ப� �� ��������.
;������樨 ��।�� �ࠢ�����
;jmp - ���⮩ ����᫮��� ���室. 15 clk.

        xor dl,dl
        ;jmp far Main1 ⮫쪮 �᫨ ��᪮�쪮 ᥣ���⮢ ����.
        jmp short Main1
        jmp near Main1   ;nasm �� ��⨬������ ���室� �� -�0
        jmp Main1
        nop             ;3 clk
Main1:  inc dl
        mov [addr_offs],word Main2
        ;jmp near [addr_offs]  ;18+EA+1 trans,clk
        mov [addr_segm],cs
        jmp far [addr_offs]   ;24+EA+2 trans,clk
        nop
Main2:  inc dl
        lea bx,Main3
        jmp bx        ;11 clk.
        nop
Main3:  inc dl
;������樨 �᫮����� ���室�.
        mov ax,0x0201  ;carry flag
        cmp al,ah
        jc short Main4
        nop
Main4:  inc dl         ;zero flag
        mov bx,0x0102
        cmp ax,bx
        jnz short Main5
        nop
Main5:  inc dl         ;sign flag
        mov al,-0x03
        dec al
        js short Main6
        nop
Main6:  inc dl         ;flag overflow
        mov al,-0x60
        sub al,0x40
        jo short Main7
        nop
Main7:  inc dl         ;carry or zero flag
        mov ax,0x0102
        cmp al,ah
        jnbe short Main8
        nop
Main8:  inc dl
        jmp return
;loop short-label - 横�, ���室 �⭮�⥫�� �� -128 �� +127.
;loope\loopz - ���� ࠢ��\���� ����, �᫨ 䫠� ��� ��⠭�����.
;jcxz short label. �믮���� ���室 �᫨ cx = 0.
        xor ax,ax
        mov cx,0x0003
Main9:  inc ax
        loop Main9      ; 17(jmp) clk or 5 clk if no.
        mov cx,0x0005
MainA:  dec ax
        loopnz MainA    ; 18(jmp) or 7 clk.
        xor cx,cx
        jcxz MainB
        nop
MainB:  mov cx,0x0003
        mov ax,0x0005
        cmp cx,0x0003
MainC:  cmp ax,0x0005
        loopz MainC
;int interrupt\into\iret
;call procedure-name - �맮� ��楤���.
        mov ax,0x0012
        ;call far TimerDelay
        call near TimerDelay
        mov [addr_offs],word TimerDelay
        call near [addr_offs]
        mov bx,TimerDelay
        call bx
;������樨 �ࠢ����� �����஬ � 䫠����.
        stc ;set carry flag
        clc ;clear carry flag
        cmc ;complement carry flag
        std ;set direction flag
        cld ;clear direction flag
        sti ;set interrupt-enable flag
        cli ;clear interrupt-enable flag
;������樨 ���譥� ᨭ�஭���樨.
        hlt ;������� ���뢠��� ��� ���.
;wait - ������� ᨣ���� test
;lock - ��䨪�, �����஢�� 設� �����.(ࠡ��� �� ��᪮�쪨� ������� 8086)
;esc  - �।��⠢��� ���譥�� ������� ������� � ���࠭�.
;nop  - ��祣�, 3 ⠪�.

;��� �ணࠬ�� ��頭�� �6.
        mov cx,SCR_BUFF_SIZE_B
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        xor ax,ax        ;first ASCII char
        mov di,ax        ; + 6 clk.
MainD:  stosb
        inc al
        inc di
        loop MainD
        mov al,0x21
        mov ah,01000001b
        mov bl,00000010b
        xor ah,ah
        mov cx,0x0003
MainE:  call near ClearTextScreen
        inc ah
        mov dx,ax
        mov ax,0x0002
        call near TimerDelay
        mov ax,dx
        loop MainE
        mov al,0x20
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
        mov ax,0x0A05
        lea bx,string_test
        call near PrintTextString
        mov ax,0x0300
        lea bx,str_tab_bases
        call near PrintTextString

        lea bx,str_conv
        lea si,bases_tab
        mov dx,0x0004
        mov di,0x0500   ;print at

MainF:  mov al,[num_conv_8]
        ;mov ax,[num_conv_16]
        mov cl,ds:[si]
        shl cl,0x01
        shl cl,0x01
        ;or cl,00000001b ; for 16-bit
        inc si
        call near BinToString
        mov ax,di
        call near PrintTextString
        add di,0x000A
        dec dx
        jnz short MainF

        mov al,0x20
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
        lea si,char_test
        mov di,0x00A1
        mov dx,0x00A0
        mov bx,0x02
        call near DrawCharBuffer
        ;call near ShiftBuffUp;Left
;��頭�� �9.
        mov al,0x20
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen

        lea si,str_8btp
        mov cx,[si]
        ;main cycle
        add si,ds:[si+0x02]
        lea bx,font_8btp
MainI:  mov al,[si]
        lea di,line_buffer
        ;or al,10000000b
        mov ah,00000000b
        call near DrawCharBuffer
        mov dh,FONT_WIDTH_PIX
        push cx
        push si

;cycle shift char
MainH:  push es
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        mov di,SCR_SIZE_WIDTH * 5 * 2 - 0x02
        lea si,line_buffer
        mov cl,FONT_HEIGHT_PIX * 2
MainG:  mov ax,ds:[si]
        mov es:[di],ax
        add si,FONT_WIDTH_PIX * 2
        add di,SCR_SIZE_WIDTH * 2
        dec cl
        jnz short MainG
        pop es

        mov al,00000000b
        lea di,line_buffer
        mov cx,FONT_CHAR_BYTE * 2 * 16
        call near ShiftTextBuffer

        mov al,00010000b
        lea di,SCR_SIZE_WIDTH * 2 * 4
        mov cx,SCR_SIZE_WIDTH * 2 * 16
        call near ShiftTextBuffer

        mov ax,0x0002
        call near TimerDelay
        dec dh

        jnz short MainH
        pop si
        pop cx
        inc si
        dec cx
        jnz short MainI

;��頭�� �10, ᬥ饭�� ���� � ANSI ���.
        mov al,'.'               ;previous Main0
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
        lea si,str_8btp
        add si,[si+0x02]
        mov al,[si]
        or al,10000000b
        lea bx,font_8btp
        xor ah,ah
        mov di,0x01A8
        call near DrawCharBuffer      ;Main cycle
        mov dl,0x04
        mov dh,00000001b              ;Shift type
MainK:  mov cl,0x05                   ;Shift one direction
MainJ:  push cx
        mov ax,0x0007
        call near TimerDelay
        xor bx,bx
        mov al,dh
        or al,00010000b
        xor di,di
        mov cx,SCR_SIZE_WIDTH * 25
        call near ShiftTextBuffer
        pop cx
        dec cl
        jnz short MainJ
        shl dh,1
        dec dl
        jnz short MainK
        jmp return


;���⨪���� �஫�.
        mov al,' '
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
;���樠������ ��砫�� ��६�����.
        lea si,str_8btp
        add si,[si+0x02]
        mov cx,0x0011
MainN:  push cx
;���⠥� ���� ᨬ����� � ���� ��ப�.
        mov ah,00000001b
        lea di,scr_buffer
        ;xor di,di           ;debug
        lea bx,font_8btp
        mov cx,0x0005
MainL:  mov al,ds:[si]
        ;or al,10000000b
        call near DrawCharBuffer
        inc si
        add di,FONT_WIDTH_PIX * 2
        loop MainL
        push si
;�஢�ਬ �뢮� � ����, ᪮��஢�� ��� �� ��࠭.
        ;lea si,scr_buffer
        ;lea di,0x0140
        ;mov cx,SCR_SIZE_WIDTH * 16
        ;mov ax,SCR_BUFF_ADDR
        ;mov es,ax
        ;cld
        ;rep movsw

;����� ��࠭� ����� ���������.
        mov dl,0x10
MainM:  mov al,00000100b
        or al,00010000b     ;screen
        mov cx,SCR_BUFF_SIZE_W
        xor di,di
        call near ShiftTextBuffer
;�����㥬 ������ ��ப� �� ���� � ������ ��ப� ��࠭�.
        push si
        push di
        push es
        lea si,scr_buffer
        mov di,SCR_BUFF_SIZE_B
        sub di,SCR_SIZE_WIDTH * 2
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        mov cx,SCR_SIZE_WIDTH
        cld
        rep movsw
        pop es
        pop di
        pop si

;���頥� ����� ᮤ�ন��� ����.
        mov al,00000100b
        lea di,scr_buffer
        mov cx,LINE_SIZE_W
        call near ShiftTextBuffer

        mov ax,0x0001
        call near TimerDelay
        dec dl
        jnz short MainM
        pop si
        pop cx
        loop MainN
        jmp return
Main0:
;�뢮��� ��䨪� ����.
        mov cx,0x0078
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        lea si,ansi_art
        mov al,' '
        mov ah,00001111b
        mov bl,00000011b
        call near ClearTextScreen
MainO:  push cx
        mov di,SCR_SIZE_WIDTH * 2 * 49
        mov cx,SCR_SIZE_WIDTH
        cld
        rep movsw
        xor di,di       ;���饭�� ��� �����.
        mov al,00010100b
        mov cx,0x0FA0
        call near ShiftTextBuffer
        mov ax,0x0005
        call near TimerDelay
        pop cx
        loop MainO
        jmp return

ansi_art    incbin "ansi_art.bin"

;����� ��� ��頭�� 8, ������ ��ப� � ���⨪��쭮�� �஫��.

LINE_SIZE_W     equ SCR_SIZE_WIDTH * 16     ;������ ��ப�.
LINE_SIZE_B     equ SCR_SIZE_WIDTH * 2 * 16 ; in bytes.

str_8btp        dw 0x0055, 0x0005               ;Line to running.
                db 00011111b                    ;color
                db 'Welcome to 8-Bit Tea Party! ';Text line to show/debug.
                db 'Hello to all our friends and followers!                    '

line_buffer     dw FONT_CHAR_BYTE * 16 dup (0)  ;Words, chars + attributes.
scr_buffer      dw SCR_SIZE_WIDTH * 16 dup (0)  ;�������⥫�� ���� 16*80*2.
font_8btp      incbin "8btp.fnt"               ;��� ���� �� 96 ᨬ�����.

;��ᮢ���� ᨬ���� ��ਡ�⠬� ⥪�⮢��� ०��� � ᨬ������ � ������ ����
;��� ��࠭. ��� �⮡ࠦ���� �窨 �ᯮ������ ᫮�� ���������, 16 ���.
;��� �⫠��� � ��������樨 㢥��稢��� 梥� �୨� �� 0 �� 15.
;������� ᪠��஢���� �ਬ������ �� 㬮�砭�� �.� �� ������ ����� ����,
;�뢮����� 2 ����� ��ਡ�⮢.
;�室:
;al:bit         �������� ��� ��頭��, ����� ��ࠡ����.
;0..6           ��� ᨬ���� ���� ��� �ᮢ����.
;7              ��� �ࠢ������ ���஬: 0=ds:[di], 1=0xB800:[di] - ��࠭
;               ���� � ���� � ���묨 ds:[di], ���� �� ��࠭ � es:[di]
;ah             梥� ��ਡ�� ��� �ᮢ����, �⠭�����.
;bx             ���� ����, ����� ����ୠ� ⠡��� �� ࠧ���� ����.
;di             ���� ���� ��࠭� ��� ������ ����� (ᬥ饭��).
;dx             �������⥫쭮, ᬥ饭�� �� ᫥������ ��ப� ���� �����.
;��室:         � ���� ��࠭� ��� �����.

DrawCharBuffer:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push es  ;����ࠥ���� ᥣ����� ॣ����.
        mov cx,ds
        test al,10000000b
        jz short DrChr1
        mov cx,SCR_BUFF_ADDR
DrChr1: mov es,cx
;�����뢠�� ���� ���� � �㪢 � ����.
        mov dx,ax
        xor ah,ah
        and al,01111111b   ;bit mask
        sub al,FONT_FIRST_CHAR
        mov ch,FONT_CHAR_BYTE
        mul ch
        add bx,ax       ;better using offset index.
        ;lea bx,char_test
;���㥬 ᨬ��� � ��ਡ��� � ᨬ�����.
        cld
        mov ax,dx
        and al,01111111b
        ;moval,0xDB     ;����譮� ASCII
        mov ch,FONT_HEIGHT_PIX * 2
        mov si,di         ;save start line
DrChr6: mov dh,[bx]
        mov di,si
        mov cl,FONT_WIDTH_PIX
DrChr3: mov es:[di],word 0x0000
        shl dh,0x01
        jnc short DrChr2
        mov es:[di],ax
DrChr2: inc di    ;add di,0x02
        inc di    ;use stosw
        dec cl
        jnz short DrChr3
        test dl,10000000b
        jz short DrChr4
        add si,SCR_SIZE_WIDTH * 2
        jmp short DrChr5
DrChr4: add si,SCR_SIZE_WIDTH * 2;FONT_WIDTH_PIX * 2
DrChr5: inc ah    ;next color
        dec ch
        jz short DrChr0
        test ch,00000001b
        jnz short DrChr6
        inc bx    ;double lines
        jmp short DrChr6
DrChr0: pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;���饭�� ⥪�⮢��� ���� ��࠭� ��� ����� �� ���ࠢ����� �� 1.
;�室:
;al:bit         ��������� ��⮢ ����� ���� �� � �㤥� �ᯮ�����.
;0              ᬥ饭�� �����;
;1              ᬥ饭�� ��ࠢ�;
;2              ᬥ饭�� �����;
;3              ᬥ饭�� ����;
;4              ��� �ࠢ������ ���஬: 0=ds:[di], 1=0xB800:[di] - ��࠭
;               ���� � ���� � ���묨 ds:[di], ���� �� ��࠭ � es:[di]
;di             ᬥ饭�� � ����, ��⭮�.
;cx             ࠧ��� ���� ������� ���� (� ᫮���).
;dx             ᬥ饭�� ����, ॠ�������� �������⥫쭮.
;�஢���� �室�� ����� �� �����⨬�����
ShiftTextBuffer:
        pushf
        push ax
        push bx
        push cx
        push si
        push di
        push bp
        push ds
        push es
        test al,00010000b
        jz short ShTBuf1
        mov si,SCR_BUFF_ADDR
        mov ds,si
ShTBuf1:mov si,ds      ;or use jump
        mov es,si
        and al,00001111b

        mov bx,di                ;bx - buffer offset.
        mov bp,cx                ;bp - counter.
        shr al,0x01                     ;test al,00000001b
        jc short ShTBuf2         ;left
ShTBuf6:mov di,bx                ;restore parameters.
        mov cx,bp
        shr al,0x01
        jc short ShTBuf3         ;right
ShTBuf7:mov di,bx                ;restore parameters.
        mov cx,bp
        shr al,0x01
        jc short ShTBuf4         ;up
ShTBuf8:mov di,bx                ;restore parameters.
        mov cx,bp
        shr al,0x01
        jc short ShTBuf5         ;down
        jmp short ShTBuf0        ;return


ShTBuf2:mov si,di
        inc si             ;Shift left.
        inc si
        dec cx
        cld
        rep movsw
        jmp short ShTBuf6
ShTBuf3:dec cx
        add di,cx                   ;Shift right.
        add di,cx
        mov si,di
        dec si
        dec si
        std
        rep movsw
        jmp short ShTBuf7
ShTBuf4:mov si,di
        add si,SCR_SIZE_WIDTH * 2          ;Shift up.
        sub cx,SCR_SIZE_WIDTH
        cld
        rep movsw
        jmp short ShTBuf8
ShTBuf5:dec cx
        add di,cx                          ;Shift down.
        add di,cx
        sub cx,SCR_SIZE_WIDTH
        mov si,di
        sub si,SCR_SIZE_WIDTH * 2
        std
        rep movsw
ShTBuf0:pop es
        pop ds
        pop bp
        pop di
        pop si
        pop cx
        pop bx
        pop ax
        popf
        ret

;DrawCharBuffer:
;        pushf
;        push di
;        push si
;        push es
;        mov ax,SCR_BUFF_ADDR
;        mov es,ax
;        mov ch,0x08
;        cld
;        mov ah,00001111b
;DrChr3: mov al,[si]
;        push di
;        mov cl,0x08
;DrChr2: shl al,0x01
;        jnc short DrChr1
;        mov es:[di],ah
;DrChr1: inc di
;        inc di
;        dec cl
;        jnz short DrChr2
;        pop di
;        add di,dx
;        inc si
;        ;mov cl,0x04   ���� ᫥���騩 梥�.
;        ;shr ah,cl
;        ;inc ah
;        ;shl ah,cl
;        add ah,00010000b
;        dec ch
;        jnz short DrChr3
;        pop es
;        pop di
;        pop di
;        popf
;        ret

char_test db 11111111b
          db 10000001b
          db 10000001b
          db 10000001b
          db 10000001b
          db 10000001b
          db 10000001b
          db 11111111b
          db 10101010b
          db 10101010b



;��᫠ � ⠡��� ��⥬� ��᫥��� ��� ��ॢ��� �� �᫠ � ��ப�.
bases_tab        db 0x10, 0x0A, 0x08, 0x02
num_conv_8       db 0xAA, -0x55
num_conv_16      dw 0xAA55, -0x55AA
num_conv_32      dd 0x0155AAFF
str_conv         dw 0x0008, 0x0004
str_conv_text    db '........'
str_tab_bases    dw 0x0050, 0x0004
str_tab_text     db 'Convert 8,16-bit numbers to strings.    '
                 db 'Hex:      Dec:      Oct:      Bin:      '

;��楤�� �८�ࠧ������ �᫠ � ��ப�.
;�室:
;al   8-bit number type.
;ax   16-bit number type.
;dx:ax 32-bit number type.
;bx   string structure address.
;cl:bit      parameters.
;0..1        data type, 32 and 64 bits, later...
;2..6        number base format.
;7           signed or unsigned number, later...
;ch:reserve
;��室:
;bx    ��ப� �뢮�� ��������� ⥪�⮬.
;�஢�ઠ �� ����� ��ப� � �����⨬���� ࠧ�來���.
;��ப� ��񬭨� ��室���� � ᥣ���� ������.

;����� ��ࠡ��� ����� � ����⥫쭮�� �᫠.
;����������� �����প� 32 ��⭮�� �᫠ ��� �������樨.

MIN_NUMBER_BASE equ 0x02
MAX_NUMBER_BASE equ 0x10

num_base_table db '0123456789ABCDEF'

BinToString:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
;�஢�ઠ �� �����⨬����, ����� ��ப� > 0
        xor di,di
        cmp di,ds:[bx]
        jz short BinToS0
        mov si,bx ;ds:si - dest. string.
;�஢�ઠ �� �����⨬���� ��⥬� ��᫥���.
        mov bx,ax
        mov al,cl
        mov ah,cl
        and ah,00000011b
        cmp ah,0x02     ;add types later
        jnc short BinToS0
        mov cl,0x02
        and al,01111100b
        shr al,cl       ;optimize...
        cmp al,MIN_NUMBER_BASE
        jc short BinToS0
        cmp al,MAX_NUMBER_BASE
        jnbe short BinToS0
        xchg bx,ax  ;bl:base, bh:type
        mov cx,bx   ;save for sign
        mov di,si
        add di,[si]     ;end of string.
        add di,[si+0x02]
        dec di
        lea bx,num_base_table
        std          ;right to left.
        add si,[si+0x02]    ;text start.
        or ch,ch
        jnz short BinToS2
BinToS1:xor ah,ah       ;8-bit divider
        div cl          ;ax/cl
        xchg ah,al      ;al-remainder
        xlat            ;al to digit
        stosb
        cmp di,si
        jc short BinToS0
        xchg ah,al
        or al,al
        jnz short BinToS1
        jmp short BinToS0
BinToS2:xor ch,ch    ;16-bit number
BinToS3:xor dx,dx
        div cx
        xchg ax,dx
        xlat
        stosb
        cmp di,si
        jz short BinToS0
        xchg ax,dx
        or ax,ax
        jnz short BinToS3
BinToS0:pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;��ଠ� ��饩 16-� ��⭮� ��ப�.
string_test   dw 0x000C ;������ ��ப�.
text_offs    dw 0x0008 ;���饭�� �� ���஬� ��稭����� �����।��⢥��� ⥪��.
reserver       db 0x04 dup (0)
;�ਬ�� १�ࢨ஢���� ��� ��ࠡ�⪨ ��� ��ਠ樨 �㭪樨 ����.
string_text  db 'Hello World!'

;��楤�� ���� ��ப� � ⥪�⮢� ����.
;��ଠ� ��ப� ��������� �.���.
;�ᯮ��㥬 �������� ����⠭�� ��࠭�.
;�室.
;al ������ �� ��ਧ��⠫� ��� ��࠭�祭��.
;ah ������ �� ���⨪���, �।�� ⮫쪮 ����.
;ds:bx      ���� �������� ��ப�.
;�஢�ઠ �� �����⨬���� ⮫쪮 � �।���� ����.

PrintTextString:
        pushf
        push ax
        push cx
        push dx
        push si
        push di
        push es

        ;mov dx,ax   ;����塞 ᬥ饭�� �� ���न��⠬.
        ;mov al,dh
        ;mov cl,SCR_SIZE_WIDTH
        ;mul cl
        ;xor dh,dh
        ;add ax,dx
        ;shl ax,1       ; 90-100 clk.


;������ ���� ᬥ饭�� �� ���न��⠬, ��⮤��� ᤢ����.
        mov dx,ax
        xchg al,ah
        xor ah,ah
        mov cl,0x03     ;char+atr*2 = 2 bytes
        shl ax,cl       ; 8+4*4 clk.
        mov di,ax
        mov cl,0x02
        shl ax,cl
        add di,ax       ; y ���᫥�
        xor dh,dh
        ;shl dx,0x01
        add di,dx
        mov ax,di ; 80 clk.

        mov dx,SCR_BUFF_SIZE_W
        cmp ax,dx;�஢��塞 �� ��९������� ����.
        ja short PrTxtS0  ;���㠫 ���.2-46

;�஢�ઠ �� ������ ��ப�. �᫨ ��������, ������뢠�� 墮��.

        mov cx,ds:[bx]
        jcxz PrTxtS0 ; �������� ���������
        mov di,ax
        shl di,0x01
        sub dx,ax    ; compare word
        cmp dx,cx
        jnc PrTxtS1
        mov cx,dx    ;����� ����� ��ப�, ᪫쪮 ���������.

;�����।�⢥��� �뢮��� �����.
PrTxtS1:mov si,bx
        add si,ds:[bx+0x02]  ;si ⥪�� ��ப�.
        mov ax,SCR_BUFF_ADDR
        mov es,ax
PrTxtS2:movsb
        inc di
        loop PrTxtS2
PrTxtS0:pop es
        pop di
        pop si
        pop dx
        pop cx
        pop ax
        popf
        ret






;�����।�⢥��� ᠬ ⥪�� � ���ᨢ, ����஫� �� ������� �� ��஭� �맮��.
;��楤�� ���⪨ ⥪�⮢��� ���� ��࠭�.
;ah   ��ਡ�� ᨬ���� �� �ଠ�� ⥪�⮢��� ��࠭�.
;al   ᨬ��� ��� ����������.
;bl   ��⮢� ����.
;0    �ᯮ�짮���� �� ᨬ���� ��� ����������.
;1    �ᯮ�짮���� �� ��ਡ�� �� ���⪨ ��/���.
;2-7  १��.

ClearTextScreen:
        pushf
        push cx
        push di
        push es
        mov cx,SCR_BUFF_SIZE_W
        mov di,SCR_BUFF_ADDR
        mov es,di
        xor di,di
        cld
        test bl,00000001b       ;5 clk
        jz ClTxtS2
        ;if (!(bl & 0x01)) go to ClTxtS0
ClTxtS1:stosb
        inc di
        loop ClTxtS1
        mov cx,SCR_BUFF_SIZE_W
        xor di,di
ClTxtS2:test bl,00000010b
        jz ClTxtS0
        xchg al,ah
        inc di
ClTxtS3:stosb
        inc di
        loop ClTxtS3
ClTxtS0:pop es
        pop di
        pop cx
        popf
        ret

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

string_src   db 0x01, 0x02, 0x03, 0x04
string_dst   db 0x05, 0x06, 0x07, 0x08

;��頭�� �5. ������樨 ��䬥⨪� � 䫠��.
      ;���⠭��:
        mov ax,0x0000
        mov bx,0x0000
        mov al,0x28
        mov ah,0x31
;sub dst,src - ���⠭��.
        sub  ah,al       ;reg:reg, 3 clk;
        sub ah,[byte_b] ;reg:mem, 16 clk+EA;
        sub al,0x22     ;acc(reg):imm, 4 clk;
        sub [byte_b],al
        mov al,[byte_b]
        sub byte [byte_b],0x01 ;mem:imm, 17 clk+EA;
        mov al,[byte_b]
;sbb dst,src - ���⠭�� � ��񬮬 䫠�� CF.
        mov ax,0x1001
        mov bx,0x0503
        sub al,bl
        sbb ah,bh       ;������� १���� 0AFE(-2);
;dec dst - ���६��� ��񬭨�� �� 1.
        dec al       ;reg8  3 clk, 2 bytes;
        dec ax       ;reg16 2 clk, 1 bytes;
        mov al,[byte_a]
        dec byte [byte_a]       ;15 clk+EA
        mov al,[byte_a]
;neg dst - �ନ��� ����⥫쭮� �᫮.
        mov al,0x01
        neg al     ;2 clk
        mov ah,[byte_b]
        neg byte [byte_b]       ;16 clk+EA
        mov ah,[byte_b]
        mov al,0x00
        neg al     ;CF=0;
;cmp dst,src - �ࠢ�����.
        mov ax,0x0102
        cmp al,ah               ;reg:reg, 3 clk;
        cmp ax,0x0001           ;reg:imm, 4 clk;
        cmp byte [byte_a],0x01       ;mem:imm, 10 clk+EA;
        cmp al,[byte_a]         ;reg:mem. 9 clk+EA;
;aas,das - ��ࠢ������� ��� ���⠭�� � ���⭮.
      ;���������:
;mul src - 㬭������ ��� �����.
;imul src - 㬭������ � ������.
        mov al,0x02
        mov bl,0x03
        mul bl     ;70-77 clk, 2 bytes;
        mov bx,0x1000
        mul bx     ;118-133 clk
        mov al,0x01
        mul byte [byte_b]       ;76-83+EA
        mov ax,0x1000
        mul word [word_a];124-139+EA
        mov al,-0x05
        mov bl,0x02
        imul bl
      ;�������:
;div src - 楫��᫥���� ������� ��� �����.
;idiv src - 楫��᫥���� ������� � ������.
        mov ax,0x0100
        mov bl,0x10
        div bl     ;al - १����, ah - ���⮪. 80-90 clk.
        div byte [byte_b]
        mov dx,0x0001
        mov bx,0xAAAA
        div bx       ;144-162 clk
        mov dx,0x0001
        div word [word_d]
        ;idiv �������祭 imul.
        ;mov bl,0x01    ;������ 室 �� ������ � ����������)))
        mov bx,0x0001   ;᫥��� �� ࠧ��୮���� ���࠭���.
        mov ax,0x0200
        mov dx,0x0000
        ;div bl         ;���࠭� �����祭�� ������ ������ ��⭮� �� �������.
        div bx
;cbw al, cwd ax - ���������� ���� � ᫮�� ��� ᫮�� � ������� ᫮��.
        mov al,-0x05
        cbw         ; 2 clk; ��⨬�����
        cwd         ; 5 clk;
;�����᪨� ����樨:
;not dst - ���栭��, �����᪮� ��.
        mov al,0x0F
        not al          ;3 clk
        mov ah,[byte_a]
        not byte [byte_a] ;16 clk+EA
        mov ah,[byte_a]
;and dst,src - �����᪮� �.
        mov al,0xAA
        mov ah,0x0F
        and al,ah       ;reg:reg, 3 clk
        and al,0x03     ;acc:imm, 4 clk
        and [byte_a],ah ;mem:reg, 16 clk+EA
        mov bh,[byte_a]
        and byte [byte_a],0xFF ;mem:imm, 17 clk+EA
        mov bh,[byte_a]
;or dst,src - �����᪮� ���.
        mov dl,0xAA
        mov dh,0x0F
        or  dl,dh       ;reg:reg, 3 clk
        or  al,0x03     ;acc:imm, 4 clk
        or  [byte_a],dh ;mem:reg, 16 clk+EA
        mov bh,[byte_a]
        or  byte [byte_a],0xFF ;mem:imm, 17 clk+EA
        mov bh,[byte_a]
;xor dst,src - �����᪮� ���.���.
        mov dl,0xAA
        mov dh,0x0F
        xor dl,dh       ;reg:reg, 3 clk
        xor al,0x03     ;acc:imm, 4 clk
        xor [byte_a],dh ;mem:reg, 16 clk+EA
        mov bh,[byte_a]
        xor byte [byte_a],0xFF ;mem:imm, 17 clk+EA
        mov bh,[byte_a]
;test dst,src - �����᪮� � ��� ��࠭���� १����.
        mov dl,0xAA
        mov dh,0x0F
        test dl,dh       ;reg:reg, 3 clk
        test al,0x03     ;acc:imm, 4 clk
        test [byte_a],dh ;mem:reg, 9 clk+EA
        mov bh,[byte_a]
        test byte [byte_a],0xFF ;mem:imm, 11 clk+EA
        mov bh,[byte_a]
;��⮢� ᤢ���.
;sal, shl: dst,counter - ᤢ�� �����
        mov cl,0x04    ;���-�� ᤢ����.
        mov ax,0x0101
        sal ah,1       ;2 clk
        shl al,1
        sal al,cl    ;8 clk + 4 �� ���
        shl byte [byte_a],cl ;20 clk+EA+4 �� ���
        mov al,[byte_a]
        sal byte [byte_b],1    ;15 clk+EA
        mov al,[byte_b]
;sar, shr: dst,counter - ᤢ�� ��ࠢ�
        mov cl,0x04    ;���-�� ᤢ����.
        mov ah,-0x05
        mov al,0x80
        shr al,cl    ;8 clk + 4 �� ���
        sar ah,cl
        sar byte [byte_a],cl ;20 clk+EA+4 �� ���
        mov al,[byte_a]
;����� ��⮢.
;rol\ror dst,counter - ���� �����,��ࠢ�.
;rcl\rcr dst,counter - ���� ��� �����,��ࠢ� � 䫠��� ��७��.
        mov cl,0x04    ;���-�� ᤢ����.
        mov ah,0x01
        mov al,0x80
        rol al,cl    ;8 clk + 4 �� ���
        rol ah,1
        ror ah,1
        ror al,cl
        ror byte [byte_a],cl ;20 clk+EA+4 �� ���
        mov al,[byte_a]
        mov ah,0x07
        mov al,0xE0
        mov cl,0x02
        rcr ah,cl
        rcl al,cl
        rcr al,cl
        rcl ah,cl
        rcl byte [byte_a],cl
        mov al,[byte_a]
;��頭�� �4. ������樨 ��䬥⨪� � 䫠��.

      ;��������:
        mov dl,0x34
        mov dh,0x12
        add dl,dh  ;reg:reg, 3 clk;
        add dl,byte [byte_a] ;reg:mem, 9 clk+EA;
        add dl,0x03     ;reg:imm, 4 clk;
        mov al,[byte_a]
        add [byte_a],dl ;mem:reg, 9 clk+EA;
        mov al,byte [byte_a]
        mov ah,0x00    ;add 16 bit, using 8 bit operands;
        mov al,0x81
        mov bl,0xA9
        mov bh,0x0A
        add al,bl      ;䫠� ��७�� ����祭
        adc ah,bh      ;�ᯮ��㥬 䫠� ��७��
        pushf
        mov ah,0x00
        sahf       ;���㫨� 䫠��.
        mov al,-0x50
        mov ah,-0x40
        add ah,al  ;䫠� ��९������� ���祭 � ��⠭����� 䫠� �����
        popf
        mov al,[byte_a]
        inc al         ;㢥��祭�� �� 1, 3 ⠪�.
        inc dx         ;2 ⠪�
        inc byte [byte_a]   ;15+�� ⠪⮢
        add ax,word [byte_a]
        mov al,[byte_a]
;BCD - ����筮-������� ���, � ������ ���㡠�� �࠭���� ��� �� 0 �� 9.
;�ਬ��: 74 = 0111 0100 - ������ ���(��⮢�� �।�⠢�����)
        mov al,0x30
        aaa        ;�� 㯠��������� � �����筮� �᫮
        add al,0x05
        daa        ;�� ����筮�� � 㯠��������.
        jmp return

;��頭�� �3.
;���⥪��� 8086, ⨯� ����樨 � ������樨 ��६�饭�� ������.
;�������� ��饣� �����祭��.
        mov al,0x01  ;immed, 4 clk
        mov ah,al    ;reg:reg, 2 clk
        mov ax,[word_c] ;10 clk
        mov dl,[byte_a] ;8 clk+EA
        mov [word_c],word 0xABCD ;10 clk+EA
        mov bx,[addr_segm]
        mov es,bx
        mov es,[addr_segm]  ;8 clk+EA
        push cs             ;11 clk
        push word [addr_segm];17 clk
        pushf
        lahf    ;load flag to ah
        sahf    ;store ah to flag
        popf
        pop bx
        pop ax
        xchg ax,bx   ;acc-reg, 3 clk
        xchg dx,[word_b]; reg-mem, 17 clk+EA
        xchg bx,dx      ;reg-reg, 4 clk
        mov al,0x03
        lea bx,bytes_t
        xlat
;���᫥��� ��䥪⨢���� ���� ��ꥪ�.
        lea si,[bytes_t]    ;2 clk+EA
        mov al,[si+3]
        les di,ds:[words_t]
        mov [addr_offs],si
        mov ax,ds
        mov [addr_segm],ax
        lds bx,ds:[addr_offs]
        mov al,[bx]
;
        jmp return
byte_a      db 0x01
byte_b      db 0x02
word_d      dw 0x0104
word_b      dw 0x1A2B
word_c      dw 0x3C4D
addr_offs   dw 0x0505
addr_segm   dw 0x6060
bytes_t     db 0x01, 0x02, 0x03, 0x04
words_t     dw 0x1A1B, 0x2C2D, 0x3E4F

;��頭�� �2.
;���⥪��� 8086, ⨯� �����樨 � ������樨 ��६�饭�� ������.
;��⮤� � ⨯� ���樨 ������.

        mov dx,0x0101;�����।�⢥���� ������.
        mov ax,dx    ;������஢�� ������, 2 ⠪�.
        mov bx,ds:[bytes_table]     ;�ࠬ�� ������ �� �����, 8 ⠪⮢.
        mov ax,ds:0x0100
        mov bx,bytes_table
        mov dh,[bx]       ;ds ᥣ���� �� 㬮�砭��.
        mov dl,ds:[bx+2]  ;���� + ᬥ饭��
        mov di,0x003
lab_1:  mov cl,es:[di]
        mov bp,words_table
        mov ax,cs:[bp+di] ;��������� ᥣ���� + 2 ⠪�, ���� + ������.
        ;���� + ������ + ᬥ饭��, ���祭� ����� �� ⠪⠬.
        mov ax,ds:[bp+di+1] ;��� ���� ⮫쪮 ॣ�����: BX, BP, SI, DI.
;���室�� � ��騬 �������� ��६�饭�� ������
        jmp return

bytes_table     db 0x01, 0x02, 0x03, 0x04
words_table     dw 0x1A1B, 0x2C2D, 0x3E4F


;��頭�� �1. ���⥪��� 8086 � �ணࠬ�� "�ਢ�� ���!", � ������ � ���஬.
        ;��⠭���� ����� � ������.
        mov ah,02h
        mov bh,0x00
        mov dx,0x0A08
        int 10h

        ;���⠥� �⤥��� ᨬ���.
        mov cx,0x05
        mov ah,0x0A
        mov al,0x43
        xor bh,bh
        int 10h

        ;���⠥� ��ப� � ������
        mov ax,0x1300
        xor bh,bh
        mov bl,00011111b
        mov cx,0x000C
        mov bp,string
        int 10h

        ;�뢮� ��ப� � ����� ��࠭�.
        mov ax,SCR_BUFF_ADDR
        mov es,ax
        mov di,0x0100
        mov si,string
        mov bh,00101111b
Prt_1:  mov bl,ds:[si]
        or bl,bl
        jz Prt_2
        mov es:[di],bx
        inc si
        add di,0x02
        jmp Prt_1
Prt_2:  mov ah,0x09
        mov dx,string
        push cs
        pop ds
        int 21h
return:

        pop dx
        pop cx
        pop bx
        pop ax
        ret


string  db 'Hello World!&', 0
word_a  dw 0x1111
dword_b dd 0x11111111
reserv  db 32 dup (0)
