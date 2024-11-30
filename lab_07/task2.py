from participant import participant
import json
import psycopg2

# -- 2. LINQ to XML/JSON. Создать XML/JSON документ, извлекая его из таблиц
# -- Вашей базы данных с помощью инструкции SELECT. 

# -- Создать три запроса:
# -- 1. Чтение из XML/JSON документа.

# -- 2. Обновление XML/JSON документа.

# -- 3. Запись (Добавление) в XML/JSON документ.

def initDB():
	try:
		connection = psycopg2.connect(
			database="chess_db",
			user="postgres",
			password="postgres",
			host="127.0.0.1", 
			port="5432"
		)
	except:
		return None
	
	return connection


def output_json(array):
	for elem in array:
		print(json.dumps(elem.get()))


def read_table_json(cursor, count = 7):
	cursor.execute("select * from participant_import")
	rows = cursor.fetchmany(count)

	array = list()
	for elem in rows: 
		tmp = elem[0]
		array.append(participant(tmp['id'], \
								 tmp['name'], \
								 tmp['sex'], \
								 tmp['age'], \
								 tmp['phone_number'], \
								 tmp['email'], \
								 tmp['rating']))

	print(f"{"id":<10} {"name":<20} {"sex":<5} {"age":<5} {"phone_number":<15} {"email":<50} {"rating":<10}\n")
	print(*array, sep='\n')
	
	return array


def update_participant(participants, participant_id):
	# Увеличивает возраст участника.
	print(f"\nПеред обновлением возраста участника с id = {participant_id}")
	print(f"{"id":<10} {"name":<20} {"sex":<5} {"age":<5} {"phone_number":<15} {"email":<50} {"rating":<10}\n")
	print(*participants, sep='\n')

	for elem in participants:
		if elem.id == participant_id:
			elem.age += 1

	print(f"\nПосле обновления возраста участника с id = {participant_id}")
	print(f"{"id":<10} {"name":<20} {"sex":<5} {"age":<5} {"phone_number":<15} {"email":<50} {"rating":<10}\n")
	print(*participants, sep='\n')


def add_participant(participants, participant):
	participants.append(participant)
	print(f"{"id":<10} {"name":<20} {"sex":<5} {"age":<5} {"phone_number":<15} {"email":<50} {"rating":<10}\n")
	print(*participants, sep='\n')


def task_2():
	connection = initDB()
	if connection is None:
		print("Ошибка подключения к БД.")
		return 

	cursor = connection.cursor()

	print("\n1. Чтение из XML/JSON документа:")
	participants_array = read_table_json(cursor)

	print('\n1. Обновление XML/JSON документа:')
	update_participant(participants_array, 2)

	print("\n1. Запись (Добавление) в XML/JSON документ:")
	add_participant(participants_array, participant(2000, \
													'Toshibo Inki', \
													'm', \
													20, \
													'+1234567890', 
													'123@gmail.com',\
													1003))

	cursor.close()
	connection.close()


if __name__ == "__main__":
	task_2()
