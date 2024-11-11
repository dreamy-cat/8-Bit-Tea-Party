;8-Бит Чаепитие! Лицензия: Creative Commons.
;Платформа: 8086, OPL3(OPL2 совместимая) звуковая карта.
;Инструменты: NASM(2.15).
;Модули: не требуются.
;Авторы: Александр Серов(funny.dreamy.cat@gmail.com).
;Быстродействие: примерное количество тактов для каждой процедуры.
;Память: процед_1 = N, процед_2 занимает М байт.

;План вещания 10, 09.11.2024:
; - кратко история Yamaha OPL, описание железа и документации;
; - модули и общий план на нашу демку:
; - попробовать определить чип и инициализация(сброс);
; - звук синусоиды с базовыми параметрами и инструмент;
; - посмотреть шумовой(ударники) вывод;
; - дополнительно протестировать прерывания.

; Отличе от видео в параметрах инструента арфы, забыли выбрать форму E0, E3 рег.
;

; Модули на код:
; - системный, только для определения параметров, инициализации и выхода;
; - звуковые эффекты, т.е. набор генерируемых звуков для игр/демо;
; - проигрывание фоновой музыки, подобрать формат и подумать над прерываниями.

; ФМ:
; Частота = Амплитуда * Синус(НесущЧаст + Индекс * МодулЧаст).

; Формула Бесселя порядка Н.
; Частота = Амплитуда * Синус(НесущЧаст + ОбратСвязФактор).

; Частотное смещение(F-Num) = 2(Октава) * Базовую частоту * Мультипликатор.

; Режимы, каналы и параметры огибающей ADSR.

; Формула таймера: Время(мс) = (256 - Счетчик) * 00.8(0.32).

OPL_REG_PORT    EQU 00388h
OPL_DATA_PORT   EQU 00389h
OPL_REG_DELAY   EQU 004h
OPL_DATA_DELAY  EQU 010h
OPL_REG_TIMER1  EQU 002h
OPL_REG_TIMER2  EQU 003h
OPL_REG_T_CTRL  EQU 004h

CPU 8086

        org 100h
        pushf
        push es

        ;call near OPLInit
; Попытка вывести нот 5 через прерывания.


        cli                              ;Set new Int
        les bx,[IRQ0I8]
        mov ax,es:[bx]
        mov dx,es:[bx + 002h]
        mov [IRQ0Store],ax
        mov [IRQ0Store + 002h],dx
        mov es:[bx], word IRQMusic
        mov es:[bx + 002h],cs
        sti

        mov al,OPL_REG_T_CTRL
        mov ah,01100000b
        call near OPLWrite
        mov ah,10000000b        ;reset
        call near OPLWrite
        mov al,OPL_REG_TIMER2
        mov ah,[IRQDelay]       ;Set t2
        call near OPLWrite
        mov al,OPL_REG_T_CTRL
        mov ah,01000010b
        call near OPLWrite

        ;int 008h

Play4:  nop
        mov al,[IRQCounter]
        cmp al,060h
        jnz short Play4
        jmp short Play3

        mov dx,00150h
Play2:  mov cx,0F000h
Play1:  nop
        nop
        nop
        nop
        nop
        loop Play1
        dec dx
        jnz short Play2

Play3:  cli
        les bx,[IRQ0I8]
        mov ax,[IRQ0Store]
        mov dx,[IRQ0Store + 002h]
        mov es:[bx],ax
        mov es:[bx + 002h],dx
        sti

        ;mov ah,000h
        ;int 16h
        ;cmp al,' '
        ;jnz short OPLSn2

        call near OPLInit
        pop es
        popf
        ret

IRQ0I8:         dd 000000020h    ; int 8 timer
IRQ0Store:      dd 000000000h
IRQW1           dw 01F41h       ;sys timer
IRQW2           dw 03F41h       ;opl
IRQDelay        db 010h
IRQCounter      db 000h
IRQNext         db 010h

IRQMusic:
        pushf
        call far [IRQ0Store]
        push ax
        push cx
        push dx
        push si
        push di
        push es
        mov ax,0B800h
        mov es,ax
        mov ax,[IRQW1]
        mov es:[00140h],ax
        inc ax
        mov [IRQW1],ax

        mov dx,OPL_REG_PORT
        in al,dx
        test al,10000000b
        jz short MusR
        mov ax,08004h   ;reset irq signal
        call near OPLWrite
        ; Set flag again later.
        mov al,[IRQCounter]
        cmp al,[IRQNext]
        jnz short MusI
        mov ah,al
        mov cl,004h
        shr ah,cl       ;index
        shl ah,1        ;*2
        add al,010h
        mov [IRQNext],al

        lea di,frequency        ;+offset of note
        xchg al,ah
        xor ah,ah
        add di,ax
        mov cx,0000Dh           ; Расширены параметры выбора формы, правка!
        lea si,harp
MusP:   mov ax,[si]
        cmp al,0A0h     ;copy freq
        jnz short MusB
        mov ah,[di]
        inc di
        jmp short MusC
MusB:   cmp al,0B0h   ;last 2 bits + KeyON!
        jnz short MusC
        and ah,11111100b
        or ah,[di]              ;F-Number
        inc di
        push ax
        mov ax,000B0h
        call near OPLWrite
        pop ax
MusC:   call near OPLWrite
        inc si
        inc si
        loop MusP

        mov ax,[IRQW2]
        mov es:[00150h],ax
        inc ax
        mov [IRQW2],ax

