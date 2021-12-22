;Release version of demo with all effects and libraries.

;Small Demo by 8-Bit Tea Party, 2021.

;Credits and thanks.

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

;Глобальные константы для демонстрации и их настройки.


DEMO_RAND_INIT  EQU 0FA0Fh              ;Инициализация генератора на старте.
DEMO_FADE_SPEED EQU 001h                ;Скорость работы эффекта появления и
                                        ;ухода экрана. Вычитание из 64
                                        ;интенсивности всех цветов.



        org 100h                        ;PSP.
        pushf

        mov ah,0Fh                      ; get current mode
        int 10h
        mov [prev_video_mode],al

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


;Testing Intro.

        ;mov ax,0A000h
        ;mov es,ax
        ;mov si,9000
        ;mov di,9080
        ;mov ah,00000001b
        ;mov bl,00h
        ;mov bh,03Fh
t1:     ;mov al,ah
        ;call near VXSetPlanes
        ;mov es:[si],bh
        ;mov al,bl
        ;call near VXGetPlane
        ;mov bh,es:[si]
        ;mov es:[di],bh
        ;add bh,020h
        ;inc bl
        ;shl ah,1
        ;test ah,00010000b
        ;jz short t1

        call near IntroVGAX
        call near WasKeyPressed
        jc short DemoR
        call near ScreenFadeOut

        mov ax,00100h
        call near VXClearVRAM
        call near Space3D
        call near WasKeyPressed
        jc short DemoR
        call near ScreenFadeOut

        mov ax,00100h
        call near VXClearVRAM
        call near AnimatedCosinus
        call near WasKeyPressed
        jc short DemoR
        call near ScreenFadeOut

        mov ax,00100h
        call near VXClearVRAM
        call near FlamesOutro
        call near WasKeyPressed
        jc short DemoR

        jmp short DemoWait

;Testing copy page.

        mov ah,00000001b
        mov al,03Fh
        call near VXClearVRAM
        mov ah,00000010b
        mov al,040h
        call near VXClearVRAM


        ;xor ah,00100000b
        ;xor al,al
        ;mov word [vx_cursor_x],0010h
        ;mov word [vx_cursor_y],0050h
        ;mov byte [vx_font_color],040h
        ;call near VXPrintString

        ;mov al,00001000b
        ;call near VXCopyPage

DemoWait:
        mov ah,00h                      ;Press any key.
        int 16h
DemoR:
        ; restore video mode
        mov ah,0
        mov al,[prev_video_mode]
        int 10h

        popf
        ret

prev_video_mode db 0
key_pressed     db 0

; Проверка нажатия клавиши
; In:   -
; Out:  флаг CF установлен, если было зарегистрировано нажатие любой клавиши
WasKeyPressed:
        pushf
        push ax
        push bx
        push cx
        push dx

        mov al,[key_pressed]
        test al,al
        jnz short WKPTrue

        mov ah,01h                      ; check for keystroke
        int 16h
        jz short WKPFalse
        mov ah,00h                      ; get keystroke (clear buffer)
        int 16h
        mov byte [key_pressed],1
WKPTrue:
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        stc
        ret

WKPFalse:
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        clc
        ret

;Using copy page procedure.
        ;mov ax,0100h
        ;call near VXClearVRAM
        ;mov al,00000100b
        ;call near VXCopyPage
        ;call near VXWaitVSync
        ;mov al,00001000b
        ;call near VXCopyPage
;Press any key for debug.
        ;push ax
        ;mov ah,00h
        ;int 16h
        ;pop ax


;1. Вступление и возможности адаптера по цветам и страницам.


INTRO_GFX_DELAY EQU 00002h              ;Задержка вывода вертикальной линии.
INTRO_TXT_SX    EQU 00000h              ;Стартовые позиции текста.
INTRO_TXT_SY    EQU 00010h
INTRO_TXT_X1    EQU 00008h              ;Change coordinates even with space.
INTRO_TXT_Y1    EQU INTRO_TXT_SY + 0B0h ;Дополнительный текст, мелким шрифтом.
INTRO_TXT_COL1  EQU 0FFh                ;Цвет текста, стартовый.
INTRO_TXT_COL2  EQU 07Fh                ;Цвет текста комментария.
INTRO_LINE_Y1   EQU 0003Ch              ;60 - for 120.
INTRO_LINE_Y2   EQU 000B4h              ;180.

; Добро пожаловать на Чай! Создавая игровой движок(движок игры) для реального
;режима процессора 8086, видеоадаптера ВГА и известного в 90-ые(интересного)
;режима Х, мы реализовали простые и классические алгоритмы эпохи начала
;демосцены.
; История: ВГА Моде-Х. Разрешение 320 на 240 точек и 256 цветов.
;Палитра адаптера 256К цветов, по 6 бит на компонент.

vga_intro_txt   dw 00E8h
                dw 0004h
                db '     WELCOME TO     '
                db '     TEA PARTY!'            ;Add space to config.
                db ' While creating game engine for 8086 CPU'
                db 'and VGA famous Mode-X our team released '
                db 'various classic effects of demoscene!   '
                db ' Resolution: 320x240 pixels, 256 colors;'
                db ' Palette: 256K and 6-bit RGB component. '

