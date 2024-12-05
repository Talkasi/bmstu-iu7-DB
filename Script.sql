-- LAB 2
-- 1. Инструкция SELECT, использующая предикат сравнения.
-- Найти имена всех участников мужского пола возраста меньше 30 лет.
SELECT id, name, sex, age
FROM participant
WHERE sex = 'm' AND age < 30;

-- 2. Инструкция SELECT, использующая предикат BETWEEN.
-- Найти имена всех участников женского пола возраста от 20 до 30 лет.
SELECT id, name, sex, age
FROM participant
WHERE sex = 'w' AND age BETWEEN 20 AND 30;

-- 3. Инструкция SELECT, использующая предикат LIKE.
-- Получить список компаний-организаторов, почта которых заканчивается на ".com".
SELECT id, company_name, email
FROM organizer
WHERE email LIKE '%.com';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Получить названия всех турниров, проводимых с '2000-01-01', приз за первое место в которых больше 1000
SELECT id, name, date, id_prizes 
FROM chess_tournament
WHERE id_prizes IN (SELECT pr.id
                    FROM prize_info pr
                    WHERE pr.first_place > 1000)
                AND date > '2000-01-01';

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- Найти все турниры, у которых за третье место денежный приз меньше 10
SELECT id, name
FROM chess_tournament
WHERE EXISTS (SELECT 1
              FROM prize_info
              WHERE third_place < 10 AND chess_tournament.id_prizes = id);
             
-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- Найти ту информацию о призах, в которой за первое место полагается больше, чем за любое второе место в любых турнирах
SELECT *
FROM prize_info
WHERE first_place >= ALL (SELECT second_place 
					   	  FROM prize_info);

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- Посчитать среднюю сумму, которую выиграл каждый человек в шахматных турнирах
SELECT p.name, AVG(CASE
			           WHEN ctp.place = 1 THEN pi.first_place
			           WHEN ctp.place = 2 THEN pi.second_place
			           WHEN ctp.place = 3 THEN pi.third_place
			           ELSE 0
			       END) AS avg_prize
FROM participant p
left JOIN chess_tournament_with_participant ctp ON p.id = ctp.id_participant
left JOIN chess_tournament ct ON ctp.id_chess_tournament = ct.id
left JOIN prize_info pi ON ct.id_prizes = pi.id
GROUP BY p.id, p.name;

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- JOIN prize_info и chess_tournament без JOIN
select ct.id, ct.name, ct.date,
	   (select first_place
	   from prize_info where prize_info.id = ct.id_prizes) as first_place_prize,
	   (select second_place
	   from prize_info where prize_info.id = ct.id_prizes) as second_place_prize,
	   (select third_place
	   from prize_info where prize_info.id = ct.id_prizes) as third_place_prize
from chess_tournament ct;

-- 9. Инструкция SELECT, использующая простое выражение CASE.
-- Посчитать сумму, которую выиграл каждый человек в шахматных турнирах
SELECT p.name, SUM(CASE
			           WHEN ctp.place = 1 THEN pi.first_place
			           WHEN ctp.place = 2 THEN pi.second_place
			           WHEN ctp.place = 3 THEN pi.third_place
			           ELSE 0
			       END) AS total_prize
FROM participant p
left JOIN chess_tournament_with_participant ctp ON p.id = ctp.id_participant
left JOIN chess_tournament ct ON ctp.id_chess_tournament = ct.id
left JOIN prize_info pi ON ct.id_prizes = pi.id
GROUP BY p.id, p.name;

-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
SELECT 
    p.id AS participant_id,
    p.name AS participant_name,
    ct.name AS tournament_name,
    ct.date AS tournament_date,
    ct.time AS tournament_time,
    CASE 
        WHEN ctw.place = 1 THEN (SELECT pi.first_place FROM prize_info pi WHERE pi.id = ct.id_prizes)
        WHEN ctw.place = 2 THEN (SELECT pi.second_place FROM prize_info pi WHERE pi.id = ct.id_prizes)
        WHEN ctw.place = 3 THEN (SELECT pi.third_place FROM prize_info pi WHERE pi.id = ct.id_prizes)
        ELSE 0
    END AS prize
