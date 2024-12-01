from faker import Faker
from random import randint, choice
import datetime
import time
import json


class participant():
	id = int()
	name = str()
	sex = str()
	age = int()
	phone_number = str()
	email = str()
	rating = int()

	def __init__(self, id, name, sex, age, phone_number, email, rating):
		self.id = id
		self.name = name
		self.sex = sex
		self.age = age
		self.phone_number = phone_number
		self.email = email
		self.rating = rating

	def get(self):
		return {
			'id': self.id, 
			'name': self.name,
			'sex': self.sex,
			'age': self.age,
			'phone_number': self.phone_number,
			'email': self.email, 
			'rating': self.rating
		}

	def __str__(self):
		return f"{self.id:<10} {self.name:<20} {self.sex:<5} {self.age:<5} {self.phone_number:<15} {self.email:<50} {self.rating:<10}"


def FakeEmail(fake: Faker):
	list_of_domains = (
		'com',
		'com.br',
		'net',
		'net.br',
		'org',
		'org.br',
		'gov',
		'gov.br'
	)

	first_name = fake.first_name()
	last_name = fake.last_name()
	company = fake.company().split()[0].strip(',')

	dns_org = fake.random_choices(
		elements=list_of_domains,
		length=1
	)[0]
	
	email = f"{first_name}.{last_name}@{company}.{dns_org}".lower()
	return email


def FakePhoneNumber(fake: Faker) -> str:
	return "+" + str(randint(1, 100)) + f'{fake.msisdn()[3:]}'


# Разработать приложение, генерирующее файл в формате JSON/XML/CSV с
# данными, соответствующими теме БД. С частотой раз в 5 минут необходимо
# создавать новый файл, имя которого соответствует разработанной маске.
# Маска должна включать в себя как минимум:
# 1. идентификатор файла
# 2. имя таблицы, в которую загружаются данные из этого файла
# 3. дату и время формирования файла

def main():
	fake = Faker()
	sex = ['w', 'm']
	
	i = 0
	while True:
		file_name = f"data/participant_{i:05d}_" + \
					str(datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S")) + ".json"
		print(file_name)

		with open(file_name, "w") as f:
			for j in range(50):
				p = participant(i * 50 + j, fake.name(), choice(sex), randint(0, 100), FakePhoneNumber(fake), FakeEmail(fake), randint(0, 10000))
				print(json.dumps(p.get()), file=f)

		i += 1
		time.sleep(60 * 5)


if __name__ == "__main__":
	main()
