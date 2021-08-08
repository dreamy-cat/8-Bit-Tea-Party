# Несколько простых примеров на Питоне.
# Оригинал: https://github.com/nquidox/learn2python.
# Вещание на 8-Bit Tea Party.

#Написать функцию arithmetic, принимающую 3 аргумента:
#первые 2 - числа, третий - операция, которая должна быть произведена над ними.
#Если третий аргумент +, сложить их; если —, то вычесть; * — умножить; / — разделить (первое на второе).
#В остальных случаях вернуть строку "Неизвестная операция".

def arithmetic (num1, num2, deis):
	num1=int(num1)
	num2=int(num2)
	if deis == "+":
		print(num1+num2)
	elif deis == "-":
		print(num1-num2)
	elif deis == "*":
		print(num1*num2)
	elif deis == "/":
		print(num1/num2)
	else:
		print("Неизвестная операция.")
		pass


num1 = 3; num2 = 2; deis = 'k'
	
'''
num1 = input("Введите первое число: ")
num2 = input("Введите второе число: ")
deis = input("Какое действие необходимо совершить?")
'''
arithmetic(3, 2, '+')

#Написать функцию is_year_leap, принимающую 1 аргумент — год,
#и возвращающую True, если год високосный, и False иначе. 

def is_year_leap (check):
	if (check % 4 == 0 and check % 100 != 0) or check % 400 == 0:
		return True
	else:
		return False

print('Year is %d,' % 2019, is_year_leap(2019))
print('Year is %d,' % 2020, is_year_leap(2020))
print('Year is %d,' % 2000, is_year_leap(2000))
print('Year is %d,' % 1900, is_year_leap(1900))

#is_year_leap(int(input("Введите число года для проверки: "))) #для разнообразия все в одну кучу

#Написать функцию square, принимающую 1 аргумент — сторону квадрата,
#и возвращающую 3 значения (с помощью кортежа): периметр квадрата, площадь квадрата и диагональ квадрата.

def square(side):
	if side <= 0:
		print('Wrong parameter.')
		return
	kortej=(side*4, side*side, side*pow(2, 0.5))
	print(kortej)
	pass

for i in range(-5, 5):
	print('Square side %d, perimeter, size, diagonal, ' % i, end = '')
	square(i)

'''
ask=input("Введите сторону квадрата: ")
ask=int(ask)
square(ask)
'''

#Написать функцию season, принимающую 1 аргумент — номер месяца (от 1 до 12),
#и возвращающую время года, которому этот месяц принадлежит (зима, весна, лето или осень). 

def season (month):
	if month in range(1, 2):
		print("Зима.")
	elif month == 12:
		print("Зима.")
	elif month in range (3, 6):
		print("Весна.")
	elif month in range (6, 9):
		print("Лето.")
	elif month in range (9, 12):
		print("Осень.")
	else:
		print("Недопустимое значение") #А почему бы и да?

def season_alt(month) :
	if month not in range(1, 13) :
		print('Month not correct, must be 1..12.')
		return
	seasons = ('Winter', 'Spring', 'Summer', 'Fall' )
	monthsInYear = 12; monthsInSeason = 3
	return seasons[(month % monthsInYear) // monthsInSeason]

for month in range(0, 13):
	print('Month %d is %s season.' % (month, season_alt(month)))


'''
ask=input("Введите номер месяца: ")
ask=int(ask)
season(ask)
'''

#Пользователь делает вклад в размере a рублей сроком на years лет под 10% годовых
#(каждый год размер его вклада увеличивается на 10%. Эти деньги прибавляются к сумме вклада, и на них в следующем году тоже будут проценты).
#Написать функцию bank, принимающая аргументы a и years, и возвращающую сумму, которая будет на счету пользователя. 

def bank (a, years):
	i=1
	while i <=years:
		a=a*1.1
		i += 1
	print (a)

def fibonacci(n):
	F0 = 0; F1 = 1; Fn = F0 + F1
	for i in range(2, n) : 
		F0 = F1; F1 = Fn; Fn = F1 + F0
	return Fn

print('Fibonacci:', end='')
for i in range(10):
	print('%d' % fibonacci(i), end=' ')

'''
ask_a=input("Какую сумму вкладываем? ")
ask_years=input("На какой срок? ")
bank(int(ask_a), int(ask_years))
'''

 #Написать функцию is_prime, принимающую 1 аргумент — число от 0 до 1000,
 #и возвращающую True, если оно простое, и False - иначе.

def if_prime(num):
	if num not in range(2, 1000):
		print("Ну по-человечески же просили ввести число в указанном диапазоне!")
		return
	i=2; prime=True
	while i < num:
		if num%i!=0:
			i+=1
		else:
			prime=False
			break
	print(prime)

for i in range(15) :
	print('Number %d is prime, ' % i, end='')
	if_prime(i)

'''
ask=input("Введите число от 0 до 1000: ")
if_prime(int(ask))
'''
