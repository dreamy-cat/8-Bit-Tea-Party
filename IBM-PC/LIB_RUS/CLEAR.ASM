; ��楤�� ���⪨ ⥪�⮢��� ���� ��࠭�. �� ��ࠬ���� ०��� ����� 
;���譨�� ��ࠬ��ࠬ�. ���㬠�� ���� � ��⥬�� 䠩� �� �뭥�� ��� ��⠢���.
; �室:
;AH	��ਡ�� ᨬ���� �� �ଠ�� ⥪�⮢��� ��࠭�.
;AL   ᨬ��� ��� ����������.
;DL   ��⮢� ���� �������⥫��� ����஥�:
;0    �ᯮ�짮���� �� ᨬ���� ��� ����������.
;1    �ᯮ�짮���� �� ��ਡ�� �� ���⪨ ��/���.
;2-7  १��.
; ��室: ���������� ���� ��࠭� � ��⮬ ����஥�.

ClearScreen:	; ! �������� ClTxtS ���� �� ClrScr[0,1 � �.�.]
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
