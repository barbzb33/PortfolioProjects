

---FIRST THING WE DO IS COMBINE THE MONTHS INTO ONE ANNUAL TABLE---

DROP TABLE IF EXISTS [cyclistic.annual];


SELECT * INTO [cyclistic.annual] 
FROM
(
	SELECT * FROM [dbo].[2205]
	UNION 
	SELECT* FROM [dbo].[2206]
	UNION 
	SELECT* FROM [dbo].[2207]
	UNION 
	SELECT* FROM [dbo].[2208]
	UNION 
	SELECT* FROM [dbo].[2209]
	UNION 
	SELECT* FROM [dbo].[2210]
	UNION 
	SELECT* FROM [dbo].[2211]
	UNION 
	SELECT* FROM [dbo].[2212]
	UNION 
	SELECT* FROM [dbo].[2301]
	UNION 
	SELECT* FROM [dbo].[2302]
	UNION 
	SELECT* FROM [dbo].[2303]
	UNION 
	SELECT* FROM [dbo].[2304]
)AS [CyclisticAnnual]
WHERE [start_station_name] IS NOT NULL
	AND [start_station_id] IS NOT NULL
    AND [end_station_name] IS NOT NULL
    AND [end_station_id] IS NOT NULL;

---change month format to show name---

	ALTER TABLE [dbo].[cyclistic.annual]
ADD month_name VARCHAR(20);

UPDATE [dbo].[cyclistic.annual]
SET [month_name] = FORMAT(started_at, 'MMMM')

---change weekday format to show name---

ALTER TABLE [dbo].[cyclistic.annual]
ADD weekday_name VARCHAR(20);

UPDATE [dbo].[cyclistic.annual]
SET weekday_name = DATENAME(WEEKDAY, weekday);

ALTER TABLE [dbo].[cyclistic.annual]
DROP COLUMN weekday;

---alter table to show only time not date for ride length---
ALTER TABLE [dbo].[cyclistic.annual]
ADD ride_length_time TIME;

UPDATE [dbo].[cyclistic.annual]
SET ride_length_time = CONVERT(TIME, ride_length);

ALTER TABLE [dbo].[cyclistic.annual]
DROP COLUMN ride_length;


SELECT *
FROM [dbo].[cyclistic.annual]

--------ANALYZE RIDE FREQUENCY FOR MEMBERS AND CASUAL RIDERS--------

SELECT member_casual, COUNT(*) AS ride_frequency
FROM [cyclistic.annual]
GROUP BY member_casual;

----percentage annually

SELECT member_casual, COUNT(*) AS ride_count, 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [dbo].[cyclistic.annual])) AS ride_percentage
FROM [dbo].[cyclistic.annual]
GROUP BY member_casual;

----months with the highest usage-----

SELECT member_casual, MONTH(started_at) AS month, COUNT(*) AS ride_count
FROM [dbo].[cyclistic.annual]
GROUP BY member_casual, MONTH(started_at)
HAVING COUNT(*) = (
    SELECT max(ride_count)
    FROM (
        SELECT member_casual, MONTH(started_at) AS month, COUNT(*) AS ride_count
        FROM [dbo].[cyclistic.annual]
        GROUP BY member_casual, MONTH(started_at)
    ) AS subquery
    WHERE subquery.member_casual = [dbo].[cyclistic.annual].member_casual
)

---month with the lowest usage---

SELECT member_casual, MONTH(started_at) AS month, COUNT(*) AS ride_count
FROM [dbo].[cyclistic.annual]
GROUP BY member_casual, MONTH(started_at)
HAVING COUNT(*) = (
    SELECT min(ride_count)
    FROM (
        SELECT member_casual, MONTH(started_at) AS month, COUNT(*) AS ride_count
        FROM [dbo].[cyclistic.annual]
        GROUP BY member_casual, MONTH(started_at)
    ) AS subquery
    WHERE subquery.member_casual = [dbo].[cyclistic.annual].member_casual
)
--------ANALYZE AVERAGE RIDE DURATIONS FOR ANNUAL MEMBERS--------

SELECT AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS average_ride_length
FROM [cyclistic.annual]
WHERE member_casual = 'member';

