CREATE TABLE IF NOT EXISTS participant
(
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR(100),
	sex CHAR,
	age INT,
	phone_number VARCHAR(15),
	email VARCHAR(100),
	rating INT
);

CREATE TABLE IF NOT EXISTS prize_info
(
	id INT NOT NULL PRIMARY KEY,
	third_place INT,
	second_place INT,
	first_place INT
);

CREATE TABLE IF NOT EXISTS organizer
(
	id INT NOT NULL PRIMARY KEY,
	company_name VARCHAR(100),
	address VARCHAR(300),
	email VARCHAR(100),
	phone_number VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS chess_tournament
(
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR(100),
	address VARCHAR(300),
	date DATE,
	time TIME,
	id_prizes INT,
	id_organizer INT
);

CREATE TABLE IF NOT EXISTS chess_tournament_with_participant
(
	-- id INT NOT NULL PRIMARY KEY,
	id_participant INT,
	id_chess_tournament INT,
	place INT
);
