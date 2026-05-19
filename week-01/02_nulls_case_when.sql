
--### is null ####

-- Find orders with no discount applied
SELECT order_id, customer_id, total_amount
FROM orders
WHERE discount_pct IS NULL;

-- Find customers with no phone on file
SELECT customer_id, email
FROM customers
WHERE phone IS NULL;


--##############33COALESCE(col, fallback)#######################
--Returns the first non-NULL value in the list. The most-used NULL function in real DE work. Use it to substitute defaults for missing data.


--orders : treat missing discount as $0 

select
	order_id  , 
	total_amount , 
	coalesce(discount_pct  , 0 ) as discount_amount , 
	total_amount - coalesce(discount_pct  , 0) as net_amount
	from orders;


-- CUstomers: fallback chain (preferred phone -> email )

select customer_id , 
	coalesce(phone , email , 'no contact') as best_contact
	from customers; 

--Production use: Prevents NULL from contaminating calculations, SUM aggregations, and display columns in dashboards.



--############### NULL IF ------TURN A VALUE INTO NULL 

-- Nullif(col,bad_value) , returns null if the two arguments are equal , otherwise returns the first argumnet , use it to suppress divide by 0 error or clean dirtly data 

--safe divisiion : avoid divide by 0 in conversion rate 

select
	product_id , 
	views , 
	purchases , 
	purchases * 100 / nullif(views,0) as conversion_pct
	from product; 


--clean dirty data : treat '0' string as null in orders 

select 
	order_id , 
	nullif(coupon_code , '') as coupon_code
	from orders;


--combine with coalesce for full control 

select 
	order_id , 
	coalesce(nullif(coupon_code , '') , 'No coupon code') as coupon_code
	from orders; 


--#####################NULL IN AGGREGATIONS ####################

-- SUM , AVG , COUNT(COL) all ignore null rows , count(*) counts all rows including nulls. This is often the result you want 


-- AVG(discount_amount) ignores orders with no discount 
-- that is different from treating them as 0 ( the whole calculation will get affected)



--average accross all orders (treat no discount as$0)

select 
	   avg(coalesce(discount_pct  , 0)) as average_discount_pct
	   from orders 
	   
	   

-----------------------------------------------------------------------------------
	   
	   
--######################## CASE WHEN ######################################
	   

--CASE WHEN  is sql's if else.

--### 3 use cases ####

--1) derive a new column based on conditions 
--2) bucket values into categories 
--3) pivot rows into columns (all inside a query) . It appears in select , where , orderby and inside aggregate functions 
	   

--syntax 

	   case
	   	when condition_1 then result_1
	   	when condition_2 then result_2 
	   	when condition_3 then result_3
	   	else default_result 
	   end
	   
--simple case -- shorthand for equality checks 
	   
	   case status -- here status is either col_name or expressions
	   	when 'completed' then 'Done'
	   	when 'cancelled' then 'void' 
	   	else 'pending'
	   end


--#### PATTERN 1 : CATEGORISE / BUCKET VALUES ####
	   
--order value tiers 
	   
select 
	order_id , 
	total_amount , 
	case 
		when total_amount >=5000								then 'high_value'
		when total_amount >=100 and total_amount <5000			then 'mid_value'
		when total_amount >0 and total_amount <100				then 'low_value'
		else 'zero_or_unknown'
		
	end as order_tier 
	from orders
	

--##### PATTERN 2 : CASE INSIDE COUNT / SUM -- CONDITIONAL AGGREGATIONS ----

--The most powerful real-world pattern
--Count or sum only the rows that meet a condition — without a subquery. This replaces multiple separate queries.
	
--Count orders by status in one query ( no group by pivot needed)

select 
	count(case when status = 'delivered' then 1 end ) as delivered , 
	count(case when status = 'cancelled' then 1 end ) as cancelled , 
	count(case when status = 'shipped' then 1 end) as shipped ,
	count(status) as total 
	
from orders; 
	   

--revenue from high-value orders vs everyone else 

select 
	sum(case when total_amount >=3000 then total_amount else 0 end ) as high_value_rev, 
	sum(case when total_amount <3000 then total_amount else 0 end) as regular_rev
from orders ;
	
	

--########## pattern 3: CASE  + NULL HANDLING TOGETHER ###############3

	
	
select 
	o.order_id ,
	c.email , 
	o.total_amount , 
	coalesce(o.discount_pct , 0 ) as discount , 
	case 
		when o.discount_pct is null	then 'no_discount'
		when o.discount_pct >=50 	then 'heavy_discout'
		else 							 'light_discount'
		
	end as discount_category , 
	
	case
		when o.status = 'completed' 
		and o.total_amount >=500 	then  'vip_completed'
		when o.status = 'completed' then 'completed'
		when o.status = 'cancelled' then 'cancelled' 
		else							 'other'
	end as order_labelalter 
	
	from orders o 
	join customers c on o.customer_id = c.customer_id ; 
	
	
	
	
	
--############################# practice questions ########################################33

	
--1. Find all customers who haven't provided their phone number.
--The customers table has a nullable phone column'
	
select 
customer_id , 
first_name , 
last_name , 
coalesce(phone , 'not provided')as phone_numbers
from customers; 

--2.  List all shipments that have not been delivered yet.
--The shipments table has actual_delivery as NULL for undelivered shipments

select 
shipment_id , 
order_id , 
carrier , 
status from shipments
where actual_delivery is null ;


--3.ind the last restock date per warehouse, and if a product has never been restocked, show 'Never Restocked' instead.
--Use COALESCE on last_restocked in the inventory table. Join with products and warehouses and show warehouse_name, product_name, and last_restocked_display.


select 
	w.warehouse_name , 
	p.product_name , 
	coalesce(i.last_restocked::TEXT, 'never restocked') as last_restocked_date
	from ecom.inventory i 
	join ecom.products p 
		on i.product_id  = p.product_id 
	join ecom.warehouses w 
		on w.warehouse_id   = i.warehouse_id ;


	
	
	
	
	
	
	