FROM participant p
JOIN chess_tournament_with_participant ctw ON p.id = ctw.id_participant
JOIN chess_tournament ct ON ctw.id_chess_tournament = ct.id;

-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
select ct.id, ct.name, ct.date,
	   (select first_place
	   from prize_info where prize_info.id = ct.id_prizes) as first_place_prize,
	   (select second_place
	   from prize_info where prize_info.id = ct.id_prizes) as second_place_prize,
	   (select third_place
	   from prize_info where prize_info.id = ct.id_prizes) as third_place_prize
into ChessTournament
from chess_tournament ct;

-- 12. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM.
SELECT p.name AS participant_name,
       p.age AS participant_age,
       ct.name AS tournament_name,
       ct.date AS tournament_date,
       ct.time AS tournament_time,
       ctp.place AS place
FROM participant p
JOIN chess_tournament_with_participant ctp ON p.id = ctp.id_participant
JOIN chess_tournament ct ON ctp.id_chess_tournament = ct.id
WHERE ctp.place = (
    SELECT MAX(place)
    FROM chess_tournament_with_participant ctp2
    WHERE ctp2.id_chess_tournament = ctp.id_chess_tournament
)
ORDER BY ct.date, ct.time, ctp.place;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
select *
from participant p 
where exists (select 1
			  from chess_tournament_with_participant ctwp 
			  where ctwp.id_participant = p.id and place = 2 and 
			  exists(select 1
			 		 from chess_tournament ct 
			 		 where ctwp.id_chess_tournament = ct.id and date > '2000-01-01'));

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
select sex, count(id)
from participant
group by sex;

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
select age, count(id)
from participant
group by age
having age > 15
order by age;

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
-- строки значений.
INSERT INTO participant (id, name, sex, age, phone_number, email, rating)
VALUES (2000, 'Donut', 'w', 18, '+71234567890', 'Default@gmail.com', 1000);

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
-- результирующего набора данных вложенного подзапроса.
INSERT INTO participant (id, name, sex, age, phone_number, email, rating)
SELECT p.id + 1 + (SELECT MAX(p1.id)
		FROM participant p1), p.name, p.sex, p.age, p.phone_number, p.email, 1000
FROM participant p
WHERE sex = 'w';

-- 18. Простая инструкция UPDATE.
UPDATE prize_info 
SET first_place = first_place * 1.5
WHERE id = 10;

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
UPDATE prize_info 
SET first_place = (SELECT AVG(first_place)
				   FROM prize_info)
WHERE id = 0;

-- 20. Простая инструкция DELETE.
DELETE from chess_tournament
WHERE id_organizer IS null;

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
DELETE FROM chess_tournament
WHERE id_prizes IN (SELECT id
				    FROM prize_info
				    where first_place + second_place + third_place < 10000);
				   
-- 22. Инструкция SELECT, использующая простое обобщенное табличное
-- выражение
with global_chess_tournament_cte as
	(select ct.id, ct.name, ct.date
	from chess_tournament ct
	where date > '2004-10-10')
select date, count(id) 
from global_chess_tournament_cte
group by date
order by date;

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
-- выражение.
-- На выдуманных данных
--WITH DirectReports (ManagerID, EmployeeID, EmployeeLevel) AS
--(
--    SELECT ManagerID, EmployeeID, 0 AS EmployeeLevel
--    FROM HumanResources.Employee
--    WHERE ManagerID IS NULL
--    UNION ALL
--    SELECT e.ManagerID, e.EmployeeID, EmployeeLevel + 1
--    FROM HumanResources.Employee e
--        INNER JOIN DirectReports d
--        ON e.ManagerID = d.EmployeeID
--)
--SELECT ManagerID, EmployeeID, EmployeeLevel
--FROM DirectReports

-- Для каждого организатора список турниров, которые он организовывал
select *
from chess_tournament ct 
where id_organizer = 28
order by id_organizer, date;

select o.id AS id_organizer,
	   string_agg(ct.id::text, ', ') AS tournament_ids
from organizer o
join chess_tournament ct on o.id = ct.id_organizer
group by o.id;

