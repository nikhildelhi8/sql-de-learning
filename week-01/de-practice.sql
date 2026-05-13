

-- ########select + from 

-- Q1: Get all data from customers
-- Q2: Get only name and city from customers
-- Q3: Get order_id, amount, status from orders

select * from customers; 
select name , city from customers;
select order_id , amount , status from orders 

-- Q4: Show customer name, city — alias city as "customer_city"
-- Q5: Show product_name and price, alias price as "cost_in_usd"
-- Q6: Show amount multiplied by 1.18 as "amount_with_tax" from orders

select name as customer_name, city as customer_city from customers; 
select product_name , price as cost_in_usd from products;

select amount*1.18 as amount_with_tax from orders;


--####### where (filtering )

-- Q1: Get all customers from 'Mumbai'
-- Q2: Get all orders with status = 'completed'
-- Q3: Get all products with price > 500

select * from customers where city = 'Mumbai'
select * from orders where status = 'completed'
select * from products where price > 500

-- Q4: Get all orders where status is 'completed' AND amount > 1000
-- Q5: Get all customers from 'USA' or 'UK'
-- Q6: Get all orders where status is IN ('cancelled', 'refunded')
-- Q7: Get all orders placed in January 2024


select * from orders where status = 'completed' and amount > 1000;


select * from customers where country in ('USA' , 'UK');

select * from orders where status in ('cacelled' , 'refunded');

select * from ORDERS where created_at > '01-01-2024' and created_at < '31-01-2024'


-- Q8: Get customers who signed up after 2022-01-01 and are from India or China
-- Q9: Get orders where amount is between 500 and 2000 and status is not cancelled
-- Q10: Get all products where stock_quantity is less than 100



select * 
from customers 
where signup_date > '2022-01-01'
and country in ('India' , 'China')

select * 
from orders 
where amount between 500 and 2000 
and status <> 'cancelled';

select *
from  products
where stock_quantity <100


--######### level3 - OrderBy + Limit 


-- Q1: Get all orders sorted by amount (low to high)
-- Q2: Get all customers sorted by signup_date (newest first)
-- Q3: Get top 5 most expensive orders

select * from orders order by amount 

select * from customers order by signup_date  desc

select * from orders order by amount desc limit 5

-- Q4: Get the 3 cheapest products by price
-- Q5: Get all completed orders sorted by amount descending
-- Q6: Get customers sorted by country, then by name alphabetically


select * from products order by price limit 3

select * from customers order by country , name 

-- Q7: Get the most recent order for each — just get top 1 order by created_at DESC
-- Q8: Get top 3 orders by amount where status = 'completed' and category = 'Electronics'


select  * from orders order by created_at desc limit 1

select * from orders where status = 'completed' and product_category = 'Electronics' order by amount desc limit 3 



--####### level 4 -- distinct ############3



-- Q1: Get all unique cities from customers
-- Q2: Get all unique product categories from orders
-- Q3: Get all unique statuses from orders

select distinct city from customers 

select distinct product_category  from orders

select distinct status from orders 

-- Q4: Get unique combinations of city and country from customers
-- Q5: Count how many unique customers placed orders
-- Q6: Count how many unique cities exist in the customers table

select distinct city , country from customers 

select count(distinct customer_id ) as unique_customers  from orders

select count(distinct city) as unique_cities from customers



--####################### GROUP BY + AGGREGATES


-- Q1: Count total number of orders per status
-- Q2: Find total revenue (SUM of amount) per product_category
-- Q3: Find average order amount per product_category


select distinct(STATUS) from orders  


select status , count(*) as total_orders
from orders
group by status
order by total_orders desc;


select product_category , sum(amount) as total_revenue
from orders
group by product_category ;

select product_category , round(avg(amount) , 2) as average_amount 
from orders 
group by product_category 
order by average_amount


-- Q4: Find total revenue per customer_id, sorted by revenue descending
-- Q5: Find number of orders and total revenue per category
-- Q6: Find the most expensive order (MAX amount) per category
-- Q7: Count how many orders each customer placed


select
	customer_id , 
	count(*) as total_orders ,
	round(sum(amount),2) as total_revenue
	from orders
	group by customer_id 
	order by total_revenue  desc
	
	
select
	product_category , 
	count(*) as total_orders,
	sum(amount) as total_revenue 
	from orders
	group by product_category ;

select 
	product_category , 
	max(amount)
	from orders
	group by product_category
	

select 
	customer_id , 
	count(*)
	from orders
	group by customer_id
	
	
	
-- Q8: Find total revenue per month (use DATE_TRUNC)
	
	
2024-03-15 14:37:52


select to_char(date_trunc('month' , created_at), 'Month') as monthly_orders , sum(amount) as total_revenue
from orders 
group by DATE_TRUNC('month', created_at)
order by monthly_orders asc


--Q9: Find total revenue per country by joining customers + orders
--     (preview of JOINs — try it, it's okay to struggle)

select country , sum(amount) as total_revenue
from orders o
inner join customers c 
on o.customer_id  = c.customer_id 
group by country 
order by country 

-- Q10: Find average order value per city

select
	city , 
	round(avg(amount) , 2) as average_amount
	from orders o
	inner join customers c 
	on o.customer_id  = c.customer_id 
	group by city 
	order by average_amount asc
	
	
	
--################# having ##################
	
-- Q1: Find categories where total revenue > 5000
-- Q2: Find customers who placed more than 2 orders
-- Q3: Find categories where average order amount > 500
-- Q4: Find customers whose total spending is more than 2000
-- Q5: Find cities (from customers table) that have more than 2 customers
-- Q6: Find product categories that had more than 3 completed orders
--     (filter status in WHERE, then use HAVING on count)
-- Q7: Find months where total revenue exceeded 5000
-- Q8: Find customers who placed orders in more than 1 product category
	
	

	select 
		product_category , 
		sum(amount) as total_revenue
		from orders
		group by product_category 
		having sum(amount) > 5000
	
	select 
		customer_id , 
		count(*) as order_count 
		from orders 
		group by customer_id 
		having count(*) > 2
		
	select
		product_category , 
		avg(amount) as average_amount
		from orders 
		group by product_category 
		having avg(amount) >500
		
	select 
		c.customer_id , 
		c.name ,
		round(sum(amount) , 2) as total_spending 
		from orders o 
		inner join customers c 
		on o.customer_id  = c.customer_id 
		group by c.customer_id , c.name
		having sum(amount) > 2000
		order by total_spending desc; 
	
	
	select
		city, 
		sum(customer_id)
		from customers 
		group by city
		having sum(customer_id) > 2
		
	select 
		product_category , 
		count(*) as completed_orders 
		from orders 
		where status = 'completed'
		group by product_category
		having count(*) > 3
		
	
	select 
		to_char(date_trunc('month' , created_at) , 'yyyy-mm') as month , 
		sum(amount) as total_revenue
		from orders 
		group by date_trunc('month' , created_at)
		having sum(amount) > 5000
		
		
--Q8: Find customers who placed orders in more than 1 product category
		
	SELECT
    c.customer_id,
    c.name,
    COUNT(DISTINCT o.product_category) AS unique_categories
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT o.product_category) > 1
ORDER BY unique_categories DESC;
		











