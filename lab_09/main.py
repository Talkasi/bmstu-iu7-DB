from time import time
import matplotlib.pyplot as plt
import psycopg2
import redis
import json
import threading
from random import randint


global_threads = True


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


# 2. Написать запрос, получающий статистическую информацию на основе
# данных БД. 
# Получение участника с максимальным рейтингом
def get_max_participant_rating(redis_client, cursor):
	successful_participant = redis_client.get("successful_participant")
	if successful_participant is not None:
		print("Из кэша:")
		print(json.loads(successful_participant))
		redis_client.close()
		return json.loads(successful_participant)

	print("Запрос к БД.")
	cursor.execute("select * \
					from participant p \
					where p.rating in (select max(p2.rating) \
									   from participant p2);")
	successful_participant = cursor.fetchall()

	redis_client.set("successful_participant", json.dumps(successful_participant))

	print("Из БД:\t", successful_participant)
	return successful_participant


# 3. Разработать приложение, учитывающее возможное добавление, удаление и
# изменение данных в основной БД:
# 1. Приложение выполняет запрос каждые 5 секунд на стороне БД.
def request_each_5_seconds_db(cursor, participant_id):
	if global_threads:
		threading.Timer(5.0, request_each_5_seconds_db, [cursor, participant_id]).start()
	
	cursor.execute(f"select * \
				   from participant \
				   where id = {participant_id};")

	res = cursor.fetchall()
	print("Из БД:\t\t", res)
	return res


# 2. Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша.
def request_each_5_seconds_redis_cache(cursor, participant_id):
	if global_threads:
		threading.Timer(5.0, request_each_5_seconds_redis_cache, [cursor, participant_id]).start()
	
	redis_client = redis.Redis(host="localhost", port=6379, db=0)
	
	cache_value = redis_client.get(f"participant_id_{participant_id}")
	if cache_value is not None:
		print("Из кэша:\t", json.loads(cache_value))
		redis_client.close()
		return json.loads(cache_value)

	cursor.execute(f"select * \
				from participant \
				where id = {participant_id};")

	res = cursor.fetchall()
	data = json.dumps(res)

	redis_client.set(f"participant_id_{participant_id}", data)
	redis_client.close()

	print("Из БД:\t", res)

	return res


def without_a_change(cursor):
	if global_threads:
		threading.Timer(10.0, without_a_change, [cursor]).start()
	redis_client = redis.Redis(host="localhost", port=6379, db=0)

	db_t_start = time()
	cursor.execute("select *\
				   from participant_copy\
				   where id = 1;")
	db_t_end = time()

	res = cursor.fetchall()

	data = json.dumps(res)
	cache_value = redis_client.get("p1")
	if cache_value is not None:
		pass
	else:
		redis_client.set("p1", data)

	
	redis_t_start = time()
	redis_client.get("p1")
	redis_t_end = time()

	redis_client.close()

	print("selected:	", data)

	return db_t_end - db_t_start, redis_t_end - redis_t_start


def delete_participant(cursor, connection):
	redis_client = redis.Redis()
	if global_threads:
		threading.Timer(10.0, delete_participant, [cursor, connection]).start() 

	cursor.execute(f"select max(id) from participant_copy;")
	participant_id = cursor.fetchall()[0][0]

	db_t_start = time()
	cursor.execute(f"delete from participant_copy\
					 where id = {participant_id};")
	db_t_end = time()

	redis_t_start = time()
	redis_client.delete(f"p{participant_id}")
	redis_t_end = time()

	redis_client.close()
	connection.commit()

	print("deleted:	", participant_id)

	return db_t_end - db_t_start, redis_t_end - redis_t_start


