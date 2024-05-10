--======== main part ==============

--TASK No. 1
--Write a SQL query that displays all the information about the movies
--with the special attribute "Behind the Scenes".

--explain analyze --67.5/0.35
select film_id, title, special_features
from film
where special_features @> array['Behind the Scenes']

--TASK No. 2
--Write 2 more options for searching for films with the "Behind the Scenes" attribute,
--using other SQL functions or statements to look up a value in an array.

--explain analyze --67.5/0.4
select title, special_features
from film
where special_features && array['Behind the Scenes']

--explain analyze --77.5 / 0.32
select title, special_features
from film
where 'Behind the Scenes' = any(special_features)

--TASK No. 3
--For each buyer, calculate how many films he rented
--with the special attribute "Behind the Scenes.

--Prerequisite for completing the task: use the request from task 1,
--placed in CTE. CTE must be used to solve the assignment.

--explain analyze -- 1385 / 10.6
with cte1 as (
	select film_id, title, special_features
	from film
	where special_features @> array['Behind the Scenes'])
select 
distinct customer_id,
count(customer_id) over(partition by customer_id) as film_amount
from 
cte1
join inventory using(film_id)
join rental using(inventory_id)
order by customer_id

--TASK No. 4
--For each buyer, calculate how many films he rented
-- with the special attribute "Behind the Scenes".

--Prerequisite for completing the task: use the request from task 1,
--placed in a subquery that must be used to solve the task.

--explain analyze --1385 / 10.5
select 
distinct customer_id,
count(customer_id) over(partition by customer_id) as film_amount
from 
	(select film_id, title, special_features
	from film
	where special_features @> array['Behind the Scenes'])
join inventory using(film_id)
join rental using(inventory_id)
order by customer_id

--explain analyze --1385/10.7
select 
distinct customer_id,
count(customer_id) over(partition by customer_id) as film_amount
from 
	(select film_id, title, special_features
	from film
	where special_features @> array['Behind the Scenes'])
join 
(select
film_id, customer_id 
from
rental 
join inventory using(inventory_id))
using(film_id)
order by customer_id

--TASK No. 5
--Create a materialized view with the query from the previous job
--and write a query to update the materialized view

create materialized view task5 as
	select 
	distinct customer_id,
	count(customer_id) over(partition by customer_id) as film_amount
	from 
		(select film_id, title, special_features
		from film
		where special_features @> array['Behind the Scenes'])
	join inventory using(film_id)
	join rental using(inventory_id)
	join customer using(customer_id)
	order by customer_id
with no data

--explain analyze -- 30 / 0.04
select * from task5

drop materialized view task5

refresh materialized view task5

--TASK No. 6
--Using explain analyze, analyze the cost of executing queries from previous tasks and answer the questions:
--1. with which SQL operator or function used when doing homework:
--searching for a value in an array consumes less system resources;
--2. Which calculation option consumes less system resources:
--using CTE or using a subquery.

--1. The @>, &&, any functions consume approximately the same amount of resources.
-- Resource consumption is reduced when using a materialized view

--2. CTE and subquery consume approximately the same amount of resources
--(CTE is slightly larger when performing seq scan, hash join, sort)


--======== Additional part ==============

--TASK No. 1
--Using the window function print for each employee
--information about the very first sale of this employee.

create materialized view task2 as
	select	
	film_id,
	inventory_id,
	rental_id,
	title,
	customer_id,
	last_name as customer_last_name,
	first_name as customer_first_name
	from film
	join inventory using(film_id)
	join rental using (inventory_id)
	join customer using(customer_id)
	
select * from task2

drop materialized view task2

--explain analyze --2347/10
--explain (format json, analyze)
select 
staff_id,
film_id,
title,
amount,
payment_date,
customer_last_name,
customer_first_name
from
(select *,
row_number() over (partition by staff_id order by payment_date)
from payment)
join task2 using(rental_id)
where row_number = 1

--explain analyze --2412 / 8.5
--explain (format json, analyze)
select 
table1.staff_id,
film_id,
title,
amount,
payment_date,
last_name as customer_last_name,
first_name as customer_first_name
from
(select *,
row_number() over (partition by payment.staff_id order by payment_date)
from payment) as table1
join customer using(customer_id)
join rental using (rental_id)
join inventory using(inventory_id)
join film using(film_id)
where row_number = 1

--TASK No. 2
--For each store, define and display the following analytical indicators in one SQL query:
-- 1. day on which the most films were rented (day in year-month-day format)
-- 2. number of films rented that day
-- 3. day on which films were sold for the smallest amount (day in year-month-day format)
-- 4. sales amount on that day

create materialized view task3 as
	select st.store_id,film_id, inventory_id, rental_id, payment_date::date, amount
	from film f 
	left join inventory using(film_id)
	left join rental using (inventory_id)
	left join staff st using(staff_id)
	left join payment using(rental_id)
		
--explain analyze -- 5473 / 42
select 
distinct store_id,
first_value (Payment_date) over(partition by store_id order by count desc) as date_max_films,
first_value (count) over(partition by store_id order by count desc) as film_amount,
first_value (Payment_date) over(partition by store_id order by sum) as date_min_amount,
first_value (sum) over(partition by store_id order by sum) as amount
from
	(select
	store_id,
	payment_date,
	count(store_id) over(partition by store_id, payment_date order by payment_date),
	sum(amount) over(partition by store_id order by payment_date)
from task3
where store_id is not null)
order by store_id

create materialized view task3_1 as
	select store_id,film_id, inventory_id, rental_id, payment_date::date, amount
	from store 
	left join inventory using(store_id)
	left join rental using(inventory_id)
	left join payment using(rental_id)
	left join film using (film_id)
	
--explain analyze --5473  / 45
select 
distinct store_id,
first_value (Payment_date) over(partition by store_id order by count desc) as date_max_films,
first_value (count) over(partition by store_id order by count desc) as film_amount,
first_value (Payment_date) over(partition by store_id order by sum) as date_min_amount,
first_value (sum) over(partition by store_id order by sum) as amount
from (
	select
		store_id,
		payment_date,
		count(store_id) over(partition by store_id, payment_date order by payment_date),
		sum(amount) over(partition by store_id order by payment_date)
	from task3_1
	where store_id is not null)
order by store_id