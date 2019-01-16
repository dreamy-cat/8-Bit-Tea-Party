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

import sys

# Вещание 1. Введение.
print('Hello World!')

# Вещание 2. Переменные и типы данных, теория.
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

# Вещание 2. Практическая часть.
secondsPerHour = 60 * 60
print("Seconds per hour,", secondsPerHour)
secondsPerDay = secondsPerHour * 24
print("Seconds per day,", secondsPerDay)
print("Hours per day with /:", secondsPerDay / secondsPerHour)
print("Hours per day with //:", secondsPerDay // secondsPerHour)

# Вещание 3. Списки, словари, кортежи и множества, теория.
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

# Вещание 3. Списки, словари, кортежи и множества, практическая часть.
divider = "\n";
print("Вывод результатов упражнений к 3 главе.")
print(divider)

# Задание 1.
# Создайте список years_list, содержащий год, в который вы родились,
#и каждый последующий год вплоть до вашего пятого дня рождения.
years_list=['1985']
i=1
while i<=5:
	add_year=str(int(years_list[0])+i)
	years_list.append(add_year)
	i+=1
print(years_list)
# Задание 2.
# В какой из годов, содержащихся в списке years_list, был ваш третий день рождения?
third_birthday=years_list[3]
print("Третий день рождения был в", third_birthday, "году.")
# Задание 3.
# В какой из годов, перечисленных в списке years_list, вам было больше всего лет?
max_age=years_list[-1]
print("Из списка годов больше всего лет мне было в", max_age, "году.")
print(divider)
# Задание 4.
# Создайте список things, содержащий три элемента: "mozzarela", "cinderella", "salmonella".
things=['mozzarela', 'cinderella', 'salmonella']
# Задание 5.
# Напишите с большой буквы тот элемент списка things, который относится к человеку, а затем выведете список.
things[1].capitalize()
print('Изменится ли значение, при таком варианте?\n', things, '\nКак видим - не изменилось.')
things[1]=things[1].capitalize()
print('Оно изменится в списке в том случае, если мы сделаем присваивание нового значения элементу списка:\n', things)
# Задание 6.
# Переведите сырный элемент списка things в верхний регистр целиком и выведете список.
things[0]=things[0].upper()
print("Сыр теперь капсом", things)
# Задание 7.
# Удалите болезнь из списка things, получите Нобелевскую премию и затем выведите список на экран.
things.pop()
win_Nobel_prize=True
print("Болезни больше нет: ", things)
if win_Nobel_prize:
	print("И за это мы получили Нобелевскую премию!")
print(divider)
# Задание 8.
# Создайте список, который называется surprise и содержит элементы 'Groucho', 'Chico', 'Harpo'.
surprise=['Groucho', 'Chico', 'Harpo']
# Задание 9.
# Напишите последний элемент списка surprise со строчной буквы, затем обратите его и напишите с прописной буквы.
name_from_surprise_list=surprise[-1].lower()
print("Последний элемент строчными буквами:", name_from_surprise_list)
inverted_name=name_from_surprise_list[::-1].capitalize()
print("Обратили имя и написали с заглавной буквы:", inverted_name)
print(divider)
# Задание 10.
# Создайте англо-французский словарь, который называется e2f, и выведите его на экран.
e2f={"dog" : "chien", "cat" : "chat", "walrus" : "morse"}
# Задание 11.
# Используя словарь e2f, выведите французский вариант слова walrus.
print("Французский вариант слова walrus:", e2f.get("walrus"))
# Задание 12.
# Создайте французско-анлийский словарь f2e на основе словаря e2f. Используйте метод items.
f2e = { v:k for k,v in e2f.items() }
print("Французско-анлийский словарь:", f2e)
# Задание 13.
# Используя словарь f2e, выведите английский вариант слова chien.
print("Английский вариант слова chien:", f2e.get("chien"))
# Задание 14.
# Создайте и выведите на экран множество английских слов из ключей словаря e2f.
print("Множество из словаря e2f:", set(e2f))
print(divider)
# Задание 15.
# Создайте многоуровневый словарь life. Используйте следующие строки для
#ключей верхнего уровня: 'animals', 'plants' и 'other'.
# Сделайте так, чтобы ключ 'animals' ссылался на другой словарь, имеющий
#ключи 'cats', 'octopi' и 'emus'. Сделайте так, чтобы ключ 'cats'
#ссылался на список строк со значениями 'Henri', 'Grumpy' и 'Lucy'.
# Остальные ключи должны ссылаться на пустые словари.
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

# Задание 16.
# Выведите на экран высокоуровневые ключи словаря life.
print("Высокоуровневые ключи словаря life:", life.keys())
# Задание 17.
# Выведите на экран ключи life['animals']
print("Ключи словаря life['animals']:", life['animals'].keys())
# Задание 18.
# Выведите значения life['animals']['cats']
print("Ключи словаря life['animals']['cats']:", life['animals']['cats'])
print(divider)
dict7 = { "colors" : {"red" : 0, "green" : 1}, "shapes" : ["square", "circle"] }
print("Complex data:", dict7, dict7.keys(), dict7['colors'].keys(), dict7['colors'].values(), dict7['shapes'])

# Вещание 4. Структура программы и управляющие конструкции. Теоретическая часть.
str1 = "abc" \
"def" \
"ghi"
print("\nChapter 4.\n");
print("Multiple lines in string:", str1)
isCorrect = True; char1 = 'a'; char2 = 'b'
if isCorrect:
	print("If operator, block True.")
	if (char1 == 'a'):
		print("First char is 'A'")
	elif char2 == 'b':
		print("Second char is 'B'")
	else:
		print("Second char isn't 'B'")
else:
	print("If operator, block False.")
if (1 < 5 and 3 > 1 or 1 > 5):
	print("Basic logic, true.")
dict1 = dict()
if dict1:
	print("Dictionary is full.")
else:
	print("Dictionary is empty.")
i = 0; j = 5
while i < 5:
	print(i, end=' ')
	if i == 1:
		print("Skip iteration, i is", i)
		i = 2
		continue
	elif j == 3:
		print("Breaking while, before end.")
		break
	i += 1
else:
	print("All iterations complete.")
list1 = list("abcd"); list2 = list("efgh")
print("All elements in list:", end=' ')
for c1, c2 in zip(list1, list2):
	print(c1, "[", c2, "]", end=' ')
else:
	print("All iterations complete.")
print("Range from 2 to 8, step 2:", end=' ')
for i in range(2, 8, 2):
	print(i, end=' ')
print("\nRange from 8 to 2, step -2:", end=' ')
for i in range(8, 2, -2):
	print(i, end=' ')
list3 = list(range(1,3)); list4 = [n for n in range(0, 5)]
print("\nCreate simple lists from ranges:", list3, list4)
list5 = [n for n in range(0, 10) if n % 3 == 0]
print("Create all numbers with multiply 3:", list5)
list6 = [(x,y) for x in [1, 2] for y in [3,4]]
print("Create list of tuples:", list6)
list7 = list("abcde"); dict2 = { c3 : list7.count(c3) for c3 in list7 }
print("All chars in list, with dictionary:", dict2)
set1 = { n for n in range(0, 10) if n % 2 == 0 }
print("Simple set with range and multiply 2:", set1)
gen1 = (n for n in range(1,4)); list8 = list(gen1)
print("Simple generation to list:", list8)
# Часть с функциями, прямо по тексту.
def function1(str="default", int=0, *args):
	print("Function_1, with string and integer:", str, int)
	print("Extra arguments:", args)
	pass
print("Call function with default arguments.")
function1()
print("Call function with simple arguments.")
function1("Hi!", 5)
print("Call function with extra arguments.")
function1("Hi!", 3, "Hello", "World!")
def function2(**args):
	'Documentation for this function...'
	print("Arguments of function", args)
	pass
function2(arg1="one", arg2 = "two", arg=3)
print("Documentation for function2:", help(function2))
def function3(func, int1):
	print("Calling function...")
	func()
	def intFunc(int1):
		print("Internal function, with parameter:", int1)
		return "Internal function with argument:" + chr(int1)
		pass
	print(intFunc(int1))
	return intFunc
	pass
fObj1 = function3; fObj2 = function2
print("Type of function object:", type(fObj1))
fObj3 = function3(fObj2, 5)
print("Calling out function object,", type(fObj3))
fObj3(3)
def editList(lst, lamb):
	for x in lst:
		print(lamb(x), end=' ')
	pass
list9 = list("abc");
print("Source list and calling with lambda:", list9, end=' ')
editList(list9, lambda x : x.upper())
def generator1(first, last):
	c = first
	while c != last:
		yield c
		c += 1
	pass
gen2 = generator1(1, 3)
print("\nSimple generator:", end = ' ')
for i in gen2:
	print(i, end=' ')
def decorator(arg):
	def function(arg):
		print("Hello", end=' ')
		return arg + '!'
		pass
	return function
	pass
fObj4 = decorator("Hello")
print("\nFunction decorator,", type(fObj4))
print(fObj4("World"))
i2 = 5;
def function4():
	global i2
	i2 += 2; i3 = 5;
	print("Global integer:", i2)
	print("All locals:", locals())
	pass
function4()
idx2 = 5;
try:
	print("Trying to read wrong index in list:", list9[idx2])
except IndexError as e:
	print("Index out of range, list size:", len(list9), e)

# Дополнительный по спискам.
'''
e2f={"dog" : "chien", "cat" : "chat", "walrus" : "morse"}
print(e2f)
#f2e = { v:k for k,v in e2f.items() }
wlist = list(e2f.items())
fdict = { wlist[0][::-1], wlist[1][::-1], wlist[2][::-1] }
print(fdict)
fdict2 = dict(zip(list(e2f.values()), list(e2f.keys())))
print(fdict2)
'''

# Вещание 4-2. Структура программы и управляющие конструкции. Практическая часть.
divider="-------------------------------------------------------------"
print("Вывод результатов упражнений к 4 главе.")
print(divider)
# Задание 1.
# Присвойте значение 7 переменной guess_me. Далее напишите условные
#проверки (if, else, elif), чтобы вывести строку 'too low', если 
#значение переменной guess_me меньше 7, 'too high', если оно больше 7,
#и 'just right', если равно 7.
guess_me = 7.0				#можно сравнивать int с float
if guess_me > 7:
	print('Too high')
elif guess_me < 7:
	print('Too low')
else:
	print('Just right')
print(divider)
# Задание 2.
# Присвойте значение 7 переменной guess_me и значение 1 переменной start.
# Напишите цикл while, который сравнивает переменные start и guess_me.
# Выведите строку 'too low', если значение переменной start меньше значения
#переменной guess_me. Если значение переменной start равно значению переменной
#guess_me, выведите строку 'found it!' и выйдите из цикла. Если значение переменной
#start больше значения переменной guess_me, выведите строку 'oops' и выйдите из цикла.
# Увеличьте значение переменной start на выходе из цикла.
guess_me = 7
start = 1
while start <= guess_me:
	if start < guess_me:
		print(start, 'is too low')
	elif start == guess_me:
		print(start, 'Found it!')
		break
	elif start > guess_me:
		print('oops')
		break
	start += 1
else:
	print("All iterations complete.")
print(divider)
# Задание 3.
# Используйте цикл for, чтобы вывести на экран значения списка [3, 2, 1, 0]
print('Вывод значений списка через цикл:')
c4_list1 = list(range(3,-1,-1))
for i in c4_list1:
	print(i, end=' ')
print(divider)
# Задание 4.
# Используйте включение списка, чтобы создать список, который содержит нечетные
#числа в диапазоне range(10).
c4_list2 = list(range(1,10,2))
c4_list3 = [number for number in range(10) if number % 2 == 1]
print('Создание списка нечетных чисел:', c4_list2, c4_list3)
print(divider)
# Задание 5.
# Используйте включение словаря, чтобы создать словарь squares. Используйте
#вызов range(10), чтобы получить ключи, и возведите их в квадрат, чтобы получить их значения.
squares = {a:a * a for a in c4_list3}
print('Итоговый словарь:', squares)
print(divider)
#Задание 6.
# Используйте включение множества, чтобы создать множество odd, которое 
#содержит четные числа в диапазоне range(10).
odd = {number for number in range(10) if number % 2 == 0}
print('Множество четных чисел:', odd)
print(divider)
# Задание 7.
# Используйте включение генератора, чтобы вернуть строку 'Got' и количество
#чисел в диапазоне range(10). Итерируйте по нему с помощью цикла for.
gen1 = (i for i in range(5)); gen2 = (c for c in "abcde")
print("Используем оба генератора для чисел и букв:", end=' ')
for i, j in zip(gen1, gen2):
	print("[", i, j, "]", end=' ')
print(divider)
# Задание 8.
# Определите функцию good, которая возвращает список ['Harry', 'Ron', 'Hermione']
def good():
	return ['Harry', 'Ron', 'Hermione']
	pass
print('Значения, возвращаемые функцией:', good())
print(divider)
# Задание 9.
# Определите функцию генератора get_odds, которая возвращает четные числа из
#диапазона range(10). Используйте цикл for, чтобы найти и вывести третье
#возвращенное значение.
def get_odds_gen():
	n = 0
	while n in range(10):
		yield n
		n += 2
		pass
gen3 = get_odds_gen();
print('Получаем значения из генерируемого списка:', end=' ')
for n in gen3:
	print(n, end=' ')
print("\n",divider)
# Задание 10.
# Определите декоратор test, который выводит строку 'start', когда вызывается
# функция, и строку 'end', когда функция завершает свою работу.
def test(func):
	def decorated_function():
		print('Start')
		func()
		print('End')
	return decorated_function
	pass
@test
def simple():
	print('Простая функция')
	pass
simple()
print(divider)
# Задание 11
# Определите исключение, которое называется OopsException. Сгенерируйте его,
#чтобы увидеть, что произойдет. Затем напишите код, позволяющий поймать это
#исключение и вывести строку 'Caught an oops'.
class OopsException(Exception):
	pass
try:
	raise OopsException('panic')
except OopsException as exc:
	print('Caught an oops:', exc)
print(divider)
# Задание 12.
# Используйте функцию zip(), чтобы создать словарь movies, который объединяет
#в пары эти списки: titles=['Creature of Habit', 'Crewel Fate'] и
#plots=['A nun turns into a monster', 'A haunted yarn shop'].
titles = ['Creature of Habit', 'Crewel Fate']
plots = ['A nun turns into a monster', 'A haunted yarn shop']
print("Объединяем списки в пары и создаем словарь:", dict(zip(titles, plots)))

# Вещание 5. Модули и пакеты. Теоретическая часть.
import sys
import lib
print("\nChapter 5.\n")
print("Arguments for tasks:", sys.argv)
print("Random letters from string:", lib.get_letter(), lib.get_letter(), lib.get_letter())
import lib as my_lib
print("Using 'my_lib':", my_lib.get_letter())
from lib import get_letter as get_l
print("Using 'from' and 'as':", get_l())
print("All paths in system variable.")
for path in sys.path:
	print(path)
from src import str_types, str_types_alt
print("String for boolean true:", str_types.str_true())
print("String for boolean false:", str_types_alt.str_false())
dict1 = { "a" : 1, "b" : 2 }; dict1.setdefault("c", 3)
print("Simple dictionary with default element:", dict1)
from collections import defaultdict
dict2 = defaultdict(int); dict2["d"]; dict2["e"]
print("Dictionary with default integer:", dict2)
def func_dict():
	return "a"
dict3 = defaultdict(func_dict); dict3["1"];
print("Dictionary with function generated default:", dict3)
from collections import Counter
list1 = list("aabbbc"); count1 = Counter(list1)
print("Simple counter from list:", count1)
print("Most common elements in counter:", count1.most_common())
from collections import OrderedDict
dict2 = OrderedDict([('a',1), ('b',2)])
print("Ordered dictionary:", dict2)
def func_deq(strw):
	from collections import deque
	d = deque(strw)
	while len(d) > 1:
		if d.popleft() != d.pop():
			return False
	return True
	# return strw == strw[::-1]
	pass
print("Word symmetric from left to right:", func_deq("abccba"))
print("Word symmetric from left to right:", func_deq("abcde"))
import itertools
print("Simple chain of list elements:", end=' ')
for item in itertools.chain([1, 2], ["a", "b"]):
	print(item, end=' ')
#for item in itertools.cycle([1, 2]):
#print(item, end=' ')
print("\nSimple acumulate of list elements:", end=' ')
for item in itertools.accumulate([1, 2, 3, 4, 5]):
	print(item, end=' ')
from pprint import pprint 
dict4 = OrderedDict([('Alpha', 'Beta'), ('Gamma', 'Delta')])
print("\nPretty print with ordered dictionary:")
pprint(dict4)

# Вещание 5. Модули и пакеты. Практическая часть.
divider="-------------------------------------------------------------"
print("Вывод результатов упражнений к 5 главе.")
print(divider)
# Задание 1.
# Создайте файл, который называется zoo.py В нем объявите функцию hours(),
#которая выводит на экран строку 'Open 9-5 daily.' Далее используйте
#интерактивный интерпретатор, чтобы импортировать модуль zoo и вызвать его
#функцию hours().
print('Импорт из файла.')
import lib
lib.hours()
print(divider)
#Задание 2.
# В интерактивном интерпретаторе импортируйте модуль zoo под именем menagerie
#и вызовите его функцию hours()
print('Импорт из файла c переименовкой.')
import lib as menagerie
menagerie.hours()
print(divider)
# Задание 3.
# Оставаясь в интерпретаторе, импортируйте непосредственно функцию hours() из
#модуля zoo и вызовите ее.
print('Импорт конкретной функции.')
from lib import hours
hours()
print(divider)
# Задание 4.
# Импортируйте функцию hours() под именем info и вызовите ее.
print('Импорт конкретной функции c переименовкой.')
from lib import hours as info
info()
print(divider)
# Задание 5.
# Создайте словарь с именем plain, содержащий пары ключ-значение 'a':1, 'b':2, 'c':3,
#а затем выведите его на экран
plain={"c" : 5, "a" : 4, "b" : 3,}
plain["d"] = 7; plain["ab"] = 8
plain.update({"a" : 9})
print('Простой словарь.', plain)
print(divider)
# Задание 6.
# Создайте OrderedDict с именем fancy из пар ключ-значение, приведенных в задании 5,
#и выведите его на экран. Изменился ли порядок ключей?
from collections import OrderedDict
fancy=OrderedDict([('a', 1), ('b', 2), ('c', 3)])
fancy2=OrderedDict(plain)
print('Упорядоченный словарь.', fancy, fancy2)
print(divider)
# Задание 7.
# Создайте defaultdict с именем dict_of_lists и передайте ему аргумент list.
# Создайте список dict_of_lists['a'] и присоедините к нему значение
#'something for a' за одну операцию. Выведите на экран dict_of_lists['a'].
from collections import defaultdict
dict_of_lists=defaultdict(list)
dict_of_lists['a'] = 'something for a'
print(dict_of_lists)

# Вещание 6. Классы и объекты. Теоретическая часть.
class Colors():
	def __init__(self, value):
		print("Colors class constructor.")
		self.color = value
	pass
	def get(self):
		return self.color
		pass
class Red(Colors):
	sum = 0;
	def __init__(self, value):
		print("Red class constructor.")
		self.red = value
		Red.sum += value
	pass
	@classmethod
	def get_sum(cls):
		return cls.sum
		pass
	def get(self):
		return self.red
		pass
	pass
	@staticmethod
	def stat_method():
		print("Static method in Red.")
		pass
	def __eq__(self, other):
		if self.red == other.red:
			return True
		else:
			return False
		pass
	def __add__(self, other):
		self.red += other.red
		pass
	def __len__(self):
		return 1
		pass
	pass
class Green(Colors):
	def __init__(self, value, obj):
		print("Green class constructor.")
		self._green = value
		self.red_obj = obj
		print("Object Red in Green,", obj.get())
		super().__init__(value)
	pass
	def get_value(self):
		return self._green
		pass
	def set_value(self, value):
		self._green = value
		pass
	green = property(get_value, set_value)
	pass
print("\n")
cl_color = Colors(0); cl_red = Red(1); cl_green = Green(1, cl_red)
print("Overloaded method get() for Colors and Red,", cl_color.get(), cl_red.get())
cl_green.set_value(2)
print("Extra method in derived class Green, set(),", cl_green.get_value())
cl_red_a = Red(2)
print("Variable changed with all objects:", cl_red_a.get_sum())
Red.stat_method();
print("Are both objects of Red equal -", (cl_red == cl_red_a))
cl_red + cl_red_a;
print("Value in Red after add,", cl_red.get())
print("Length of Red object,", len(cl_red))
from collections import namedtuple
TupleColors = namedtuple('Colors', 'red green')
tuple5 = TupleColors('0', '1')
print(tuple5)

# Вещание 6. Объекты и классы. Практическая часть.
divider="-------------------------------------------------------------"
print("Вывод результатов упражнений к 6 главе.")
print(divider)
# #Задание 1.
# Создайте класс, который называется Thing, не имеющий содержимого, и
#выведите его на экран. Затем Создайте объект example этого класса и
#также выведите его. Совпадают ли выведенные значения?
class Thing():
	pass
print(Thing)
example = Thing
print(example)
if Thing == example:
	print('Совпадают.')
else:
	print('Не совпадают.')
print(divider)
# Задание 2.
# Создайте новый класс с именем Thing2 и присвойте его методу letters
#значение 'abc'. Выведите на экран значение атрибута letters.
class Thing2():
	def letters():
		print('abc')
	pass
Thing2.letters()
print(divider)
# Задание 3.
# Создайте еще один класс, который, конечно же, называется Thing3. В этот раз
#присвойте значение 'xyz' атрибуту объекта, который называется letters.
# Выведите на экран значение атрибута letters. Понадобилось ли вам создавать
#объект класса, чтобы сделать это?
class Thing3():
	def __init__(self, letters):
		self.letters = letters
		pass
something = Thing3('xyz')
print('Значение атрибута letters:', something.letters)
print(divider)
# Задание 4.
# Создайте класс, который называется Element, имеющий атрибуты объекта name, symbol
#и number. Создайте объект этого класса со значениями 'Hydrogen', 'H' и 1.
class Element():
	def __init__(self, name, symbol, number):
		self.name = name
		self.symbol = symbol
		self.number = number
	pass
element1 = Element('Hydrogen', 'H', '1')
print(element1.name, element1.symbol, element1.number)
print(divider)
# Задание 5.
# Создайте словарь со следующими ключами и значениями: 'name': 'Hydrogen',
#'symbol' : 'H', 'number' : 1. Далее создайте объект с именем hydrogen
#класса Element с помощью этого словаря.
c6_dict = {'name' : 'hydrogen', 'symbol' : 'H', 'number' : '1'}
hydrogen = Element(c6_dict.get('name'), c6_dict.get('symbol'), c6_dict.get('number'))
print(hydrogen.name)
print(hydrogen.symbol)
print(hydrogen.number)
print(divider)
# Задание 6.
# Для класса Element определите метод с именем dump(), который выводит на экран
#значения атрибутов объекта (name, symbol, number). Создайте объект hydrogen из
#этого нового определения и используйте метод dump(), чтобы вывести на экран его атрибуты.
c6_dict = {'name' : 'hydrogen', 'symbol' : 'H', 'number' : '1'}
hydrogen = Element(c6_dict.get('name'), c6_dict.get('symbol'), c6_dict.get('number'))
print(hydrogen.name)
print(hydrogen.symbol)
print(hydrogen.number)
print(divider)
# #Задание 7.
# Вызовите функцию print(hydrogen). В определении класса Element измените имя метода
#dump на __str__, создайте новый объект hydrogen и затем снова вызовите метод print(hydrogen).
class Element():
	def __init__(self, name, symbol, number):
		self.name = name
		self.symbol = symbol
		self.number = number
		pass
	def dump(self):
		print("Dump method:")
		print(self.name, self.symbol, self.number)
		pass
	def __str__(self):
		return str(self.name) + ":" + str(self.symbol) + ":" + str(self.number)
print("Dump method and __str__.");
hydrogen = Element('Hydrogen', 'H', '1')
hydrogen.dump()
print(hydrogen)
helium = Element('Helium', 'He', '2')
print(helium)
print(divider)
# Задание 8.
# Модифицируйте класс Element, сделав атрибуты name, symbol, number закрытыми.
# Определите для каждого атрибута свойство получателя, возвращающее значение
#соответствующего атрибута.
class Element():
	def __init__(self, name, symbol, number):
		self.__name = name
		self.__symbol = symbol
		self.__number = number
		pass
	def name(self):
		return self.__name
	def symbol(self):
		return self.__symbol
	def number(self):
		return self.__number
	pass
objE = Element("Helium", "He", 2)
print("Hidden variables in Element:", objE.name(), objE.symbol(), objE.number())
# Задание 9.
# Определите три класса: Bear, Rabbit, Octothorpe. Для каждого из них определите
#всего один метод - eats(). Он должен возвращать значения 'berries' (для Bear),
#'clover' (для Rabbit) или 'campers' (для Octothorpe). Создайте по одному
#объекту каждого класса и выведите на экран то, что ест указанное животное.
class Bear():
	def eats(self):
		eats = 'berries'
		return eats
class Rabbit():
	def eats(self):
		eats = 'clover'
		return eats
class Octothorpe():
	def eats(self):
		eats = 'campers'
		return eats
bear = Bear()
rabbit = Rabbit()
octothorpe = Octothorpe()
print ('Bear eats', bear.eats())
print ('Rabbit eats', rabbit.eats())
print ('Octothorpe eats', octothorpe.eats())
print(divider)
# Задание 10.
# Определите три класса: Laser, Claw, SmartPhone. Каждый из них имеет только один метод - does().
# Он возвращает значения 'disintegrate' (Laser), 'crush' (Claw), 'ring' (SmartPhone).
# Далее определите класс Robot, который содержит по одному объекту каждого из этих классов.
# Определите метод does() для класса Robot, который выводит на экран все, что делают его компоненты.
class Laser():
	def does(self):
		val = 'disintegrate'
		return val
	pass
class Claw():
	def does(self):
		val = 'crush'
		return val
	pass
class SmartPhone():
	def does(self):
		val = 'ring'
		return val
	pass
class Robot():
	def __init__(self, objL, objC, objS):
		self.laser = objL
		self.claw = objC
		self.smartphone = objS
		pass
	def does(self):
		return self.laser.does(), self.claw.does(), self.smartphone.does()
	pass
cl_l = Laser(); cl_c = Claw(); cl_s = SmartPhone()
robot1 = Robot(cl_l, cl_c, cl_s)
print('Robot does', robot1.does())

