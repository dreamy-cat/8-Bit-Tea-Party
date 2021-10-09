;Small Demo by 8-Bit Tea Party, 2021.

;Stream music by John Broomhall - Transport Tycoon Deluxe (Adlib/SBPro).

;Stream 13. Mode-X, VGA library.

;План вещания:
;1. Снова пару слов об инструментах и библиотеке.
;2. Взаимодействие в команде и репозитории, показать исходники.
;3. Вывод экрана, синхронизация по лучу, смена видео-страниц и палитра.
;4. Вывод картинки(Лого 8-Битного чаепития) и если успеем, то пискель.
;5. Демонстрация организации памяти, с переделкой прошлой процедуры.

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

;1. Рекомендации по инструментам и структуре проекта.

; Данила Курьер. Использование ФАСМа:

;А так в fasm мне нравится много вещей:
;1. Скорость, компактность.
;2. Полная самодостаточность. Ни для каких форматов не нужен линковщик или что-то внешнее.
;3.  ОЧЕНЬ мощные макросы, на которых можно реализовать что угодно.
;Я так понимаю, что чуть ли не вся поддержка виндовых EXE сделана на макросах, а не захардкожена в программе, это просто взрывает мозг в хорошем смысле. Причем этим реально удобно пользов
;ться. Где-то краем глаза читал, что с помощью макросов и поддержку Z80 добавляли. В х86 ассемблер, ага :)
;4. Девиз "One source - one code" (ну, или как-то так). Смысл в том, что нет
;опций командной строки или настроек ini-файла, которые бы влияли на генерацию кода. Вообще. Все, что нужно для компиляции, полностью описывается самим исходником и директивами в
;нем. Получается, что, выкладывая куда-то сорс, ты можешь быть уверен, что ЛЮБАЯ его сборка даст тот же бинарный код, что и у тебя.
;5. Предельная лаконичность и немногословность. Несмотря на п.4.
;6. Мощная стандартная библиотека с ОС-зависимыми и общими частями. Я до нее, правда, пока так и не добрался ))
;7. Прикольные синтаксические плюшки типа анонимных (не путать с локальными) меток.
;8. Отсутствие танцев с бубном вокруг т.н. "оптимизатора" (привет, NASM). По умолчанию и без лишних слов генерятся наиболее оптимальные и интуитивно ожидаемые коды инструкций. Если хочется какой-то экзотики, есть всегда возможность уточнить.
;9. При необходимости без проблем генерится просто кусок машинного кода, без привязки к какому-либо формату.
;10. Проверенность временем и делом :)
; На fasm написаны целые ОС: MenuetOS, KolibriOS.
;
;А главный минус - то, что нет возможности искусственно ограничить уровень
;процессора. Какие инструкции юзаешь, такие и генерятся, все на совести
;программиста. Из-за этого тоже под наши общие задачи не подойдет.

;Данила Курьер: "Для себя не стал заморачиваться с поисками расширителя, а
;просто использую виндовую версию ФАСМ, тем более, что для неё очень удобная
;ИДЕ - ФРЕШ, которую давно хотел пощупать.".

;Вацлав: "Насм можно перенаправить поток ошибок в файл, может быть удобно".
;Ключ: -Z filename.err. CTRL + O для ДОС навигатора, сразу посмотреть.

; Для русского языка в DOSBox вписать строку: Z:\keyb.com ru 866.
; Данила Курьер: rk.com - double font; uniscr.com.

;Константин: вопрос по внешним инструментам.

;1. Исходник, открытость и лицензия.
;2. Командная строка, обязательно.
;3. Пожелания по языку, неважно, но Питон предпочтительней.

;2. Пожелания к взаимодействию в команде.

;Про список книг, он будет отдельно в файле текстовом и в Вики.

; Вацлав: ВОПРОС! Почитав учебники про арифметику на ассемблере у меня
;возникло стойкое убеждение, что авторы упускают очень важный момент.
;А именно: у нас есть просто числа и числа со знаком. Соответственно
;процессор меняет логику арифметики. И меняет он етому что старший бит
;числа равен 1, а потому что в регистре флагов есть бит - флаг знака.
;Перед выполнением команды процессор смотрит этот флаг и если он 1
;(поднят) - включает арифметику для чисел со знаком на понимание этого...
;А у вас как этот процесс прошел?

;Danila:
;Флаг знака - это следствие, а не причина :)
; Он устанавливается в зависимости от результата последней операции,
;чтобы его потом могли анализировать условные переходы и другие команды.
;Ни на какую логику арифметических операций он не влияет.
;Для сложения и вычитания логика одинаковая что для знаковых чисел, что для
;беззнаковых, так уж они устроены. Проц сам не знает, знаковые числа он
;сложил или нет, результат все равно будет верным, в обоих случаях.
;Там же, где логика различается, есть разные версии команд: DIV/IDIV,
;MUL/IMUL для беззнаковых и знаковых соответственно.
;И еще раз: флаги не влияют на результаты операций, они выставляются
;по этим результатам.

;Напоминание про макросы.

;3. Вывод экрана, синхронизация по лучу, смена видео-страниц и палитра.

CPU 8086        ;8087 as math. coprocessor.

%include "GLOBAL.ASM"

;Video DAC palette registers.

VGA_DAC_WRITE   EQU 3C8h
VGA_DAC_READ    EQU 3C7h
VGA_DAC_DATA    EQU 3C9h
VGA_PEL_MASK    EQU 3C6h

;Theory of DAC and docs.

;Program start.

        org 100h                        ;PSP.
        pushf

        ;call near SetModeX

