from peewee import *

# -- 3. LINQ to SQL. Создать классы сущностей, которые моделируют таблицы
# -- Вашей базы данных. 

# -- Создать запросы четырех типов:
# -- 1. Однотабличный запрос на выборку.

# -- 2. Многотабличный запрос на выборку.

# -- 3. Три запроса на добавление, изменение и удаление данных в базе
# -- данных.

# -- 4. Получение доступа к данным, выполняя только хранимую
# -- процедуру.


connection = PostgresqlDatabase(
	database="chess_db",
	user="postgres",
	password="postgres",
	host="127.0.0.1", 
	port=5432
)


class BaseModel(Model):
	class Meta:
		database = connection


class Participant(BaseModel):
	id = IntegerField(column_name='id')
	name = CharField(column_name='name')
	sex = CharField(column_name='sex')
	age = IntegerField(column_name='age')
	phone_number = CharField(column_name='phone_number')
	email = CharField(column_name='email')
	rating = IntegerField(column_name='rating')

	class Meta:
		table_name = 'participant'


class PrizeInfo(BaseModel):
	id = IntegerField(column_name='id')
	third_place = IntegerField(column_name='third_place')
	second_place = IntegerField(column_name='second_place')
	first_place = IntegerField(column_name='first_place')

	class Meta:
		table_name = 'prize_info'


class Organizer(BaseModel):
	id = IntegerField(column_name='id')
	company_name = CharField(column_name='company_name')
	address = CharField(column_name='address')
	email = CharField(column_name='email')
	phone_number = CharField(column_name='phone_number')

	class Meta:
		table_name = 'organizer'


class ChessTournament(BaseModel):
	id = IntegerField(column_name='id')
	name = CharField(column_name='name')
	address = CharField(column_name='address')
	date = DateField(column_name='date')
	time = TimeField(column_name='time')
	prizes_id = ForeignKeyField(PrizeInfo, backref='prizes_id')
	organizer_id = ForeignKeyField(Organizer, backref='organizer_id')

	class Meta:
		table_name = 'chess_tournament'


class ChessTournamentWithParticipant(BaseModel):
	id = IntegerField(column_name='id')
	participant_id = ForeignKeyField(PrizeInfo, backref='participant_id')
	chess_tournament_id = ForeignKeyField(ChessTournament, backref='chess_tournament_id')
	place = IntegerField(column_name='place')

	class Meta:
		table_name = 'chess_tournament_with_participant'


def query_1():
	participant = Participant.get(Participant.id == 2)
	print("\n1. Однотабличный запрос на выборку.")

	print("\nУчастник с id = 2:")
	print("Id:", participant.id)
	print("Name:", participant.name)
	print("Age:", participant.age)
	print("Sex:", participant.sex)
	print("Phone number:", participant.phone_number)
	print("Email:", participant.email)
	print("Rating:", participant.rating)

	query = Participant.select().where(Participant.age == 18).where(Participant.rating > 1000).limit(10).order_by(Participant.id)
	print("\nЗапрос:\n", query)
	participants_selected = query.dicts().execute()

	print("\nРезультат:")
	for elem in participants_selected:
		print(elem)


def query_2():
	global connection 
	print("\n2. Многотабличный запрос на выборку.")
	print("Вывести id организатора, его компанию, имя турнира и дату его проведения максимум для 10 турниров, если они проводились не ранее 2023 года.")

	query = Organizer \
			.select(Organizer.id, Organizer.company_name, ChessTournament.name, ChessTournament.date) \
			.join(ChessTournament, on=(Organizer.id == ChessTournament.organizer_id)) \
			.order_by(Organizer.id) \
			.limit(10) \
			.where(ChessTournament.date > "2023-01-01")

	print("\nЗапрос:\n", query, "\n")
	result = query.dicts().execute()
	for elem in result:
		print(elem)


def query_3():
	print("\n3. Три запроса на добавление, изменение и удаление данных в базе данных.")
	print_last_five_participants()

	print("Добавление участника в БД.")
	add_participant(9999, 'Toshibo Inki', 'm', 20, '+1234567890', '123@gmail.com', 3333)
	print_last_five_participants()

	print("Изменение имени участника в БД.")
	update_name(9999, 'Toshibo Anki')
	print_last_five_participants()

	print("Удаление участника из БД.")
	delete_participant(9999)
	print_last_five_participants()


def query_4():
	global connection 
	cursor = connection.cursor()

	print("\n4. Получение доступа к данным, выполняя только хранимую процедуру.")

	print_last_five_participants()
	cursor.execute("CALL update_participant_phone_number(%s, %s);", (2999, "+71111111111111"))
	connection.commit()

	print_last_five_participants()
	cursor.execute("CALL update_participant_phone_number(%s, %s);", (2999, "+72222222222222"))
	connection.commit()
	print_last_five_participants()

	cursor.close()
	

def print_last_five_participants():
	print("Последние 5 участников (по id):")
	query = Participant.select().limit(5).order_by(Participant.id.desc())
	for elem in query.dicts().execute():
		print(elem)
	print()


def add_participant(new_id, new_name, new_sex, new_age, new_phone_number, new_email, new_rating):
	global connection 
	
	try:
		with connection.atomic() as atomic:
			Participant.create(id=new_id, \
							   name=new_name, \
							   sex=new_sex, \
							   age=new_age, \
							   phone_number=new_phone_number, \
							   email=new_email, \
							   rating=new_rating)
	except:
		print("Ошибка.")
		atomic.rollback()


def update_name(participant_id, new_name):
	participant = Participant(id=participant_id)
	participant.name = new_name
	participant.save()


def delete_participant(participant_id):
	participant = Participant.get(Participant.id == participant_id)
	participant.delete_instance()


def task_3():
	global connection 

	query_1()
	query_2()
	query_3()
	query_4()

	connection.close()


if __name__ == "__main__":
	task_3()