-- 24. Оконные функции. Использование конструкци MIN/MAX/AVG OVER()
SELECT 
    p.id AS participant_id,
    p.name AS participant_name,
    p.rating AS participant_rating,
    t.name AS tournament_name,
    AVG(p.rating) OVER (PARTITION BY twp.id_chess_tournament) AS average_rating,
    MAX(p.rating) OVER (PARTITION BY twp.id_chess_tournament) AS max_rating,
    MIN(p.rating) OVER (PARTITION BY twp.id_chess_tournament) AS min_rating
FROM chess_tournament_with_participant twp
JOIN participant p ON twp.id_participant = p.id
JOIN chess_tournament t ON twp.id_chess_tournament = t.id
ORDER BY t.date, twp.place;

-- 25. Оконные фнкции для устранения дублей
-- Придумать запрос, в результате которого в данных появляются полные дубли.
-- Устранить дублирующиеся строки с использованием функции ROW_NUMBER()
INSERT INTO chess_tournament_with_participant (id_participant, id_chess_tournament, place)
SELECT *
FROM chess_tournament_with_participant p
WHERE p.id_participant = 953;


DELETE FROM chess_tournament_with_participant
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
            ROW_NUMBER() OVER (PARTITION BY id_participant, id_chess_tournament, place ORDER BY (SELECT NULL)) AS rn
        FROM chess_tournament_with_participant
    ) AS ranked
    WHERE rn > 1
);

-- LAB3

-- Разработать и тестировать 10 модулей 
-- Четыре функции 
-- Скалярную функцию
-- Функция для получения среднего рейтинга участников турнира по ID турнира.

CREATE OR REPLACE FUNCTION get_average_rating(tournament_id INT)
RETURNS FLOAT AS $$
DECLARE
    avg_rating FLOAT;
BEGIN
    SELECT AVG(p.rating) INTO avg_rating
    FROM participant p
    JOIN chess_tournament_with_participant ct ON p.id = ct.id_participant
    WHERE ct.id_chess_tournament = tournament_id;

    RETURN avg_rating;
END;
$$ LANGUAGE plpgsql;

-- Подставляемую табличную функцию
-- Функция для получения списка участников турнира.

CREATE OR REPLACE FUNCTION get_participants(tournament_id INT)
RETURNS TABLE(id_participant INT, name VARCHAR, place INT) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.name, ct.place
    FROM participant p
    JOIN chess_tournament_with_participant ct ON p.id = ct.id_participant
    WHERE ct.id_chess_tournament = tournament_id;
END;
$$ LANGUAGE plpgsql;

-- Многооператорную табличную функцию
-- Функция для получения всех турниров с их участниками и рейтингом.

CREATE OR REPLACE FUNCTION get_tournaments_with_participants()
RETURNS TABLE(tournament_name VARCHAR, participant_name VARCHAR, rating INT) AS $$
BEGIN
    RETURN QUERY
    SELECT ct.name, p.name, p.rating
    FROM chess_tournament ct
    JOIN chess_tournament_with_participant ctp ON ct.id = ctp.id_chess_tournament
    JOIN participant p ON ctp.id_participant = p.id;
END;
$$ LANGUAGE plpgsql;

-- Рекурсивную функцию или функцию с рекурсивным ОТВ 
-- Функция для вычисления факториала числа (рекурсивная).

