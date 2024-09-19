--Participant constraints

ALTER TABLE participant
    ADD CONSTRAINT age CHECK (age >= 0 and age <= 100);
ALTER TABLE participant
    ADD CONSTRAINT rating CHECK (0 <= rating AND rating <= 10000);

-- Set default values
ALTER TABLE prize_info
    ALTER COLUMN third_place SET DEFAULT 0;

ALTER TABLE prize_info
    ALTER COLUMN second_place SET DEFAULT 0;

ALTER TABLE prize_info
    ALTER COLUMN first_place SET DEFAULT 0;

-- Add check constraints
ALTER TABLE prize_info
    ADD CONSTRAINT chk_third_place CHECK (third_place >= 0);

ALTER TABLE prize_info
    ADD CONSTRAINT chk_second_place CHECK (second_place >= 0);

ALTER TABLE prize_info
    ADD CONSTRAINT chk_first_place CHECK (first_place >= 0);

--Organizer constraints
ALTER TABLE organizer
    ALTER COLUMN company_name SET DEFAULT 'unknown';

--Chess_tournament constraints
ALTER TABLE chess_tournament
    ALTER COLUMN name SET DEFAULT 'Chess Turnament';
ALTER TABLE chess_tournament
    ADD CONSTRAINT date  CHECK (date >= '1900-01-01'::date AND date <= current_date);
ALTER TABLE chess_tournament
    ADD CONSTRAINT id_prizes FOREIGN KEY (id_prizes) REFERENCES prize_info(id);
ALTER TABLE chess_tournament
    ADD CONSTRAINT id_organizer FOREIGN KEY (id_organizer) REFERENCES prize_info(id);