--------------------------
-- Test production queries
--------------------------


-- select the names of all counties in a particular state
-- used for populating the dropdown menu where user selects location
SELECT name
FROM County
WHERE state = 'NC'
ORDER BY name ASC;

-- select aggregate pollution and demographic data
-- for a particular county
SELECT County.name, County.state, SUM(carbon_monoxide) AS CO, SUM(oxides_of_nitrogen) AS NO, SUM(sulfur_dioxide) AS SO2, SUM(particulate_matter_10) AS PM10, SUM(lead) AS lead, SUM(mercury) AS mercury, population_density, unemployment_rate, median_income, percent_HS, percent_bachelors
FROM County, Facility, FacilityPollution
WHERE Facility.county = County.name
AND Facility.state = County.state
AND Facility.EIS_ID = FacilityPollution.EIS_ID
GROUP BY County.name, County.state
HAVING County.name = 'Durham'
AND County.state = 'NC';

-- select counties with aggregate lead pollution greater than 5 tons
-- display their unemployment rate 
SELECT County.name, County.state, County.unemployment_rate, SUM(lead)
FROM County, Facility, FacilityPollution
WHERE County.name = Facility.county
	AND County.state = Facility.state
	AND Facility.EIS_ID = FacilityPollution.EIS_ID
GROUP BY County.name, County.state
HAVING SUM(lead) > 5
ORDER BY County.unemployment_rate DESC;

-- select the top 10 counties with highest population_density
-- and display corresponding pollution info
-- used for observing whether there is a correlation between population density
-- and pollution
SELECT County.name, County.state, SUM(carbon_monoxide) AS CO, SUM(oxides_of_nitrogen) AS NO, SUM(sulfur_dioxide) AS SO2, SUM(particulate_matter_10) AS PM10, SUM(lead) AS lead, SUM(mercury) AS mercury
FROM County, Facility, FacilityPollution
WHERE County.name = Facility.county
	AND County.state = Facility.state
	AND Facility.EIS_ID = FacilityPollution.EIS_ID
GROUP BY County.name, County.state
ORDER BY County.population_density DESC
LIMIT 10;

-- select the 10 counties with lowest median median_income
-- and display their pollution data
SELECT County.name, County.state, SUM(carbon_monoxide) AS CO, SUM(oxides_of_nitrogen) AS NO, SUM(sulfur_dioxide) AS SO2, SUM(particulate_matter_10) AS PM10, SUM(lead) AS lead, SUM(mercury) AS mercury
FROM County, Facility, FacilityPollution
WHERE County.name = Facility.county
	AND County.state = Facility.state
	AND Facility.EIS_ID = FacilityPollution.EIS_ID
GROUP BY County.name, County.state
ORDER BY County.median_income ASC
LIMIT 10;

-- select counties with similar demographic data as a particular county
-- we use median income and Durham, NC here as an example
-- the median income of Durham, NC is 50078
SELECT C2.name, C2.state, C2.median_income 
FROM County AS C1, County AS C2
WHERE C1.name = 'Durham'
	AND C1.state = 'NC'
	AND C1.median_income <= C2.median_income+500
	AND C1.median_income >= C2.median_income-500
	AND C2.name <> C1.name;

-- select the top 10 polluters in terms of carbon monoxide emission in a particular state
-- we use California as an example
SELECT name, city, carbon_monoxide
FROM Facility, FacilityPollution
WHERE state = 'CA'
	AND Facility.EIS_ID = FacilityPollution.EIS_ID
	AND carbon_monoxide > 0
ORDER BY carbon_monoxide DESC
LIMIT 10;