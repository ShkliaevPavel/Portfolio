--Task №1
--Output unique city names from the city table.
select distinct city
from city;



--Task №2
--Modify the query from the previous task so that the query displays only those cities
--whose names begin with “L” and end with “a”, and the names do not contain spaces.
select distinct city
from city
where city like 'L%a' and city not like '% %';




--Task №3
--Get information on payments that were made from the table of payments for movie rentals
--in the period from June 17, 2005 to June 19, 2005 inclusive,
--and the cost of which exceeds 1.00.
--Payments must be sorted by payment date.

select payment_id, amount , payment_date 
from payment
where payment_date::date between '2005-06-17' and '2005-06-19'
and amount >1.00
order by payment_date 




--Task №4
-- Display information about the last 10 payments for movie rentals.

select payment_id, payment_date, amount
from payment
order by payment_date desc 
limit 10



--Task №5
--Display the following information about customers:
-- 1. Last name and first name (in one column separated by a space)
-- 2. Email
-- 3. Length of the email field value
-- 4. Date of last update of the buyer's record (no time)
--Give each column a name in Russian.

select 
concat_ws(' ',last_name,first_name) as "Фамилия и имя", 
email as "Электронная почта", 
char_length(email) as "Длина email",
last_update::date as "Дата последнего обновления"
from customer;

 

--Task №6
--Display in one query only active buyers whose names are KELLY or WILLIE.
--All letters in the last name and first name from upper case must be converted to lower case.

select lower(first_name), lower(last_name), active
from customer
where activebool and first_name in ('KELLY', 'WILLIE')



--======== ADDITIONAL PART ==============

--Task №1
--Display information about films that are rated “R” and have rental prices starting from
--0.00 to 3.00 inclusive, as well as films with a rating of “PG-13” and a rental cost greater than or equal to 4.00.

select film_id, title, description, rental_rate, rating
from film
where rating = 'R' and rental_rate between 0.00 and 3.00
or
rating = 'PG-13' and rental_rate >=4.00




--Task №2
--Get information about the three movies with the longest movie descriptions.

select film_id, title, description, char_length(description) as descr_lenght
from film
order by descr_lenght desc
limit 3



--Task №3
-- Output the Email of each customer, dividing the Email value into 2 separate columns:
--the first column must contain the value specified before @,
--the second column must contain the value specified after @.

select customer_id, email, split_part(email,'@',1) as Name, split_part(email,'@',2) as domain
from customer 



--Task №4
--Modify the query from the previous task, adjust the values in the new columns:
--the first letter of the line must be capital, the rest lowercase.

select 
	customer_id, 
	email,
	concat(
		initcap(
			split_part(
				split_part(email,'@',1),
				  '.',1)
				),
		'.',
		lower(
			split_part(
				split_part(email,'@',1),
				  '.',2)
			 )
		  ) as Name, 
	concat(
		initcap(
			split_part(
				split_part(email,'@',2),
				  '.',1)
				),
		'.',
		lower(
			split_part(
				split_part(email,'@',2),
				  '.',2)
			  ) 
			) as domain
from customer