# Простые программки и примеры на Питоне, для вещаний на канале "Восьмибитное Чаепитие".
# Simple tasks and examples on Python, for streams on '8-Bit Tea Party'.

# https://github.com/dreamy-cat/8-Bit-Tea-Party
# https://github.com/nquidox/learn2python

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
# Практическая часть, глава 2.
secondsPerHour = 60 * 60
print("Seconds per hour,", secondsPerHour)
secondsPerDay = secondsPerHour * 24
print("Seconds per day,", secondsPerDay)
print("Hours per day with /:", secondsPerDay / secondsPerHour)
print("Hours per day with //:", secondsPerDay // secondsPerHour)
# Вещание 3, теоретическая часть.
print("\nStream 3. Lists, vectors, maps and sets.\n")
list1 = ['a', 'b', 'c']; list2 = list(); list3 = list("Alpha")
print("Simple, empty and converted list:", list1, list2, list3)
tuple1 = ('d', 'e', 'f'); list4 = list(tuple1)
print("Create list from tuple:", list4)
str1 = "8-Bit Tea Party"; list5 = str1.split(' ')
print("Convert list from string:", list5)
print("Second element in list:", list5[1])
list6 = [list4, list5]; list4[0] = 'D'
print("List of lists, second element and range[1,2]:", list6, list6[1], list6[1][1:3])
list5.append("Stream")
print("List inversion and append with element:", list5[::-1], list5)
list4.extend(list3)
print("Extended list with other list:", list4)
list4.insert(2, 'E'); del list4[3]; list4.remove('h')
print("Insert 'E' to [2], delete [3] and remove 'h':", list4)
isA = 'a' in list4;
idx1 = list4.index('a')
c1 = list4.pop()
print("Existance of 'a' in list, index and pop operator:", isA, idx1, c1)
c2 = list4.count('e'); list4.sort(reverse = True); l1 = len(list4);
print("Count 'e' in sorted list and length:", c2, list4, l1)
str2 = ' '.join(list5)
print("List to string conversion:", str2)
list7 = list4; list8 = list4.copy()
list7[0] = 'B'
print("Previous list [0] element updated and it's copy:", list4, list8)
tuple2 = 'a', 'b', 'c'; tuple3 = ('d', 'e'); tuple4 = ('f', 'g'); c3, c4 = tuple3
print("Tuple sources, chars:", tuple2, tuple3, tuple4, c3, c4)
tuple3, tuple4 = tuple4, tuple3
print("Tuples exchanged:", tuple3, tuple4)
dict1 = {}; dict2 = { "a" : 1, "b" : 2 }; dict3 = dict([['a', 3], ['c', 4]])
dict4 = dict(('d5', 'e6'))
print("Source dictionaries:", dict1, dict2, dict3, dict4)
dict4['f'] = 7
dict2.update(dict3)
del dict2['b']
print("Create new element, update all elements and delete 'b' in dictionary:", dict4, dict2)
dict2.clear()
isA = 'a' in dict2
print("Is element 'a' in cleared dictionary:", isA, dict2)
print("Element in dictionary with ['e'] and get('e') element:", dict4['e'], dict4.get('e'))
print("All keys, values and items in dictionary:", dict4.keys(), dict4.values(), dict4.items())
dict5 = dict3; dict6 = dict3.copy()
dict5['c'] = 5; dict6['c'] = 6
print("Source, reference and copy of dictionaries:", dict3, dict5, dict6)
set1 = set(); set2 = { 1, 2, 3 }; set3 = { 2, 3 }; set4 = set("alpha")
set5 = (['a', 'b', 'c']); set6 = set({ "d" : 1, "e" : 2}); set7 = set(('f', 'g', 'h'))
print("Source sets and string:", set1, set2, set3, set4)
print("Sets from other data, 'g' in last set:", set5, set6, set7, 'g' in set7)
print("Result sets in operations 'and', 'or' and 'xor':", set2 & set3, set2 | set3, set2 ^ set3)
print("Result of simple compare:", set2 > set3, set2 < set3, set2.issubset(set3), set2.issuperset(set3))
# Вещание 3, практическая часть.
divider = "\n";
print("Вывод результатов упражнений к 3 главе.")
print(divider)
#Задание 1.
#Создайте список years_list, содержащий год, в который вы родились,
#и каждый последующий год вплоть до вашего пятого дня рождения.
years_list=['1985']
i=1
while i<=5:
	add_year=str(int(years_list[0])+i)
	years_list.append(add_year)
	i+=1
print(years_list)
#Задание 2.
#В какой из годов, содержащихся в списке years_list, был ваш третий день рождения?
third_birthday=years_list[3]
print("Третий день рождения был в", third_birthday, "году.")
#Задание 3.
#В какой из годов, перечисленных в списке years_list, вам было больше всего лет?
max_age=years_list[-1]
print("Из списка годов больше всего лет мне было в", max_age, "году.")
print(divider)
#Задание 4.
#Создайте список things, содержащий три элемента:
#"mozzarela", "cinderella", "salmonella"
things=['mozzarela', 'cinderella', 'salmonella']
#Задание 5.
#Напишите с большой буквы тот элемент списка things, который
#относится к человеку, а затем выведете список.
things[1].capitalize()
print('Изменится ли значение, при таком варианте?\n', things, '\nКак видим - не изменилось.')
things[1]=things[1].capitalize()
print('Оно изменится в списке в том случае, если мы сделаем присваивание нового значения элементу списка:\n', things)
#Задание 6.
#Переведите сырный элемент списка things в верхний регистр целиком и выведете список.
things[0]=things[0].upper()
print("Сыр теперь капсом", things)
#Задание 7.
#Удалите болезнь из списка things, получите Нобелевскую премию
#и затем выведите список на экран.
things.pop()
win_Nobel_prize=True
print("Болезни больше нет: ", things)
if win_Nobel_prize:
	print("И за это мы получили Нобелевскую премию!")
print(divider)
#Задание 8.
#Создайте список, который называется surprise и содержит элементы 'Groucho', 'Chico', 'Harpo'.
surprise=['Groucho', 'Chico', 'Harpo']
#Задание 9.
#Напишите последний элемент списка surprise со строчной буквы, затем обратите его и напишите с прописной буквы.
name_from_surprise_list=surprise[-1].lower()
print("Последний элемент строчными буквами:", name_from_surprise_list)
inverted_name=name_from_surprise_list[::-1].capitalize()
print("Обратили имя и написали с заглавной буквы:", inverted_name)
print(divider)
#Задание 10.
#Создайте англо-французский словарь, который называется e2f,
#и выведите его на экран.
e2f={"dog" : "chien", "cat" : "chat", "walrus" : "morse"}
#Задание 11.
#Используя словарь e2f, выведите французский вариант слова walrus.
print("Французский вариант слова walrus:", e2f.get("walrus"))
#Задание 12.
#Создайте французско-анлийский словарь f2e на основе словаря e2f. Используйте метод items.
f2e = { v:k for k,v in e2f.items() }
print("Французско-анлийский словарь:", f2e)
#Задание 13.
#Используя словарь f2e, выведите английский вариант слова chien.
print("Английский вариант слова chien:", f2e.get("chien"))
#Задание 14.
#Создайте и выведите на экран множество английских слов из ключей словаря e2f.
print("Множество из словаря e2f:", set(e2f))
print(divider)
#Задание 15.
#Создайте многоуровневый словарь life. Используйте следующие строки для
#ключей верхнего уровня: 'animals', 'plants' и 'other'.
#Сделайте так, чтобы ключ 'animals' ссылался на другой словарь, имеющий
#ключи 'cats', 'octopi' и 'emus'. Сделайте так, чтобы ключ 'cats'
#ссылался на список строк со значениями 'Henri', 'Grumpy' и 'Lucy'.
#Остальные ключи должны ссылаться на пустые словари.
cats_list=['Henri', 'Grumpy', 'Lucy']

animals_dict={
	"cats" : cats_list,
	"octopi" : "",
	"emus" : "",
}

life={
	"animals" : animals_dict,
	"plants" : "",
	"other" : "",
}

#Задание 16.
#Выведите на экран высокоуровневые ключи словаря life.
print("Высокоуровневые ключи словаря life:", life.keys())
#Задание 17.
#Выведите на экран ключи life['animals']
print("Ключи словаря life['animals']:", life['animals'].keys())
#Задание 18.
#Выведите значения life['animals']['cats']
print("Ключи словаря life['animals']['cats']:", life['animals']['cats'])
print(divider)
dict7 = { "colors" : {"red" : 0, "green" : 1}, "shapes" : ["square", "circle"] }
print("Complex data:", dict7, dict7.keys(), dict7['colors'].keys(), dict7['colors'].values(), dict7['shapes'])
