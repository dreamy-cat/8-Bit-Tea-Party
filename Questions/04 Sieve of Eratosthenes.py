#Sieve of Eratosthenes 
#Решето Эратосфена
# Оригинал: https://github.com/nquidox/learn2python. Вещание на 8-Bit Tea Party.

#предел работы скрипта
limit=16; it = 0

#будем считать, что каждый индекс списка является простым числом
numbers_list=[True]*limit
#и сразу отбросим ноль с единицей 
numbers_list[0]=False
numbers_list[1]=False

#просеиваем все числа от 2 до 1000 включительно
for number in range(2, limit):
	if numbers_list[number]:
		for i in range(2*number, limit, number):
			it += 1
			numbers_list[i]=False

#создаем список только из простых чисел
prime_numbers=[]
for number in range(limit):
	if numbers_list[number]:
		prime_numbers.append(number)

print("Prime numbers to", limit, ":", prime_numbers)
print("Iterations:", it)

limit = 16; it = 0
nums = list(range(0, limit + 1))
print("\nSource list all numbers:", nums)
i = 2
while i * i <= limit:
	if nums[i] != 0:
		j = i * i
		while j <= limit:
			it += 1
			nums[j] = 0
			j += i
	i += 1
nums.remove(1)
while 0 in nums:
	nums.remove(0)
print("Prime numbers to", limit, ":", nums)
print("Iterations:", it)
