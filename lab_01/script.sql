CREATE TABLE IF NOT EXISTS participant
(
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR(100),
	sex CHAR,
	age INT CHECK (age >= 0 and age <= 100),
	phone_number VARCHAR(10),
	email VARCHAR(100),
	rating INT CHECK (0 <= rating AND rating <= 10000)
);

CREATE TABLE IF NOT EXISTS prize_info
(
	id INT NOT NULL PRIMARY KEY,
	third_place INT DEFAULT(0) CHECK (third_place >= 0),
	second_place INT DEFAULT(0) CHECK (third_place >= 0),
	first_place INT DEFAULT(0) CHECK (third_place >= 0)
);

CREATE TABLE IF NOT EXISTS organizer
(
	id INT NOT NULL PRIMARY KEY,
	company_name VARCHAR(100) DEFAULT 'unknown',
	address VARCHAR(300),
	email VARCHAR(100),
	phone_number VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS chess_tournament
(
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR(100) DEFAULT 'Chess Turnament',
	address VARCHAR(300),
	date DATE,
	time TIME,
	durability TIME,
	id_prizes INT,
	FOREIGN KEY (id_prizes) REFERENCES prize_info(id),
	id_organizer INT,
	FOREIGN KEY (id_organizer) REFERENCES organizer(id)
);

CREATE TABLE IF NOT EXISTS chess_tournament_with_participant
(
	-- id INT NOT NULL PRIMARY KEY,
	id_participant INT,
	FOREIGN KEY (id_participant) REFERENCES participant(id),
	id_chess_tournament INT,
	FOREIGN KEY (id_chess_tournament) REFERENCES chess_tournament(id),
	place INT CHECK(place > 0)
);