CREATE OR REPLACE FUNCTION factorial(n INT)
RETURNS INT AS $$
BEGIN
    IF n <= 1 THEN
        RETURN 1;
    ELSE
        RETURN n * factorial(n - 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Четыре хранимых процедуры
-- Хранимую процедуру без параметров или с параметрами
-- Процедура для вывода всех турниров.

CREATE OR REPLACE PROCEDURE list_all_tournaments()
LANGUAGE plpgsql AS $$
DECLARE
    record RECORD;
BEGIN
    RAISE NOTICE 'Турниры:';
    
    FOR record IN SELECT * FROM chess_tournament LOOP
        RAISE NOTICE 'ID: %, Name: %', record.id, record.name;
    END LOOP;

    RAISE NOTICE 'Вывод завершен.';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Произошла ошибка: %', SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE update_participant_phone_number(p_id INT, new_phone_number VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
	UPDATE participant
	SET phone_number = new_phone_number
	WHERE id = p_id;
END;
$$;


-- Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ 
-- Процедура для вычисления и вывода факториала числа (рекурсивная).

CREATE OR REPLACE PROCEDURE print_factorial(n INT)
LANGUAGE plpgsql AS $$
DECLARE
    result INT := 1;
BEGIN
    IF n <= 0 THEN
        RAISE NOTICE 'Factorial of % is 1', n;
        RETURN;
    END IF;

    result := factorial(n);
    RAISE NOTICE 'Factorial of % is %', n, result;
END;
$$;

-- Хранимую процедуру с курсором
-- Процедура для извлечения участников турнира с использованием курсора.

CREATE OR REPLACE PROCEDURE get_participants_by_tournament(tournament_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    participant_cursor CURSOR FOR 
        SELECT p.name FROM participant p 
        JOIN chess_tournament_with_participant ct ON p.id = ct.id_participant 
        WHERE ct.id_chess_tournament = tournament_id;

    participant_name VARCHAR(100);
BEGIN
    OPEN participant_cursor;

    LOOP
        FETCH participant_cursor INTO participant_name;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Participant: %', participant_name;
    END LOOP;

    CLOSE participant_cursor;
END;
$$;


-- Функцию вход -- игрок
-- выход % соотношение его занятия 1, 2, 3 по отношению ко всем его играм

drop function get_place_info;

CREATE OR REPLACE FUNCTION get_place_info(participant_id INT)
RETURNS TABLE (
    first_place_percentage NUMERIC,
    second_place_percentage NUMERIC,
    third_place_percentage NUMERIC
) AS $$
DECLARE
    total_games INT;
    first_place_count INT;
    second_place_count INT;
    third_place_count INT;
BEGIN
    SELECT COUNT(*) INTO total_games
    FROM chess_tournament_with_participant
    WHERE id_participant = participant_id;

	RAISE NOTICE 'total_games: %', total_games;

    SELECT COUNT(*) INTO first_place_count
    FROM chess_tournament_with_participant
    WHERE id_participant = participant_id AND place = 1;

	RAISE NOTICE 'first_place_count: %', first_place_count;

    SELECT COUNT(*) INTO second_place_count
    FROM chess_tournament_with_participant
    WHERE id_participant = participant_id AND place = 2;

	RAISE NOTICE 'second_place_count: %', second_place_count;

    SELECT COUNT(*) INTO third_place_count
    FROM chess_tournament_with_participant
    WHERE id_participant = participant_id AND place = 3;

	RAISE NOTICE 'third_place_count: %', third_place_count;

    first_place_percentage := CASE WHEN total_games > 0 THEN (first_place_count::NUMERIC / total_games) * 100 ELSE 0 END;
    second_place_percentage := CASE WHEN total_games > 0 THEN (second_place_count::NUMERIC / total_games) * 100 ELSE 0 END;
    third_place_percentage := CASE WHEN total_games > 0 THEN (third_place_count::NUMERIC / total_games) * 100 ELSE 0 END;

	RAISE NOTICE 'first_place_percentage: %', first_place_percentage;
	RAISE NOTICE 'second_place_percentage: %', second_place_percentage;
	RAISE NOTICE 'third_place_percentage: %', third_place_percentage;

    RETURN QUERY SELECT first_place_percentage, second_place_percentage, third_place_percentage;
END;
$$ LANGUAGE plpgsql;

SELECT * 
FROM get_place_info(1);


-- Хранимую процедуру доступа к метаданным 
-- Процедура для получения информации о структуре таблицы participant.

CREATE OR REPLACE PROCEDURE get_table_structure(table_name TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('SELECT column_name, data_type FROM information_schema.columns WHERE table_name = %L', table_name);
END;
$$;

CREATE OR REPLACE PROCEDURE get_table_structure(table_name TEXT)
LANGUAGE plpgsql AS $$
DECLARE
    column_record RECORD;
BEGIN
    FOR column_record IN EXECUTE format('SELECT column_name, data_type FROM information_schema.columns WHERE table_name = %L', table_name) LOOP
        RAISE NOTICE 'Column: %, Data Type: %', column_record.column_name, column_record.data_type;
    END LOOP;
END;
$$;

CALL get_table_structure('participant');

	
-- Два DML триггера
-- Триггер AFTER
-- Триггер для обновления информации о рейтинге после добавления участника.

CREATE OR REPLACE FUNCTION update_rating_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE participant SET rating = rating + 10 WHERE id = NEW.id_participant;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_participant
AFTER INSERT ON chess_tournament_with_participant
FOR EACH ROW EXECUTE FUNCTION update_rating_after_insert();

-- Триггер INSTEAD OF
-- Триггер для обработки удаления из chess_tournament_with_participant.

create or replace view relationsView as
select *
from chess_tournament_with_participant;

create or replace function do_not_delete_relations()
returns trigger as
$$
begin
	raise notice 'Cannot delete relations';
	return old;
end;
$$ language plpgsql;

drop trigger if exists do_not_delete_relations_trigg on relationsView;

create trigger do_not_delete_relations_trigg
	instead of delete on relationsView
	for each row 
	execute procedure do_not_delete_relations();

select *
from relationsView
where id_participant = 1;

delete 
from relationsView
where id_participant = 1;

-- Тестирование функций
SELECT get_average_rating(1);
SELECT * FROM get_participants(1);
SELECT * FROM get_tournaments_with_participants();
SELECT factorial(5);

-- Тестирование процедур
CALL list_all_tournaments();
CALL print_factorial(5);
CALL get_participants_by_tournament(1);
CALL get_table_structure('participant');

SELECT *
FROM participant p 
WHERE p.id = 1;
 
INSERT INTO chess_tournament_with_participant (id_participant, id_chess_tournament, place)
VALUES (1, 1, 1); -- 1 участвует в турнире 1, занимает 1 место.
-- После выполнения этого запроса рейтинг участника с id = 1 должен увеличиться на 10.


-- LAB 4
-- SQL CLR
-- Целью данной лабораторной работы является изучение возможностей
-- расширения функциональности модулей на базе SQL CLR на примере создания
-- хранимых процедур, триггеров, пользовательских типов, функций и агрегатов на
-- высокопроизводительных языках.

-- SELECT * FROM pg_language;
-- SELECT name, default_version, installed_version FROM pg_available_extensions;
-- CREATE EXTENSION plpython3u;

-- Задание
-- Создать, развернуть и протестировать 6 объектов SQL CLR:
-- Определяемую пользователем скалярную функцию CLR

-- Получить информацию о призах турнира с индексом id
CREATE OR REPLACE FUNCTION get_tournament_prize_info(id INT)
RETURNS INT
AS $$
res = plpy.execute(f" \
    SELECT id_prizes \
    FROM chess_tournament  \
    WHERE id = {id};", 2)
if res:
    return res[0]['id_prizes']
$$ LANGUAGE plpython3u;

SELECT * 
FROM prize_info
WHERE id = get_tournament_prize_info(22);

select *
from chess_tournament ct 
where id = 22;

CREATE OR REPLACE FUNCTION update_with_verify(id INT, new_prize INT)
RETURNS void
AS $$
try:
    plpy.execute(f"UPDATE prize_info SET third_place = third_place + {new_prize} WHERE id = {id};")
except plpy.SPIError as e:
    plpy.notice("Error while updating: %s" % e.args)
else:
    plpy.notice("Update done")
$$ LANGUAGE plpython3u;

select update_with_verify(1, 1);

-- Пользовательскую агрегатную функцию CLR
--Для сохранения внутренних данных при повторных вызовах одной и той же функции 
--предусмотрен глобальный словарь SD. Для размещения публичных данных предназначен 
--глобальный словарь GD, доступный всем функциям на Python в сеансе; используйте его с осторожностью.
CREATE OR REPLACE FUNCTION calculate_average_rating(tournament_id INT)
RETURNS FLOAT AS $$
    total_rating = plpy.execute(f"""
        SELECT AVG(rating) AS avg_rating
        FROM participant p
        JOIN chess_tournament_with_participant ctp ON p.id = ctp.id_participant
        WHERE ctp.id_chess_tournament = {tournament_id};
    """)
    
    if total_rating and total_rating[0]['avg_rating'] is not None:
        return total_rating[0]['avg_rating']
    else:
        return 0.0
$$ LANGUAGE plpython3u;

SELECT id, calculate_average_rating(id) 
FROM chess_tournament;

CREATE OR REPLACE FUNCTION calculate_average_rating_NEW(tournament_id INT)
RETURNS FLOAT AS $$
    from statistics import mean
    ratings = []
    
    try:
        query = """
            SELECT rating
            FROM participant p
            JOIN chess_tournament_with_participant ctp ON p.id = ctp.id_participant
            WHERE ctp.id_chess_tournament = $1;
        """
        
        stmt = plpy.prepare(query, ['int'])

        result = plpy.execute(stmt, (tournament_id,))

        for row in result:
            if row['rating'] is not None:
                ratings.append(row['rating'])

        if ratings:
            avg_rating = mean(ratings)
            plpy.notice(f"Calculated average rating: {avg_rating} for tournament_id: {tournament_id}")
            return avg_rating
        else:
            plpy.notice(f"No ratings found for tournament_id: {tournament_id}, returning 0.0")
            return 0.0
            
    except Exception as e:
        plpy.error(f"Error calculating average rating: {e}")
        return None
$$ LANGUAGE plpython3u;

SELECT id, calculate_average_rating_NEW(id) 
FROM chess_tournament;

-- Определяемую пользователем табличную функцию CLR
CREATE OR REPLACE FUNCTION tournament_in_year(year INT)
RETURNS TABLE 
(
	id INT,
	name VARCHAR,
	date DATE,
	year_date INT
)
AS $$
	buf = plpy.execute(f" \
	select id, name, date, extract(year from date) as year_date \
	from chess_tournament")
	result_ = []
	for i in buf:
		if i["year_date"] == year:
			result_.append(i)
	return result_
$$ LANGUAGE plpython3u;

SELECT * FROM tournament_in_year(2000);

-- Проверка
SELECT id, name, date, extract(year from date) as year_date
FROM chess_tournament 
WHERE extract(year from date) = 2000;

-- Хранимую процедуру CLR
CREATE OR REPLACE FUNCTION change_rating(old_rating int, new_rating int)
RETURNS void
AS $$
	plan = plpy.prepare("UPDATE participant set rating = $1 where rating = $2", ["INT", "INT"])
	plpy.execute(plan, [new_rating, old_rating])
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION change_rating_new(old_rating INT, new_rating INT)
RETURNS void AS $
    try:
        plan = plpy.prepare("UPDATE participant SET rating = $1 WHERE rating = $2", ["INT", "INT"])
        result = plpy.execute(plan, [new_rating, old_rating])
        
        if result:
            plpy.notice(f"Updated {result[0]['row_count']} participant(s) from rating {old_rating} to {new_rating}.")
        else:
            plpy.notice(f"No participants found with rating {old_rating}. No updates made.")
    
    except Exception as e:
        # Log the error message
        plpy.error(f"Error changing rating from {old_rating} to {new_rating}: {e}")

$ LANGUAGE plpython3u;


-- Проверка
SELECT * 
FROM change_rating(2, 3);

SELECT *
FROM participant 
where rating = 3;

-- Триггер CLR
drop table if exists old;
create temp table old (participant_id int, chess_tournament_id int, place int, data_deletion DATE);
create or replace function backup_deleted_relations()
returns trigger 
as $$
	plan = plpy.prepare("insert into old(participant_id, chess_tournament_id, place, data_deletion) \
						 values($1, $2, $3, NOW());", ["int", "int", "int"])
	pi = TD['old']
	rv = plpy.execute(plan, [pi["id_participant"], pi["id_chess_tournament"], pi["place"]])
	return TD['new']
$$ language  plpython3u;

drop trigger if exists backup_deleted_relations on chess_tournament_with_participant; 
create trigger backup_deleted_relations
before delete on chess_tournament_with_participant for each row
execute procedure backup_deleted_relations();

delete from chess_tournament_with_participant
where id_participant = 20;

select * from old;

-- Определяемый пользователем тип данных CLR

CREATE TYPE participant_raiting AS
(
	name VARCHAR,
	raiting INT
);

CREATE OR REPLACE FUNCTION get_participant_raiting(participant_id INT)
RETURNS participant_raiting
AS $$
	plan = plpy.prepare(" 			\
	select name, rating 	        \
	from participant				\
	where id = $1;", ["INT"])
	run = plpy.execute(plan, [participant_id])
	
	if (run.nrows()):
		return (run[0]["name"], run[0]["rating"])
$$ LANGUAGE plpython3u;

DROP FUNCTION get_participant_raiting(int);
DROP TYPE IF EXISTS participant_raiting;

SELECT * 
FROM get_participant_raiting(118);

select *
from participant p 
where p.id = 118;

-- LAB 5
-- Использование XML/JSON с базами данных
-- Целью лабораторной работы является приобретение практических навыков
-- использования языка запросов для обработки данных в формате XML или JSON
-- на примере реляционных таблиц, содержащих столбец типа xml или json (jsonb).
-- Задание
-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки в XML
-- проверить все режимы конструкции FOR XML

select to_json(p) from participant p;
select to_json(ctwp) from chess_tournament_with_participant ctwp;
select to_json(ct) from chess_tournament ct;
select to_json(pi) from prize_info pi;
select to_json(o) from organizer o;

-- 2. Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.
CREATE TABLE IF NOT EXISTS participant_copy
(
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR(100),
	sex CHAR,
	age INT,
	phone_number VARCHAR(15),
	email VARCHAR(100),
	rating INT
);

-- 2.1 Экспорт
-- Terminal:
psql --username=postgres
\c chess_db
\copy (select row_to_json(p) from participant p) to '/home/talkasi/bmstu-iu7-DB/lab_05/participant.json'

create table participant_import(doc json);
\copy participant_import from '/home/talkasi/bmstu-iu7-DB/lab_05/participant.json';
select * from participant_import;

INSERT INTO participant_copy(id, name, sex, age, phone_number, email, rating)
SELECT 
    (doc->>'id')::integer,
    doc->>'name', 
    doc->>'sex', 
    (doc->>'age')::integer,
    doc->>'phone_number', 
    doc->>'email', 
    (doc->>'rating')::integer
FROM participant_import;

SELECT * FROM participant_copy;

-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.

drop table products;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    details json
);

INSERT INTO products (name, details) VALUES
('Laptop', 
 '{"brand": "Dell", "model": "XPS 13", "processor": "Intel i7", "ram": "16GB", "storage": "512GB SSD"}'),
('Smartphone', 
 '{"brand": "Apple", "model": "iPhone 13", "processor": "A15 Bionic", "ram": "4GB", "storage": "128GB"}'),
('Tablet', 
 '{"brand": "Samsung", "model": "Galaxy Tab S7", "processor": "Snapdragon 865+", "ram": "8GB", "storage": "256GB"}');

SELECT * FROM products;

-- 4. Выполнить следующие действия:
--    1. Извлечь XML/JSON фрагмент из XML/JSON документа
select '[{"owner_id":0,"passport_id":1111111111,"last_name":"Иванов"},
		 {"owner_id":1,"passport_id":2222222222,"last_name":"Петров"}]'::json->0;

--    2. Извлечь значения конкретных узлов или атрибутов XML/JSON
-- документа

SELECT 
    name,
    details->>'brand' AS brand,
    details->>'model' AS model,
    details->>'processor' AS processor,
    details->>'ram' AS ram,
    details->>'storage' AS storage
FROM products;

--    3. Выполнить проверку существования узла или атрибута
select details->'storage' is not NULL field_exists from products;
select details->'not_exist' is not null field_exists from products;

--    4. Изменить XML/JSON документ
select jsonb_set('{"brand": "Samsung", "model": "Galaxy Tab S7", "processor": "Snapdragon 865+", "ram": "8GB", "storage": "256GB"}',
	   '{brand}', jsonb '"SAMSUNG"')

--    5. Разделить XML/JSON документ на несколько строк по узлам
CREATE TABLE info 
(
    doc json
);

DROP TABLE info;

INSERT INTO info (doc) VALUES 
('[{"name": "Ira", "age": 20, "favorite": {"actor": "Benedict", "film": "Sherlock"}},
{"name": "Roma", "age": 20, "favorite": {"actor": "Pattinson", "film": "Twilight"}},
{"name": "Alena", "age": 19, "favorite": {"actor": "Cucumber", "film": "Holme"}}]');

SELECT * FROM info;

SELECT jsonb_array_elements(doc::jsonb) 
FROM info;

-- Лабораторная работа № 7
-- Использование технологии LINQ
-- Задание
-- 1. LINQ to Object. Создать не менее пять запросов с использованием всех
-- ключевых слов выражения запроса. Object - коллекция объектов, структура
-- которых полностью соответствует одной из таблиц БД, реализованной в
-- первой лабораторной работе

-- 2. LINQ to XML/JSON. Создать XML/JSON документ, извлекая его из таблиц
-- Вашей базы данных с помощью инструкции SELECT. 

-- Создать три запроса:
-- 1. Чтение из XML/JSON документа.

-- 2. Обновление XML/JSON документа.

-- 3. Запись (Добавление) в XML/JSON документ.

-- 3. LINQ to SQL. Создать классы сущностей, которые моделируют таблицы
-- Вашей базы данных. 

-- Создать запросы четырех типов:
-- 1. Однотабличный запрос на выборку.

-- 2. Многотабличный запрос на выборку.

-- 3. Три запроса на добавление, изменение и удаление данных в базе
-- данных.

-- 4. Получение доступа к данным, выполняя только хранимую
-- процедуру.

ALTER TABLE chess_tournament 
RENAME COLUMN id_organizer TO organizer_id;



DROP TABLE flight;
DROP TABLE satellite;

CREATE TABLE satellite (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    production_date DATE NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE flight (
    satellite_id INT REFERENCES satellite(id),
    launch_date DATE NOT NULL,
    launch_time TIME NOT NULL,
    day_of_week VARCHAR(15) NOT NULL,
    flight_type INT CHECK (flight_type IN (0, 1)),
    PRIMARY KEY (satellite_id, launch_date, launch_time)
);

INSERT INTO satellite (name, production_date, country) VALUES
('Hubble Space Telescope', '1990-04-24', 'USA'),
('International Space Station', '1998-11-20', 'USA'),
('Mars Reconnaissance Orbiter', '2005-03-10', 'USA'),
('Soyuz MS-01', '2016-11-21', 'Russia'),
('Luna 1', '1959-01-12', 'Russia'),
('Chandrayaan-1', '2008-10-22', 'India'),
('Tiangong', '2011-09-29', 'China'),
('Galileo', '2016-10-14', 'European Union');


INSERT INTO flight (satellite_id, launch_date, launch_time, day_of_week, flight_type) VALUES
(1, '1990-04-24', '12:30:00', 'Tuesday', 0),
(2, '1998-11-20', '16:00:00', 'Friday', 0),
(3, '2005-03-10', '14:00:00', 'Thursday', 1),
(4, '2016-11-21', '03:00:00', 'Monday', 0),
(5, '1959-01-12', '22:00:00', 'Monday', 1),
(6, '2008-10-22', '15:45:00', 'Wednesday', 0),
(7, '2011-09-29', '18:30:00', 'Thursday', 1),
(8, '2016-10-14', '09:15:00', 'Friday', 0),
(8, '2024-10-14', '09:15:00', 'Friday', 1),
(8, '2023-10-14', '09:15:00', 'Friday', 1),
(3, '2023-03-10', '14:00:00', 'Thursday', 0),
(4, '2024-11-21', '03:00:00', 'Monday', 0),
(5, '1924-01-12', '22:00:00', 'Monday', 1);

1) Этот запрос ищет спутник, у которого наибольшее количество запусков. 

Запрос выбирает satellite_id и количество запусков для каждого спутника из таблицы flight, 
проводится группировка по satellite_id, чтобы подсчитать количество запусков для каждого спутника.
Результаты сортируются по количеству запусков в порядке убывания.
Запрос ограничивает вывод до одного результата -> возвращает только спутник с наибольшим количеством запусков.

-- explain для проверки 
EXPLAIN
SELECT satellite_id, COUNT(*) AS launch_count
FROM flight
GROUP BY satellite_id
ORDER BY launch_count DESC
LIMIT 1;

2) Этот запрос ищет пары спутников из таблицы satellite, которые принадлежат одной и той же стране. 

Он выбирает id и country для обоих спутников и проверяет условие, что идентификатор первого спутника (s1.id) 
меньше идентификатора второго спутника (s2.id). Это условие предотвращает дублирование пар спутников и 
исключает случаи, когда спутник сравнивается сам с собой.

-- explain для проверки
EXPLAIN
SELECT s1.id, s1.country, s2.id, s2.country
FROM satellite s1
JOIN satellite s2 ON s1.country = s2.country
WHERE s1.id < s2.id;



