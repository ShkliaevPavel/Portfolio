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