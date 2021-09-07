;8-Bit Tea Party! 2021.
;License: Creative Commons.
;Platform: 8086/87, VGA(256Kb), DOS.
;Tools: NASM.
;Author: Dmitry Galashin.

;Example for VGA-X:Clear procedure in library.

;Пример использования процедуры очистки или заполнения экрана в режиме Х,
;для библиотеки VGA-X, можно использовать все страницы видео памяти с разными
;данными.

%include "VGA-X.ASM"

        org 100h
        pushf

        popf
        ret

%include "VX_SYS.asm"
