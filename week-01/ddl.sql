-- # DDL for data engineering #


-- data types -the most consequential ddl decision

-- 1) INTEGER TYPES  -- BIGINT( +-9.2 quintillion) VS INT(+-2.1 billion)

-- Use BIGINT for any ID that could grow large
-- INT maxes out at ~2.1 billion rows -- pipelines hit this in production

create  table orders(
	order_id bigint primary key , -- safe for any scale  
	quantity int ,  -- fine for quantities 
	status_code smallint -- final for small enums (save space at scale )
	
)



--2) TEXT TYPES -- THE VARCHAR VS TEXT 

-- In PostgreSQL, TEXT and VARCHAR(n) have identical performance
-- VARCHAR(n) adds a constraint (max n characters), TEXT has no limit

create table customers(
	
	email varchar(255) , --contraints is the point , not performance
	notes text ,  -- unbounded text , no constraint needed
	country_code char(2) --fiexed- lengeth exact fit(ISO CODE : 'IN' , 'DE')
)



-- 3) NUMERIC TYPES -- precision matters for money 

-- NEVER store money as FLOAT or DOUBLE -- floating point rounding errors
-- 0.1 + 0.2 = 0.30000000000000004 in floating point

create table transactions(

	amount numeric (12 , 2), -- exact upto 999,999,999,999.99
	tax_rate numeric(5 ,4 ), -- exact: up to 9.9999
	score float  ,-- fine for ML scores, analytics (approximate is ok)
	account_number double 

)


-- 4) TIMESTAMPS TYPS -- THE MOST COMMON DDL MISTAKES 

--TIMESTAMP stores no timezone — it's a "naive" timestamp. TIMESTAMPTZ stores the moment in UTC and converts on display. In data engineering, always use TIMESTAMPTZ. When your pipeline runs across timezones (and it will), TIMESTAMP silently gives you wrong answers.


create table events(
	
	created_at timestamptz  , -- timestamp with time zone -- always prefer this 
	processed_at timestamptz ,
	event_date date ,  -- date only , no time component 
	duration_ms interval  -- time duration (eg '2 hours 30 min')
)



-- 5) BOOLEAN  

is_active BOOLEAN default true , 
is_deleted boolean not null default false


--6) JSON TYPES (POSTGRESSQL-SPECIFIC , DE-Critical)

create table raw_events(
	
	payload		jsonb , -- binary json , indexed , prefered for de wordk 
	metadata json -- plain text json , no indexing 

)

































