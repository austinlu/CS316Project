-------------------------------------------------- 
-- Run this script using "psql -af setup.sql" 
-- to create and load the sample database

--TWO ASSUMPTIONS:

--All facilities have a county and state
--All county's are similarly named
--------------------------------------------------

DROP TRIGGER TF_FacilityCounty;
DROP TABLE State cascade;
DROP TABLE County;
DROP TABLE Facility cascade;
DROP TABLE FacilityPollution;

DROP TABLE rawco;
drop table rawhg;
drop table rawpb;
DROP TABLE rawno;
drop table rawpm;
drop table rawso;

DROP TABLE eis2co;
drop table eis2hg;
drop table eis2pb;
DROP TABLE eis2no;
drop table eis2pm;
drop table eis2so;

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
	address VARCHAR ,
	city VARCHAR,
	county VARCHAR, --will need a trigger--
	state VARCHAR(2),
	industry VARCHAR,
	latitude double precision,
	longitude double precision
);

CREATE TABLE EIS2CO(
	EIS_ID INTEGER NOT NULL,
	carbon_monoxide double precision NOT NULL
);

CREATE TABLE EIS2Hg(
	EIS_ID INTEGER NOT NULL,
	mercury double precision NOT NULL
);

CREATE TABLE EIS2Pb(
	EIS_ID INTEGER NOT NULL,
	lead double precision NOT NULL
);

CREATE TABLE EIS2NO(
	EIS_ID INTEGER NOT NULL,
	oxides_of_nitrogen double precision NOT NULL
);

CREATE TABLE EIS2pm(
	EIS_ID INTEGER NOT NULL,
	particulate_matter_10  double precision NOT NULL
);
CREATE TABLE EIS2So(
	EIS_ID INTEGER NOT NULL,
	sulfur_dioxide double precision NOT NULL
);

CREATE TABLE RawCO(
	EIS_ID INTEGER NOT NULL,
	PollutantVol double precision,
	state VARCHAR(2),
	county VARCHAR,
	name VARCHAR NOT NULL,
	ft VARCHAR,
	tn VARCHAR,
	city VARCHAR,
	zip VARCHAR ,
	naics varchar,
	industry VARCHAR,
	fips varchar,
	address VARCHAR,
	lat double precision,
	longitude double precision
	
);

CREATE TABLE RawPb(
	EIS_ID INTEGER NOT NULL,
	PollutantVol double precision,
	state VARCHAR(2),
	county VARCHAR,
	name VARCHAR NOT NULL,
	ft VARCHAR,
	tn VARCHAR,
	city VARCHAR,
	zip VARCHAR,
	naics integer,
	industry VARCHAR,
	fips integer,
	address VARCHAR,
	lat double precision,
	longitude double precision
	
);

CREATE TABLE RawHg(
	EIS_ID INTEGER NOT NULL,
	PollutantVol double precision,
	state VARCHAR(2),
	county VARCHAR,
	name VARCHAR NOT NULL,
	ft VARCHAR,
	tn VARCHAR,
	city VARCHAR ,
	zip VARCHAR ,
	naics integer,
	industry VARCHAR,
	fips integer,
	address VARCHAR,
	lat double precision,
	longitude double precision
	
);

CREATE TABLE RawSO(
	EIS_ID INTEGER NOT NULL,
	PollutantVol double precision,
	state VARCHAR(2),
	county VARCHAR,
	name VARCHAR NOT NULL,
	ft VARCHAR,
	tn VARCHAR,
	city VARCHAR ,
	zip VARCHAR ,
	naics integer,
	industry VARCHAR,
	fips integer,
	address VARCHAR,
	lat double precision,
	longitude double precision
	
);


CREATE TABLE RawNO(
	EIS_ID INTEGER NOT NULL,
	PollutantVol double precision,
	state VARCHAR(2),
	county VARCHAR,
	name VARCHAR NOT NULL,
	ft VARCHAR,
	tn VARCHAR,
	city VARCHAR ,
	zip VARCHAR ,
	naics integer,
	industry VARCHAR,
	fips integer,
	address VARCHAR,
	lat double precision,
	longitude double precision
	
);