--------IDENTIFY PEAK USAGE TIMES FOR BOTH MEMBERS AND CASUAL RIDERS---------

SELECT DATEPART(HOUR, started_at) AS hour_of_day, DATENAME(WEEKDAY, started_at) AS weekday, COUNT(*) AS ride_frequency
FROM [cyclistic.annual]
WHERE member_casual = 'member'
GROUP BY DATEPART(HOUR, started_at), DATENAME(WEEKDAY, started_at)
ORDER BY ride_frequency DESC;

SELECT DATEPART(HOUR, started_at) AS hour_of_day, DATENAME(WEEKDAY, started_at) AS weekday, COUNT(*) AS ride_frequency
FROM [cyclistic.annual]
WHERE member_casual = 'casual'
GROUP BY DATEPART(HOUR, started_at), DATENAME(WEEKDAY, started_at)
ORDER BY ride_frequency DESC;

---max ride length per member type----

SELECT MAX(ride_length) AS max_ride_length
FROM [dbo].[cyclistic.annual]
WHERE member_casual = 'casual';

SELECT MAX(ride_length) AS max_ride_length
FROM [dbo].[cyclistic.annual]
WHERE member_casual = 'member' ;

-------ANALYZE AVERAGE RIDE DURATION FOR CASUAL RIDERS----

SELECT AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS average_ride_length
FROM [cyclistic.annual]
WHERE member_casual = 'casual';


--------IDENTIFY MOST FREQUENT START AND STOP STATIONS FOR MEMBERS -----

SELECT start_station_name, COUNT(*) AS frequency
FROM [cyclistic.annual]
WHERE member_casual = 'member' and start_station_name IS NOT NULL
GROUP BY start_station_name
ORDER BY frequency DESC;

SELECT end_station_name, COUNT(*) AS frequency
FROM [cyclistic.annual]
WHERE member_casual = 'member' AND end_station_name IS NOT NULL
GROUP BY end_station_name
ORDER BY frequency DESC;


----IDENTIFY MOST FREQUENT START AND STOP STATIONS FOR CASUAL RIDERS----

SELECT start_station_name, COUNT(*) AS frequency
FROM [cyclistic.annual]
WHERE member_casual = 'casual' and start_station_name IS NOT NULL
GROUP BY start_station_name
ORDER BY frequency DESC;

SELECT end_station_name, COUNT(*) AS frequency
FROM [cyclistic.annual]
WHERE member_casual = 'casual' AND end_station_name IS NOT NULL
GROUP BY end_station_name
ORDER BY frequency DESC;

---max ride length per member type----

SELECT MAX(ride_length) AS max_ride_length
FROM [dbo].[cyclistic.annual]
WHERE member_casual = 'casual';

SELECT MAX(ride_length) AS max_ride_length
FROM [dbo].[cyclistic.annual]
WHERE member_casual = 'member' ;

----max start and end locations with longitude and latitude----
SELECT member_casual, start_station_name, start_lat, start_lng, COUNT(*) AS start_location_count
FROM [dbo].[cyclistic.annual]
GROUP BY member_casual, start_station_name, start_lat, start_lng
HAVING COUNT(*) = (
    SELECT MAX(start_location_count)
    FROM (
        SELECT member_casual, start_station_name, start_lat, start_lng, COUNT(*) AS start_location_count
        FROM [dbo].[cyclistic.annual]
        GROUP BY member_casual, start_station_name, start_lat, start_lng
    ) AS subquery
    WHERE subquery.member_casual = [dbo].[cyclistic.annual].member_casual
)
ORDER BY member_casual;

SELECT member_casual, end_station_name, end_lat, end_lng, COUNT(*) AS end_location_count
FROM [dbo].[cyclistic.annual]
GROUP BY member_casual, end_station_name, end_lat, end_lng
HAVING COUNT(*) = (
    SELECT MAX(end_location_count)
    FROM (
        SELECT member_casual, end_station_name, end_lat, end_lng, COUNT(*) AS end_location_count
        FROM [dbo].[cyclistic.annual]
        GROUP BY member_casual, end_station_name, end_lat, end_lng
    ) AS subquery
    WHERE subquery.member_casual = [dbo].[cyclistic.annual].member_casual
)
ORDER BY member_casual;

