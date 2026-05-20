--################### STRING FUNCTIONS ############################


--## 3. MINIMUM THEORY YOU MUST KNOW
--
--- Strings in PostgreSQL are wrapped in **single quotes**: `'hello'`
--- String functions **do not modify the original data** — they return a new value
--- Most string functions return `NULL` if the input is `NULL` — always keep this in mind
--- Indexes on columns do NOT work efficiently when you wrap a column in a function (e.g., `UPPER(email) = ...`). This matters for performance in production.



--1) upper() and lower() 

select
	customer_id , 
	first_name , 
	last_name , 
	lower(email) as email_normalized , 
	upper(first_name) as first_name_display 
from customers 
where lower(email) = 'rohan.sharma@gmail.com'


--2) trim()

select 
	customer_id , 
	lower(trim(email)) as email_clean , 
	upper(first_name) as first_name_upper
from customers ;

--3) length() -- return the number of character in the string 
select 
	customer_id , 
	first_name , 
	phone , 
	length(phone) as phone_length
from customers
where phone is not null 
and length(phone) <10 ;


--data quality check pattern using filtering 

select
	count(*) filter (where length(trim(email)) =0) as empty_email_count , 
	count(*) filter (where length(phone)!=10) as bad_phone_count
from customers
where phone is not null ; 


--3) concat() -- join multiple string together into one 

--build full name from reporting 

select 
	customer_id , 
	concat(first_name , ' ' , last_name) as full_name , 
	email
from customers
limit 10;

--build a human readable order label 

select 
	order_id , 
	concat('ORD-' , order_id , ' | Status ', status ) as order_label , 
	total_amount
from orders 
where status = 'delivered';


-- ALTERNATE SYNTAX FOR CONCATENATION  -- || operator 

select first_name || ' ' || last_name as full_name 
from customers 

--concat is safer as it silently ignores null , || operator propogates null (if any part is null , the whole result is null )

select
	concat('Hello ' , null , 'world') , 
	'Hello' || null || 'world';


--4) SUBSTRING() -- extracts a portion of the string by position 

substring (string from start_position for length)
or 
substring(string , start_position , length)

-- Position starts at 1 not 0 ( its not a zero index)

select

	product_id , 
	sku , 
	substring(sku from 1  for 3) as sku_category_code
from products ; 

-- Extract domain name from emaili (find position of @ first)

select
	email , 
	substring(email from position('@' in email)+1) as email_domainalter 
from customers; 



--5) trim() -- remove leading and trailing spaces 


--**Variants:**
--```sql
--TRIM(string)          -- removes spaces from both sides
--LTRIM(string)         -- removes spaces from the left only
--RTRIM(string)         -- removes spaces from the right only
--TRIM('x' FROM string) -- removes a specific character instead of spaces
--```

select 
	customer_id,
	trim(first_name) as first_name_clean , 
	trim('  Rohan   ') as example_trim 
from customers; 


SELECT
    customer_id,
    TRIM(LOWER(first_name)) AS first_name_clean,
    TRIM(LOWER(last_name))  AS last_name_clean,
    TRIM(LOWER(email))      AS email_clean,
    TRIM(phone)             AS phone_clean
FROM customers;


--PRODUCTION USAGE-----REAL DE PIPELINES 


--1) **ETL Cleaning Layer:**

-- if i need to add clear clean data in the final table , then i need to write below function
-- example clean final table -- customer_clean ( which will take data from different tables )

insert into customer_clean 
select
	customer_id , 
	trim(first_name) 	as first_name , 
	trim(last_name) 	as last_name , 
	trim(lower(email))	as email , 
	trim(phone)			as phone , 
	signup_date , 
	is_active
from customer_raw
where length(trim(email)) > 0 -- drop blank emails 
	and position('@' in email) > 1;


--2) Reporting / dashboard layer -- 

select 	
	c.customer_id id , 
	concat(c.first_name , ' ' , c.last_name) as customer_name , 
	upper(o.status)						   as order_status , 
	concat('$' , max(o.total_amount))	   as amount_display
from orders o 
join customers c on o.customer_id  = c.customer_id 
where o.status = 'delivered'
group by c.customer_id  , c.first_name , c.last_name , o.status
order by max(o.total_amount)  desc

		


--################## DATE FUNCTION ###############################################

--
--*Two main date types in PostgreSQL:**
--- `DATE` — stores only the date: `2024-03-15`
--- `TIMESTAMP` — stores date + time: `2024-03-15 14:30:00`
--
--**Key rule:** You can always cast a TIMESTAMP to DATE by using `::DATE` or `CAST(col AS DATE)`.
select order_date::date from orders; 


1) current_date and now() -- return the current date/ time 

select current_date; 
select now(); 
select current_timestamp; -- same as now ()


--find orders placed today 
select order_id , customer_id , total_amount 
from orders 
where order_date::DATE = current_date;

--find customers who signed up in the last 30 days 

select customer_id , first_name , email , signup_date
from customers 
where signup_date >= current_date - interval '30 days' ;


--2) EXTRACT  ( PART FROM COLUMN)

--**Parts you must know:** `year`, `month`, `day`, `quarter`, `hour`, `minute`, `dow` (day of week, 0=Sunday)


--Break down order_date into components 

