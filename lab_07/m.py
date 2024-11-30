import datetime
from peewee import *

db = PostgresqlDatabase('chess_db', user='postgres', password='postgres', host='127.0.0.1', port=5432)

class BaseModel(Model):
    class Meta:
        database = db

class Satellite(BaseModel):
    name = CharField()
    production_date = DateField()
    country = CharField()

class Flight(BaseModel):
    satellite = ForeignKeyField(Satellite, backref='flights')
    launch_date = DateField()
    launch_time = TimeField()
    day_of_week = CharField()
    flight_type = IntegerField()


db.connect()
db.create_tables([Satellite, Flight])


def find_oldest_russian_satellite():
    query = "SELECT * FROM satellite WHERE country = 'Russia' ORDER BY production_date ASC LIMIT 1"
    
    cursor = db.execute_sql(query)
    result = cursor.fetchone()
    return result

def find_latest_satellite_launched_this_year():
    query = """SELECT * FROM satellite 
               JOIN flight ON satellite.id = flight.satellite_id 
               WHERE EXTRACT(YEAR FROM flight.launch_date) = EXTRACT(YEAR FROM CURRENT_DATE) AND flight_type = 1
               ORDER BY flight.launch_date DESC LIMIT 1"""
    
    cursor = db.execute_sql(query)
    result = cursor.fetchone()
    return result

def find_latest_returned_satellite_last_year():
    query = """SELECT * FROM satellite 
               JOIN flight ON satellite.id = flight.satellite_id 
               WHERE EXTRACT(YEAR FROM flight.launch_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1  AND flight_type = 0
               ORDER BY flight.launch_date DESC LIMIT 1"""
    
    cursor = db.execute_sql(query)
    result = cursor.fetchone()
    return result


print("Самый древний спутник в России:", find_oldest_russian_satellite())
print("Спутник, который в этом году отправлен позже всех:", find_latest_satellite_launched_this_year())
print("Спутник, который в прошлом календарном году вернулся последним:", find_latest_returned_satellite_last_year())

def find_oldest_russian_satellite_orm():
    return (Satellite
            .select()
            .where(Satellite.country == 'Russia')
            .order_by(Satellite.production_date)
            .limit(1)
            .get())

def find_latest_satellite_launched_this_year_orm():
    return (Satellite
            .select()
            .join(Flight)
            .where(Flight.launch_date.year == datetime.datetime.now().year, Flight.flight_type == 1)
            .order_by(Flight.launch_date.desc())
            .limit(1)
            .get())

def find_latest_returned_satellite_last_year_orm():
    return (Satellite
            .select()
            .join(Flight)
            .where(Flight.launch_date.year == datetime.datetime.now().year - 1, Flight.flight_type == 0)
            .order_by(Flight.launch_date.desc())
            .limit(1)
            .get())

print("Самый древний спутник в России (ORM):", find_oldest_russian_satellite_orm())
print("Спутник, который в этом году отправлен позже всех (ORM):", find_latest_satellite_launched_this_year_orm())
print("Спутник, который в прошлом календарном году вернулся последним (ORM):", find_latest_returned_satellite_last_year_orm())

db.close()
