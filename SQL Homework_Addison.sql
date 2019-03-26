use sakila;
/*1a. Display the first and last names of all actors from the table actor.*/
select first_name, last_name 
from actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/
select ucase(concat(first_name, " ", last_name)) as 'Actor Name'
from actor;

/*2a.You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/
select actor_id, first_name, last_name 
from actor
where first_name='Joe';

/*2b. Find all actors whose last name contain the letters GEN:*/
select actor_id, first_name, last_name 
from actor
where last_name like '%GEN%';

/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:*/
select last_name, first_name
from actor
where last_name like '%LI%'
order by last_name, first_name asc;

/*2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

/*3a. create a column in the table actor named description and use the data type BLOB*/
alter table actor
add description blob;

/*3b.Delete the description column.*/
alter table actor
drop description;

/*4a. List the last names of actors, as well as how many actors have that last name.*/
select last_name, count(last_name) as number_of_last_name
from actor
group by last_name;

/*4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
select last_name, count(last_name) as number_of_last_name
from actor
group by last_name
having number_of_last_name>1;

/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.*/
update actor
set first_name="HARPO"
where last_name="WILLIAMS" and first_name="GROUCHO";

/*4d.In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
update actor
set first_name="GROUCHO"
where first_name="HARPO";

/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/
show create table address;

/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address*/
select s.first_name, s.last_name, a.address,a.address2,a.district,a.location,a.postal_code
from staff s inner join address a 
on s.address_id = a.address_id;

/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.*/
select  p.staff_id, s.first_name, s.last_name, sum(p.amount) as total_amount
from staff s right join payment p 
on s.staff_id =p.staff_id
where p.payment_date between  '2005-08-01' and '2005-08-31'
group by p.staff_id;

/* 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/
select f.film_id, f.title, count(fa.actor_id) as number_of_actors
from film f inner join film_actor fa
on f.film_id = fa.film_id
group by f.film_id;

/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/
select f.title, count(i.inventory_id) as number_of_inventory
from film f inner join inventory i
on f.film_id = i.film_id
group by f.film_id
having f.title="Hunchback Impossible";

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name*/
select c.first_name, c.last_name, sum(p.amount) as 'Total Amount Paid'
from payment p inner join customer c
on p.customer_id=c.customer_id
group by c.customer_id
order by c.last_name asc;

/*7a Use subqueries to display the titles of movies starting with the letters K and Q whose language is English*/
select title from film 
where title like 'K%' or title like 'Q%' 
and language_id= (
select language_id
from language 
where name="English") ;

/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/
select first_name, last_name 
from actor
where actor_id in (
	select actor_id
	from film_actor 
	where film_id=
		(select film_id
		from film
		where title='Alone Trip'));
        
/*7c.names and email addresses of all Canadian customers. Use joins to retrieve this information.*/
select first_name, last_name, email, address_id
from customer
where address_id in
(select a.address_id 
from address a inner join city ci 
on a.city_id =ci.city_id 
inner join country c
on ci.country_id=c.country_id
where c.country="Canada");

/* 7d Identify all movies categorized as family films.*/
select f.title, c.name
from film f inner join film_category fc
on f.film_id = fc.film_id
inner join category c
on fc.category_id =c.category_id
where c.name="Family"
order by f.title asc;

/*7e. Display the most frequently rented movies in descending order.*/
select f.title, count(r.rental_id) as "Total Rental"
from film f inner join inventory i
on f.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
group by f.film_id
order by count(r.rental_id)  desc;

/*7f. Write a query to display how much business, in dollars, each store brought in.*/
select st.store_id,  sum(p.amount) as "Total Revenue"
from payment p inner join rental r
on p.rental_id = r.rental_id
inner join inventory i
on i.inventory_id = r.inventory_id
inner join store st
on st.store_id = i.store_id
group by st.store_id
order by sum(p.amount) desc;

/*7g. Write a query to display for each store its store ID, city, and country.*/
select st.store_id, ct.city, c.country
from store st inner join address a
on st.address_id=a.address_id
inner join city ct
on ct.city_id=a.city_id
inner join country c
on ct.country_id=c.country_id;

/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
select cat.name, sum(p.amount) as "Gross Revenue"
from category cat inner join film_category fc
on cat.category_id = fc.category_id
inner join inventory i
on fc.film_id = i.film_id
inner join rental r
on i.inventory_id =r.inventory_id
inner join payment p
on p.rental_id =r.rental_id
group by cat.category_id
order by sum(p.amount) desc
limit 5;

/*8a. create a view.*/
Create view Top_five_genres
as select cat.name, sum(p.amount) as "Gross Revenue"
from category cat inner join film_category fc
on cat.category_id = fc.category_id
inner join inventory i
on fc.film_id = i.film_id
inner join rental r
on i.inventory_id =r.inventory_id
inner join payment p
on p.rental_id =r.rental_id
group by cat.category_id
order by sum(p.amount) desc
limit 5;

/*8b. How would you display the view that you created in 8a?*/
select * from Top_five_genres;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
drop view Top_five_genres;









