--SQL VIEW

DROP VIEW IF EXISTS forestation;

CREATE VIEW forestation
AS
(SELECT f.country_code AS forest_country_code,
f.country_name AS forest_country_name,
f.year AS f_year,
f.forest_area_sqkm AS forest_sq_km,
l.country_code AS land_country_code,
l.country_name AS land_country_name,
l.year AS l_year,
l.total_area_sq_mi *2.59 AS land_sq_km,
r.country_name AS region_country_name,
r.country_code AS region_country_code,
r.region AS r_region,
r.income_group AS r_income_group,
(f.forest_area_sqkm/(l.total_area_sq_mi *2.59))*100 AS percent_forrest_area
FROM forest_area AS f
JOIN land_area AS l
ON f.country_code = l.country_code AND f.year = l.year
JOIN regions AS r
ON r.country_code = l.country_code);

--1. Global Situation
--a.What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
SELECT f_year,
       forest_sq_km,
       forest_country_name
FROM   forestation
WHERE  f_year = 1990
       AND forest_country_name = 'World';


--b.What was the total forest area (in sq km) of the world in 2016? 
--Please keep in mind that you can use the country record in the table is denoted as “World.”
SELECT f_year,
       forest_sq_km,
       forest_country_name
FROM   forestation
WHERE  f_year = 2016
       AND forest_country_name = 'World';

--c.What was the change (in sq km) in the forest area of the world from 1990 to 2016?
WITH sub1
     AS (SELECT f_year,
                forest_sq_km,
                forest_country_code
         FROM   forestation
         WHERE  f_year = 1990
                AND forest_country_name = 'World'),
     sub2
     AS (SELECT f_year,
                forest_sq_km,
                forest_country_code
         FROM   forestation
         WHERE  f_year = 2016
                AND forest_country_name = 'World')
SELECT sub1.forest_sq_km - sub2.forest_sq_km AS diff_forest_sq_km
FROM   sub1
       JOIN sub2
         ON sub1.forest_country_code = sub2.forest_country_code; 

--d.What was the percent change in forest area of the world between 1990 and 2016?
WITH sub1
     AS (SELECT f_year,
                forest_sq_km,
                forest_country_code
         FROM   forestation
         WHERE  f_year = 1990
                AND forest_country_name = 'World'),
     sub2
     AS (SELECT f_year,
                forest_sq_km,
                forest_country_code
         FROM   forestation
         WHERE  f_year = 2016
                AND forest_country_name = 'World')
SELECT ( sub1.forest_sq_km - sub2.forest_sq_km ) / ( sub1.forest_sq_km ) * 100
       AS
       per_change_forest
FROM   sub1
       JOIN sub2
         ON sub1.forest_country_code = sub2.forest_country_code; 

--e.If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

WITH sub1
AS
  (
         SELECT f_year,
                forest_sq_km,
                forest_country_code
         FROM   forestation
         WHERE  f_year = 1990
         AND    forest_country_name = 'World'),
  sub2
AS
  (
         SELECT f_year,
                forest_sq_km,
                forest_country_code
         FROM   forestation
         WHERE  f_year = 2016
         AND    forest_country_name = 'World')
  SELECT   land_country_name,
           land_sq_km,
           abs((land_sq_km) -
           (
                  SELECT sub1.forest_sq_km - sub2.forest_sq_km
                  FROM   sub1
                  JOIN   sub2
                  ON     sub1.forest_country_code = sub2.forest_country_code)) AS diff_forest_area
  FROM     forestation
  WHERE    l_year = '2016'
  ORDER BY diff_forest_area
  LIMIT    1;


--2. Regional Situation
--a.What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
    SELECT r_region,
       f_year,
       Round(( ( Sum(forest_sq_km) / Sum(land_sq_km) ) * 100 ) :: NUMERIC, 2) AS
       per_change_forest
FROM   forestation
WHERE  f_year = 2016
       AND r_region = 'World'
GROUP  BY r_region,
          f_year; 
--a.1.Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
SELECT r_region,
       Round(( ( Sum(forest_sq_km) / Sum(land_sq_km) ) * 100 ) :: NUMERIC, 2) AS
       per_change_forest
