from py_linq import *
from participant import *

# -- Использование технологии LINQ
# -- Задание
# -- 1. LINQ to Object. Создать не менее пять запросов с использованием всех
# -- ключевых слов выражения запроса. Object - коллекция объектов, структура
# -- которых полностью соответствует одной из таблиц БД, реализованной в
# -- первой лабораторной работе

def request_1(participants):
    # 1. Участники турниров, которые старше 50 лет, отсортированные по имени:
	# select
	# where
	# order_by

	result = participants \
			.where(lambda x: x['age'] > 50) \
			.order_by(lambda x: x['name']) \
			.select(lambda x: [x['name'], x['age']])
	return result


def request_2(participants):
	# 2. Количество участников, которые старше 50:

	# count
	result = participants.count(lambda x: x['age'] > 50)
	return result


def request_3(participants):
	# Минимальный, максимальный возраст всех участников:
	age = Enumerable([{participants.min(lambda x: x['age']), \
					   participants.max(lambda x: x['age'])}])
	# Средний рейтинг всех участников:

	rating = Enumerable([participants.avg(lambda x: x['rating'])])

	# min
	# max
	# avg 
	# join
	result = Enumerable(rating).join(age, lambda x: x)
	print(age, rating)
	return result


def request_4(participants):
	# Группировка по полу участника.
	# group_by
	result = participants \
			.group_by(key_names=['sex'], key=lambda x: x['sex']) \
			.select(lambda g: {'key': g.key.sex, 'count': g.count()})
	return result


def request_5(participants):
	# Проверить, есть ли среди участников мужчина 30 лет с рейтингом от 1000 до 2000
	result = participants \
		.where(lambda x: x['age'] == 30 and 1000 <= x['rating' <= 2000]) \
		.order_by(lambda x: x['name']) \
		.select(lambda x: [x['name'], x['age']])
	
	return result.count()


def task_1():
	participants = Enumerable(create_participants('../lab_01/participant.csv'))

	print('\n1. Участники турниров, которые старше 50 лет, отсортированные по имени:')
	for elem in request_1(participants): 
		print(elem)

	print(f'\n2. Количество участников, которые старше 50: {str(request_2(participants))}')

	print('\n3. Минимальный, максимальный возраст всех участников и\nСредний рейтинг всех участников:')

	for elem in request_3(participants): 
		print(elem)

	print('\n4.Группировка по полу:')
	for elem in request_4(participants): 
		print(elem['key'], ":", elem['count'])

	print(f'\n5. Существование среди участников мужчины 30 лет с рейтингом от 1000 до 2000: {str(bool(request_5(participants)))}')


if __name__ == "__main__":
	task_1()
