-- ####SQL Execution Order — this is the most interview-tested concept here#######

--SQLL does NOT execute in the order you write it. It executes like this:
--1. FROM       → get the table
--2. WHERE      → filter rows
--3. GROUP BY   → group remaining rows
--4. HAVING     → filter groups
--5. SELECT     → pick columns / compute aggregates
--6. DISTINCT   → remove duplicates
--7. ORDER BY   → sort
--8. LIMIT      → cut results



---### PRACTICAL SYNTAX / USAGE

--Basic skeleton 

--SELECT column1, column2, AGG_FUNCTION(column3)
--FROM table_name
--WHERE condition
--GROUP BY column1, column2
--HAVING AGG_FUNCTION(column3) > some_value
--ORDER BY column1 DESC
--LIMIT 10;


-- 1) SELECT + FROM -- THE FOUNDATION 

--Get all columns ( avoid in production expensive)
--select * from orders;

--select order_id , customer_id , amount from orders; 

--alias columns fro readability 
--select order_id , amound as revenue from orders ; 


-- 2) WHERE  -- row level filtering 
--
--	single condition 
--select * from orders where status = 'complted'
--
--	multiple conditions 
--select * from orders 
--where status = 'completed'
--and amount > 100 
--
-- IN Operator ( replaces multiple OR)
--select * from orders
--where status in ('completed' , 'shipped');
--
--Date Filtering ( very common in DE)
--select * from orders
--where created_at >= '2024-01-01'
--and created_at < '2024-02-01'
--
--
--Null Handling 
--select * from orders where refund_amount is null ; 
--select * from orders where refund_amount is not null ; 



--3) GROUP BY + AGGREGATES-- THE WORKHORSE OF ANALYTICS 

--Count orders per customer 
--select customer_id , count(*) as total_orders
--from orders 
--group by customer_id ; 
--
----total revenuw per city 
--select city , sum(amount) as total_revenue
--from orders 
--group by city;

--multiple aggregates at once 

--select 
--	city, 
--	count(*) as order_count , 
--	sum(amount) as total_revenue , 
--	avg(amount) as avg_order_value , 
--	max(amount) as biggest_order 
--from orders
--group by city; 


--####### having - filter the grouping 

select city , count(*) as order_count 
from orders 
group by city 
having count(*) > 1000;


--cities with revenue over 1 million 

select city , sum(amount) as total_revenue
from orders
group by city 
having sum(amount) > 100000
order by total_revenue desc; 



--#########Order by -- sorting 

--Ascening (default)
--select * from orders order by amount ; 
--
--descending 
--select * from orders order by amount desc; 
--
--sort by multiple columns (first order by city  , then order by amount on the cities)
--select * from orders order by city asc , amount desc ; 
--
--sort by alias ( work here because order by runs after select)
--
--select city , sum(amount) as total_revenue
--from orders 
--group by city 
--order by total_revenue desc;



--########## DISTINCT --- REMOVES DUPLICATES 

--Unique cities that placed orders 
--
--select distict city from orders ;
--
---- unique combinations  ( distinct applies to full select rows ( both city and status(city , status)
--select distict  city , status from orders ; 
--
----count unique customers 
--
--select count(distinct customer_id) from orders 


--######### TOP 20% CONCEPTS THAT GIVE 80% RESULTS ############333


--1) COUNT(*) vs COUNT(column)
--
--COUNT(*)          -- counts all rows including NULLs
--COUNT(amount)     -- counts only non-NULL values in that column
--COUNT(DISTINCT customer_id)  -- counts unique non-NULL values

--2) WHERE vs HAVING — know this cold

--WHERE filters rows → runs before grouping → cannot use aggregates
--HAVING filters groups → runs after grouping → must use aggregates

--3). The GROUP BY rule Every non-aggregated column in SELECT must appear in GROUP BY.

--4)  NULL behavior

--WHERE col = NULL → WRONG, returns nothing
--WHERE col IS NULL → CORRECT
--Aggregates like SUM, AVG, COUNT(col) ignore NULLs automatically

--5)  ORDER BY with LIMIT for Top-N queries

-- Top 5 customers by revenue
--SELECT customer_id, SUM(amount) AS revenue
--FROM orders
--GROUP BY customer_id
--ORDER BY revenue DESC
--LIMIT 5;