CREATE TABLE Rawpm(
	EIS_ID INTEGER NOT NULL,
	PollutantVol double precision,
	state VARCHAR(2),
	county VARCHAR,
	name VARCHAR NOT NULL,
	ft VARCHAR,
	tn VARCHAR,
	city VARCHAR ,
	zip VARCHAR ,
	naics integer,
	industry VARCHAR,
	fips integer,
	address VARCHAR,
	lat double precision,
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

\COPY rawCO from '/home/azureuser/proj/2011 facility total Carbon Monoxide (CO).csv' DELIMITER ',' CSV HEADER;
\COPY rawPb from '/home/azureuser/proj/2011 facility total lead (Pb).csv' DELIMITER ',' CSV HEADER;
\COPY rawHg from '/home/azureuser/proj/2011 facility total mercury (Hg).csv' DELIMITER ',' CSV HEADER;
\COPY rawNO from '/home/azureuser/proj/2011 facility total nitrogen oxides (NOX).csv' DELIMITER ',' CSV HEADER;
\COPY rawpm from '/home/azureuser/proj/2011 facility total particulate matter 10 microns and less (PM10).csv' DELIMITER ',' CSV HEADER;
\COPY rawSO from '/home/azureuser/proj/2011 facility total sulfur dioxide (SO2).csv' DELIMITER ',' CSV HEADER;


INSERT INTO Facility
SELECT 	EIS_ID,name,address,city,county,state,industry,lat,longitude
FROM rawCO where exists (select * from state where state.abbreviation = rawCO.state)
			and exists (select * from county where rawCO.county = county.name)
			and rawCO.state in (select state from county where rawCO.county = county.name)
			and rawCO.EIS_ID not in (select EIS_ID from facility);
			
INSERT INTO EIS2CO
SELECT 	EIS_ID,pollutantVol
FROM rawCO where rawCO.EIS_ID in (select EIS_ID from facility);			

INSERT INTO Facility
SELECT 	EIS_ID,name,address,city,county,state,industry,lat,longitude
FROM rawPb where exists (select * from state where state.abbreviation = rawPb.state)
			and exists (select * from county where rawPb.county = county.name)
			and rawPb.state in (select state from county where rawPb.county = county.name)
			and rawPb.EIS_ID not in (select EIS_ID from facility);

INSERT INTO EIS2pb
SELECT 	EIS_ID,pollutantVol
FROM rawpb where rawpb.EIS_ID in (select EIS_ID from facility);	

INSERT INTO Facility
SELECT 	EIS_ID,name,address,city,county,state,industry,lat,longitude
FROM rawHg where exists (select * from state where state.abbreviation = rawHg .state)
			and exists (select * from county where rawHg .county = county.name)
			and rawHg .state in (select state from county where rawHg .county = county.name)
			and rawHg.EIS_ID not in (select EIS_ID from facility);

INSERT INTO EIS2hg
SELECT 	EIS_ID,pollutantVol
FROM rawhg where rawhg.EIS_ID in (select EIS_ID from facility);	

INSERT INTO Facility
SELECT 	EIS_ID,name,address,city,county,state,industry,lat,longitude
FROM rawno where exists (select * from state where state.abbreviation = rawno .state)
			and exists (select * from county where rawno .county = county.name)
			and rawno .state in (select state from county where rawno .county = county.name)
			and rawno.EIS_ID not in (select EIS_ID from facility);

INSERT INTO EIS2no
SELECT 	EIS_ID,pollutantVol
FROM rawno where rawno.EIS_ID in (select EIS_ID from facility);	

INSERT INTO Facility
SELECT 	EIS_ID,name,address,city,county,state,industry,lat,longitude
FROM rawpm where exists (select * from state where state.abbreviation = rawpm .state)
			and exists (select * from county where rawpm .county = county.name)
			and rawpm .state in (select state from county where rawpm .county = county.name)
			and rawpm.EIS_ID not in (select EIS_ID from facility);

INSERT INTO EIS2pm
SELECT 	EIS_ID,pollutantVol
FROM rawpm where rawpm.EIS_ID in (select EIS_ID from facility);	

INSERT INTO Facility
SELECT 	EIS_ID,name,address,city,county,state,industry,lat,longitude
FROM rawso where exists (select * from state where state.abbreviation = rawso .state)
			and exists (select * from county where rawso .county = county.name)
			and rawso .state in (select state from county where rawso .county = county.name)
			and rawso.EIS_ID not in (select EIS_ID from facility);

INSERT INTO EIS2so
SELECT 	EIS_ID,pollutantVol
FROM rawso where rawso.EIS_ID in (select EIS_ID from facility);	

insert into facilitypollution(eis_id,mercury, carbon_monoxide, lead ,oxides_of_nitrogen,particulate_matter_10,sulfur_dioxide)
	select * from eis2hg natural join eis2co
						natural join eis2pb
						natural join eis2no
						natural join eis2pm
						natural join eis2so;
						
\COPY county TO '/home/azureuser/proj/countyTable.csv' DELIMITER ',' CSV;
\COPY state TO '/home/azureuser/proj/stateTable.csv' DELIMITER ',' CSV;
\COPY facility TO '/home/azureuser/proj/facilityTable.csv' DELIMITER ',' CSV;
\COPY facilitypollution TO '/home/azureuser/proj/facilitypollutionTable.csv' DELIMITER ',' CSV;