MusI:   inc byte [IRQCounter]
MusR:   pop es
        pop di
        pop si
        pop dx
        pop cx
        pop ax
        iret

; Simple harp sound data.
harp    db 020h, 00000010b      ;0-3 Multi, KSR, EG-Type, vib, AM.
        db 040h, 00101001b      ;KSL key scale lev, 2B(A) + 6bits.
        db 060h, 075h           ;Attack/Decay 4/4 bits.
        db 080h, 0F5h           ;Sustain/Release 4/4 bits.
        db 0A0h, 0B0h           ;Frequency 8 bit lower.
        db 0E0h, 00000000b      ;Исправление не как на вещании!
        db 023h, 00000001b      ;Operator 2.
        db 043h, 10000011b
        db 063h, 0F2h
        db 083h, 0F3h
        db 0E3h, 00000000b      ;Добавлена еще и обратная связь по нулям.
        db 0C0h, 00000000b      ;Feedback.
        db 0B0h, 00110001b      ;0-1 Freq-N, 2-4 octave, 5 key-on!

frequency db 0B0h, 001h, 0CAh, 001h, 002h, 002h, 041h, 002h, 087h, 002h

;Hex-es Freq notes.
;           181          293.7       D
;           198          311.1       D#
;           1B0          329.6       E
;           1CA          349.2       F
;           1E5          370.0       F#
;           202          392.0       G
;           220          415.3       G#
;           241          440.0       A
;           263          466.2       A#
;           287          493.9       B
;           2AE          523.3       C


; Simple drum sound.
data_b  db 0BDh, 00101000b      ;snare
        db 031h, 00000001b      ;0-3 Multi, KSR, EG-Type, vib, AM.
        db 051h, 11000011b      ;KSL key scale lev, 2B(A) + 6bits.
        db 071h, 013h           ;Attack/Decay 4/4 bits.
        db 091h, 082h           ;Sustain/Release 4/4 bits.
        db 0A0h, 0B0h           ;Frequency 8 bit lower.
        db 034h, 00000001b      ;Operator 2.
        db 054h, 11000011b
        db 074h, 013h
        db 094h, 082h
        db 0A0h, 00101101b      ;0-1 Freq-N, 2-4 octave, 5 key-on!

; Simple sin sound data.
data_a  db 020h, 00000001b      ;0-3 Multi, KSR, EG-Type, vib, AM.
        db 040h, 11000011b      ;KSL key scale lev, 2B(A) + 6bits.
        db 060h, 011h           ;Attack/Decay 4/4 bits.
        db 080h, 0FFh           ;Sustain/Release 4/4 bits.
        db 0A0h, 0B0h           ;Frequency 8 bit lower.
        db 023h, 00000001b      ;Operator 2.
        db 043h, 11000011b
        db 063h, 011h
        db 083h, 0FFh
        db 0B0h, 00101101b      ;0-1 Freq-N, 2-4 octave, 5 key-on!

OPLSound:
        pushf
        push ax
        push cx
        push si
        mov cx,0000Ah
        lea si,data_b
OPLSn1: mov ax,[si]
        call near OPLWrite
        inc si
        inc si
        loop OPLSn1
        pop si
        pop cx
        pop ax
        popf

OPLInit:        ;init OPL
        pushf
        push ax
        xor ax,ax
OPLI1:  call near OPLWrite
        inc al
        jnz short OPLI1
        pop ax
        popf
        ret

OPLDetect:
        pushf
; Детектирование OPL2.
        mov al,OPL_REG_T_CTRL
        mov ah,01100000b
        call near OPLWrite
        mov ah,10000000b
        call near OPLWrite
        mov dx,OPL_REG_PORT
        in al,dx
        mov bl,al               ;bl = status
        mov ah,0FFh
        mov al,OPL_REG_TIMER1
        call near OPLWrite
        mov al,OPL_REG_T_CTRL
        mov ah,00100001b
        call near OPLWrite      ;mask T2 and start T1
        mov cx,00010h
OPLD1:  stc
        call near OPLDelay
        loop OPLD1
        in al,dx
        mov bh,al               ;bh = Timer1
        mov al,OPL_REG_T_CTRL
        mov ah,01100000b
        call near OPLWrite
        mov ah,10000000b
        call near OPLWrite
        and bl,0E0h             ;00h
        and bh,0E0h             ;C0h
        popf
        ret

OPLWrite:       ;AH - data, AL - reg.
        pushf
        push dx
        mov dx,OPL_REG_PORT
        out dx,al
        clc
        call near OPLDelay
        mov dx,OPL_DATA_PORT
        xchg ah,al
        out dx,al
        stc
        call near OPLDelay
        xchg al,ah
        pop dx
        popf
        ret

OPLDelay:       ;SImple delay reg or data ports reads, remake. CF0-1 = par.
        pushf
        push ax
        push cx
        push dx
        mov dx,OPL_REG_PORT
        jc short OPLDel0
        mov cx,OPL_REG_DELAY
        jmp short OPLDel1
OPLDel0:mov cx,OPL_DATA_DELAY
OPLDel1:mov ah,0FFh             ;remove
        in al,dx
        loop OPLDel1
        pop dx
        pop cx
        pop ax
        popf
        ret

;20.11.21, А.С.: Заголовок файла и старт.