IntroVGAX:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp

        call near VXSetFullDAC
        mov ax,0100h
        call near VXClearVRAM
        call near VXSetActDispPage      ;Using only one page for intro.

        mov word [vx_cursor_x],INTRO_TXT_SX
        mov word [vx_cursor_y],INTRO_TXT_SY
        mov byte [vx_font_color],INTRO_TXT_COL1

        mov dx,GFX_SCR_WIDTH            ;Calculate screen horizontal center.
        shr dx,1
        mov ax,GFX_RGB_COLORS
        shl ax,1
        mov si,dx
        sub si,ax
        mov di,dx
        add di,ax
        dec di                          ;SI,DI - left and right v.coords.

        xor bp,bp                       ;String pring offset.
        mov bx,0FF00h                   ;Main cycle.
        mov cx,0100h                    ;Cycle for all colors.
Intro2: push cx
        test cx,0001h                   ;Even - left, odd - right line.
        jnz short Intro0
        mov al,bl
        add bl,02h                      ;Next line and color.
        mov dx,si
        add si,0002h
        jmp short Intro1
Intro0: mov al,bh
        sub bh,02h
        mov dx,di
        sub di,0002h
Intro1: call near VXWaitVSync
        ;call near VXWaitVSync
        mov cx,INTRO_LINE_Y1            ;Draw vertical lines.
Intro7: call near VXSetPixel
        inc cx
        cmp cx,INTRO_LINE_Y2
        jnz short Intro7

        call near VXWaitVSync
        call near VXWaitVSync

        push bx                         ;Print char.
        push ax
        lea bx,vga_intro_txt
        mov dx,bp
        mov al,01h
        mov ah,11000001b
        cmp dx,24h
        jc short Intro4
        mov ah,11000000b
Intro4: call near VXPrintString
        inc bp
        cmp bp,24h
        jne short Intro5
        mov byte [vx_font_color],INTRO_TXT_COL2
        mov word [vx_cursor_x],INTRO_TXT_X1
        mov word [vx_cursor_y],INTRO_TXT_Y1

Intro5: cmp bp,24h
        jne short Intro6
Intro6:
        pop ax                          ;Restore text counter.
Intro3: pop bx
        pop cx
        call near WasKeyPressed
        jc short IntroR
        loop Intro2

IntroR: pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;Процедура для демки. Гашением экрана через палитру и синхронизацией по лучу.

ScreenFadeOut:
        pushf
        push ax
        push cx
        push dx
        mov ax,0040h
        mov cl,DEMO_FADE_SPEED
        div cl
        mov cl,al
SFadeO5:call near VXWaitVSync           ;Add extra sync if needed.
        xor al,al
SFadeO4:call near VXGetPalColor
        cmp ah,DEMO_FADE_SPEED
        jbe short SFadeO1
        sub ah,DEMO_FADE_SPEED
        jmp short SFadeO6
SFadeO1:xor ah,ah
SFadeO6:cmp dl,DEMO_FADE_SPEED
        jbe short SFadeO2
        sub dl,DEMO_FADE_SPEED
        jmp short SFadeO7
SFadeO2:xor dl,dl
SFadeO7:cmp dh,DEMO_FADE_SPEED
        jbe short SFadeO3
        sub dh,DEMO_FADE_SPEED
        jmp short SFadeO8
SFadeO3:xor dh,dh
SFadeO8:call near VXSetPalColor
        inc al
        jnz short SFadeO4
        dec cl
        jnz short SFadeO5
        pop dx
        pop cx
        pop ax
        popf
        ret

;Процедура для демки. Появление экрана через палитру и синхронизацией по лучу.

ScreenFadeIn:
        pushf
        push ax
        push dx

        xor al,al

        pop dx
        pop ax
        popf
        ret


;Минимальный 3Д космос по направлениям движения и вперед.


CENTER_3D_X     EQU 1000h               ;Center of projection coordinates.
CENTER_3D_Y     EQU 1000h

SPACE_3D_TIMER  EQU 0310h
SPACE_STARS     EQU 0FFh                ;Stars in space, max 255.
SPACE_TXT_OFFS  EQU 00780h              ;1920 words minus bottom vpage.
SPACE_TXT_SX    EQU 00000h              ;Start text.
SPACE_TXT_SY    EQU 000C0h
SPACE_TXT_COLOR EQU 07Fh                ;Blue or bright blue.
SPACE_COLORS    EQU 0FFh                ;All blue/white colors.
SPACE_STAR_SIZE EQU 08h                 ;Mask for stars depth/delay.
SPACE_VMASK     EQU 00C0h               ;Mask for text on screen.
SPACE_MASK_X    EQU 1FFFh               ;Mask for horizontal star position.
SPACE_MASK_Y    EQU 1FFFh               ;Mask for vertical star position.
SPACE_MASK_Z    EQU 00FFh               ;Mask for star depth.
SPACE_MULT      EQU 0080h               ;Factor for XY.


;3 words with parameters X,Y,Z and reserved word.

stars_xyz:      dw 4 * SPACE_STARS dup (0000h)   ;In every direction.

stars_move:     dw 0h, 0h, -03h
                dw 0h, SPACE_MULT, 0h
                dw -SPACE_MULT, SPACE_MULT, 0h
                dw -SPACE_MULT, 0h, 0h
                dw -SPACE_MULT, -SPACE_MULT, 0h
                dw 0h, -SPACE_MULT, 0h
                dw SPACE_MULT, -SPACE_MULT, 0h
                dw SPACE_MULT, 0h, 0h
                dw SPACE_MULT, SPACE_MULT, 0h

