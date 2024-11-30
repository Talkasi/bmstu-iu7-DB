class participant():
    id = int()
    name = str()
    sex = str()
    age = int()
    phone_number = str()
    email = str()
    rating = int()

    def __init__(self, id, name, sex, age, phone_number, email, rating):
        if not (0 <= age <= 100):
            raise ValueError("Возраст должен быть от 0 до 100.")
        if not (0 <= rating <= 10000):
            raise ValueError("Рейтинг должен быть от 0 до 10000.")

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


def create_participants(file_name):
    file = open(file_name, 'r')
    participants = list()

    for line in file:
        arr = line.split(',')
        arr[0], arr[3], arr[6] = int(arr[0]), int(arr[3]), int(arr[6])
        try:
            participants.append(participant(*arr).get())
        except ValueError as e:
            print(f"Error creating participant from line '{line.strip()}': {e}")

    return participants
