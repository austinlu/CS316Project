-------------------------------------------------- 
-- Run this script using "psql -af sample.sql" 
-- to create and load the sample database
--------------------------------------------------

DROP TABLE State;
DROP TABLE County;
DROP TABLE Facility;
DROP TABLE FacilityPollution;

CREATE TABLE State (
	abbreviation VARCHAR(2) NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE County (
	name VARCHAR(50) NOT NULL,
	state VARCHAR(2) NOT NULL REFERENCES State(abbreviation),
	unemployment_rate INTEGER NOT NULL,
	population INTEGER NOT NULL
	PRIMARY KEY(name, state)
);

CREATE TABLE Facility (
	EIS_ID INTEGER NOT NULL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	address VARCHAR(50) NOT NULL,
	city VARCHAR(50) NOT NULL,
	county VARCHAR(50) NOT NULL REFERENCES County(name),
	state VARCHAR(2) NOT NULL REFERENCES State(abbreviation),
	zipcode INTEGER NOT NULL,
	industry VARCHAR(50) NOT NULL
);

CREATE TABLE FacilityPollution (
	EIS_ID INTEGER NOT NULL PRIMARY KEY REFERENCES Facility(EIS_ID),
	carbon_monoxide INTEGER,
	oxides_of_nitrogen INTEGER,
	sulfur_dioxide INTEGER,
	"particulate_matter_2.5" INTEGER,
	particulate_matter_10 INTEGER,
	lead INTEGER,
	mercury INTEGER 
);



--------------------------------------------------
-- Insert sample data into the tables just created 
--------------------------------------------------
INSERT INTO State('NC', 'North Carolina');
INSERT INTO State('VA', 'Virginia');
INSERT INTO STATE('CA', 'California');

INSERT INTO County('Durham', 'NC');