; Элементарное трехмерное пространство наполненное звездами с применением
;двух видео страниц и вертикальной синхронизацией.
; Кто "Опасный" в Элите?! :)
;Видеобуффер в 256 килобайт содержит четыре битовых плана с
;простыми трюками аппаратного ускорения.
; Структура режима Х: Три видеостраницы по 75 и 31 свободных килобайта.
;

space_3D_txt    dw 00F0h
                dw 0004h
                db ' Elementary 3D Space, filled with stars '
                db 'and using both video pages with V-Sync. '
                db ' Who is the Dangerous in Elite?! :)     '
                db ' VRAM is 256Kb contains four bit-planes '
                db 'with some hardware acceleration tricks. '
                db ' Mode-X: 3 pages of 75Kb and 31Kb free. '

Space3D:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp

        xor ax,ax
        xor dx,dx
SpPal1: call near VXSetPalColor
        inc al
        inc ah
        inc dl
        inc dh
        cmp al,040h
        jnz short SpPal1
        xor ah,ah
        xor dx,dx
SpPal2: call near VXSetPalColor
        inc dh
        inc dl
        inc al
        cmp al,080h
        jnz short SpPal2
        xor ah,ah
        xor dx,dx
SpPal3: call near VXSetPalColor
        inc ah
        inc dl
        inc al
        cmp al,0C0h
        jnz short SpPal3
        xor ah,ah
        xor dx,dx
SpPal4: call near VXSetPalColor
        inc ah
        inc dl
        inc dh
        inc al
        jnz short SpPal4

        mov word [vx_cursor_x],SPACE_TXT_SX
        mov word [vx_cursor_y],SPACE_TXT_SY
        mov byte [vx_font_color],SPACE_TXT_COLOR

        xor al,al
        mov ah,SPACE_STARS
        call near CreateStars3D

        lea di,stars_move
        mov bh,01h
        mov bl,00000001b                        ;Active screen.
        xor bp,bp                               ;String offset.
Space2: mov cx,SPACE_3D_TIMER                   ; main cycle
Space1: push cx
        mov ah,00h
        ;int 16h
        call near VXWaitVSync
        mov al,bl
        call near VXSetActDispPage
        push cx
        push di
        push es
        mov cx,GFX_SCR_ADDR
        mov es,cx
        xor ah,ah
        and al,00000011b
        mov dx,GFX_PAGE_SIZE_B
        mov cx,GFX_PAGE_SIZE_W - SPACE_TXT_OFFS
        mul dx
        mov di,ax
        mov al,00001111b
        call near VXSetPlanes
        xor ax,ax
        cld
        rep stosw
        pop es
        pop di
        pop cx
        call near MoveSpace3D
        call near DrawSpace3D
        xor bl,00000101b                        ;Change pages.
        pop cx

;Press any key for debug.
        push ax
        mov ah,00h
        ;int 16h
        pop ax

        push bx                                 ;
        push ax
        lea bx,space_3D_txt
        mov ah,01100000b
        mov dx,bp
        call near VXPrintString
        sub word [vx_cursor_x],08h
        test cx,0001h
        jnz short Space3
        add word [vx_cursor_x],08h
        inc bp
Space3: pop ax
        pop bx
        call near WasKeyPressed
        jc short SpaceR
        loop Space1                             ;Main cycle.

        add di,0006h
        dec bh
        jnz short Space2

SpaceR: pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;DS:DI - moving directions with words.

MoveSpace3D:
        pushf
        push ax
        push bx
        push cx
        push di

        lea bx,stars_xyz
        xor cl,cl
        xor ch,ch
MovS3D1:mov ax,[bx]
        add ax,[di]                     ;Add X.
        ;jc short MovS3D2
        cmp ax,SPACE_MASK_X             ;2D projection coordinate, not do.
        jnc short MovS3D2
        mov [bx],ax
        mov ax,[bx+02h]
        add ax,[di+02h]                 ;Add Y.
        ;jc short MovS3D2
        cmp ax,SPACE_MASK_Y             ;2D projection coordinate, not do.
        jnc short MovS3D2
        mov [bx+02h],ax
        mov ax,[bx+04h]
        add ax,[di+04h]                 ;Add Z.
        cmp ax,SPACE_MASK_Z
        jnc short MovS3D2
        mov [bx+04h],ax
        jmp short MovS3D3
MovS3D2:mov al,ch                       ;Store.
        mov ah,01h
        call near CreateStars3D
MovS3D3:add bx,SPACE_STAR_SIZE
        inc ch
        cmp ch,SPACE_STARS
        jnz short MovS3D1

        pop di
        pop cx
        pop bx
        pop ax
        popf
        ret

DrawSpace3D:
        pushf
        push ax
        push bx
        push cx
        mov cx,SPACE_STARS
        lea bx, stars_xyz
DrS3D1: mov al,[bx+06h]
        call near VXSetPixel3D
        add bx,SPACE_STAR_SIZE
        loop DrS3D1
        pop cx
        pop bx
        pop ax
        popf
        ret