select
	order_id , 
	order_date , 
	extract(year		from order_date) as order_year, 
	extract(month		from order_date) as order_month , 
	extract(quarter     from order_date) as order_quarter , 
	extract(day 		from order_date) as order_day , 
	extract(dow			from order_date) as day_of_week  , 
	to_char(order_date , 'FMday') as order_day
	
from orders 
limit 5 ; 

--Monthly revenue report -- the most common real-world use 

select 
	extract(year from order_date) as order_year , 
	extract(month from order_date) as order_month , 
	count(*) 					  as total_orders , 
	sum(total_amount)				as total_revenue
from orders
where status = 'delivered'
group by 1,2
order by 1,2

-- ** Alternative- date_part()** identical to extract , just different syntax 

DATE_PART('MONTH' , order_date) -- same as extract(month from order_date)



--3) DATE_TRUNC() -- Truncate a date to a boundary 

-- what it does -- rounds a date down to nearest year , month , week , day , hours etc

--syntax 
--date_trunc('precision' , column)

-- Truncate to month: 2024-03-15 → 2024-03-01
-- Truncate to year:  2024-03-15 → 2024-01-01
-- Truncate to week:  2024-03-15 → 2024-03-11 (Monday of that week)


select
	order_id , 
	order_date , 
	date_trunc('month' , order_date) as order_month_start , 
	date_trunc('year' , order_date) as order_year_start , 
	date_trunc('week' , order_date) as order_week_start

from orders
limit 5


--monthly revenue report using date_trunc (cleaner than extract for grouping)

select 
	date_trunc('month' , order_date) as month , 
	count(*) 						 as total_orders , 
	sum(total_amount)				 as revenue 
from orders
where status = 'delivered'
group by 1 
order by 1 ; 


--4)  Date Arithmetic -- Adding as subtracting time  -- add or subtract intervals from dates



```--sql
-- Syntax: date + INTERVAL 'N unit'
CURRENT_DATE + INTERVAL '7 days'     -- 7 days from now
CURRENT_DATE - INTERVAL '30 days'    -- 30 days ago
CURRENT_DATE + INTERVAL '3 months'   -- 3 months from now
CURRENT_DATE - INTERVAL '1 year'     -- 1 year ago
```


--eg 
-- find orders placed in last 90 days 

select
	order_id , 
	customer_id , 
	order_date , 
	status , 
	total_amount
from orders
where order_date >= current_date - interval '90 days'
order by order_date desc ; 

-- Find customers who signed up more than 1 year ago (retained customers)

select
	customer_id , 
	first_name, 
	last_name , 
	signup_date , 
	current_date - signup_date::date as days_since_signup 
from customers
where signup_date < current_date - interval '1 year'
	and is_active = true
order by signup_date; 

```sql
-- Subtract two dates → returns number of days as integer
date1 - date2

-- Subtract two timestamps → returns INTERVAL
timestamp1 - timestamp2
```

--how many days has each customer been with us ?

select 
	customer_id , 
	first_name , 
	signup_date , 
	current_date - signup_date as days_as_customer
from customers
order by days_as_customer desc; 


-- Order fulfillment time: days between order placed and updated (proxy for delivery)
-- Using shipments table is ideal, but using orders alone as a simple example:

SELECT
    order_id,
    order_date::DATE   AS placed_on,
    updated_at::DATE   AS last_updated,
    (updated_at::DATE - order_date::DATE) AS days_to_update
FROM orders
WHERE status = 'delivered'
  AND updated_at IS NOT NULL
LIMIT 10;


-- TO_CHAR() --  format dates as strings for display 
--what it does -- converts a date/timestamp to a formatted string

-- dashboard and reports need dates in human-readable formats like "March 2024" or "Q1- 2025"

--format options 

select to_char(order_date , 'Month YYYY') from orders;
to_char(order_date , 'DD/MM/YYYY'); 
to_char(order_date , 'yyyy-mm');
to_char(order_date , '"Q"Q yyyy');
to_char(order_date , 'Day')


--EG
-- Monthly revenue dashboard with formatted month labels

select 
	to_char(order_date , 'Month YYYY') as month_label , 
	count(*)						   as total_orders , 
	sum(total_amount)				   as revenue
from orders
where status = 'delivered'
group by date_trunc('month' , order_date) , to_char(order_date , 'Month YYYY')
order by date_trunc('month' , order_date);



-- Important questions 

--Q1) write a query to show monthly revenue for 2024 for delivered orders 

select
	to_char(date_trunc('month' , order_date) , 'Month') as month , 
	count(*)						 as order_count , 
	sum(total_amount)				 as revenue
from orders
where status = 'delivered'
	and extract(year from order_date)  = 2024
group by date_trunc('month' , order_date) 
order by date_trunc('month' , order_date) ; 


--Q2: "Find customers who haven't placed any order in the last 6 months.

select
	c.customer_id , c.first_name , c.email
from customers c
left join orders o 
	on c.customer_id = o.customer_id 
	and o.order_date >= CURRENT_DATE - interval '6 months'
where o.order_id is null ;


--Q3: How would you find orders placed on weekends?

select * from orders
where extract(dow from order_date) in (0,6); -- 0 = sunday , 6 = saturday

--Q4 - Calculate the average days between order placement and today for pending orders.

select 
	avg(current_date - order_date::Date) as avg_days_pending 
from orders
where status = 'pending';












































