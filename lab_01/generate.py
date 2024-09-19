from faker import Faker
from random import randint, choice

MAX = 1000

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

def FakeAddress(fake: Faker):
    address = fake.address()
    return address.replace('\n', ' ').replace(',', '.')

def GenerateChessTournament():
    # id | name | address | date | time | id_prizes | id_organizer
    fake = Faker()
    result = open("chess_tournament.csv", "w")

    for i in range(MAX):
        line = "{0},{1},{2},{3},{4},{5},{6}\n".format(
            i, fake.name(), FakeAddress(fake), fake.date(), fake.time(), randint(0, MAX - 1), randint(0, MAX - 1))
        result.write(line)

    result.close()

def GenerateOrganizer():
    # id | company_name | address | email | number
    fake = Faker()
    result = open("organizer.csv", "w")

    for i in range(MAX):
        line = "{0},{1},{2},{3},{4}\n".format(
            i, fake.company().split()[0].strip(','), FakeAddress(fake), FakeEmail(fake), FakePhoneNumber(fake))
        result.write(line)

    result.close()


def GenerateParticipant():
    # id | full_name | sex | age | phone_number | email | raiting
    fake = Faker()
    result = open("participant.csv", "w")

    sex = ['w', 'm']

    for i in range(MAX):
        line = "{0},{1},{2},{3},{4},{5},{6}\n".format(
            i, fake.name(), choice(sex), randint(0, 100), FakePhoneNumber(fake), FakeEmail(fake), randint(0, 10000))
        result.write(line)

    result.close()


def GeneratePrizeInfo():
    # id | 1st | 2nd | 3rd | Валюта?
    fake = Faker()
    result = open("prize_info.csv", "w")

    for i in range(MAX):
        prize = sorted([randint(0, 10000), randint(0, 10000), randint(0, 10000)])
        line = "{0},{1},{2},{3}\n".format(
            i, prize[0], prize[1], prize[2])
        result.write(line)

    result.close()


def GenerateChessTournamentWithPartiscipant():
    # id | id_participant | id_chess_tournament | place
    fake = Faker()
    result = open("chess_tournament_with_participant.csv", "w")

    for i in range(MAX):
        line = "{0},{1},{2}\n".format(
            randint(0, MAX), randint(0, MAX), randint(0, 100))
        result.write(line)

    result.close()


if __name__ == "__main__":
    GenerateOrganizer()
    GenerateChessTournament()
    GenerateParticipant()
    GeneratePrizeInfo()
    GenerateChessTournamentWithPartiscipant()