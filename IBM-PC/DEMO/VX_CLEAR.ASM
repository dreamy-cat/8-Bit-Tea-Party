;8-Bit Tea Party! 2021.
;License: Creative Commons.
;Platform: CPU 8086\87, GPU VGA, REAL MODE, DOS.
;Tools: NASM.
;Author: Dmitry Galashin.

;Clear all or part of video memory in Mode-X of VGA with color.

CPU 8086

%include "vga-x.asm"

	org 100h
	pushf
	;call near VXSetModeX

	mov ah,00h		;Press any key.
	int 16h

	popf
	ret

;Процедура очистки экрана в режиме Х.
;Вход:
;AL	index color to fill;
;AH	index of page(0..2);
;Output: videobuffer.

VXClearScreen:
        pushf

        popf
        ret
