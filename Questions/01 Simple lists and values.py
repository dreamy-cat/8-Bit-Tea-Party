#BME280 v1.2
#Циклический сбор данных с датчика BME280 в списки и вывод среднего значения.
#Оригинал: https://github.com/nquidox/learn2python. Эта версия - модель без железа, только для вещание на 8-Bit Tea Party.

#Блок импорта
#import smbus2
#import bme280

import os
import time
import random

#Самое начало
os.system('cls' if os.name == 'nt' else 'clear')

#Подрубаем датчик
#port = 1
#address = 0x76
#bus = smbus2.SMBus(port)

#calibration_params = bme280.load_calibration_params(bus, address)

#Считывание показаний (перенесено в основной цикл, иначе не будем получать новые значения)
#data = bme280.sample(bus, address, calibration_params)

#Блок функций
def createlist (ldata, param):
    ldata.append(param)
    return ldata

def updatelist (ldata, param):
    ldata.pop(0)
    ldata.append(param)
    return ldata

def midval (ldata, razm):
    summ = 0
    for i in ldata:
        summ = summ + i
    summ = summ/razm
    # return summ / razm
    return summ

#Списки и переменные
ltemp = []
lpres = []
lhumi = []
lrazm = 3                   #размер списка
sleeptime = 1               #период обновления
programCounter = 5

#Основной цикл
while programCounter > 0 :
    # data = bme280.sample(bus, address, calibration_params)
    temperature = random.randint(0, 5)
    ltemp.append(random.randint(0,5))
    lpres.append(random.randint(0, 3))
    lhumi.append(random.randint(0, 7))
    print('List of temperatures ', ltemp)
    print('List of pressures ', lpres)
    print('List of humidity ', lhumi)
    if len(ltemp) == lrazm:
        print ('''Показания BME280 на ''', programCounter)
        print ('''\tТемпература =''', midval(ltemp, lrazm))
        print ('''\tДавление (гПа) =''', midval(lpres, lrazm))
        print ('''\tОтносительная влажность =''', midval(lhumi, lrazm))
        ltemp.pop(0)
        lpres.pop(0)
        lhumi.pop(0)
    else:
        print('Not enough data.')
    time.sleep(sleeptime)
    programCounter -= 1
    # os.system('clear')

# конец
