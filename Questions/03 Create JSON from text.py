# Чтение текстового файла base.txt - файл должен быть создан. И создание на его основе
#json-файла, содержащего массив уникальных слов либо из строки, если файл отсутствует.
#Оригинал: https://github.com/nquidox/learn2python. Вещание на 8-Bit Tea Party.

#блок импорта
import re

def file_to_list(filename):
	#читаем файл, берем слова только из букв и переводим в lower_case
	raw_list = []
	with filename as raw_text:
		for line in raw_text:
			for word in re.findall(r'[a-zA-Z]+',line):
				raw_list.append(word.lower())
	return raw_list

def string_to_list(string):
	#читаем строку, берем слова только из букв и переводим в lower_case
	raw_list = []
	for word in re.findall(r'[a-zA-Z]+',string):
		raw_list.append(word.lower())
	return raw_list

def make_uniqe_list(raw_list):
	#создаем новый список, исключая повторяющиеся элементы и сортируем по алфавиту
	uni_list = []
	for i in raw_list:
		if i not in uni_list:
			uni_list.append(i)
		uni_list.sort()
	return uni_list

def write_to_json(uni_list):
	#блок записи (переписывает существующий list.json)
	new_file=open('list.json','w')
	new_file.write('[\n')
	for i in uni_list:
		new_file.write('\t'+'"'+i+'"'+','+'\n')
	new_file.write(']')
	new_file.close()

def count_words(words):
	# Считаем количество вхождений слов в список.
	counters = {}
	for word in words:
		if word not in counters:
			counters[word] = 0
		counters[word] += 1
	print("\nWords in list:\n", counters)
	return counters

def dict_to_json(words_dict):
	#блок записи (переписывает существующий list.json), словарем
	new_file=open('dict.json','w')
	new_file.write('{\n')
	print("\nWriting dictionary to file:\n")
	for i in words_dict:
		new_file.write('\t'+'"'+i+'": "'+str(words_dict[i])+'",'+'\n')
		print('\t'+'"'+i+'": "'+str(words_dict[i])+'",')
	new_file.write('}')
	new_file.close()

#основной блок

#создаем списки для работы

words, uniqe_words=[],[]

try:
    file = open('base.txt','r')			#проверка существования файла
except IOError as exc:					#работа со строкой, если файл base.txt не существует
    ask=('''This is an example string for case when base file does not exist.
    		This program should make a JSON file using the text you are reading now.
    		I hope i didn't make any mistakes because my English isn't perfect.
    	''')
    string_to_list(ask)
    make_uniqe_list(words)
    write_to_json(uni_list)
else:
    with file:							#работа с файлом, если файл base.txt существует
        words = file_to_list(file)
        print("Words in file:\n", words)
        counters = count_words(words)
        dict_to_json(counters)
        uniqe_words = make_uniqe_list(words)
        print("\nUniqe words:\n", uniqe_words)
        write_to_json(uniqe_words)
