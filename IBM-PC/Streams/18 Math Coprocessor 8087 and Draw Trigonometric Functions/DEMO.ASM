;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;Вещание 18. Математический сопроцессор 8087, синус-косинус и палитра.

;План вещания, 07.11.2021.

;- немного истории сопроцессора 8087;
;- процедура установки полного набора базовых цветов ВГА в палитру;
;- расчет синуса и косинуса на ширину экрана с учетом палитры.

;Демка для изучения ассемблера и архитектуры процессора Intel 8086/87.
;Несколько анимированных эффектов, сколько успеем и что сможем. :)
;Дата старта: 01.06.2021.
;Дата выхода проекта: 31.12.2021 ну или раньше, как будет удобней.

;Общее описание и платформа(подробнее в файле 'readme.dos').

;Платформа: ДОС-совместимая от условной версии 5.0, реальный режим адресации.
;Процессор: только 8086(88) и математический сопроцессор 8087.
;Основная память: 64Кб для кода и стека(модель минимальная). Остальные данные
;желательно уложить в 512Кб. Для запуска на "тяжелых" ДОС конфигурациях.
;Расширенная память: через драйвер XMS, не более 16Мб(не защищенный режим).
;Графический адаптер: IBM VGA, 256Кб, 6 бит на цвет, палитра 2^18 цветов,
;графический Х-режим, 320x240x8бит на цвет по таблице.
;Звуковая плата: Adlib/SBPro(OPL2/OPL3), FM - частотная модуляция.
;Формат файла: .COM, 64Kb, использовать функции ДОС-а для запроса памяти.

CPU 8086                                ;8087 as math. coprocessor.

%include "VGA-X.ASM"

DRAW_OFFS_X             EQU 0003h       ;Offset for graphics horizontal.
DRAW_CENTER_Y           EQU 078h        ;120 for mode X.
DRAW_OFFS_Y_SIN         EQU 0058h       ;Center for SIN graphics.
DRAW_OFFS_Y_COS         EQU 0098h       ;Center for COS graphics.
DRAW_FUNC_SIZE          EQU 020h        ;Size of draw sin,cos in pixels.
RED_DEF_INDEX           EQU 000h        ;Indexes for default color palette.
GREEN_DEF_INDEX         EQU 040h
BLUE_DEF_INDEX          EQU 080h
BW_DEF_INDEX            EQU 0C0h

        org 100h                        ;PSP.
        pushf

        call near VXSetModeX            ;Init gfx.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        ;mov ax,0FA0Fh
        ;call near RandomSimple          ;Random init.

        call near VXSetFullDAC
        finit
        fstcw word [control_reg]
        mov ax,[control_reg]
        and ah,11110000b
        mov [control_reg],ax
        fldcw [control_reg]     ;round 32-bits
        mov cx,013Ah
        xor bx,bx
DrSC0:  push cx                 ;main
        fld dword [start_x]
        fptan
        fincstp
        fst dword [value_tg]
        fld1
        fdiv ST0,ST1
        fstp dword [value_ctg]
        mov al,02h
        lea si,value_tg
        lea di,screen_y_sin
DrSC2:  fld dword [si]
        fst ST1
        fmul ST0,ST1            ;tg^2 or ctg^2
        fld1
        fadd ST0,ST1            ;(tg^2 + 1) or (ctg^2 + 1)
        fld1
        fdiv ST0,ST1            ;1 / (tg^2 + 1) or 1 / (ctg^2 + 1)
        fsqrt
        cmp al,02h
        jne short DrSC5
        cmp bx,04Eh             ;первая четверть
        jc short DrSC1
        cmp bx,0EDh
        jnc short DrSC1
        jmp short DrSC4
DrSC5:  cmp bx,009Dh            ;for sin(x)
        jc short DrSC1
DrSC4:  fld dword [sign_neg]
        fmul ST0,ST1            ;умножить на -1
DrSC1:  fimul word [screen_size_y]
        frndint
        fistp word [di]
        add si,004h
        add di,0002h
        dec al
        jnz short DrSC2
        fld dword [start_x]
        fadd dword [step_x]
        fstp dword [start_x]

        mov al,02h
        lea si,screen_y_sin

        mov bp,DRAW_OFFS_Y_SIN
DrSC3:  push bx
        push ax
        mov cx,bp
        sub cx,[si]
        mov [si],cx             ; y coordinate
        mov dx,bx
        add dx,DRAW_OFFS_X
        ;mov al,0FFh
        ;call near VXSetPixel

        mov bl,[si]
        mov bh,bl               ; y coordinate
        sub bh,DRAW_FUNC_SIZE
        mov ah,cl               ; x coordinate
DrSC7:  cmp bl,bh
        jz short DrSC6
        mov al,bl
        sub al,bh
        add al,GREEN_DEF_INDEX + 31
        call near VXSetPixel
        dec bl
        dec cx
        jmp short DrSC7
DrSC6:  mov cl,ah
        mov bl,[si]
        mov bh,bl
        add bh,DRAW_FUNC_SIZE
DrSC8:  cmp bl,bh
        jz short DrSC9
        mov al,bh
        sub al,bl
        add al,BLUE_DEF_INDEX + 31
        call near VXSetPixel
        inc cx
        inc bl
        jmp short DrSC8
DrSC9:  pop ax
        pop bx
        add bp,DRAW_FUNC_SIZE * 2
        add si,0002h
        dec al
        jnz short DrSC3
        pop cx
        inc bx
        dec cx
        jnz DrSC0


Dem0:   mov ah,00h                      ;Press any key.
        int 16h
        popf
        ret

;Parameters for FPU.

control_reg     dw 0000h
start_x         dd 0.0
step_x          dd 0.02
sign_neg        dd -1.0
pi_2            dd 1.57
value_tg        dd 0.0
value_ctg       dd 0.0
screen_y_sin    dw 0h
screen_y_cos    dw 0h
screen_size_y   dw DRAW_FUNC_SIZE
fpu_data        dw 10h dup (0)

; Функция установки (замены) одиночного цвета в палитре видеоадаптера.
; Назначает цвету с заданным индексом новые компоненты: Read, Green, Blue.
; Вход:
; AL    индекс цвета
; AH    Red
; DL    Green
; DH    Blue
; VXSetPalColor:

;Set all possible VGA colors of each componet RGB in 6 bits colors(0..63).

VXSetFullDAC:
        pushf
        push ax
        push dx
        xor ax,ax
        xor dx,dx
SetFD0: call near VXSetPalColor
        cmp al,40h
        jnc short SetFD1
        inc ah            ;next red
        and ah,00111111b
        jmp short SetFD4
SetFD1: cmp al,80h
        jnc short SetFD2
        inc dl            ;next green
        and dl,00111111b
        jmp short SetFD4
SetFD2: cmp al,0C0h
        jnc short SetFD3
        inc dh            ;next blue
        and dh,00111111b
        jmp short SetFD4
SetFD3: inc ah
        inc dl
        inc dh
SetFD4: inc al
        test al,al
        jnz  short SetFD0
        pop dx
        pop ax
        popf
        ret


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

;3. Демонстрация организации памяти, с освобождением под ДОС-вызовы.

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

;4. Синхронизация по лучу, смена видео-страниц и выбор плоскости(вспом).
;Сказать про драйвера на всякий случай и настройки ДОСБокса.
;Параметры: фуллдабл=истина, ВСИНК для ДОСБокс включен.

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
;%include "rnd_s.asm"