FROM   forestation
WHERE  f_year = 2016
GROUP  BY r_region
ORDER  BY per_change_forest DESC; 

--b.What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
SELECT r_region,
       f_year,
       Round(( ( Sum(forest_sq_km) / Sum(land_sq_km) ) * 100 ) :: NUMERIC, 2) AS
       per_change_forest
FROM   forestation
WHERE  f_year = 1990
       AND r_region = 'World'
GROUP  BY r_region,
          f_year; 
-- b.1. Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
SELECT r_region,
       Round(( ( Sum(forest_sq_km) / Sum(land_sq_km) ) * 100 ) :: NUMERIC, 2) AS
       per_change_forest
FROM   forestation
WHERE  f_year = 1990
GROUP  BY r_region
ORDER  BY per_change_forest DESC;

--3. Country Level Detail
--a.Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
     WITH sub1
AS
  (
         SELECT forest_country_code,
                forest_country_name,
                r_region,
                forest_sq_km
         FROM   forestation
         WHERE  f_year = 1990
         AND    forest_sq_km IS NOT NULL
         AND    forest_country_name != 'World'),
  sub2
AS
  (
         SELECT forest_country_code,
                forest_country_name,
                r_region,
                forest_sq_km
         FROM   forestation
         WHERE  f_year = 2016
         AND    forest_sq_km IS NOT NULL
         AND    forest_country_name != 'World')
  SELECT   sub1.forest_country_code AS code,
           sub1.forest_country_name AS country,
           sub1.r_region,
           sub1.forest_sq_km                       AS forest_sq_km_1990,
           sub2.forest_sq_km                       AS forest_sq_km_2016,
           (sub1.forest_sq_km - sub2.forest_sq_km) AS diff_forest_sq_km
  FROM     sub1
  JOIN     sub2
  ON       sub1.forest_country_code = sub2.forest_country_code
  AND      sub1.forest_country_name = sub2.forest_country_name
  AND      (
                    sub1.forest_sq_km IS NOT NULL
           AND      sub2.forest_sq_km IS NOT NULL)
  ORDER BY diff_forest_sq_km DESC
  LIMIT    5;

--b.Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
  WITH sub1
AS
  (
         SELECT forest_country_code,
                forest_country_name,
                r_region,
                forest_sq_km
         FROM   forestation
         WHERE  f_year = 1990
         AND    forest_sq_km IS NOT NULL
         AND    forest_country_name != 'World'),
  sub2
AS
  (
         SELECT forest_country_code,
                forest_country_name,
                r_region,
                forest_sq_km
         FROM   forestation
         WHERE  f_year = 2016
         AND    forest_sq_km IS NOT NULL
         AND    forest_country_name != 'World')
  SELECT   sub1.forest_country_code AS code,
           sub1.forest_country_name AS country,
           sub1.r_region,
           sub1.forest_sq_km                                                                    AS forest_sq_km_1990,
           sub2.forest_sq_km                                                                    AS forest_sq_km_2016,
           round((((sub1.forest_sq_km - sub2.forest_sq_km)/sub1.forest_sq_km) *100)::NUMERIC,2) AS per_change_forest
  FROM     sub1
  JOIN     sub2
  ON       sub1.forest_country_code = sub2.forest_country_code
  AND      sub1.forest_country_name = sub2.forest_country_name
  AND      (
                    sub1.forest_sq_km IS NOT NULL
           AND      sub2.forest_sq_km IS NOT NULL)
  ORDER BY per_change_forest DESC
  LIMIT    5;

--Success Story Analysis
WITH sub1
     AS (SELECT forest_country_code,
                forest_country_name,
                r_region,
                forest_sq_km
         FROM   forestation
         WHERE  f_year = 1990
                AND forest_sq_km IS NOT NULL
                AND forest_country_name != 'World'),
     sub2
     AS (SELECT forest_country_code,
                forest_country_name,
                r_region,
                forest_sq_km
         FROM   forestation
         WHERE  f_year = 2016
                AND forest_sq_km IS NOT NULL
                AND forest_country_name != 'World')
