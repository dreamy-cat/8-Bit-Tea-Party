;Simple random function for register A.
;Authours: Alexander
;
;Function returns random 8-bit value,
;in register A, using simple arthmetic
;and bit operators.
;Distribution not so good but fast. 
;Needs global name 'RANDOM_INIT' to
;initialization - EQU #NN DEFB, ALASM.
;
;Parameters:
;-
;
;Returns:
;A      random value [0..255].
;
;Function does not restored flags, and
;if RANDOM_INIT is zero, then no random.
;Platforms: SPECTRUM,PENTAGON  48K,128K.
;Assemble: ALASM v5.09.
;Code size: 28 bytes.
;Static data size: 2 bytes.
;Performance: 
;
;Функция простой генерации примерно
;случайного числа для регистра А.
;Автор: Александр
;
;Функция возвращает случайное значение в
;регистре А, используя минимальную
;арифметику и операции с битами.
;Распределение далеко от идеального,
;но вроде бы работает быстро.
;Используется глобальное имя, константа
;"RANDOM_INIT EQU #NN", размер байт, для
;инициализации последовательности.
;
;Параметры:
;-
;
;Возврат(регистры или память):
;А	случайное значение [0..255].
;
;Функция не сохраняет состояние флагов
;и если значение RANDOM_INIT равно нулю,
;то и последовательность будет вся 0.
;
;Платформы: Спектрум, Пентагон 48К, 128К.
;Ассемблер: АЛАЗМ 5.09.
;Размер кода: 28 байт.
;Размер статичных данных: 2 байта.
;Производительность: быстро! :)

RANDOM_INIT	EQU #10

RANDOM_DATA:    DB RANDOM_INIT
                DB #00

RANDOM_SIMPLE:
        PUSH BC
        LD A,(RANDOM_DATA)      ;INIT
        AND %00001111   ;MASK
        JR Z,RND_1
        LD B,A          ;15 ROTATIONS
        LD A,(RANDOM_DATA)
RND_2:  RLA             ;ROTATE
        DJNZ RND_2
RND_1:  LD BC,(RANDOM_DATA)
        XOR C           ;BITS MANIPUL
        ADD A,B
        LD B,C
        LD C,A
        LD (RANDOM_DATA),BC
        POP BC
        RET             ;RETURN A
