--1. Print the names of planes that have less than 50 seats.

--explain analyze -- 34.57/0.55
select
model as aircraft_model,
count(seat_no) as number_of_seats
from aircrafts
left join seats using(aircraft_code)
group by model
having count(seat_no)<50

--2. Print the percentage change in the monthly ticket booking amount, rounded to the nearest hundredth.

--explain analyze -- 82913 / 161
with recursive r as 
	(select 
	min(date_trunc('month', book_date)) as x 
	from bookings
	union
	select x + interval '1 month' as x
	from r
	where x < 
		(select max(date_trunc('month', book_date)) 
		 from bookings))
select 
to_char(date_trunc('month',x),'mm.yyyy') as month,
round(((sum-lag(sum) over(order by month))/lag(sum) over(order by month))::numeric *100,2) as change_percent
from r
left join 
	(select
	date_trunc('month', book_date) as "month",
	sum(total_amount)
	from bookings
	group by date_trunc('month', book_date)) table1 on r.x=table1.month
order by 1

--3. Print the names of aircraft without business class. Use the array_agg function in your solution.

--explain analyze --34.69 / 0.522
select model as aircrafts_without_business
from aircrafts
left join seats using(aircraft_code)
group by model
having 'Business' != all(array_agg(fare_conditions))

--4. Print the cumulative total of the number of seats on airplanes for each airport for each day.
--Consider only those planes that flew empty and only those days
--when more than one such aircraft took off from the same airport.
--Output the airport code, departure date, number of empty seats and cumulative total.

select 
departure_airport,
actual_departure,
empty_seat_no,
sum(empty_seat_no) over (partition by departure_airport,actual_departure::date order by actual_departure) as cumulative_total
from
	(select 
	departure_airport,
	actual_departure,
	count(departure_airport) over(partition by departure_airport, actual_departure::date) as amount_of_flights,
	count as empty_seat_no
	from flights_v fv
	left join boarding_passes using(flight_id)
	join
		(select
		aircraft_code,
		count(seat_no)
		from seats
		group by aircraft_code) as s on fv.aircraft_code = s.aircraft_code
	where boarding_passes.seat_no is null and status in ('Departed', 'Arrived'))
where amount_of_flights >1

--5. Find the percentage of flights on the routes out of the total number of flights.
--Output the airport names and percentages.
--Use a window function in your solution.

--explain analyze -- 9046 / 78
with 
cte1 as
	(select
	distinct departure_airport||'-'||arrival_airport as route2,
	count(departure_airport||'-'||arrival_airport) over(partition by departure_airport||'-'||arrival_airport) as route_no,
	count(flight_id) over()
	from flights
	group by route2, flight_id),
cte2 as 
	(select 
	distinct departure_airport||'-'||arrival_airport as route1,
	departure_airport_name,
	arrival_airport_name
	from routes)
select 
departure_airport_name,
arrival_airport_name,
100*route_no::numeric / count::numeric as route_ratio
from cte1
join cte2 on route2 = route1
order by 1

--explain analyze --10680 / 112
select 
distinct departure_airport_name,
arrival_airport_name,
100*(count(route) over(partition by route)::numeric/count(flight_id) over()) as route_ratio
from 
	(select
	flight_id,
	departure_airport_name,
	arrival_airport_name,
	departure_airport||'-'||arrival_airport as route
	from flights_v)
order by 1

--6. Print the number of passengers for each mobile operator code.
--Operator code is three characters after +7

--explain analyze --73205 / 566
select 
substring(contact_data->>'phone',3,3) as phone_code,
count(substring(contact_data->>'phone',3,3)) as amount
from tickets
group by phone_code

--7. Classify financial turnover (the amount of flight costs) by route:
--up to 50 million – low
--from 50 million inclusive to 150 million – middle
--from 150 million inclusive – high
--Output the number of routes in each resulting class.

--explain analyze --26488 / 337
select 
route_class,
count(*) as number_of_routes
from
	(select
	departure_airport||'-'||arrival_airport as route,
	sum(amount),
	case 
		when sum(amount) <50000000 then 'Low'
		when sum(amount) >=50000000 and sum(amount)<150000000 then 'Middle'
		else 'High'
	end as route_class
	from ticket_flights
	join flights_v using(flight_id)
	group by departure_airport||'-'||arrival_airport)
group by route_class
order by 
	case when route_class = 'Low' then 1
		 when route_class = 'Middle' then 2
		 when route_class = 'High' then 3
	end

--8. Calculate the median cost of flights (amount),
--median cost of booking and ratio of median booking to median cost of flights,
--round the result to the nearest hundredth.

with 
cte1 as
	(select
	percentile_disc(0.5) within group (order by amount) as median_ticket
	from ticket_flights),
cte2 as
	(select
	distinct book_ref,
	sum(amount) over(partition by book_ref)
	from tickets
	join ticket_flights using(ticket_no))
select 
median_ticket,
percentile_disc(0.5) within group (order by sum) as median_booking,
round(percentile_disc(0.5) within group (order by sum)/median_ticket,2) as ratio
from cte1, cte2
group by median_ticket

with
cte1 as
	(select
	1 as x,
	percentile_disc(0.5) within group (order by amount) as median_ticket
	from ticket_flights),
cte2 as
	(select
	1 as x,
	percentile_disc(0.5) within group (order by sum) as median_booking
	from
		(select
		book_ref,
		sum(amount)
		from bookings
		left join tickets using(book_ref)
		left join ticket_flights using(ticket_no)
		group by book_ref))
select 
median_ticket,
median_booking,
round(median_booking/median_ticket,2) as median_ratio
from cte1
join cte2 using(x)

--9*. Find the minimum cost of one kilometer of flight for a passenger.
--To do this, determine the distance between airports and take into account the cost of the flight.

--To find the distance between two points on the Earth's surface, use
--additional module earthdistance.
--For this module to work, you need to install another module – cube.

--Important:
--Installation of additional modules occurs through the CREATE EXTENSION statement module_name.
--Modules are already installed in the cloud database.
--The earth_distance function returns the result in meters.

create extension cube

create extension earthdistance

select
departure_airport_name,
arrival_airport_name,
round(amount/(earth_distance(ll_to_earth(a1.latitude,a1.longitude),
					   		 ll_to_earth(a2.latitude, a2.longitude))/1000)::numeric,2) as min_km_cost
from flights_v fv
join airports a1 on fv.departure_airport=a1.airport_code
join airports a2 on fv.arrival_airport=a2.airport_code
join ticket_flights using(flight_id)
order by min_km_cost
limit 1