;Set pixel 3D. AL - color, BX - address of coordinates(X,Y,Z).

VXSetPixel3D:
        pushf
        push ax
        push cx
        push dx
        push bp
        push si

        mov bp,ax
        mov si,[bx+04h]                 ;Z parameter.
        test si,si
        jz short SPix3D0
        xor dx,dx
        mov ax,[bx]                     ;Coordinate x.
        sub ax,CENTER_3D_X
        jnc short SPix3D1
        not dx                          ;Negative.
        idiv si
        jmp short SPix3D2
SPix3D1:div si                          ;Unsigned.
SPix3D2:add ax,GFX_SCR_WIDTH / 2
        mov cx,ax                       ;X position.
        xor dx,dx
        mov ax,[bx+02h]                 ;Y
        sub ax,CENTER_3D_Y
        jnc short SPix3D3
        not dx
        idiv si
        jmp short SPix3D4
SPix3D3:div si
SPix3D4:add ax,GFX_SCR_HEIGHT / 2

        cmp ax,SPACE_VMASK              ;Dirty trick for text, remove in lib!
        jnc short SPix3D0

        xchg cx,ax                      ;Position Y
        mov dx,ax
        mov ax,bp
        xor ah,ah                       ;Al - color.
        call near VXSetPixel

SPix3D0:pop si
        pop bp
        pop dx
        pop cx
        pop ax
        popf
        ret

;al - star index
;ah - counter

CreateStars3D:
        pushf
        push ax
        push bx
        push cx
        push di
        xor cx,cx
        xchg ch,ah
        lea di,stars_xyz
        mov cl,03h
        shl ax,cl
        add di,ax                       ;Star X.
        mov cl,ch
CrStar2:xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_X
CrStar0:mov [di],ax                     ;Store X.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_Y
        mov [di+02h],ax                 ;Store Y.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_MASK_Z
        test ax,ax
        jnz short CrStar3
        inc ax
CrStar3:mov [di+04h],ax                 ;Store Z.
        xor ax,ax
        call near RandomSimple
        and ax,SPACE_COLORS

        ;add ax,0010h                   ;Was removed from release.

        mov [di+06h],ax
        add di,SPACE_STAR_SIZE
        inc ch
        dec cl
        jnz short CrStar2
        pop di
        pop cx
        pop bx
        pop ax
        popf
        ret


;3. Анимация косинуса с использованием математического сопроцессора.

DRAW_OFFS_X     EQU 0003h               ;Offset for graphics horizontal.
DRAW_CENTER_Y   EQU 078h                ;120 for mode X.
DRAW_OFFS_Y_COS EQU 00078h              ;Center for COS graphics.
DRAW_FUNC_SIZE  EQU 020h                ;Size of draw sin,cos in pixels.
DRAW_COS_WIDTH  EQU 0013Bh              ;314 pixels for better PI. +1 for st.
                                        ;13A - is correct value.
RED_DEF_INDEX   EQU 000h                ;Indexes for default color palette.
GREEN_DEF_INDEX EQU 040h
BLUE_DEF_INDEX  EQU 080h
BW_DEF_INDEX    EQU 0C0h

ANIM_COS_TIMER  EQU 000D0h
MATH_TXT_SX     EQU 00000h
MATH_TXT_SY     EQU 00018h
MATH_TXT_X1     EQU 00000h
MATH_TXT_Y1     EQU 000B0h

MATH_TXT_NEXT   EQU 026h                ;Upper part of text lenght.
MATH_TXT_COL1   EQU 0007Fh
MATH_TXT_COL2   EQU 000FFh

control_reg     dw 0000h
start_x         dd 0.00
value_x         dd 0.00
step_x          dd 0.02                 ;Full 2PI.
offset_x_anim   dd 0.04                 ;Offset X for every frame.
anim_accel      dd 0.01
sign_neg        dd -1.0
pi_00           dd 0.00
pi_14           dd 0.79
pi_12           dd 1.57
pi_34           dd 2.36
pi_44           dd 3.14
pi_54           dd 3.93
pi_64           dd 4.71
pi_74           dd 5.50
pi_84           dd 6.28                 ;May be plus 1 or equal.
value_tg        dd 0.0
screen_size_y   dw DRAW_FUNC_SIZE
fpu_data        dw 10h dup (0)
scr_y_cos_tab   dw DRAW_COS_WIDTH dup (0000h)

anim_cos_txt    dw 00CAh
                dw 0004h
                db '  REALTIME MATH ON  '
                db '  8087 COPROCESSOR'            ;Add space to config.
                db ' Color animation of trigonometric cosine'
                db 'creating by slow formula of tangent and '
                db 'square root, but fully on mathematical  '
                db 'coprocessor. 8086 became an artist...:) '
                db '                                        '
                ;db ' Precision: 32-bit single, real.        '

fpu_state       dw 0

;Математика в реальном времени на сопроцессоре 8087.
;Анимация тригонометрической функции косинуса и палитры цвета
;рассчитывается по медленной формуле через тангенс и извлечение
;квадратного корня, но полностью на математическом сопроцессоре.
;86-ой... стал художником. :)
; Точность вычислений: 32-битная, реальная.

