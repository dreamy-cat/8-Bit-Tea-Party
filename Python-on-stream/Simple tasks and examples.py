# Простые программки и примеры на Питоне, для вещаний на канале "Восьмибитное Чаепитие".
# Simple tasks and examples on Python, for streams on '8-Bit Tea Party'.

'''
1 Введение.
2 Переменные, типы данных и операторы.
3 Списки, словари, кортежи и множества.
4 Управляющие конструкции и базовые структуры.
5 Модули и пакеты.
6 Объекты и классы.
7 Строки, форматы и регулярные выражения.
8 Файлы, общие вопросы. И работа с БД.
9 Работа с сетью. Фреймворки.
10 Системные вызовы, процессы, потоки и дата и время.
11 Многопоточность и может сокеты.
12 Дополнительное вещание. Практические рекомендации.
'''

print('Hello World!')
print('Part 2. Types and variables.')
a = 3; b = a; f = 1.5; str1 = "Hi!"
print("Integers A and B and types:", a, b, type(a), type(b))
print("Floating point F and type:", f, type(f))
print("String 'Hi!' and type -", str1, type(str1))
r = (a - b + a * b) / a
print("All basic operators for integers (A - B + A * B) / A =", r)
r = a * a // b
print("Integer division A * A // B =", r)
r = a * a % 5
print("Remainder of the division A * A % B =", r)
b = b + 1; b += 1
print("Binary 15:", 0b1111)
print("Octal 10:", 0o12)
print("Hexidecimal 12:", 0x0C)
print("Integers for boolean True and False:", int(True), int(False))
print("Integer from string '7',", int("7"))
print("Intger from floating point '3.9',", int(3.9))
print("Boolean True and False to floating point,", float(True), float(False))
print("Integer '-5' to floating point,", float(-5))
str2 = "Hello"; str3 = "World!"
str4 = str2 + " " + str3;
print("Two strings combined -", str4)
print("Multiply string 'World!' - ", str3 * 3)
print("Tab next position\tBackslash\\")
print("Char from string, index 3 - ", str2[2])
print("Substring from 2 to 10 -", str4[2:10])
print("Substring from 2 to 8, step 2 -", str4[2:8:2])
print("Substring from 0 to 5, step 2 -", str4[:5:2])
print("Length string str4, ", len(str4))
str5 = "Alpha, Beta, Gamma"
lst = str5.split(', ')
print("Split string with commas -", lst)
str6 = ', '.join(lst)
print("Join words to string -", str6)
print("Is string starts with 'Alpha',", str6.startswith('Alpha'))
print("Is string ends with 'Gamma',", str6.endswith('Gamma'))
print("Position of 'Beta',", str6.find('Beta'))
print("Back position of 'Beta',", str6.rfind('Beta'))
print("Char 'a' count in string,", str6.count('a'))
print("Is string contains chars and digits,", str6.isalnum())
print("Cut chars from begin and end, ", str6.strip('a'))
str7 = "the fat cat"
print("Capitalize first char -", str7.capitalize())
print("Title all words -", str7.title())
print("Upper chars in string,", str7.upper())
print("Lower char in string,", str7.lower())
print("Left justify in field:", str7.ljust(25))
print("Right justify in field:", str7.rjust(25))
print("Center justify in field:", str7.center(25))
print("Fat cat becomes funny -", str7.replace("fat", "funny", 1))

secondsPerHour = 60 * 60
print("Seconds per hour,", secondsPerHour)
secondsPerDay = secondsPerHour * 24
print("Seconds per day,", secondsPerDay)
print("Hours per day with /:", secondsPerDay / secondsPerHour)
print("Hours per day with //:", secondsPerDay // secondsPerHour)
