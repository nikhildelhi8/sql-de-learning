-- ============================================
-- DDL (POSTGRESQL)
-- ============================================





--SQL DATATYPES -- 
--
--Numbers -- 
--INT -- WHOLE NUMBER UPTO 2.1B
--BIGINT -- WHOLE NUMBER UPTO 9.2 QUIDRILIAN NUMBERS 
--NUMERIC(P, S) -- EXACT DECIMAL 
--FLOAT -- APPROXIMATE DECIMALS 
--smallint -- TINY WHOLE NUMBERS 
--
--TEXTS --
--
--VARCHAR(N) -- TEXT WITH MAX LENGTH 
--TEXT -- UNLIMITED LENGTH TEXT 
--CHAR(N) -- FIXED LENGTH TEXT 
--
--DATE / TIMES -- 
--
--DATE -- CALENDAR DATE ONLY 
--TIMESTAMP -- DATE + TIME , NO ZONE TIMINGS
--TIMESTAMPZ -- DATE + TIME + ZONE TIMINGS 
--interval -- DURATION OF TIME 
--
--BOOLEAN -- 
--true / false / null 
--always pair with not null to avoid 3-valued logic bugs 
--
--SEMI-STRUCTURED (POSTGRES SQL)
--
--JSON -- STORED AS TEXT , VALIDATED ON INSERT 
--JSONB -- BINARY JSONB , INDEXED , QUERYABLE INSIDE 
--USE JSONB for PIPELINE data , JSON ALMOST NEVER 
--
--
--** 3 RULE THAT PREVENT 90% of BUGS 
--
---RULE 1  -- MONEY 
--Never user float for currency. 0.1 + 0.2 = 0.300000004 not correct for currency , always use 
--numeric (12,2) for financial columns 
--
---RULE 2 -- IDs 
--Use BIGINT for all IDs , not INT . INT maxes out at 2.1 billion rows.
--
---Rule 3 -- Timestamps
--always timestamptz not timestamp . when your pipeline crosses timezones timestamp gives silent error 
--


-- ============================================
-- 1) INTEGER TYPES
-- ============================================
-- BIGINT (±9.2 quintillion) vs INT (±2.1 billion)
-- Use BIGINT for IDs that can grow large

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,       -- safe for any scale
    quantity INT,                      -- fine for quantities
    status_code SMALLINT               -- ideal for small enums (saves space)
);


-- ============================================
-- 2) TEXT TYPES
-- ============================================
-- TEXT vs VARCHAR(n)
-- Same performance in PostgreSQL; VARCHAR adds constraint

CREATE TABLE customers (
    email VARCHAR(255),                -- constraint-based
    notes TEXT,                        -- unbounded text
    country_code CHAR(2)               -- fixed-length (ISO codes like 'IN', 'DE')
);


-- ============================================
-- 3) NUMERIC TYPES
-- ============================================
-- NEVER use FLOAT/DOUBLE for money (precision issues)

CREATE TABLE transactions (
    amount NUMERIC(12, 2),             -- exact: up to 999,999,999,999.99
    tax_rate NUMERIC(5, 4),            -- exact: up to 9.9999
    score FLOAT,                       -- approximate (OK for ML/analytics)
    account_number DOUBLE PRECISION    -- high precision floating point
);


-- ============================================
-- 4) TIMESTAMP TYPES
-- ============================================
-- TIMESTAMP = no timezone (dangerous)
-- TIMESTAMPTZ = stored in UTC, converted on display (preferred)

CREATE TABLE events (
    created_at TIMESTAMPTZ,            -- always prefer this
    processed_at TIMESTAMPTZ,
    event_date DATE,                   -- date only
    duration INTERVAL                  -- duration (e.g., '2 hours 30 minutes')
);


-- ============================================
-- 5) BOOLEAN TYPES
-- ============================================
-- Avoid NULL (3-valued logic: TRUE/FALSE/NULL causes bugs)
-- Always use NOT NULL + DEFAULT

CREATE TABLE users (
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);


-- ============================================
-- 6) JSON TYPES (POSTGRESQL-SPECIFIC)
-- ============================================
-- JSONB = binary, indexed, preferred for data engineering
-- JSON = plain text, no indexing

CREATE TABLE raw_events (
    payload JSONB,                     -- preferred
    metadata JSON                      -- plain JSON
);


Combined Example --

CREATE TABLE patients (
    -- BIGINT because patient IDs will eventually exceed INT's 2.1B limit
    patient_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- VARCHAR(100) because names have a sensible max length — the constraint matters
    full_name       VARCHAR(100) NOT NULL,

    -- DATE not TIMESTAMP — we only care about the date of birth, not the time
    date_of_birth   DATE NOT NULL,

    -- CHAR(1) because gender codes are exactly 1 character: 'M', 'F', 'U'
    -- CHAR pads with spaces to fill the declared length — only use for truly fixed-length values
    blood_type      CHAR(3),            -- 'A+ ', 'B- ', 'O+ '

    -- NUMERIC(5,2) for exact weight — FLOAT would give you 72.30000000001 kg
    weight_kg       NUMERIC(5, 2),

    -- BOOLEAN + NOT NULL — never nullable boolean, avoids 3-valued logic bugs
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,

    -- TIMESTAMPTZ — patient registered across different hospital branches (timezones matter)
    registered_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- JSONB — semi-structured insurance data, structure varies per insurer
    insurance_data  JSONB
);












-- ============================================
-- CONSTRAINTS 
-- ============================================



-- ============================================
-- 1) Primary key 
-- ============================================

-- single column PK 

create table products(
	product_id BIGINT primary key , -- automatically not null + unique
	name text not null 
);

--Composite pk -- when the combination is unique , not individual columns

create table order_items(
	order_id bigint , 
	product_id bigint , 
	quantity int not null , 
	primary key (order_id , product_id) -- one row per product per order 
);

-- ============================================
-- 2) foriegn key 
-- ============================================


create table orders(
	
	order_id bigint primary key , 
	customer_id bigint not null , 
	foriegn key (customer_id) reference customers(customer_id)
		on delete restrict -- block deletion of customer if they have orders 
		on update cascade -- if customer_id changes , update all orders 
);


































