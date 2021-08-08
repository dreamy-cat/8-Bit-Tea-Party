;Warning! This values doesn't tested yet, be careful with real hardware.

;File with all parameters to CRT Controller of VGA adapter.
;Using to setup Mode-X, 320 horizontal, 240 vertical, 256 colours.
;Format: PORT 0x3C2...
;INDEX register VGA, first DB, see doc for VGA.
;DATA, use AX register and OUT DX,AX command.
;Tweaker by Robert Schmidt(links later).

;Файл со всеми параметрами для контроллера электронно-лучевой трубки, при
;настройке режима Х, адаптера VGA, размеры 320*200 точек и 256 цветов.
;Формат: порты: 0x3C2 и т.д.
;Индекс регистра адаптера в первой строке.
;Данные - параметр для записи в порт.
;Удобней всего использовать AX аккумулятор и команду OUT DX,AX.

mode_x_table:           ;All values for ports.

;0x3C2
        db 00h
        db 0E3h
;0x3d4
        db 00h
        db 5Fh
        db 01h
        db 4Fh
        db 02h
        db 50h
        db 03h
        db 82h
        db 04h
        db 54h
        db 05h
        db 80h
        db 06h
        db 0Dh
        db 07h
        db 3Eh
        db 08h
        db 00h
        db 09h
        db 41h
        db 10h
        db 0EAh
        db 11h
        db 0ACh
        db 12h
        db 0DFh
        db 13h
        db 28h
        db 14h
        db 00h
        db 15h
        db 0E7h
        db 16h
        db 06h
        db 17h
        db 0E3h
;0x3C4
        db 01h
        db 01h
        db 04h
        db 06h
;0x3CE
        db 05h
        db 40h
        db 06h
        db 05h
;0x3C0
        db 10h
        db 41h
        db 13h
        db 00h
