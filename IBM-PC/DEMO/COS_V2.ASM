; Демка для изучения ассемблера и архитектуры процессора Intel 8086/87.
;Несколько анимированных эффектов, сколько успеем и что сможем. :)
; Дата старта: 01.06.2021.
; Дата выхода проекта: 31.12.2021 ну или раньше, как будет удобней(фестиваль).

CPU 8086                                ;8087 математический сопроцессор.

;Глобальные константы для демонстрации и общие настройки.

%include "vga-x.asm"

DEMO_RAND_INIT  EQU 0FA0Fh              ;Инициализация генератора на старте.
DEMO_FADE_SPEED EQU 001h                ;Скорость работы эффекта появления и
                                        ;ухода экрана. Вычитание из 64
                                        ;интенсивности всех цветов.
        org 00100h
        pushf

        call near VXSetModeX            ;Init gfx, set pages and clear VRAM.
        xor al,al
        call near VXSetActDispPage
        mov al,00001111b
        call near VXSetPlanes
        xor al,al
        ;mov al,90h
        mov ah,00001111b
        call near VXClearVRAM
        call near VXLoadFontBIOS        ;Init default font.
        mov ax,DEMO_RAND_INIT
        call near RandomSimple          ;Random init.
        ;call near VXSetFullDAC
        mov ax,00100h
        call near VXClearVRAM
        call near CosineAnimation
        ;call near ScreenFadeOut
DemoR:  mov ah,00h                      ;Press any key.
        int 16h
        popf
        ret

;3. Анимация косинуса с использованием математического сопроцессора.

; Косинус с градиентом в реальном времени на математическом сопроцессоре 8087.
;Анимация тригонометрической функции косинус и стандартной палитры цвета
;рассчитывается по классической формуле через тангенс с учетом знака. Шаг,
;амплитуда и градиент от времени анимации настраиваемая.
; Точность вычислений: 32-битная, реальная, округление к ближайшему целому.

; Комментарий от Данилы и чуть более быстрый вариант первой версии (80287).
;Сохраняем регистр SWR сопроцессора в память, чтобы потом считать в AX.
;На старших моделях FPU можно сразу сделать fstsw ax
;       fstsw word [fpu_state]
;       mov ax,[fpu_state]
; Загружаем флаги из регистра AH, флаги C0, C2, C3 из FPU при этом попадают
;в CF, PF, ZF соответственно. После этого можно использовать привычные
;условные переходы, предполагая, что fcom всегда сравнивает ST0 с операндом,
;то есть фактически имеет вид: fcom ST0, argument
;       sahf
;       jbe short DrSC1                 ; ST0 <= Src (pi/2)
;       fcom dword [pi_64]              ;
;       fstsw word [fpu_state]
;       mov ax,[fpu_state]
;       sahf
;       ja short DrSC1                  ; ST0 > Src (pi*6/4)

;Flags bits using compare.
;Operands:        C3:     C2:   C0:     Word to compare bit or mask:
;ST(0) > SRC      0       0     0       00000h
;ST(0) < SRC      0       0     1       00100h
;ST(0) = SRC      1       0     0       04000h
;Incomparable     1       1     1       04500h

COS_TIMER       EQU 000D0h              ;Общий таймер для выравниваия времени.
;COS_CENTER_Y    EQU 078h                ;120 для режима X, центр экрана.
COS_OFFS_Y       EQU 00078h              ;Center for COS graphics.
COS_HEIGHT      EQU 040h
COS_WIDTH       EQU 00140h    ; 0013Bh              ;314 pixels for better PI. +1 for st.
                                        ;13A - is correct value.
COS_RED         EQU 000h                ;Indexes for default color palette.
COS_GREEN       EQU 040h                ;Start component.
COS_BLUE        EQU 080h
COS_TEXT_X1     EQU 00000h              ; Позиции и цвета вывода текста на
COS_TEXT_Y1     EQU 00018h              ;экране, Сначала идет крупный заголовок.
COS_TEXT_X2     EQU 00000h
COS_TEXT_Y2     EQU 000B0h
COS_TEXT_NEXT   EQU 026h                ;Upper part of text lenght.
COS_TEXT_C1     EQU 0007Fh
COS_TEXT_C2     EQU 000FFh

