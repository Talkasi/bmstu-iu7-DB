import time
import psycopg2
import redis
import matplotlib.pyplot as plt
import numpy as np

db_config = {
    'dbname': 'chess_db',
    'user': 'postgres',
    'password': 'postgres',
    'host': 'localhost',
    'port': '5432'
}

redis_client = redis.StrictRedis(host='localhost', port=6379, db=0)

QUERY = "SELECT name, rating FROM participant ORDER BY rating ASC LIMIT 10;"
N = 100
N_CHANGED = 10

def execute_query():
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()
    start_time = time.time()
    cursor.execute(QUERY)
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return time.time() - start_time, result


def cache_query():
    cached_result = redis_client.get(QUERY)
    if cached_result:
        return 0, eval(cached_result)
    else:
        execution_time, result = execute_query()
        redis_client.set(QUERY, str(result))
        return execution_time, result


def modify_data(action):
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    if action == 'add':
        cursor.execute("SELECT COALESCE(MAX(id), 0) FROM participant;")
        max_id = cursor.fetchone()[0]
        new_id = max_id + 1

        cursor.execute(
            "INSERT INTO participant (id, name, sex, age, phone_number, email, rating) VALUES (%s, 'New Participant', 'M', 30, '1234567890', 'new@example.com', 50);", (new_id,))
    
    elif action == 'delete':
        cursor.execute("SELECT id FROM participant WHERE name = 'New Participant';")
        del_id = cursor.fetchone()[0]
        cursor.execute("DELETE FROM participant WHERE id = %s;", (del_id,))

    elif action == 'update':
        cursor.execute(
            "UPDATE participant SET rating = rating + 10 WHERE name = 'New Participant';")

    conn.commit()
    cursor.close()
    conn.close()

    redis_client.delete(QUERY)


def measuring():
    times_db_no_change = []
    times_redis_no_change = []

    # График 1: Обращения без изменения данных
    for _ in range(N):
        db_time, _ = execute_query()
        times_db_no_change.append(db_time)

        redis_time, _ = cache_query()
        times_redis_no_change.append(redis_time)

    plt.figure(figsize=(12, 6))
    plt.plot(np.arange(1, len(times_db_no_change) + 1),
             times_db_no_change, label='Время обращения к базе данных', color='red')
    plt.plot(np.arange(1, len(times_redis_no_change) + 1),
             times_redis_no_change, label='Время обращения из кэша', color='green')
    plt.xlabel('Номер обращения')
    plt.ylabel('Время, с')
    plt.title('Обращения без изменения данных')
    plt.legend()
    plt.show()

    # График 2: Обращения с добавлением данных
    times_db_add = []
    times_redis_add = []

    for i in range(N):
        if i % N_CHANGED == 0:
            modify_data('add')
        db_time, _ = execute_query()
        times_db_add.append(db_time)
        redis_time, _ = cache_query()
        times_redis_add.append(redis_time)

    plt.figure(figsize=(12, 6))
    plt.plot(np.arange(1, len(times_db_add) + 1),
             times_db_add, label='Время обращения к базе данных', color='red')
    plt.plot(np.arange(1, len(times_redis_add) + 1),
             times_redis_add, label='Время обращения из кэша', color='green')
    plt.xlabel('Номер обращения')
    plt.ylabel('Время, с')
    plt.title('Обращения с добавлением данных')
    plt.legend()
    plt.show()

    # График 3: Обращения с удалением данных
    times_db_delete = []
    times_redis_delete = []

    for i in range(N):
        if i % N_CHANGED == 0:
            modify_data('delete')
        db_time, _ = execute_query()
        times_db_delete.append(db_time)
        redis_time, _ = cache_query()
        times_redis_delete.append(redis_time)

    plt.figure(figsize=(12, 6))
    plt.plot(np.arange(1, len(times_db_delete) + 1),
             times_db_delete, label='Время обращения к базе данных', color='red')
    plt.plot(np.arange(1, len(times_redis_delete) + 1),
             times_redis_delete, label='Время обращения из кэша', color='green')
    plt.xlabel('Номер обращения')
    plt.ylabel('Время, с')
    plt.title('Обращения с удалением данных')
    plt.legend()
    plt.show()

    # График 4: Обращения с обновлением данных
    times_db_update = []
    times_redis_update = []

    for i in range(N):
        if i % N_CHANGED == 0:
            modify_data('update')
        db_time, _ = execute_query()
        times_db_update.append(db_time)
        redis_time, _ = cache_query()
        times_redis_update.append(redis_time)

    plt.figure(figsize=(12, 6))
    plt.plot(np.arange(1, len(times_db_update) + 1),
             times_db_update, label='Время обращения к базе данных', color='red')
    plt.plot(np.arange(1, len(times_redis_update) + 1),
             times_redis_update, label='Время обращения из кэша', color='green')
    plt.xlabel('Номер обращения')
    plt.ylabel('Время, с')
    plt.title('Обращения с обновлением данных')
    plt.legend()
    plt.show()


if __name__ == "__main__":
    measuring()
