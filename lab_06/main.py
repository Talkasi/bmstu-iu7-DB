# Лабораторная работа № 6
# Технология доступа к данным РБД
# Целью лабораторной работы является приобретение практических навыков
# подключения к базе данных и выполнению запросов из приложения.
# Задание
# Разработать консольное приложение с меню, состоящее из 10 функций,
# демонстрирующих основные приемы работы с базой данных. Все запросы,
# функции и процедуры должны выполняться на стороне базы данных

import psycopg2
from psycopg2 import Error

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


def execScalarRequest(cursor):
    # -- Информация о конкретном участнике турнира
    participant_id = int(input("Введите id пользователя, информацию о котором хотите вывести: "))
    cursor.execute(f" \
        SELECT * \
        FROM participant \
        WHERE id = {participant_id}")

    row = cursor.fetchall()
    print("Полученная информация: ", row)
    return


def execMultipleJoinRequest(cursor):
    # -- Посчитать сумму, которую выиграл каждый человек в шахматных турнирах
    cursor.execute(f" \
        SELECT p.id, p.name, SUM(CASE \
			                    WHEN ctp.place = 1 THEN pi.first_place \
			                    WHEN ctp.place = 2 THEN pi.second_place \
			                    WHEN ctp.place = 3 THEN pi.third_place \
			               ELSE 0 \
			           END) AS total_prize \
        FROM participant p \
        LEFT JOIN chess_tournament_with_participant ctp ON p.id = ctp.id_participant \
        LEFT JOIN chess_tournament ct ON ctp.id_chess_tournament = ct.id \
        LEFT JOIN prize_info pi ON ct.id_prizes = pi.id \
        GROUP BY p.id, p.name;")

    rows = cursor.fetchall()
    print("Полученная информация: ")
    for row in rows:
        print(row)
    return

def execCTE(cursor):
    # -- Получить количество турниров, проводимых в конкретный день с 2004-10-10
    cursor.execute("\
        with global_chess_tournament_cte as \
	        (select ct.id, ct.name, ct.date \
	    from chess_tournament ct \
	    where date > '2004-10-10') \
        select date, count(id) \
        from global_chess_tournament_cte \
        group by date \
        order by date;")
    
    rows = cursor.fetchall()
    print("Полученная информация: ")
    for row in rows:
        print(row)
    return

def execMetaRequest(cursor):
    # -- Информация о всех индексах созданных для таблицы participant
    cursor.execute(f"SELECT * FROM pg_catalog.pg_indexes WHERE tablename = 'participant';")
    row = cursor.fetchall()
    print("Полученная информация: ", row)
    return

def execScalarFunc(cursor):
    # -- Функция для получения среднего рейтинга участников турнира по ID турнира.
    tournament_id = int(input("Введите id турнира, средний рейтинг участников которого хотите вывести: "))
    cursor.execute(f"SELECT get_average_rating({tournament_id});")

    row = cursor.fetchone()
    print("Полученная информация: ", row[0])
    return 

def execTableFunc(cursor):
    # -- Функция для получения списка участников турнира.
    tournament_id = int(input("Введите id турнира, участников которого хотите вывести: "))
    cursor.execute(f"SELECT * FROM get_participants({tournament_id});")

    rows = cursor.fetchall()
    print("Полученная информация: ")
    for row in rows:
        print(row)
    return

def execSavedProc(cursor):
    # -- Процедура для вывода всех турниров.
    cursor.execute("CALL list_all_tournaments();")
    # -- Выводит результат в RAISE NOTICE, тк хранимые процедуры не возвращают значения
    return 

def execSysFunc(cursor):
    # -- Вывод имени текущей базы данных и пользователя
    cursor.execute("SELECT current_database(), current_user;")
    current_database, current_user = cursor.fetchone()
    print(f"Имя текущей базы данных:\n{current_database}\nИмя пользователя:\n{current_user}")
    return 

def createTable(cursor, connection):
    cursor.execute("\
        CREATE TABLE IF NOT EXISTS chess_moves \
        ( \
            id INT NOT NULL PRIMARY KEY, \
            play_id INT, \
            move_number INT, \
            position VARCHAR(10), \
            participant_id INT, \
            FOREIGN KEY(participant_id) REFERENCES participant(id) \
        );")

    connection.commit()
    print("Таблица создана")
    return

def execInsert(cursor, connection):
    id = int(input("Введите уникальное id записи: "))
    play_id = int(input("Введите уникальное id игровой партии: "))
    move_number = int(input("Введите уникальный номер хода: "))
    position = input("Введите позицию хода: ")
    participant_id = int(input("Введите уникальный id участника, совершающего ход: "))

    try:
        cursor.execute(f"insert into chess_moves (id, play_id, move_number, position, participant_id) \
                        values ({id}, {play_id}, {move_number}, {position}, {participant_id});")
    except:
        print("Ошибка запроса.")
        connection.rollback()
        return

    connection.commit()
    cursor.execute("SELECT * FROM chess_moves;")
    
    rows = cursor.fetchall()
    print("Содержимое таблицы chess_moves: ")
    for row in rows:
        print(row)
    return

def main_func():
    connection = initDB()
    if connection is None:
        print("Ошибка подключения к БД.")
        return 

    cursor = connection.cursor()
    command = -1
    while command != 0:
        print("Меню:")
        print("0 - Выход;")
        print("1 - Выполнить скалярный запрос;")
        print("2 - Выполнить запрос с несколькими соединениями (JOIN);")
        print("3 - Выполнить запрос с ОТВ(CTE) и оконными функциями;")
        print("4 - Выполнить запрос к метаданным;") #??
        print("5 - Вызвать скалярную функцию (написанную в третьей лабораторной работе);")
        print("6 - Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе);")
        print("7 - Вызвать хранимую процедуру (написанную в третьей лабораторной работе);")
        print("8 - Вызвать системную функцию или процедуру;")
        print("9 - Создать таблицу в базе данных, соответствующую тематике БД;")
        print("10 - Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.")

        command = int(input("Введите команду: "))
        if command == 0:
            return
        elif command == 1:
            execScalarRequest(cursor)
        elif command == 2:
            execMultipleJoinRequest(cursor)
        elif command == 3: 
            execCTE(cursor)
        elif command == 4:
            execMetaRequest(cursor)
        elif command == 5:
            execScalarFunc(cursor)
        elif command == 6:
            execTableFunc(cursor)
        elif command == 7:
            execSavedProc(cursor)
        elif command == 8: 
            execSysFunc(cursor)
        elif command == 9:
            createTable(cursor, connection)
        elif command == 10:
            execInsert(cursor, connection)
        else:
            print("Неверная комнада.")
    
    cursor.close()
    connection.close()


if __name__ == '__main__':
    main_func()