AnimatedCosinus:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp

        call near VXSetFullDAC
        mov ax,0FFC0h
        mov dx,0FFFFh
        call near VXSetPalColor         ;Cosinus line in center.
        xor ax,ax
        call near VXSetActDispPage      ;Using one page.

        mov word [vx_cursor_x],MATH_TXT_SX
        mov word [vx_cursor_y],MATH_TXT_SY
        mov byte [vx_font_color],MATH_TXT_COL1

        finit
        fstcw word [control_reg]
        mov ax,[control_reg]
        and ah,11110000b
        mov [control_reg],ax
        fldcw [control_reg]             ;round 32-bits

        ;mov bp,00010h                   ;Animation cycle.
        mov bp,ANIM_COS_TIMER
        ;mov bp,00001h
        xor dx,dx

DrSCC:  push dx
        mov cx,DRAW_COS_WIDTH           ;Fix bug or leave as is. :)
        xor bx,bx
        lea di,scr_y_cos_tab

DrSC0:  fld dword [value_x]             ;Draw full cosinus using CX counter.
        fptan
        fincstp
        ;fst dword [value_tg]

DrSC2:  ;fld dword [value_tg]
        fst ST1
        fmul ST0,ST1                    ;tg^2
        fld1
        fadd ST0,ST1                    ;(tg^2 + 1)
        fld1
        fdiv ST0,ST1                    ;1 / (tg^2 + 1)
        fsqrt

        fld dword [value_x]             ;Position X.
        fcom dword [pi_12]
;        fstenv [fpu_data]
;        mov ax,[fpu_data+02h]           ;C0,C1 == 0 for ST0 > DATA, 8,10 bits.
;        test ax,0500h
;        jnz short DrSC1
; Сохраняем регистр SWR сопроцессора в память, чтобы потом считать в AX.
; На старших моделях FPU можно сразу сделать fstsw ax
        fstsw word [fpu_state]
        mov ax,[fpu_state]
; Загружаем флаги из регистра AH, флаги C0, C2, C3 из FPU при этом попадают
; в CF, PF, ZF соответственно. После этого можно использовать привычные
; условные переходы, предполагая, что fcom всегда сравнивает ST0 с операндом,
; то есть фактически имеет вид: fcom ST0, argument
        sahf
        jbe short DrSC1                 ; ST0 <= Src (pi/2)

        fcom dword [pi_64]              ;
;        fstenv [fpu_data]
;        mov ax,[fpu_data+02h]
;        test ax,0500h
;        jz short DrSC1
        fstsw word [fpu_state]
        mov ax,[fpu_state]
        sahf
        ja short DrSC1                 ; ST0 > Src (pi*6/4)

        ;jmp short DrSC1

DrSC4:  fincstp                         ;Remove X position.
        fld dword [sign_neg]
        fmul ST0,ST1                    ;Change sign.
        jmp short DrSCB
DrSC1:  fincstp
DrSCB:  fimul word [screen_size_y]
        frndint
        fistp word [di]                 ;Save to table and next X.
        add di,0002h

        fld dword [value_x]
        fadd dword [step_x]
        fcom dword [pi_84]
        fstenv [fpu_data]               ;SR - second word, 14 bit, equal C3.
        mov ax,[fpu_data+02h]
        test ax,04000h
        jnz short DrSCA1
        test ax,00500h
        jnz short DrSCA                 ;Add because other bits set/reset.
DrSCA1: fincstp
        fldz                            ;To zero as cycle.
DrSCA:  fstp dword [value_x]            ;Next x.
        loop DrSC0

;        mov cx,DRAW_COS_WIDTH          ;Testing drawing from memory.
;        lea si,scr_y_cos_tab
;TST1:   mov word [si],0010h
;        add si,0002h
;        loop TST1

        lea si,scr_y_cos_tab            ;Draw full cosinus.
        mov di,DRAW_COS_WIDTH
        mov dx,DRAW_OFFS_X

        call near VXWaitVSync           ;Starting drawing.

DrSC3:  mov cx,DRAW_OFFS_Y_COS          ;BX = Y.
        sub cx,[si]                     ;Or ADD.

        ;mov [si],cx                     ; y coordinate
        ;mov al,0FFh                    ;Only cosinus without colors.
        ;call near VXSetPixel

        mov bh,DRAW_OFFS_Y_COS - DRAW_FUNC_SIZE ; 8bit.
        ;add bl,GREEN_DEF_INDEX + 31
        mov ah,cl                       ;Save start coordinate Y.
        mov al,BLUE_DEF_INDEX           ;Last green color.

DrSC7:  cmp cl,bh                       ;Draw up.
        jc short DrSC6
        call near VXSetPixel
        dec al
        dec cx
        jmp short DrSC7

DrSC6:  ;call near VXWaitVSync

        mov cl,ah                       ;Restore Y start.
        mov bh,DRAW_OFFS_Y_COS + DRAW_FUNC_SIZE
        mov al,BW_DEF_INDEX

DrSC8:  cmp cl,bh
        jnc short DrSC9
        call near VXSetPixel
        inc cx
        dec al
        jmp short DrSC8