SELECT sub1.forest_country_code                  AS code,
       sub1.forest_country_name                  AS Country,
       sub1.r_region,
       sub1.forest_sq_km                         AS forest_sq_km_1990,
       sub2.forest_sq_km                         AS forest_sq_km_2016,
       ( sub1.forest_sq_km - sub2.forest_sq_km ) AS diff_forest_sq_km,
       Round(( ( ( sub1.forest_sq_km - sub2.forest_sq_km ) / sub1.forest_sq_km )
               * 100
             ) ::
             NUMERIC, 2)                         AS per_change_forest
FROM   sub1
       join sub2
         ON sub1.forest_country_code = sub2.forest_country_code
            AND sub1.forest_country_name = sub2.forest_country_name
            AND ( sub1.forest_sq_km IS NOT NULL
                  AND sub2.forest_sq_km IS NOT NULL )
ORDER  BY per_change_forest DESC; 

--c.If countries were grouped by percent forestation in quartiles, 
--which group had the most countries in it in 2016?
WITH t1
     AS (SELECT forest_country_code,
                forest_country_name,
                r_region,
                f_year,
                forest_sq_km,
                percent_forrest_area
         FROM   forestation
         WHERE  f_year = 2016
                AND ( forest_sq_km IS NOT NULL
                      AND land_sq_km IS NOT NULL )
                AND forest_country_name != 'World'
         ORDER  BY percent_forrest_area DESC),
     t2
     AS (SELECT t1.forest_country_code,
                t1.forest_country_name,
                t1.r_region,
                t1.f_year,
                t1.forest_sq_km,
                t1.percent_forrest_area,
                CASE
                  WHEN t1.percent_forrest_area >= 75 THEN '75% - 100%'
                  WHEN t1.percent_forrest_area >= 50 THEN '50% - 75%'
                  WHEN t1.percent_forrest_area >= 25 THEN '25% -50%'
                  ELSE '0-25%'
                END AS quartiles
         FROM   t1
         ORDER  BY quartiles DESC)
SELECT t2.quartiles,
       Count(*)
FROM   t2
GROUP  BY 1
ORDER  BY 2 DESC; 

--d.List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
WITH t1
     AS (SELECT forest_country_code,
                forest_country_name,
                r_region,
                f_year,
                forest_sq_km,
                percent_forrest_area
         FROM   forestation
         WHERE  f_year = 2016
                AND ( forest_sq_km IS NOT NULL
                      AND land_sq_km IS NOT NULL )
                AND forest_country_name != 'World'
         ORDER  BY percent_forrest_area DESC),
     t2
     AS (SELECT t1.forest_country_code,
                t1.forest_country_name,
                t1.r_region,
                t1.f_year,
                t1.forest_sq_km,
                t1.percent_forrest_area,
                CASE
                  WHEN t1.percent_forrest_area >= 75 THEN '75% - 100%'
                  WHEN t1.percent_forrest_area >= 50 THEN '50% - 75%'
                  WHEN t1.percent_forrest_area >= 25 THEN '25% -50%'
                  ELSE '0-25%'
                END AS quartiles
         FROM   t1
         ORDER  BY quartiles DESC)
SELECT t2.forest_country_code,
       t2.forest_country_name,
       t2.r_region,
       Round(Cast(t2.percent_forrest_area AS NUMERIC), 2) AS
       percent_forrest_area
FROM   t1
       JOIN t2
         ON t1.forest_country_code = t2.forest_country_code
            AND t1.forest_country_name = t2.forest_country_name
WHERE  t2.percent_forrest_area >= 75
ORDER  BY percent_forrest_area DESC; 

--e.How many countries had a percent forestation higher than the United States in 2016?

WITH t1
     AS (SELECT forest_country_code,
                forest_country_name,
                r_region,
                f_year,
                forest_sq_km,
                percent_forrest_area
         FROM   forestation
         WHERE  f_year = 2016
                AND ( forest_sq_km IS NOT NULL
                      AND land_sq_km IS NOT NULL )
                AND forest_country_name != 'World'
         ORDER  BY percent_forrest_area DESC)
SELECT Count(t1.forest_country_name)
FROM   t1
WHERE  t1.percent_forrest_area > (SELECT t1.percent_forrest_area
                                  FROM   t1
                                  WHERE
       t1.forest_country_name = 'United States'); 