control_reg     dw 00000h               ; Состояние 8087.
value_x         dd 0.00
cos_x           dd 0.1                 ;Full 2PI.
cos_x_step      dd +0.00005
cos_x_min       dd 0.1
cos_x_max       dd 0.2
cos_y           dd 04.0               ;Height of cosine.
cos_y_int       dw 00004h
cos_y_step      dd +1.0
cos_y_min       dd 4.0
cos_y_max       dd 16.0               ;Size of draw cos in pixels.
fpu_data        dw 10h dup (00000h)
cos_table       dw GFX_SCR_WIDTH dup (00000h)
offset_x_anim   dd 0.04                 ;Offset X for every frame.
anim_accel      dd 0.01
sign_neg        dd -1.0
pi_00           dd 0.00
pi_14           dd 0.79
pi_24           dd 1.57
pi_34           dd 2.36
pi_44           dd 3.14
pi_54           dd 3.93
pi_64           dd 4.71
pi_74           dd 5.50
pi_84           dd 6.28                 ;May be plus 1 or equal.

anim_cos_txt    dw 00CAh
                dw 0004h
                db '  REALTIME MATH ON  '
                db '  8087 COPROCESSOR'            ;Add space to config.
                db ' Color animation of trigonometric cosine'
                db 'using slow formula of tangent and '
                db 'square root, but fully on mathematical  '
                db 'coprocessor. 8086 became an artist...:) '
                db '                                        '
                ;db ' Precision: 32-bit single, real.        '

CosineAnimation:
        pushf                           ; Сохранение регистров в стек.
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        call near VXSetFullDAC          ; Инициализация полной стандратной
        xor ax,ax                       ;палитры цветов VGA, как в Intro.
        call near VXSetActDispPage      ; Используем только 0-ю видеостраницу.
        mov word [vx_cursor_x],COS_TEXT_X1
        mov word [vx_cursor_y],COS_TEXT_Y1
        mov byte [vx_font_color],COS_TEXT_C1

        finit                           ; Инициализация 8087, правка для жел.!
        fstcw word [control_reg]        ;CR to memory, with await.
        and word [control_reg],0F0FFh   ;Reset all masks, trunc only save res.
        fldcw [control_reg]             ;Round to near and 32-bits float.
        mov bp,00080h ;ANIM_COS_TIMER           ;Animation cycle or debug.
        xor si,si                       ;Text offset.

DrSCC:  mov cx,GFX_SCR_WIDTH            ;Fix bug or leave as is. :)
        mov di,cos_table                ; Всегда пишем какой именно БАГ! :)

DrSC0:  fld dword [value_x]             ;Draw full cosinus using CX counter.
        fptan                           ;Top after, ST0 is 1.
        fincstp                         ;Stack top to ST0.
DrSC2:  fst ST1                         ;Save tan ST1 to ST0.
        fmul ST0,ST1                    ;tg^2 ST0 * ST1.
        fdecstp                         ;Was ST7 = 1 or use fld1.
        fadd ST0,ST1                    ;(tg^2 + 1), ST0 + ST1.
        fld1                            ;ST0 = 1.
        fdiv ST0,ST1                    ;1 / (tg^2 + 1), ST0 / ST1.
        fsqrt
        fld dword [value_x]             ;Store position x and check for sign.
        fcom dword [pi_24]
        fstenv [fpu_data]               ;C0,C1 == 0 for ST0 > DATA, 8,10 bits.
        test word [fpu_data + 002h],00500h
        jnz short DrSC1                 ;Page 73.
        fcom dword [pi_64]
        fstenv [fpu_data]
        test word [fpu_data + 002h],00500h
        jz short DrSC1
        fincstp                         ;Remove X position, store neg.
        fchs                            ; *-1! Работает! :)
        ;fld dword [sign_neg]
        ;fmul ST0,ST1                    ;Change sign of result cosec.
        jmp short DrSCB
DrSC1:  fincstp                         ;To result of cosec.
DrSCB:  fmul dword [cos_y]
        frndint                         ;Convert to intger.
        fistp word [di]                 ;Save to table and next X.
        add di,00002h

        fld dword [value_x]             ; Смещение по координате Х.
        fadd dword [cos_x]
        fcom dword [pi_84]              ;If period is more or equal than 2Pi.
        fstenv [fpu_data]               ;SR - second word, 14 bit, equal C3.
        mov ax,[fpu_data + 002h]
        test ax,04000h                  ;May be not the case.
        jnz short DrSCA1
        test ax,00500h
        jnz short DrSCA                 ;Add because other bits set/reset.
DrSCA1: fincstp
        fldz                            ;To zero as cycle, sub 2Pi.
DrSCA:  fstp dword [value_x]            ;Next x.
        loop DrSC0

; Полное рисование косинуса с градинтом по таблице.
        call near VXWaitVSync           ;Starting drawing.

        push si                         ; Или удалить напрмую без вызов.
        mov si,GFX_PLANE_SIZE_B / 3
        mov di,GFX_PLANE_SIZE_B / 3 * 2
        xor al,al
        mov ah,00000001b
        call near VXClearVRAM2
        pop si

        mov di,cos_table                ;Draw full cosinus.
        xor dx,dx
        cmp bp,00002h
        jnz short DrSCW
        mov al,03Fh                     ;Only cosinus without colors.
        jmp short DrSC3
