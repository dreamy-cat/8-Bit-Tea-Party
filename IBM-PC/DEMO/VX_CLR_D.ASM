;8-Bit Tea Party!
;Licinse: Creative Commons.

;Example for VGA-X:Clear procedure in library.
;Пример использования процедуры очистки или заполнения экрана в режиме Х,
;для библиотеки VGA-X.

%include "global.asm"

        org 100h
        xor ax,ax
        ret

%include "vgax_lib.asm"
