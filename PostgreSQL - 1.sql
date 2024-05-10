--=============== POSTGRESQL =======================================

--======== main part ==============

--TASK No. 1
--Make a query to the payment table and use window functions to add calculated columns according to the conditions:
--Number all payments from 1 to N by payment date
--Number payments for each buyer, sorting payments should be by payment date
--Calculate the cumulative total of all payments for each buyer, sorting should
--be first by payment date, and then by payment amount from smallest to largest
--Number payments for each buyer by payment amount from largest to
--smaller so that payments with the same value have the same number value.
--You can create a separate SQL query for each item, or you can combine all columns in one query.

select *,
row_number() over(order by payment_date) as payment_number
from payment

select *,
row_number() over(partition by customer_id order by payment_date) as customer_payment_number
from payment

select *,
sum(amount) over(partition by customer_id order by payment_date::date, amount)
from payment

select *,
dense_rank() over(partition by customer_id order by amount desc)
from payment

--TASK No. 2
--Using the window function, display the payment cost and cost for each customer
--payment from the previous line with a default value of 0.0, sorted by payment date.

select 
customer_id,
payment_id, 
payment_date,
amount,
lag(amount,1,0.0) over( partition by customer_id order by payment_date)
from payment

--TASK No. 3
--Using the window function, determine how much each buyer's next payment will be
--more or less than current.

select 
customer_id,
payment_id, 
payment_date,
amount,
(lead(amount) over(partition by customer_id order by payment_date) - amount) as difference
from payment


--TASK No. 4
--Using the window function for each customer, display information about his last rent payment.

--explain analyze --1331 / 12.5
select customer_id, payment_id, payment_date, amount 
from (select
distinct on (customer_id)*,
first_value(rental_id) over (partition by customer_id order by payment_date desc)
from payment)
where rental_id = first_value

--explain analyze --1482 / 12.0
with cte1 as (
	select
	*,
	first_value(rental_id) over (partition by customer_id order by payment_date desc)
	from payment)
select customer_id, payment_id, payment_date, amount
from cte1
where rental_id = first_value

--explain analyze --1482 / 12.0
select 
customer_id,
payment_id,
payment_date,
amount
from (select
	*,
	first_value(rental_id) over (partition by customer_id order by payment_date desc)
	from payment)
where rental_id = first_value

--======== Additional part ==============

--TASK No. 1
--Using the window function, display the sales amount for each employee for August 2005
--with a cumulative total for each employee and for each sales date (without taking into account time)
--sorted by date.

--explain analyze --369.68 / 12.5
with cte1 as(
select * from payment
where date_trunc('month',payment_date) = '2005-08-01'
order by staff_id, payment_date)
select
staff_id,
to_char(payment_date, 'dd.mm.yyyy') as payment_date,
sum_amount,
sum(sum_amount) over (partition by staff_id order by payment_date)
from
(select
distinct sum(amount) over(partition by payment_date::date, staff_id order by Payment_date::date) as sum_amount,
staff_id,
payment_date::date
from cte1
order by staff_id, payment_date)

--TASK No. 2
--On August 20, 2005, a promotion was held in stores: the buyer of every hundredth payment received
--additional discount on your next rental. Use the window function to display all customers,
-- who received a discount on the day of the promotion

with cte1 as(
select
customer_id,
last_name||' '||first_name as customer_name,
payment_date
from payment
join customer using(customer_id)
where payment_date::date = '2005-08-20')
select *
from (
select *,
row_number() over(order by payment_date)
from cte1)
where mod(row_number::numeric,100)=0


--TASK No. 3
--For each country, identify and display in one SQL query the buyers who
-- fall under the following conditions:
-- 1. buyer who rented the largest number of films
-- 2. the buyer who rented films for the largest amount
-- 3. the customer who last rented the film

with 
cte1 as 
	(select *
	from country
	left join city using (country_id)
	left join address using (city_id)
	left join customer using (address_id)
	left join payment using (customer_id)),
cte2 as
	(select *
	from film
	left join inventory using(film_id)
	left join rental using(inventory_id)
	left join payment using (rental_id))
select *
from(
	select distinct customer_id, country, max_films
	from (
		select *,
		first_value(max_films) over (partition by country)
		from(
			select 
			cte1.customer_id,
			cte1.country,
			count(film_id) over (partition by country, cte1.customer_id) as max_films
			from cte1
			join cte2 using(payment_id)
			order by country, max_films desc
			)
		  )
	where max_films = "first_value"
	order by country
	)
full join
	(select * from
		(select distinct customer_id, country, max_amount
		from (
			select *,
			first_value(max_amount) over (partition by country)
			from(
				select 
				cte1.customer_id,
				cte1.country,
				sum(cte1.amount) over (partition by country, cte1.customer_id) as max_amount
				from cte1
				join cte2 using(payment_id)
				order by country, max_amount desc
				)
			  )
		where max_amount = "first_value"
		order by country
		)
	)
using(customer_id)

with 
cte1 as 
	(select *
	from country
	left join city using (country_id)
	left join address using (city_id)
	left join customer using (address_id)
	left join payment using (customer_id)),
cte2 as
	(select *
	from film
	left join inventory using(film_id)
	left join rental using(inventory_id)
	left join payment using (rental_id))
select distinct customer_id, country, last_rental
from (
	select *,
	first_value(last_rental) over (partition by country)
	from(
		select 
		cte1.customer_id,
		cte1.country,
		max(rental_date) over (partition by country, cte1.customer_id) as last_rental
		from cte1
		join cte2 using(payment_id)
		order by country, last_rental desc
		)
	  )
where last_rental = "first_value"
order by country