-- select all facilities within a particular county
SELECT *
FROM Facilities
WHERE county = 'Durham'
AND state = 'NC'
ORDER BY carbon_monoxide DESC;