DrSC9:  inc dx
        add si,0002h                    ;Next cosinus Y value.
        dec di
        jnz short DrSC3

        ;fld dword [offset_x_anim]       ;Acceleration.
        ;fadd dword [anim_accel]
        ;fstp dword [offset_x_anim]

        fld dword [start_x]             ;Animation offset, optional if bug.
        fadd dword [offset_x_anim]
        fcom dword [pi_84]
        fstenv [fpu_data]               ;SR - second word, 14 bit, equal C3.
        mov ax,[fpu_data+02h]
        test ax,04000h
        jnz short DrSCD1
        test ax,00500h
        jnz short DrSCD                 ;Add because other bits set/reset.
DrSCD1: fincstp
        fldz                            ;To zero.
DrSCD:  fst dword [start_x]             ;Next x.
        fstp dword [value_x]

        pop dx
        ;call near VXWaitVSync          ;Print char.
        lea bx,anim_cos_txt
        mov al,01h
        mov ah,11000001b
        cmp dx,MATH_TXT_NEXT
        jc short DrSCP1
        mov ah,11000000b
DrSCP1: call near VXPrintString
        inc dx
        cmp dx,MATH_TXT_NEXT
        jne short DrSCP2
        mov byte [vx_font_color],MATH_TXT_COL2
        mov word [vx_cursor_x],MATH_TXT_X1
        mov word [vx_cursor_y],MATH_TXT_Y1
DrSCP2:
        call near WasKeyPressed
        jc short DrSCR
        dec bp
        jnz DrSCC

DrSCR:  pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret


;4. Эффект движения и смещений прямоугольников с градиентом.

RECTS_SCREEN            EQU 040h        ;Rectangles on screen.
RECT_SIZE               EQU 08h         ;Data size.
RECT_OFFS_X             EQU 20h         ;Center and 256 pixels max.
RECT_OFFS_Y             EQU 38h         ;56 and 128 pixels max.

MoveRectangles:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp

        lea bx,rects_data
        mov cx,01h
        lea si,rects_color
        mov di,0004h                    ;active and display page
        mov ax,0000h
RMove1: xor al,al
        call near VXSetActDispPage
        mov al,ch
        call near CreateRect
        mov word [bx],0000h
        mov word [bx + 02h],0000h
        mov word [bx + 04h],013Fh
        mov word [bx + 06h],00EFh
        mov al,01h
        mov ah,0
        call near VXDrawRect
        ;mov ax,di
        mov al,00000001b
        call near VXSetActDispPage
        mov al,01h;[si]
        mov ah,00h
        call near VXDrawRect
        add bx,RECT_SIZE
        inc si
        inc ch
        dec cl
        jnz short RMove1
        ;mov word [bx],0000h
        ;mov word [bx + 02h],0000h
        ;mov word [bx + 04h],013Fh
        ;mov word [bx + 06h],00EFh
        ;mov al,01h
        ;mov ah,01h
        ;call near VXDrawRect

; Полноэкранное смещение медленным методом.

        mov cx,80h          ;main cycle
        mov ah,00010001b
        mov dx,04h
        mov al,00h
        call near VXMoveScreen
        mov bl,00000001b      ;active page - 0, display page - 1
        mov dx,04h
RMove2: mov ah,00010001b
        call near VXWaitVSync
        mov di,ax
        mov al,bl
        xor al,00000101b
        call near VXSetActDispPage
        mov bl,al
        ;mov ah,00h
        ;INT 16h
        mov ax,di
        call near VXMoveScreen
        test cl,00000001h
        jnz short RMove3
        inc al
RMove3: loop RMove2


        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;Rectangles left-top and right-bottom pixels and color.

rects_data      dw RECTS_SCREEN * 4 dup (0000h)
rects_color     db RECTS_SCREEN dup (00h)

;Полноэкранное смещение активной страницы вверх на количество точек и
;заполнение освободившегося пространства по правилам. Не используется смещение
;страниц адаптера и память за пределами страницы не изменяется.
;
;al - color to fill.
;ah bits:
;0..3   bits of direction left, right, up, down;
;4      fill with color all empty space;
;5..7   reserved.
;dx     size in pixels, screen size max.

VXMoveScreen:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push es
        push bp
        test dx,dx
        jz MovScrR
        mov di,GFX_SCR_ADDR
        mov es,di
        mov bx,ax
MovScr3:mov si,[vx_scr_active]
        mov di,si
        test bh,00001111b
        jz MovScrR
        test bh,00000001b              ; move left
        jz short MovScr0
        shr dx,1
        shr dx,1
        add si,dx
        cld
        mov bp,GFX_SCR_HEIGHT
MovScrD:mov cx,GFX_BYTES_PER_LINE
        sub cx,dx
MovScrB:mov al,00000001b
MovScrA:call VXSetPlanes
        mov ah,es:[si]
        mov es:[di],ah
        shl al,1
        test al,00010000b
        jz short MovScrA
        inc si
        inc di
        loop MovScrB
        test bh,00010000b
        jz short MovScrC
        mov al,00001111b
        call near VXSetPlanes

        mov al,bl
        mov cx,dx
        rep stosb
        add si,dx
MovScrC:dec bp
        jnz short MovScrD
        xor bh,00000001b
        jmp short MovScr3
MovScr0:test bh,00000010b
        jz short MovScr1
MovScr1:test bh,00000100b       ;move up, es:si -> es:di
        jz short MovScr2
        mov ax,dx
        mov cx,dx
        mov dx,GFX_BYTES_PER_LINE
        mul dx                          ;64k MAX
        add si,ax
        mov ax,GFX_SCR_HEIGHT
        sub ax,cx
        mov cx,GFX_BYTES_PER_LINE
        mul cx
        xchg ax,cx
        mov dx,GFX_PAGE_SIZE_B
