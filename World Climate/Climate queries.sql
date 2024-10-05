/* Question 1:
What are the top 10 countries with the highest average temperature?
(do not include avg_temp = NULL) */

SELECT country,
ROUND(AVG(avg_temp)::NUMERIC,2)
FROM temperatures_by_country
WHERE avg_temp IS NOT NULL
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;



-------------------------------------------------------------------------------------------
/* Question 2:
Calculate the difference in average temperature between Djibouti and Greenland
for the period from 2000 to 2013. The difference should be based on the average
temperature for each country over the entire period. */

SELECT
ROUND(ABS(AVG(avg_temp) FILTER(WHERE country = 'Djibouti') - AVG(avg_temp) FILTER(WHERE country = 'Greenland'))::NUMERIC,2)
FROM temperatures_by_country
WHERE EXTRACT (YEAR FROM dt) BETWEEN '2000' AND '2013'
AND avg_temp IS NOT NULL;



-------------------------------------------------------------------------------------------
/* QUESTION 3:
Between the years 2000 and 2013, calculate the year over year change for
average temperature difference between Djibouti and Greenland? */

WITH djibouti AS (
	SELECT
      EXTRACT (YEAR FROM dt) AS date_year,
      AVG(avg_temp) AS temperature_djibouti
  FROM temperatures_by_country
  WHERE country = 'Djibouti'
  AND EXTRACT (YEAR FROM dt) BETWEEN '2000' AND '2013'
  GROUP BY 1
),

greenland AS(
  SELECT
  	EXTRACT (YEAR FROM dt) AS date_year,
    AVG(avg_temp) AS temperature_greenland
  FROM temperatures_by_country
  WHERE country = 'Greenland'
  AND EXTRACT (YEAR FROM dt) BETWEEN '2000' AND '2013'
  GROUP BY 1
),

temp_dif AS (
SELECT d.date_year AS year,
temperature_djibouti - temperature_greenland AS year_temp_dif,
LAG(temperature_djibouti,1) OVER(ORDER BY d.date_year) - LAG(temperature_greenland,1) OVER(ORDER BY d.date_year) AS previous_temp_dif
FROM djibouti AS d 
JOIN greenland AS g
USING(date_year)
ORDER BY 1
)
  
SELECT
		year,
    (year_temp_dif - previous_temp_dif) / previous_temp_dif AS yoy_temp_dif
FROM temp_dif
ORDER BY year;

    

-------------------------------------------------------------------------------------------
/* Question 4:
Starting from the year 2000, first extract a list with countries with 3
consecutively yearly average temperature increase. Then find the percentage
of the countries with 3 consecutively yearly average temperature increase
over all the countries. */

WITH year_cleaned AS(
  
  SELECT
  		EXTRACT (YEAR FROM dt) AS year_,
  		country,
  		AVG(avg_temp) AS current_year_temp
  		  
  FROM temperatures_by_country
  
  GROUP BY 1,2
),

yoy_temps AS (
  
  SELECT
  		year_,
			country,
  		current_year_temp,
      LAG(current_year_temp,1) OVER(ORDER BY year_) AS previous_year_temp,
  		LAG(current_year_temp,2) OVER(ORDER BY year_) AS two_years_ago_temp,
  		LAG(current_year_temp,3) OVER(ORDER BY year_) AS three_years_ago_temp
  
  FROM year_cleaned
)

/* for creating the list of the counties per year with 3 consecutive year over year temperature increase:
SELECT
		DISTINCT year_,
    country,
    COUNT(country) OVER(PARTITION BY year_) AS num_country_per_year
    
FROM yoy_temps

WHERE year_ >= 2000
		AND previous_year_temp > current_year_temp
		AND two_years_ago_temp > current_year_temp
    AND three_years_ago_temp > two_years_ago_temp;
*/    

SELECT
		ROUND (100.0 * COUNT(DISTINCT country) / (SELECT COUNT(DISTINCT country) FROM yoy_temps WHERE year_ >= 2000), 2) AS country_ratio
    
FROM yoy_temps

WHERE year_ >= 2000
    AND previous_year_temp > current_year_temp
    AND two_years_ago_temp > current_year_temp
    AND three_years_ago_temp > two_years_ago_temp;



-------------------------------------------------------------------------------------------
/* Question 5:
For August 2013, classify countries into 'Hot', 'Moderate', and 'Cold'
based on their average temperatures. (Hot: >30, Moderate: between 20 and 30, Cold: Otherwise) */

SELECT
		DISTINCT country,
    AVG(avg_temp)

FROM temperatures_by_country
WHERE DATE_TRUNC ('month',dt) BETWEEN '2013-06-01' AND '2013-08-01'
		AND avg_temp IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
;



-------------------------------------------------------------------------------------------
/* Question 6:
List countries that saw a difference of more than 10°C between their highest and
lowest temperatures in the first eight months of 2013. */

SELECT
country,
MAX(avg_temp) - MIN(avg_temp)

FROM temperatures_by_country
WHERE DATE_TRUNC ('month',dt) BETWEEN '2013-01-01' AND '2013-08-01'
GROUP BY 1
HAVING MAX(avg_temp) - MIN(avg_temp) > 10
ORDER BY 2 DESC;



-------------------------------------------------------------------------------------------
/* Question 7:
Compare Russia's monthly temperatures for each month in 2013 with the same month
in 2012 to check for warmer or cooler trends. */

SELECT 
    TO_CHAR(year_2012.dt, 'Mon') AS month_,
    year_2012.avg_temp AS temp_2012, 
    year_2013.avg_temp AS temp_2013,
    CASE 
        WHEN year_2013.avg_temp > year_2012.avg_temp THEN 'Warmer'
        WHEN year_2013.avg_temp < year_2012.avg_temp THEN 'Cooler'
        ELSE 'Same'
    		END AS trend

FROM temperatures_by_country AS year_2012
    JOIN temperatures_by_country AS year_2013
    ON 
      year_2012.country = 'Russia'
      AND year_2013.country = 'Russia'
      AND EXTRACT(MONTH FROM year_2012.dt) = EXTRACT(MONTH FROM year_2013.dt)
      AND EXTRACT(YEAR FROM year_2012.dt) = 2012
      AND EXTRACT(YEAR FROM year_2013.dt) = 2013

ORDER BY EXTRACT(MONTH FROM year_2012.dt);



-------------------------------------------------------------------------------------------
/* Question 8:
Identify pairs of countries that had, on average, similar temperatures
(less than 1 degree difference) in the years from 2010 to 2013. */

WITH filtered_table AS (
  
  SELECT
      country,
      AVG (avg_temp) AS avg_temperature
  
  FROM temperatures_by_country
  
  WHERE EXTRACT (YEAR FROM dt) BETWEEN 2010 AND 2013
  
  GROUP BY 1
)


SELECT
		country_1st.country AS country_1,
    country_2nd.country AS country_2,
    ROUND( ABS(country_1st.avg_temperature - country_2nd.avg_temperature)::NUMERIC, 2) AS temperature_difference

FROM filtered_table AS country_1st
		JOIN filtered_table AS country_2nd
    ON
    	country_1st.country != country_2nd.country
      AND ABS(country_1st.avg_temperature - country_2nd.avg_temperature) < 1
;