def insert_participant(cursor, connection):
	redis_client = redis.Redis()
	if global_threads:
		threading.Timer(10.0, insert_participant, [cursor, connection]).start() 

	cursor.execute(f"select max(id) from participant_copy;")
	participant_id = cursor.fetchall()[0][0] + 1
	
	db_t_start = time()
	cursor.execute(f"insert into participant_copy \
				 values({participant_id}, 'Name', 'm', 33, '+111111111', 'def@ui.com', 10000);")
	db_t_end = time()

	cursor.execute(f"select * from participant_copy\
				 where id = {participant_id};")
	res = cursor.fetchall()

	data = json.dumps(res)
	redis_t_start = time()
	redis_client.set(f"p{participant_id}", data)
	redis_t_end = time()

	redis_client.close()
	connection.commit()

	print("inserted:	", data)

	return db_t_end - db_t_start, redis_t_end - redis_t_start


def update_participant(cursor, connection):
	redis_client = redis.Redis()
	if global_threads:
		threading.Timer(10.0, update_participant, [cursor, connection]).start() 

	participant_id = randint(0, 100)
	
	db_t_start = time()
	cursor.execute(f"update participant_copy set rating = 1 where id = {participant_id};")
	db_t_end = time()

	cursor.execute(f"select * from participant_copy\
					where id = {participant_id};")

	res = cursor.fetchall()
	data = json.dumps(res)

	redis_t_start = time()
	redis_client.set(f"p{participant_id}", data)
	redis_t_end = time()

	redis_client.close()
	connection.commit()

	print("updated:	", data)

	return db_t_end - db_t_start, redis_t_end - redis_t_start


def show_graph(index, values, title):
	plt.bar(index, values)
	plt.title(title)
	plt.show()


# гистограммы
def graphs(cursor, connection):
	n_runs = 1000
	global global_threads
	global_threads = False

	t1 = 0
	t2 = 0
	for i in range(n_runs):
		b1, b2 = without_a_change(cursor)
		t1 += b1
		t2 += b2
	show_graph(["БД", "Redis"], [t1 / 1000, t2 / 1000], "Без изменения данных")


	t1 = 0
	t2 = 0
	for i in range(1000):
		b1, b2 = insert_participant(cursor, connection)
		t1 += b1
		t2 += b2
	show_graph(["БД", "Redis"], [t1 / 1000, t2 / 1000], "При добавлении новых строк каждые 10 секунд")


	t1 = 0
	t2 = 0
	for i in range(1000):
		b1, b2 = delete_participant(cursor, connection)
		t1 += b1
		t2 += b2
	show_graph(["БД", "Redis"], [t1 / 1000, t2 / 1000], "При удалении строк каждые 10 секунд")


	t1 = 0
	t2 = 0
	for i in range(1000):
		b1, b2 = update_participant(cursor, connection)
		t1 += b1
		t2 += b2
	show_graph(["БД", "Redis"], [t1 / 1000, t2 / 1000], "При изменении строк каждые 10 секунд")

	global_threads = True


def make_cache(cursor):
	redis_client = redis.Redis(host="localhost", port=6379, db=0)

	for id in range(1000):
		cache_value = redis_client.get("p" + str(id))
		if cache_value is not None:
			redis_client.close()
			return json.loads(cache_value)

		cursor.execute("select *\
					from participant\
					where id = %s;", (id, ))

		res = cursor.fetchall()

		redis_client.set("p" + str(id), json.dumps(res))
		redis_client.close()

	return res


def main():
	redis_client = redis.Redis(host="localhost", port=6379, db=0)
	connection = initDB()
	if connection is None:
		print("Ошибка подключения к БД.")
		return 

	cursor = connection.cursor()
	command = -1
	while command != 0:
		print("Меню:")
		print("0 - Выход;")
		print("1 - Получение участника с максимальным рейтингом;")
		print("2 - Приложение выполняет запрос каждые 5 секунд на стороне БД;")
		print("3 - Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша;")

		command = int(input("Введите команду: "))
		if command == 0:
			return
		elif command == 1:
			get_max_participant_rating(redis_client, cursor)
		elif command == 2:
			participant_id = int(input("ID участника: "))
			request_each_5_seconds_db(cursor, participant_id)
		elif command == 3: 
			participant_id = int(input("ID участника: "))
			request_each_5_seconds_redis_cache(cursor, participant_id)
		else:
			print("Неверная комнада.")
	
	cursor.close()
	connection.close()
	redis_client.close()


if __name__ == '__main__':
	main()
