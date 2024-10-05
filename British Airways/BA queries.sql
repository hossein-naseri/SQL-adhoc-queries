/* Question #1:
To get started with analysis, create a summary of how many short-haul versus
long-haul flights happen.
A typical short-haul flight in Europe has a maximum distance of 2,000 km.

How many flights are scheduled or completed for both short-haul and long-haul
flights in 2023? */

SELECT
    CASE
        WHEN distance_flown > 2000 THEN 'long-haul'
        ELSE 'short-haul'
    END AS haul_type,
    count(*) AS total_flight
      
FROM ba_flight_routes AS bfr
		JOIN ba_flights AS bf
    		ON bf.flight_number = bfr.flight_number
    
WHERE status IN ('Completed', 'Scheduled')

GROUP BY 1;



------------------------------------------------------------------------------------------------
/* Question #2
We can calculate how full flights were by comparing the number of passengers on the flight
against the capacity of the aircraft.

Calculate the average number of empty seats for the short-haul and long-haul flights.
Additionally, can you also calculate
the average number of empty seats as a percentage of the maximum number of passengers?

If the manufacturer and sub-type are not available for flights, we do not need to show
the results of these flights. */

SELECT
    CASE
        WHEN distance_flown > 2000 THEN 'long-haul'
        ELSE 'short-haul'
    END AS haul_type,
    AVG(capacity - total_passengers) AS avg_empty_seats,
    AVG((capacity - total_passengers)::NUMERIC/capacity) AS avg_empty_seat_pct
    
FROM
		ba_flights AS bf
    JOIN ba_aircraft AS ba
    		ON ba.flight_id = bf.flight_id
    LEFT JOIN ba_fuel_efficiency AS bfe
    		ON bfe.manufacturer = ba.manufacturer
    		AND bfe.ac_subtype = ba.ac_subtype
    LEFT JOIN ba_flight_routes AS bfr
    		ON bfr.flight_number = bf.flight_number
      
GROUP BY 1;



------------------------------------------------------------------------------------------------
/* Question #3
Calculate the total number of scheduled flights used with more than 100 empty seats in the plane. 

Split the flights by short-haul and long-haul flights.

Exclude the flights where the manufacturer and sub-type are not available */

SELECT
    CASE
        WHEN distance_flown > 2000 THEN 'long-haul'
        ELSE 'short-haul'
    END AS haul_type,
    COUNT(DISTINCT bf.flight_id) AS total_flights
      
FROM
		ba_flights AS bf
    JOIN ba_aircraft AS ba
        ON ba.flight_id = bf.flight_id
    JOIN ba_fuel_efficiency AS bfe
        ON bfe.manufacturer = ba.manufacturer
        AND bfe.ac_subtype = ba.ac_subtype
    JOIN ba_flight_routes AS bfr
        ON bfr.flight_number = bf.flight_number
        
WHERE capacity - total_passengers > 100
		AND status = 'Scheduled'
    
GROUP BY 1;



------------------------------------------------------------------------------------------------
/* Question #4
What short-haul flight routes that have been completed have the highest average
number of empty seats? 

Include the flight number, departure city, arrival city, number of completed flights,
and average empty seats in your results.

Make sure to include all flights that are available in the data even if the capacity
information for some flights might be missing. */

SELECT
    bf.flight_number,
    departure_city,
    arrival_city,
    COUNT(DISTINCT bf.flight_id) AS number_of_flights,
    AVG(capacity - total_passengers) AS avg_empty_seats
      
FROM
		ba_flights AS bf
    LEFT JOIN ba_aircraft AS ba
    		ON ba.flight_id = bf.flight_id
    LEFT JOIN ba_fuel_efficiency AS bfe
        ON bfe.manufacturer = ba.manufacturer
        AND bfe.ac_subtype = ba.ac_subtype
    LEFT JOIN ba_flight_routes AS bfr
    		ON bfr.flight_number = bf.flight_number
    
WHERE distance_flown <= 2000
		AND status = 'Completed'
    
GROUP BY 1,2,3

ORDER BY 5 DESC;



------------------------------------------------------------------------------------------------
/* Question #5
What are the short-haul flight routes and the average number of seats for short-haul
flight routes that only have been completed 2 or fewer times? 

Include the flight number, departure city, arrival city, and average empty seats in your results.

Make sure to include all flights that are available in the data even if the capacity information
for some flights might be missing. */

SELECT
    bf.flight_number,
    departure_city,
    arrival_city,
    AVG(capacity - total_passengers) AS avg_empty_seats
      
FROM
		ba_flights AS bf
    LEFT JOIN ba_aircraft AS ba
    		ON ba.flight_id = bf.flight_id
    LEFT JOIN ba_fuel_efficiency AS bfe
        ON bfe.manufacturer = ba.manufacturer
        AND bfe.ac_subtype = ba.ac_subtype
    LEFT JOIN ba_flight_routes AS bfr
    		ON bfr.flight_number = bf.flight_number
    
WHERE distance_flown <= 2000
		AND status = 'Completed'

GROUP BY 1,2,3

HAVING COUNT(DISTINCT bf.flight_id) <= 2;



------------------------------------------------------------------------------------------------
/* Question #6
What are the short-haul flight routes and the average number of seats for short-haul
flight routes that only
have been completed 2 or fewer times that either depart or arrive in London? 

Include the flight number, departure city, arrival city, and average empty seats in your results.

Make sure to include all flights that are available in the data even if the capacity information
for some flights might be missing. */

SELECT
    bf.flight_number,
    departure_city,
    arrival_city,
    AVG(capacity - total_passengers) AS avg_empty_seats
    