;Memory allocation, so small, or using linker.

        ;mov ah,48h
        ;mov bx,0FFFFh
        ;int 21h

;Set DAC 256-colours palette for standard 13h mode or Mode-X.

        mov ax,13h                      ;Set mode 320x200x256.
        int 10h

;Effect with loading bmp files.

        mov al,1Eh                      ;Main cycle.
Dem9:   push ax

;Load color table from BMP, using DOS int.

        mov ah,3Dh                      ;Open file.
        mov al,00h                      ;File open mode.
        lea dx,bitmap_file
        int 21h
        mov [file_handler],ax

        mov bx,[file_handler]           ;Move pointer to data array.
        mov ah,42h
        xor cx,cx
        mov dx,1078                     ;Bitmap (0A) dword.
        mov al,00h                      ;From start file.
        int 21h

        mov bp,ds                       ;Read file.
        mov ax,SCR_GFX_ADDR
        mov ds,ax
        mov ah,3Fh                      ;Read.
        mov cx,0FA00h                   ;320*200
        xor dx,dx
        int 21h
        mov ds,bp                       ;Restore data segment.

;Load RGBA color table from bitmap_file: RGBA = 8-8-8-0 bits.

        xor cx,cx
        mov dx,36h                      ;First color table(see doc).
        mov ah,42h
        mov al,0h
        int 21h                         ;Seek file.
        mov ah,3Fh
        mov cx,400h                     ;256colors * 4 rgba bytes. 1024.
        lea dx,palette_rgba
        int 21h

        mov bx,[file_handler]           ;Close file.
        mov ah,3Eh
        int 21h

;Reverse screen vertical.

        mov ax,SCR_GFX_ADDR
        mov es,ax
        xor si,si
        mov di,0F8C0h                  ;64000-320
        mov cx,64h                     ;200/2 = 100
        cld
Dem7:   mov bx,0A0h                    ;320 / 2 = 160 words to move.
        push si
        push di
Dem6:   mov ax,es:[si]
        mov dx,es:[di]
        mov es:[si],dx
        mov es:[di],ax
        inc si
        inc si
        inc di
        inc di                          ;Next pair of pixels.
        dec bx
        jnz short Dem6
        pop di
        pop si
        add si,140h                     ;+320.
        sub di,140h
        dec cx
        jnz short Dem7

;Usin BIOS setup DAC.

        lea si,palette_rgba
        mov ax,1010h
        xor bx,bx                       ;First RGB -> 18bit + 6Bit = 24bit
        mov di,100h                     ;256 colors.
Dem8:   mov dh,ds:[si+2]
        mov ch,ds:[si+1]                ;dl -> cl
        mov dl,ds:[si+0]
        mov cl,2h                       ;8Bit color -> 6bit color.
        shr ch,cl
        shr dl,cl
        shr dh,cl
        mov cl,dl
        int 10h
        inc bx
        add si,04h                      ;Next table color.
        push ax
        mov ax,01h
        call near TimerDelay
        pop ax
        dec di
        jnz short Dem8

        lea bx,bitmap_file
        mov ah,[bx+9]
        inc ah
        cmp ah,":"
        jne short Dem10
        mov ah,[bx+8]
        inc ah
        mov ds:[bx+8],ah                ;Bad code.
        mov ah,"0"
Dem10:  mov [bx+9],ah                   ;Digits.
        mov ah,00h                      ;Press any key.
        int 16h
        pop ax
        dec al
        jnz Dem9                        ;No 16bit, near.

        jmp near Dem0

        ;call near ColorTableDraw

;Make default DAC with simple increment.

        mov al,00h
        mov cx,100h
        lea di,palette
Dem1:   mov ds:[di],al                  ;Set all colors.
        mov ds:[di+1],al
        mov ds:[di+2],al
        add di,3h
        inc al
        loop Dem1

;Set full RGB colors for VGA.

        lea bx,palette
        mov dx,bx
        mov ch,00h                      ;All 256 colors.
Dem3:   mov cl,40h                      ;64 max intensity for color.
        mov al,ch
        xor ah,ah
        mov di,ax                       ;Offset for color component.
Dem2:   mov byte ds:[bx+0],0            ;Clear color.
        mov byte ds:[bx+1],0
        mov byte ds:[bx+2],0
        mov ds:[bx+di],ah               ;Save one component.
        add bx,03h                      ;Next color.
        inc ah
        dec cl
        jnz short Dem2
        inc ch
        cmp ch,03h                      ;Order.
        jnz short Dem3

;Set all colors, using BIOS function.

        mov ax,1012h                    ;Set all palette.
        xor bx,bx                       ;First color index.
        mov cx,100h                     ;Colors counter.
        lea dx,palette                  ;Palette data, RGB.
        int 10h

        call near ColorTableDraw

;Set DAC palette using ports VGA (Daniil).


Dem0:   mov ah,00h                      ;Press any key...
        int 16h

        popf
        ret

bitmap_file     db "SCR\SCR_00.BMP",0
file_handler    dw 0000h
extra_data_seg  dw 0000h
palette         db 100h * 03h dup (0)
palette_rgba    db 100h * 04h dup (0)

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

;Library procedures.

;Timer later.

TimerDelay:
        pushf
        push ax
        push bx
        push dx
        push di
        push es
        mov bx,ax
        mov ax,0x0040
        mov es,ax
        mov di,0x006C
        mov dx,es:[di]
TimDel1:mov ax,es:[di]
        sub ax,dx
        cmp ax,bx
        jc short TimDel1
        pop es
        pop di
        pop dx
        pop bx
        pop ax
        popf
        ret

%include "vgax_lib.asm"
