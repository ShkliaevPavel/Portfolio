--======== main part ==============

--TASK No. 1
--Database: if the connection is to a cloud database, then create a new schema with a prefix in
--as a surname, the name must be in Latin in lower case and create tables
--in this new scheme, if the connection is to a local server, then create a new scheme and
--you create tables in it.


--Design a database containing three directories:
--· language (English, French, etc.);
--· nationality (Slavs, Anglo-Saxons, etc.);
--· countries (Russia, Germany, etc.).
--Two tables with connections: language-nationality and nationality-country, many-to-many relationships. An example of a table with relationships is film_actor.
--Requirements for reference tables:
--· presence of primary key constraints.
--· the entity identifier must be assigned by auto-increment;
--· entity names must not contain null values, and duplicates should not be allowed in entity names.
--Requirements for tables with links:
--· the presence of primary and foreign key constraints.

--As an answer to the task, send requests for creating tables and requests for --adding 5 rows of data to each table.
 
--CREATE TABLE LANGUAGES

create table "language" (
				language_id int2 primary key generated always as identity,
				language_name varchar(50) not null unique,
				created_at timestamp not null default now(),
				created_user varchar(64) not null default current_user,
				deleted boolean not null default false
				)
				
select * from language

--ENTERING DATA INTO THE LANGUAGES TABLE

insert into "language" (language_name)
values ('English'), ('Frech'), ('Spanish'), ('Swedish'), ('Chinese')


--CREATION OF NATIONALITY TABLE
create table nationality (
				nationality_id int2 primary key generated always as identity,
				nationality_name varchar(50) not null unique,
				created_at timestamp not null default now(),
				created_user varchar(64) not null default current_user,
				deleted boolean not null default false
				)

--ENTERING DATA INTO THE NATIONALITY TABLE

insert into nationality (nationality_name)
values ('English'), ('Canadian'), ('Cuban'), ('Spanish'), ('Swedish')

--CREATING A COUNTRY TABLE
create table country (
				country_id int2 primary key generated always as identity,
				country_name varchar(50) not null unique,
				created_at timestamp not null default now(),
				created_user varchar(64) not null default current_user,
				deleted boolean not null default false
				)


--ENTRY DATA INTO THE COUNTRY TABLE

insert into country (country_name)
values ('England'), ('Canada'), ('Cuba'), ('Spain'), ('Sweden')

--CREATING THE FIRST TABLE WITH RELATIONS
create table language_nationality(
				language_id int2 references "language"(language_id),
				nationality_id int2 references nationality(nationality_id),
				last_update timestamp not null default now(),
				primary key (language_id,nationality_id)
				)

								
--ENTERING DATA INTO A TABLE WITH RELATIONS
insert into language_nationality
values (1,1), (1,2), (2,2), (3,3), (3,4)

--CREATING A SECOND TABLE WITH RELATIONS
create table nationality_country(
				nationality_id int2 references nationality(nationality_id),
				country_id int2 references country(country_id),
				last_update timestamp not null default now(),
				primary key (nationality_id,country_id)
				)

--ENTERING DATA INTO A TABLE WITH RELATIONS

insert into nationality_country
values (1,1), (2,1), (3,3), (4,5), (5,5)

--Additional part

--TASK No. 1
--Create a new table film_new with the following fields:
--· film_name - movie name - data type varchar(255) and constraint not null
--· film_year - year of release of the film - integer data type, condition that the value must be greater than 0
--· film_rental_rate - movie rental cost - data type numeric(4,2), default value 0.99
--· film_duration - duration of the film in minutes - integer data type, not null constraint and condition that the value must be greater than 0
--If you are working in a cloud database, then before the table name, specify the name of your schema.

create table film_new(
				film_name varchar(255) not null,
				film_year int check(film_year >0),
				film_rental_rate numeric(4,2) default 0.99,
				film_duration int not null check(film_duration >0))

				select * from film_new
					
--TASK No. 2
--Fill the film_new table with data using an SQL query, where the columns correspond to data arrays:
--· film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--· film_year - array[1994, 1999, 1985, 1994, 1993]
--· film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--· film_duration - array[142, 189, 116, 142, 195]

Create table table1( "The Shawshank Redemption" varchar, "The Green Mile" varchar, "Back to the Future" varchar, "Forrest Gump" varchar, "Schindlers List" varchar)

insert into table1 ("The Shawshank Redemption" , "The Green Mile", "Back to the Future" , "Forrest Gump" , "Schindlers List" )
values(1994, 1999, 1985, 1994, 1993),
	  (2.99, 0.99, 1.99, 2.99, 3.99),
	  (142, 189, 116, 142, 195)

select * from table1

delete from  table1

drop table table1

select * 
from crosstab(
'select "The Shawshank Redemption" , "The Green Mile", "Back to the Future" , "Forrest Gump" , "Schindlers List" from table1') as table2 
("film_name" varchar, "film_year" varchar,"film_rental_rate" varchar,"film_duration" varchar)


select * 
from crosstab4(
'select a,b,c,d,e,f from table1') as table2
				
insert into film_new (film_name, film_year, film_rental_rate, film_duration)
	array[['The Shawshank Redemption'], ['The Green Mile'], ['Back to the Future'], ['Forrest Gump'], ['Schindlers List']],
	array([1994], [1999], [1985], [1994], [1993]),
	array[[2.99], [0.99], [1.99], [2.99], [3.99]],
	array[[142], [189], [116], [142], [195]]

insert into film_new
	values (
		film_name array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List'],
		film_year = array[1994, 1999, 1985, 1994, 1993],
		film_rental_rate = array[2.99, 0.99, 1.99, 2.99, 3.99],
		film_duration = array[142, 189, 116, 142, 195])

create extension tablefunc
		
insert into 
select * 
from crosstab(
'select film_name, film_year, film_rental_rate, film_duration from film_new') as ct (row text, "a" varchar, "b" varchar,"c" varchar,"d" varchar,"e" varchar)
(a,b,c,d,e)
values('film_name', 'The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List'),
	  ('film_year', 1994, 1999, 1985, 1994, 1993),
	  ('film_rental_rate', 2.99, 0.99, 1.99, 2.99, 3.99),
	  ('film_duration',142, 189, 116, 142, 195)
	  