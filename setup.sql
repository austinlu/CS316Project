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
	population_density double precision NOT NULL,
	unemployment_rate double precision NOT NULL,
	median_income double precision NOT NULL,
	percent_HS double precision NOT NULL,
	percent_bachelors double precision NOT NULL,

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
	industry VARCHAR(50)
);

CREATE TABLE FacilityPollution (
	EIS_ID INTEGER NOT NULL PRIMARY KEY REFERENCES Facility(EIS_ID),
	carbon_monoxide double precision, --tons--
	oxides_of_nitrogen double precision, --tons--
	sulfur_dioxide double precision, --tons--
	"particulate_matter_2.5" double precision, --tons--
	particulate_matter_10 double precision, --tons--
	lead double precision, --tons--
	mercury double precision --lbs--
);



--------------------------------------------------
-- Insert sample data into the tables just created 
--------------------------------------------------
INSERT INTO State('NC', 'North Carolina');
INSERT INTO State('VA', 'Virginia');
INSERT INTO State('CA', 'California');

INSERT INTO County('Durham', 'NC', 935.7, 7.3, 50078, 86.9, 44.3);
INSERT INTO County('Forsyth', 'NC', 700.7, 8.6, 49828, 68.1, 32);
INSERT INTO County('Brunswick', 'NC', 899.3, 9.3, 52832, 70.2, 24.2);
INSERT INTO County('Los Angeles', 'CA', 2419.6, 11.1, 48838, 67.8, 14);
INSERT INTO County('Marin', 'CA', 1490.2, 12.3, 51002, 62.8, 22.6);
INSERT INTO County('Arlington', 'VA', 2100.5, 4.8, 52901, 67.8, 25.4);
INSERT INTO County('Augusta', 'VA', 960.1, 6.1, 42004, 77.8, 35.9);

INSERT INTO Facility(14639511, 'MP Durham, LLC','2115 East Club Boulevard',	'Durham' ,'NC',	27704, NULL);
INSERT INTO Facility(8051011, 'Duke University' ,'200 Facility Center' 'Durham', 'NC', 27710, 'Colleges, Universities, and Professional Schools');
INSERT INTO Facility(8051711, 'Carolina Sunrock LLC - Muirhead Distribution Center','1503 Camden Avenue','Brunswick','NC', 27704,'Ready-Mix Concrete Manufacturing');
INSERT INTO Facility(8052311, 'Cree Inc - Silicon Dr', '4600 Silicon Drive','Forsythe','NC',27709 ,'Semiconductor and Related Device Manufacturing' );				
INSERT INTO Facility(2255111, ' LOS ANGELES INT AIRPORT' ,'1 World Way', 'Los Angeles', 'CA', 90045, 'Other Airport Operations');
INSERT INTO Facility(4073511, 'BP WEST COAST PROD.LLC', '2350 E 223RD ST', 'Marin', 'CA', 90749, 'Petroleum Refinery' );
INSERT INTO Facility(4086111, 'CHEVRON PRODUCTS CO.', 'W EL SEGUNDO BLVD', 'Arlington', 'VA', 60245, NULL);
INSERT INTO Facility(324110, 'EXXONMOBIL OIL CORPORATION', '3700 W 190TH ST', 'Augusta', 'VA', 62800, 'Petroleum Refinery');

INSERT INTO FacilityPollution(14639511, 49.2, 1.2, 90.52,8000.51, 2300.51, 5.2, 600.2);
INSERT INTO FacilityPollution(8051011, 82.2, 2.11, 40999.1, 30000, 5000.45, 14.2, 305.6);
INSERT INTO FacilityPollution(8051711, 52.2, 0, 999.1, 3500, 603.35, 11.2, 200.5);
INSERT INTO FacilityPollution(8052311, 10.0, 0.8, 2099.1, 61010, 5800.42, 4.8, 79.1);
INSERT INTO FacilityPollution(2255111, 11.2, 0.51, 3109.9, 1510, 424.65, 3.2, 95.6);
INSERT INTO FacilityPollution(4073511, 40.2, 1.11, 1269.2, 9010, 125.45, 0, 91.5);
INSERT INTO FacilityPollution(4086111, 51.0, 0.28, 2299.1, 290, 52.15, 3.8, 25.2);
INSERT INTO FacilityPollution(324110, 99.9, 2.99, 50190.0, 99200, 9889.92, 19.8, 798.9);
