-- select the names of all counties in a particular state
-- used for populating the dropdown menu where user selects location
SELECT name
FROM County
WHERE state = 'CA'
ORDER BY name asc;

-- select names of top 10 CO-polluting facilities 
-- within a particular county and state
SELECT Facility.name
FROM Facility, FacilityPollution
WHERE Facility.EIS_ID = FacilityPollution.EIS_ID 
AND county = 'Durham'
AND state = 'NC'
ORDER BY carbon_monoxide DESC
LIMIT 10;

-- select aggregate pollution data and demographics data
-- for a particular county
SELECT County.name, County.state, SUM(carbon_monoxide), SUM(oxides_of_nitrogen), SUM(sulfur_dioxide), SUM("particulate_matter_2.5"), SUM(particulate_matter_10), SUM(lead), SUM(mercury), population_density, unemployment_rate, median_income, percent_HS, percent_bachelors
FROM County, Facility, FacilityPollution
WHERE Facility.county = County.name
AND Facility.state = County.state
AND Facility.EIS_ID = FacilityPollution.EIS_ID
GROUP BY County.name, County.state
HAVING County.name = 'Durham'
AND County.state = 'NC';

-- select the names of all counties with unemployment rate above 8%
-- and that contain at least one facility that emits 10+ tons of lead
SELECT name, state
FROM County
WHERE unemployment_rate > 8.0
AND EXISTS (
	SELECT * FROM Facility, FacilityPollution
	WHERE Facility.EIS_ID = FacilityPollution.EIS_ID
	AND Facility.county = County.name
	AND Facility.state = County.state
	AND FacilityPollution.lead > 10.0
);


