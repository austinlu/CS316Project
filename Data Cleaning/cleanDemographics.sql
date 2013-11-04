-------------------------------------------------- 
-- Run this script using "psql -af filename.sql" 
-- to create and load transition cleaning databases that can be exported as csv
--------------------------------------------------

DROP TRIGGER TF_FacilityCounty;
DROP TABLE State cascade;
DROP TABLE County;
DROP TABLE Facility cascade;
DROP TABLE FacilityPollution;
DROP TABLE CountyDemo;
DROP TABLE CountyFipsunemp;
DROP TABLE exportTable;


CREATE TABLE State (
	abbreviation VARCHAR(2) NOT NULL,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE CountyDemo (
	fips VARCHAR,
	population_density double precision NOT NULL,
--WILLADD THIS LATER...		unemployment_rate double precision NOT NULL,
	median_income double precision NOT NULL,
	percent_HS double precision NOT NULL,
	percent_bachelors double precision NOT NULL

);

CREATE TABLE CountyFipsunemp (
	stateName VARCHAR,
	countyName VARCHAR,
	fips VARCHAR,
	unemp_rate double precision -- June 2012 http://www.bls.gov/lau/#tables --
);


--------------------------------------------------
-- Insert PRODUCTION data into the tables just created 
--------------------------------------------------
COPY state from '/home/azureuser/proj/stateTable.csv' DELIMITER ',' CSV;
COPY Countydemo from '/home/azureuser/proj/countyTable.csv' DELIMITER ',' CSV;
COPY countyfipsunemp from '/home/azureuser/proj/workingFIPSandUNEMP.csv' DELIMITER ',' CSV;

SELECT countyName, abbreviation, population_density, unemp_rate,median_income, percent_HS, percent_bachelors 
INTO TABLE exportTable
FROM state,countydemo, countyfipsunemp
WHERE State.name = countyfipsunemp.stateName AND countyfipsunemp.fips = countydemo.fips;

\COPY exportTable TO '/home/azureuser/proj/countyTable.csv' DELIMITER ',' CSV;