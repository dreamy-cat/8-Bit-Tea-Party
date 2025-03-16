; Процедура очистки текстового буфера экрана. Все параметры режима являются 
;внешними параметрами. Подумать пока в системный файл их вынести или оставить.
; Вход:
;AH	атрибут символа по формату текстового экрана.
;AL   символ для заполнения.
;DL   битовые поля дополнительных настроек:
;0    использовать ли символы для заполнения.
;1    использовать ли атрибут при очистки ДА/НЕТ.
;2-7  резерв.
; Выход: заполнение буфера экрана у учетом настроек.

ClearScreen:	; ! Заменить ClTxtS просто на ClrScr[0,1 и т.д.]
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
