;8-Bit Tea Party! 2021.
;License: Creative Commons.

;Names and constants for VGA Mode-X library, use for all procedures in code.
;Do not define any data, variables or code.

;����� � ����⠭�� �⭮��騥�� � ������⥪� VGA Mode-X, �� ��楤���.
;�� ��।��塞 ��६����, ����� ��� ���, ����� ����� �� �㫥��� ࠧ���.
;���஡��� � ਣ�����, ������� � ������ ����� ��ᬮ���� � ���㬥��樨.

;VGA video memory layout. ISA 16 bit data bus, 256Kb model.
;4 maps(0..3), 64Kb each, total 256Kb(standard).
;Config: 64Kb from 0xA000 address, 4 planes.
;Planes: 2 bits for every pixel in every plane, total 8bit.
;Colors: 256 table, RGB(6-6-6) bits, from 18bits total 256K colors.

;VGA I/O registers, as standard on 1992.

;General registers.

VGA_MISC_WRITE          EQU 3C2h        ;
VGA_MISC_READ           EQU 3CCh        ;
VGA_INPUT_STATUS_1      EQU 3DAh        ;Input status register 1, using VSync.

;Sequencer registers.

VGA_SEQUENCER_ADDR      EQU 3C4h        ;out dx,ax 16-bit port output.
VGA_SEQUENCER_DATA      EQU 3C5h        ;

;CRT controller register.

VGA_CRT_ADDR            EQU 3D4h        ;Or 3B4 for MDA, using bit selector.
VGA_CRT_DATA            EQU 3D5h
VGA_START_HIGH_ADDR     EQU 00Ch        ;High 8-bit of address regen. buffer.
VGA_START_LOW_ADDR      EQU 00Dh        ;Low 8-bit of address regen. buffer.

;Graphics controller registers.

VGA_GRAPHICS_ADDR       EQU 3CEh
VGA_GRAPHICS_DATA       EQU 3CFh

;Video DAC palette registers.

VGA_DAC_WRITE           EQU 3C8h
VGA_DAC_READ            EQU 3C7h
VGA_DAC_DATA            EQU 3C9h
VGA_PEL_MASK            EQU 3C6h

;Other constants using in library.

VGA_PLANES_MASK         EQU 00001111b   ;��᪠ ��� ��� ������ VGA.

;Global constants, may be later wiil move to GLOBAL.ASM
;��騥 ����⠭�� �易��� � ��䨪��, ���� ��⠢�� �����, �� �������� ��
;� ���饬 ��७�ᥬ � 䠩� �������� ��� ��� �஥�⮢.
;�ᯮ��㥬 �������� ����ன�� ��࠭� �� ᥩ��, ����� �������� �������.

SCR_GFX_ADDR            EQU 0A000h      ;�������� ���� ����᪮�� ��࠭�.
SCR_GFX_SIZE_BYTES      EQU 000012C00h  ;������ ��࠭� � �����, 76800.
SCR_GFX_SIZE_PAR        EQU 012C0h      ;������ ��࠭� � ��ࠣ���(16), 4800.
SCR_GFX_PLANE_SIZE      EQU 04B00h      ;������ �-����� � �����, 19200.
SCR_GFX_ALL_PAGES       EQU 003h        ;�ᥣ� ��࠭�� � ०��� �.
SCR_GFX_PAGE_0_OFFS     EQU 00000h      ;���饭�� �㫥��� ��࠭���.
SCR_GFX_PAGE_1_OFFS     EQU 04B00h      ;��ࢠ� ��࠭��� ��� ०��� 320*240.
SCR_GFX_PAGE_2_OFFS     EQU 09600h      ;���� ��࠭�� ��� ०��� 320*240.
SCR_GFX_WIDTH           EQU 0140h       ;320 �祪 �� �ਭ�.
SCR_GFX_HEIGHT          EQU 00F0h       ;240 �祪 �� ����.
SCR_GFX_COLORS          EQU 00100h      ;256 梥⮢ �� ⠡���.
SCR_GFX_BPP             EQU 008h        ;������⢮ ��� �� ���.
SCR_GFX_BPC             EQU 006h        ;������⢮ ��� �� ��������� 梥�.
