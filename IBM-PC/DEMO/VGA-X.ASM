;8-��� �����⨥! 2021.
;��業���: Creative Commons.
;�����ଠ: 8086, VGA(256Kb), BIOS.
;�����㬥���: NASM(2.15.05).
;���㫨: ���� �� ᠬ� �����.
;�����: ����ᠭ�� ��஢(funny.dreamy.cat@gmail.com).
;����த���⢨�: �ਬ�୮� ������⢮ ⠪⮢ ��� ������ ��楤���.
;������: ��楤_1 = N, ��楤_2 �������� � ����.
;��⪠� ����� ���������:
;25.09.21, �.�.: ������讥 ���������� ���������, ��⠫쭮� ��������.

;Global names, constants and structures for VGA Mode-X graphics library,
;use for all procedures and data in code, no memory allocated.
;Do not define any data, variables or code.

;�������� �����, ����⠭�� � �������� ����᪮� ������⥪� VGA Mode-X.
;�� ��।��塞 ��६����, ����� ��� ���, ����� ����� �� �㫥��� ࠧ���.
;���஡��� � ਣ�����, ������� � ������ ����� ��ᬮ���� � ���㬥��樨.

;VGA library for Mode-X, 320*240*256 colours with pixel's planes.
;Warning! Using library on real hardware is not recommended and can damage
;your monitor/adapter. Tested only in DOSBox. :)

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

;Global constants and names for Mode-X graphics library.
;��騥 ����⠭�� �易��� � ��䨪��, ���� ��⠢�� �����, �� �������� ��
;� ���饬 ��७�ᥬ � 䠩� �������� ��� ��� �஥�⮢.
;�ᯮ��㥬 �������� ����ன�� ��࠭� �� ᥩ��, ����� �������� �������.

GFX_SCR_ADDR            EQU 0A000h      ;�������� ���� ����᪮�� ��࠭�.
GFX_SCR_WIDTH           EQU 00140h      ;320 �祪 �� �ਭ�, ᫮��.
GFX_SCR_HEIGHT          EQU 000F0h      ;240 �祪 �� ����, ᫮��.
GFX_SCR_SIZE_B          EQU 000012C00h  ;������ ��࠭� � �����, 76800.
GFX_SCR_SIZE_W          EQU 09600h      ;������ ��࠭� � ᫮���, 38400.
GFX_SCR_SIZE_P          EQU 012C0h      ;������ ��࠭� � ��ࠣ���, 4800.
GFX_PLANE_SIZE_B        EQU 04B00h      ;������ �-����� � �����, 19200.
GFX_PLANE_SIZE_W        EQU 02580h      ;������ �-����� � ᫮���, 9600.
GFX_PLANE_SIZE_P        EQU 004B0h      ;������ �-����� � ��ࠣ���, 1200.
GFX_ALL_PAGES           EQU 003h        ;�ᥣ� ��࠭�� � ०��� �.
GFX_PAGE_SIZE_B         EQU 04B00h      ;������ ��࠭��� � �����, 19200.
GFX_PAGE_SIZE_W         EQU 02580h      ;������ ��࠭��� � ᫮���, 9600.
GFX_PAGE_SIZE_P         EQU 004B0h      ;������ ��࠭��� � ��ࠣ���, 1200.
GFX_PAGE_0_OFFS         EQU 00000h      ;���饭�� �㫥��� ��࠭���.
GFX_PAGE_1_OFFS         EQU 04B00h      ;��ࢠ� ��࠭��� ��� ०��� 320*240.
GFX_PAGE_2_OFFS         EQU 09600h      ;���� ��࠭�� ��� ०��� 320*240.
GFX_COLORS              EQU 00100h      ;256 梥⮢ �� ⠡���.
GFX_BPP                 EQU 008h        ;������⢮ ��� �� ���.
GFX_BPC                 EQU 006h        ;������⢮ ��� �� ��������� 梥�.
GFX_BYTES_PER_LINE      EQU 050h        ;���� �� ������ ����� ���ᥫ��.