DrSCW:  mov al,07Fh
DrSC3:  mov cx,COS_OFFS_Y               ;BX = Y.
        sub cx,[di]                     ;Or ADD.
        call near VXSetPixel            ; Рисование пикселя Косинуса.
        ;jmp short DrSCU

; Clear part of screen or draw an 'glowing' of cos.
        ;xor al,al
        mov al,0C0h                     ;First variant only one color.
        mov ah,080h
        sub al,[cos_y_int]
        sub al,[cos_y_int]
        sub ah,[cos_y_int]
        sub ah,[cos_y_int]
        xor bx,bx
DrSCT:  inc bx                          ; Оичстка сверху.
        push cx
        add cx,bx
        call near VXSetPixel
        pop cx
        push cx
        sub cx,bx
        xchg al,ah                      ; Смена цветов вверх и вниз.
        call near VXSetPixel
        xchg al,ah
        pop cx
        cmp al,080h                     ; До 128-го цвета.
        jbe short DrSCV
        dec al
DrSCV:  cmp ah,040h
        jbe short DrSCX
        dec ah
DrSCX:  cmp bx,00010h                   ; Размерность очистки сверху.
        jnz short DrSCT

DrSCU:  add di,00002h
        inc dx
        cmp dx,COS_WIDTH
        jnz short DrSCW                 ; Замыкаем цикл отрисовки.

        ;jmp short DrSCH

; Изменение динамики высоты косинуса.

        fld dword [cos_y]               ;STP = ?
        fadd dword [cos_y_step]
        fcom dword [cos_y_min]          ;If Y less than MIN.
        fstenv [fpu_data]               ;SR - second word, 14 bit, equal C3.
        test word [fpu_data + 002h],00100h
        jnz short DrSCD
        fcom dword [cos_y_max]          ;If Y more than MAX.
        fstenv [fpu_data]
        test word [fpu_data + 002h],04500h
        jnz short DrSCE                 ;All bits must be reset.
DrSCD:  fincstp                         ;If Y is out of range, then change
        fld dword [cos_y_step]          ;sign of step.
        fmul dword [sign_neg]           ; ! FCHS но не точно, нет вершины.
        fstp dword [cos_y_step]
DrSCE:  fld dword [cos_y]
        fadd dword [cos_y_step]
        fst dword [cos_y]               ;STP = 0?
        ;fabs
        frndint
        fistp word [cos_y_int]          ;integer.

        ;xor dx,dx
        ;mov cx,[cos_y_int]
        ;mov al,07Fh
        ;call near VXSetPixel
        jmp short DrSCI

; Динамическое смещение по координате Х, и дальше.

DrSCH:  fld dword [cos_x]
        fadd dword [cos_x_step]
        fcom dword [cos_x_min]
        fstenv [fpu_data]
        test word [fpu_data + 002h],00100h
        jnz short DrSCF
        fcom dword [cos_x_max]
        fstenv [fpu_data]
        test word [fpu_data + 002h],04500h
        jnz short DrSCG
DrSCF:  fincstp
        fld dword [cos_x_step]
        fmul dword [sign_neg]
        fstp dword [cos_x_step]
DrSCG:  fld dword [cos_x]
        fadd dword [cos_x_step]
        fstp dword [cos_x]

; Печать с ожиданием сигнала, сюда перенести часть вычисления на нечетный кадр.
DrSCI:  call near VXWaitVSync           ;Print char.
        mov dx,si                       ;DX - text offset.
        mov bx,anim_cos_txt
        mov al,001h
        mov ah,11000001b
        cmp dx,COS_TEXT_NEXT
        jc short DrSCP1
        mov ah,11000000b
        jmp short DrSCP2
DrSCP1: call near VXPrintString
        inc si
        cmp si,COS_TEXT_NEXT
        jne short DrSCP2
        mov byte [vx_font_color],COS_TEXT_C2
        mov word [vx_cursor_x],COS_TEXT_X2
        mov word [vx_cursor_y],COS_TEXT_Y2

DrSCP2: ;fldz
        ;fstp dword [value_x]
        dec bp
        jnz DrSCC                       ; Замыкание цикла анимации.

        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

%include "vga_sys.asm"
%include "dac.asm"
%include "pixel.asm"
%include "random.asm"
%include "print_g.asm"
%include "lines.asm"
;%include "fm_opl.asm"
