-------------------------------------------------- 
-- Run this script using "psql -af setup.sql" 
-- to create and load production database
-- FIXME: Do full joins in setupProd for facilitypollution prod table, not natural joins!
-------------------------------------------------- 

TRIGGER TF_FacilityCounty;
DROP TABLE State cascade;
DROP TABLE County;
DROP TABLE Facility cascade;
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
	name VARCHAR NOT NULL,
	address VARCHAR,
	city VARCHAR,
	county VARCHAR, --will need a trigger--
	state VARCHAR(2),
	industry VARCHAR,
	latitude double precision,
	longitude double precision
);


CREATE TABLE FacilityPollution (
	EIS_ID INTEGER NOT NULL PRIMARY KEY REFERENCES Facility(EIS_ID),
	carbon_monoxide double precision, --tons--
	oxides_of_nitrogen double precision, --tons--
	sulfur_dioxide double precision, --tons--
	particulate_matter_10 double precision, --tons--
	lead double precision, --tons--
	mercury double precision --lbs--
);

CREATE TRIGGER TG_FacilityCounty
	BEFORE INSERT OR UPDATE
	ON Facility
	FOR EACH ROW
	EXECUTE PROCEDURE TF_FacilityCounty();

CREATE OR REPLACE FUNCTION TF_FacilityCounty() RETURNS TRIGGER AS $$
BEGIN
	IF (NEW.county NOT IN (SELECT name FROM County WHERE County.State = NEW.State)) THEN
		RAISE EXCEPTION 'Facility must be in a valid county.';
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

--------------------------------------------------
-- Insert PRODUCTION data into the tables just created 
--------------------------------------------------

COPY state from '/home/azureuser/proj/stateTable.csv' DELIMITER ',' CSV;
COPY county from '/home/azureuser/proj/countyTable.csv' DELIMITER ',' CSV;
COPY facility from '/home/azureuser/proj/facilityTable.csv' DELIMITER ',' CSV;
COPY facilitypollution from '/home/azureuser/proj/facilitypollutionTable.csv' DELIMITER ',' CSV;