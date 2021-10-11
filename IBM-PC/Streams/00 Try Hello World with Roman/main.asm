text segment 'code'
     assume CS:text, DS:text

begin:
	mov	ax,data				;загрузка адреса сегмента данных
	mov	dx,ax				;в ds через ax
	mov	ah,09h				;функция dos вывода $-строки на экран
	mov	dx,offset message		;загрузка адреса строки
	int	21h				;вызов DOS
	mov	ax,4c00h			;функция завершения программы код - 0
	int	21h				;вызов dos
 text ends
data  	segment
	message 	db 80*25 dup (' '),10,13		;блок пробелов для очистки экрана
			db 9, 'Hello world!',10,13		;форматированая строковая
			db 9, 'This is a multiline',10,13	;переменая с разделением
			db 9, 'formatted text',10,13	;строк
			db 9, 'displaying program';
			db 9, 'with screen clearing$'
data ends
stk 	segment stack 'stack'
	dw 128 dup(0)
stk ends
	end begin