FROM
		ba_flights AS bf
    LEFT JOIN ba_flight_routes AS bfr
    		ON bfr.flight_number = bf.flight_number
    LEFT JOIN ba_aircraft AS ba
    		ON ba.flight_id = bf.flight_id
    LEFT JOIN ba_fuel_efficiency AS bfe
        ON bfe.manufacturer = ba.manufacturer
        AND bfe.ac_subtype = ba.ac_subtype
    
WHERE distance_flown <= 2000
    AND status = 'Completed'
    AND (departure_city = 'London' OR arrival_city = 'London')

GROUP BY 1,2,3

HAVING COUNT(DISTINCT bf.flight_id) <= 2;



------------------------------------------------------------------------------------------------
/* Question #7: 
Create a list of flights, showing the flight ID, departure city, arrival city, manufacturer,
and aircraft sub-type that will be used for each flight

Show the results for all flights that are available even if not all information is available
for all flights. */

SELECT
    bf.flight_id,
    bfr.departure_city,
    bfr.arrival_city,
    ba.manufacturer,
    ba.ac_subtype
  
FROM ba_flights AS bf
    LEFT JOIN ba_flight_routes AS bfr
      USING (flight_number)
    LEFT JOIN ba_aircraft AS ba
      USING (flight_id)
;



------------------------------------------------------------------------------------------------
/* Question #8: 
What is the maximum number of passengers that have been on every available aircraft
(manufacturer and sub-type) for flights that have been completed?

If the manufacturer and sub-type are not available for flights, we do not need to show the results
of these flights. */

SELECT
    ba.manufacturer,
    ba.ac_subtype,
    MAX(bf.total_passengers)
    
FROM ba_flights AS bf
    INNER JOIN ba_aircraft AS ba
    	ON bf.flight_id = ba.flight_id
    
WHERE bf.status = 'Completed'

GROUP BY ba.manufacturer, ba.ac_subtype;



------------------------------------------------------------------------------------------------
/* Question #9: 
Since only some aircraft are capable of flying long distances overseas, we want to filter out
the planes that only do shorter distances.

What aircraft (manufacturer and sub-type) have completed flights of a distance of more than
7,000 km? 

If the manufacturer and sub-type are not available for flights, we do not need to show
the results of these flights. */

SELECT
    DISTINCT ba.manufacturer,
    ba.ac_subtype
    
FROM ba_aircraft AS ba
    JOIN ba_flights AS bf
    	USING (flight_id)
    JOIN ba_flight_routes AS bfr
    	USING (flight_number)

WHERE bfr.distance_flown > 7000
  	AND status = 'Completed';



------------------------------------------------------------------------------------------------
/* Question #10: 
What is the most used aircraft (manufacturer and sub-type) for flights departing from London
and arriving in Basel, Trondheim, or Glasgow? 

Include the number of flights that the aircraft was used for.

If the manufacturer and sub-type are not available for flights, we do not need to show
the results of these flights. */

SELECT
    ba.manufacturer,
    ba.ac_subtype,
    COUNT(*) AS flight_count
  
FROM
    ba_aircraft AS ba
    JOIN ba_flights AS bf
    	USING (flight_id)
    JOIN ba_flight_routes AS bfr
    	USING (flight_number)
  
WHERE departure_city = 'London'
		AND arrival_city IN ('Basel', 'Trondheim', 'Glasgow')
  
GROUP BY 1,2

ORDER BY 3 DESC

LIMIT 1;



------------------------------------------------------------------------------------------------
/* Question #11: 
For the flight routes highlighted in question 4 combined, would there have been an aircraft that,
on average, would use less fuel on the flight routes? 

The fuel used in liters per flight can be calculated by multiplying the fuel efficiency metric
by distance, baggage weight, and number of passengers. 

What aircraft (manufacturer and sub-type) would you recommend to use for each of these
flight routes if you use the average fuel consumption as your guiding metric?

If the manufacturer and sub-type are not available for flights, we do not need to show the
results of these flights. */

SELECT
    ba.manufacturer,
    ba.ac_subtype,
    AVG(bfe.fuel_efficiency * bfr.distance_flown * bf.total_passengers * bf.baggage_weight) AS fuel_cons
  
FROM
    ba_aircraft AS ba
    JOIN ba_flights AS bf
    	USING (flight_id)
    JOIN ba_flight_routes AS bfr
    	USING (flight_number)
    JOIN ba_fuel_efficiency AS bfe
    	USING (manufacturer, ac_subtype)
    
WHERE departure_city = 'London'
		AND arrival_city IN ('Basel', 'Trondheim', 'Glasgow')
  	AND fuel_efficiency != 0
  	AND distance_flown != 0
  	AND total_passengers != 0
  	AND baggage_weight != 0
    
GROUP BY 1,2

ORDER BY 3
;



------------------------------------------------------------------------------------------------
/* Question #12: 
The fuel used in liters per flight can be calculated by multiplying the fuel efficiency metric
by distance, baggage weight, and number of passengers. 

Calculate the total amount of fuel used per kilometer flown of completed flights per manufacturer. 
What manufacturer has used less fuel per km in total?

If flights do not have data available about the aircraft type, you can exclude the flights
from the analysis. */

SELECT
    ba.manufacturer,
    SUM(bfe.fuel_efficiency * bf.total_passengers * bf.baggage_weight * distance_flown)
    		/ SUM(distance_flown) AS fuel_per_kilometer
  
FROM
    ba_aircraft AS ba
    JOIN ba_flights AS bf
    	USING (flight_id)
    JOIN ba_fuel_efficiency AS bfe
    	USING (manufacturer, ac_subtype)
    JOIN ba_flight_routes
    	USING(flight_number)
    
WHERE ac_subtype IS NOT NULL
		AND status = 'Completed'
    
GROUP BY 1

ORDER BY 2;
	

