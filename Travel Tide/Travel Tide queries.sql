/* Question #1:

return users who have booked and completed at least 10 flights, ordered by user_id. */

SELECT user_id
FROM sessions
WHERE cancellation = 'false' AND flight_booked = 'true'
GROUP BY user_id
HAVING COUNT (trip_id) >= 10
ORDER BY 1;



------------------------------------------------------------------------------------------------------
/* Question #2: 
Write a solution to report the trip_id of sessions where:

1. session resulted in a booked flight
2. booking occurred in May, 2022
3. booking has the maximum flight discount on that respective day.

If in one day there are multiple such transactions, return all of them. */


WITH max_flight_discount AS (
  
  SELECT
        trip_id,
        DATE_TRUNC('day',session_start)::DATE AS order_day_start,
        DATE_TRUNC('day',session_end)::DATE AS order_day_end,
        flight_discount_amount,
        MAX(flight_discount_amount) OVER(PARTITION BY DATE_TRUNC('day',session_start)) AS max_discount_in_day
  
  FROM sessions
  
  WHERE flight_booked = 'true'
)

SELECT trip_id

FROM max_flight_discount

WHERE order_day_start >= '2022-05-01'
    AND order_day_end <= '2022-05-31'
    AND max_discount_in_day = flight_discount_amount;



------------------------------------------------------------------------------------------------------
/* Question #3: 
Write a solution that will, for each user_id of users with greater than 10 flights, find out the
largest window of days between the departure time of a flight and the departure time of the next
departing flight taken by the user. */

WITH joined_tables AS (
  
  SELECT
      user_id,
      departure_time,
  		COUNT(trip_id) OVER (PARTITION BY user_id) AS trip_count,
      LAG(departure_time,1) OVER (PARTITION BY user_id ORDER BY departure_time) AS previous_departure
  
  FROM sessions
  		INNER JOIN flights
      USING(trip_id)
  
  WHERE flight_booked = 'true'
)


SELECT
		user_id,
		MAX((departure_time::DATE - previous_departure::DATE))
FROM joined_tables
WHERE trip_count > 10
GROUP BY user_id;



------------------------------------------------------------------------------------------------------
/* Question #4:
Find the user_id’s of people whose origin airport is Boston (BOS) and whose first and last flight were
to the same destination. Only include people who have flown out of Boston at least twice.
*/

WITH filtered_table AS (

  SELECT
      user_id,
  		destination_airport,
  		departure_time,
  		COUNT(trip_id) OVER (PARTITION BY user_id) AS total_trips,
			MIN(departure_time) OVER (PARTITION BY user_id) AS first_trip_date,
      MAX(departure_time) OVER (PARTITION BY user_id) AS last_trip_date

  FROM sessions
      INNER JOIN flights
        USING(trip_id)
  
  WHERE cancellation = 'false'
      AND flight_booked = 'true'
      AND origin_airport = 'BOS'
),


first_last_destinations AS (
  
SELECT
		*,
    LEAD(destination_airport) OVER(PARTITION BY user_id) AS final_destination

FROM filtered_table
  
WHERE (departure_time = first_trip_date OR departure_time = last_trip_date)
		AND total_trips >=2
)


SELECT DISTINCT user_id

FROM first_last_destinations

WHERE final_destination = destination_airport
;

    
