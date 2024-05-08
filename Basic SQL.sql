--======== Main part ==============

--Task №1
--Display for each customer his residential address,
--city and country of residence.

select last_name||' '||first_name as Customer_name, address, city, country
from customer
left join address using(address_id )
left join city using(city_id)
left join country using(country_id)

--Task №2
--Using an SQL query, count the number of customers for each store.

select store_id, count(customer_id) as amount_of_customers
from store
left join  customer using(store_id)
group by store.store_id

--Edit the request and display only those stores
--whose number of customers is more than 300.
--To solve, use filtering by grouped rows
--using the aggregation function.

select store_id, count(customer_id) as amount_of_customers
from store
left join  customer using(store_id)
group by store.store_id
having count(customer_id) >300


-- Edit the request by adding information about the city of the store,
--as well as the surname and name of the seller who works in this store.

--explain analyze --28.77/0.15
select 
s.store_id, 
amount_of_customers, 
city, 
st.last_name||' '||st.first_name as staff_name
from store s
left join address a using(address_id)
left join city c using(city_id)
join (select store_id, count(customer_id) as amount_of_customers
	  from customer
	  group by store_id
	  having count(customer_id) >300) as s2
	  on s.store_id = s2.store_id
left join staff st on s.store_id=st.store_id

--explain analyze --57.86/0.49
select 
s2.*, count(c.customer_id) as amount_of_customers
from customer c
join
	(select 
	s.store_id, 
	c.city,
	st.last_name||' '||st.first_name as staff_name
	from store s
	left join address a using(address_id)
	left join city c using(city_id)
	left join staff st on s.store_id=st.store_id) as s2
on c.store_id=s2.store_id
group by s2.store_id, s2.city, s2.staff_name
having count(customer_id) >300

--Task №3
--Bring out the TOP 5 buyers,
--who have rented the largest number of films ever

--explain analyze --1248.48/15.3
select 
last_name||' '||first_name as Customer_name,
count(film_id)as amount_of_films
from customer c
join 
	(select p.customer_id, film_id 
	from film f
	left join inventory i using(film_id)
	left join rental r using(inventory_id)
	left join payment p using(rental_id)) as f2 using(customer_id)
group by customer_id
order by count(film_id) desc
fetch first 5 rows with ties

--Task №4
--Calculate 4 analytical indicators for each buyer:
-- 1. number of films he rented
-- 2. the total cost of payments for renting all films (round the value to a whole number)
-- 3. minimum payment for film rental
-- 4. maximum payment for film rental

--explain analyze --1389.01/17.8
select 
last_name||' '||first_name as Customer_name,
count(film_id)as amount_of_films,
round(sum(amount)) as total_cost,
min(amount) as min_cost, 
max(amount) as max_cost
from customer c
left join 
	(select p.customer_id, film_id, amount 
	from
	film f
	left join inventory i using(film_id)
	left join rental r using(inventory_id)
	left join payment p using(rental_id)) as f2 using(customer_id)
group by customer_id
order by amount_of_films desc

--Task №5
--Using the data from the city table, make all possible pairs of cities so that
--as a result, there were no pairs with the same city names. The solution must be through the Cartesian product.
 
select c1.city, c2.city
from city c1
cross join city c2
where c1.city != c2.city
order by c1.city

--Task №6
--Using data from the rental table about the date the film was issued for rent (the rental_date field) and
--return date (return_date field), calculate the average quantity for each customer
--days for which he returns films. The result should be fractional values, not an interval.

select customer_id, round(avg((return_date::date-rental_date::date)),2) as avg_rental_duration
from rental
group by customer_id
order by customer_id

--======== ADDITIONAL PART ==============

--Task №1
--For each film, count how many times it was rented and the total cost of renting the film for the entire time.

--explain analyze --1344.71/13.6
select 
	f.film_id,
	f.title, 
	l."name" as language_name,
	rental_count, 
	total_cost
from film f
left join (
	select 
		i.film_id, 
		count(r.rental_id) as rental_count, 
		sum(p.amount) as total_cost
	from inventory i 
	left join rental r using(inventory_id)
	left join payment p using(rental_id)
	group by i.film_id) as i using(film_id)
join "language" l using(language_id)
join (
	select film_id, string_agg("name",',') as category_name
	from film_category fc2 
	join category c2 using(category_id)
	group by film_id) as fc using(film_id)
group by f.film_id, l.language_id, rental_count, total_cost
order by 1

--Task №2
--Modify the request from the previous task and use it to display movies that are not on DVD discs.

--explain analyze --526.79/1.714
select 
	film_id,
	title,
	rating,
	release_year,
	l."name" as language_name,
	rental_count,
	total_cost
from 
	(select 
		film_id, 
		title, 
		rating, 
		release_year, 
		language_id, 
		count(rental_id) as rental_count,
		sum(amount) as total_cost
	from film f
	left join inventory i using(film_id)
	left join rental r using(inventory_id)
	left join payment p using(rental_id)
	where inventory_id is null
	group by film_id) as f	
left join "language" l using(language_id)
join (select 
		film_id, 
		string_agg("name",',')
	  from film_category fc
	  join category c using(category_id)
	  group by film_id) as f2 using(film_id)
order by 1

--Count the number of sales made by each salesperson. Add a calculated column "Premium".
--If the number of sales exceeds 7300, then the value in the column will be "Yes", otherwise the value should be "No".

select 
staff_id, 
count(payment_id) as number_of_sales,
case 
	when count(payment_id)>7300 then 'Yes'
	else 'No'
end "Премия"
from staff
left join payment using(staff_id)
group by staff_id