MovScr5:mov al,00000001b
MovScr4:call VXSetPlanes
        mov ah,es:[si]
        mov es:[di],ah
        shl al,1
        test al,00010000b
        jz short MovScr4
        inc si
        inc di
        dec dx
        loop MovScr5
        test bh,00010000b
        jz short MovScr6
        mov al,00001111b
        call VXSetPlanes
        cld
        mov al,bl
        mov cx,dx
        rep stosb
MovScr6:xor bh,00000100b
        jmp MovScr3
MovScr2:test bh,00001000b               ;mov down
        jz MovScr3
        mov ax,GFX_SCR_HEIGHT
        sub ax,dx
        mov dx,GFX_BYTES_PER_LINE
        mul dx
        mov cx,GFX_PAGE_SIZE_B
        add si,ax
        add di,cx
        mov dx,cx
        mov cx,ax
MovScr8:dec si
        dec di
        mov al,00000001b
MovScr7:call VXSetPlanes
        mov ah,es:[si]
        mov es:[di],ah
        shl al,1
        test al,00010000b
        jz short MovScr7
        dec dx
        loop MovScr8
        test bh,00010000b
        jz short MovScr9
        mov al,00001111b
        call near VXSetPlanes
        std
        dec di
        mov al,bl
        mov cx,dx
        rep stosb
MovScr9:xor bh,00001000b
        jmp MovScr3
MovScrR:pop bp
        pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

;al - index.

CreateRect:
        pushf
        push ax
        push bx
        push dx
        push si
        push di
        lea di,rects_data
        lea si,rects_color
        xor ah,ah
        add si,ax
        shl ax,1
        shl ax,1
        shl ax,1
        add di,ax
        xor dx,dx
        xor ax,ax
        call near RandomSimple
        xor dh,dh
        mov dl,ah
        add dx,RECT_OFFS_X
        mov [di],dx
        mov dl,al
        xor dh,dh
        add dx,RECT_OFFS_X
        cmp dx,[di]
        jnc short CrRect1
        xchg dx,[di]
CrRect1:mov [di + 04h],dx
        xor ax,ax
        call near RandomSimple
        and ax,7F7Fh
        add al,RECT_OFFS_Y
        add ah,RECT_OFFS_Y
        mov dl,al
        xor dh,dh
        mov [di + 02h],dx
        mov dl,ah
        xor dh,dh
        cmp dl,[di + 02h]
        jnc short CrRect2
        xchg dl,[di + 02h]
CrRect2:mov [di + 06h],dx
        xor ax,ax
        call near RandomSimple
        mov [si],al
        pop di
        pop si
        pop dx
        pop bx
        pop ax
        popf
        ret


;5. Горящее пламя, авторы, ссылки и завершение.


FLAME_HEIGHT            EQU 050h        ;Flame max.
FLAME_SIZE              EQU FLAME_HEIGHT * GFX_SCR_WIDTH
FLAME_SIZE_PLANE        EQU (FLAME_SIZE / 4) - 80       ;Without random line.
FLAME_INTENSE           EQU 01h
FLAME_SCR_ADDR          EQU GFX_BYTES_PER_LINE * 50h
FLAME_SRC_OFFS          EQU FLAME_SIZE - GFX_SCR_WIDTH
FLAME_COLOR_MASK        EQU 0FFFFh
FLAME_8BTP_COLOR        EQU 07Fh

FLAME_TIMER             EQU 001A0h
FLAME_TXT_SX            EQU 00004h
FLAME_TXT_SY            EQU 00010h
FLAME_TXT_X1            EQU 00000h
FLAME_TXT_Y1            EQU 000A0h

FLAME_TXT_NEXT          EQU 00Dh           ;Upper part of text lenght.
FLAME_TXT_COL1          EQU 0007Fh
FLAME_TXT_COL2          EQU 00Fh

back_rect       dw 0000h, 009Fh, 013Fh, 00EFh   ;Background for text.

flame_outro_txt dw 01AAh
                dw 0004h
                db '    8-BIT    '
                db '  TEA PARTY  '            ;Add space to config.
                db '   Classic flame using fast shifts...   '
                db ' Create special for Demodulation 2021,  '
                db '          by 8-Bit Tea Party!           '
                db '    Thanks for watching and good Tea!   '
                db '                                        '
                db '  Code: Alexander Serov, Danila Peroff  '
                db '           and Danya Potapov.           '
                db '      Organizer: Dmitry Galashin.       '
                db ' Thanks to our friends: Andrew, Vasily, '
                db 'Vovan, Eugene, Konstantin, Roman and...!'


;Классика пламени с быстрыми сдвигами и арифметкой.

FlamesOutro:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es

;Print title on screen.

        mov ah,10000010b
        mov al,FLAME_TXT_NEXT
        lea bx,flame_outro_txt
        xor dx,dx
        mov word [vx_cursor_x],FLAME_TXT_SX
        mov word [vx_cursor_y],FLAME_TXT_SY
        mov byte [vx_font_color],FLAME_8BTP_COLOR
        call near VXPrintString
        add dl,al
        mov word [vx_cursor_x],FLAME_TXT_SX
        call near VXPrintString

