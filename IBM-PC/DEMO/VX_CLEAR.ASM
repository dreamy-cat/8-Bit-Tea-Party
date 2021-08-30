;8-Bit Tea Party!
;License: Creative Commons.

;Clear all or part of video memory in Mode-X of VGA with color.

%include "global.asm"

VXClearScreen:
        pushf

        popf
        ret

%include "vgax_lib.asm"