;Draw background for text.

        lea bx,back_rect
        mov al,FLAME_8BTP_COLOR
        mov ah,-01h
        call near VXDrawRect

;Set color palette for flames, from yellow to orange.

        mov al,00h                      ;Создаём жёлто-ораньжевую палитру.
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

;Flame effect without procedures, to release version.

Start:  mov ax,GFX_SCR_ADDR
        mov es,ax
        cld
;        mov bp,FLAME_TIMER              ;Main cycle.
        mov dx,1Ah

        mov word [vx_cursor_x],FLAME_TXT_X1
        mov word [vx_cursor_y],FLAME_TXT_Y1
        mov byte [vx_font_color],FLAME_TXT_COL2

FlameA: push dx
        mov di,FLAME_SCR_ADDR
        lea si,flame_data
        mov bx,di
        mov dx,si
        add si,FLAME_SIZE

;Формируем линию-источник огня, самая нижняя в буфере.
Flame0: dec si
        dec si
        xor ax,ax
        call near RandomSimple
        and ax,FLAME_COLOR_MASK
        ;mov word ds:[si],0FFFFh
        mov [si],ax
        cmp si,flame_data + FLAME_SRC_OFFS
        ja short Flame0

;Отображаем буфер пламяни на экран.
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

;Обновляем буфер пламени для всех пикселей кроме исходной линии.
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

;Правило пламени, менять по вкусу...
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

        pop dx
        cmp dx,[flame_outro_txt]
        jnb short Flame8
        push bx                                 ;
        push ax
        lea bx,flame_outro_txt
        mov al,01h
        mov ah,10000000b
        call near VXPrintString
        inc dx
        pop ax
        pop bx

Flame8: call near WasKeyPressed
        jc short Dem0
;        dec bp
;        jnz FlameA
        jmp near FlameA

Dem0:   pop es
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret


;Other code.


;4. Синхронизация по лучу, смена видео-страниц и выбор плоскости(вспом).
;Сказать про драйвера на всякий случай и настройки ДОСБокса.
;Параметры: фуллдабл=истина, ВСИНК для ДОСБокс включен.

VGASync:mov cx,0300h
        mov ax,GFX_SCR_ADDR
        mov es,ax
        cld
Wait1:  mov ax,0101h                    ;Blue color.
        call near VXWaitVSync
        push cx
        xor di,di
        mov cx,2580h                    ;Full page.
        rep stosw
        mov cx,0F000h
Wait2:  nop                             ;Empty command.
        nop
        nop
        loop Wait2
        mov ax,0202h
        xor di,di
        mov cx,2580h
        rep stosw
        pop cx
        loop Wait1

;Библиотечные процедуры, уже оформленных в файлы или для переноса в них.

;Полноэкранное копирование страниц видео памяти адаптера.
;al - bits:
;0..1   mode write to page as VGA;
;0..1   source page index;
;2..3   destination page index;
;Without error verify page indexes, only full pages 0,1 and 2.

VXCopyPage:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push ds
        ;push es

        xor si,si
        mov di,si
        mov dx,GFX_PAGE_SIZE_B
        mov ch,al
        shr al,1
        shr al,1
        and al,00000011b
        test al,al
        jz short CopyPg1
        mov cl,al
        dec cl
        mov ax,dx
        shl ax,cl
        add si,ax                       ;Source page address.
CopyPg1:mov al,ch
        shr al,1
        shr al,1
        shr al,1
        shr al,1
        test al,00000011b
        jz short CopyPg2
        mov cl,al
        dec cl
        mov ax,dx
        shl ax,cl
        add di,ax                       ;Destination page address.
CopyPg2:

        ;mov al,ch                       ;Set VGA mode for write byte.
        ;and al,00000011b
        ;mov dx,VGA_GRAPHICS_ADDR
        ;xchg al,ah
        ;mov al,0; VGA_GRAPH_DATA_ROTATE
        ;out dx,al
        ;xchg al,ah
        ;shl al,1
        ;shl al,1
        ;shl al,1
        ;inc dx
        ;out dx,al
        ;out dx,al                      ;Check.
        ;inc dx
        ;in al,dx

        cld
        mov dx,GFX_PLANE_SIZE_B
        mov ax,GFX_SCR_ADDR
        mov ds,ax
        ;mov es,ax
        mov bl,00000001b
        mov bh,00h
CopyPg3:mov al,bl
        call near VXSetPlanes           ;Remake using VGA hardware register.
        mov al,bh
        call near VXGetPlane
        mov cx,dx
CopyPg4:mov al,[di]
        ;and ax,[si]                    ;Add later other modes.
        or al,[si]
        ;mov al,[si]
        mov [di],al
        add si,0001h
        add di,0001h
        loop CopyPg4
        ;rep movsb
        sub si,dx
        ;sub si,dx
        ;sub di,dx
        sub di,dx
        inc bh
        shl bl,1
        test bl,00010000b
        jz short CopyPg3

        ;pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

%include "vx_sys.asm"
%include "vx_dac.asm"
%include "vx_pixel.asm"
%include "rnd_s.asm"
%include "vx_print.asm"
%include "vx_lines.asm"

;To speed up assembly, remove.
flame_data      db FLAME_SIZE dup (00h)
