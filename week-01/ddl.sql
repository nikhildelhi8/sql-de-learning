-- ============================================
-- DDL (POSTGRESQL)
-- ============================================





--SQL DATATYPES -- 
--
--Numbers -- 
--INT -- WHOLE NUMBER UPTO 2.1B
--BIGINT -- WHOLE NUMBER UPTO 9.2 QUIDRILIAN NUMBERS 
--NUMERIC(P, S) -- EXACT DECIMAL used in financial values 
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

create table patients(
	
	patient_id bigint generated always as identity primary key , 
	full_name varchar(100) not null 
	
)
-- generated always as identity (autoincrement the id value , if not used then manually need to provide the data)


--COMPOSTIE KEY -- The combination of two columns is unique 

-- example -- An appointment can have many doctors , a doctor can have many appointments but 
-- each doctor can only be assigned to a given appointment ONCE

create table appointment_doctors (
	appointment_id BIGINT not null , 
	doctor_id      bigint not null , 
	role           varchar(50) , 
	primary key (appointment_id , doctor_id)
	
)


-- ============================================
-- 2) foriegn key 
-- ============================================

-- A forign key says -- the value in this column must already exist as primary key in that other table . Its how you 
--enforce tha data doesn't become orphaned 

--Real world analogy -- Imagine a hospital where you can book an appointment for a patient who doesn't exist in the system.
-- A forign key makes that impossible on the db level 

-- ON DELETE OPTIONS -- WHAT HAPPENS WHEN A PARENT ROW IS DELETED ?

-- --> RESTRICT
--		Block the delete. Cannot delete a patient who still has appointments. Most common in DE.
--
-- --> CASCADE
--		Delete children too. Deleting a patient auto-deletes all their appointments. Use very carefully.
--
--  --> SET NULL
--		Orphan gracefully. Appointment stays, patient_id becomes NULL. Only when relationship is optional.
--
-- 	-->SET DEFAULT
--		Rare. sets FK to the column's default value. Almost never used.


create  table appointments (

appointment_id	 BIGINT generated always as identity primary key , 
patient_id		 bigint not null , 
doctor_id 		 bigint not null , 
scheduled_at 	 timestampz not null ,
status			 varchar(20) not null default 'scheduled' , 

-- the fk declaration patient_id must exist in patients.patient_id 

foreign key (patient_id) 
	references patients(patient_id) 
	on delete restrict , -- block deletion of a patient who has appointmenets 
	
foreign key (doctor_id)
	references doctors(doctor_id) 
	on delete restrict

);


-- ============================================
-- 3) CHECK  
-- ============================================


--A CHECK constraint lets you write a condition that every row must satisfy. The database evaluates it on every INSERT and UPDATE. If the condition is false, the operation is rejected.
--Real-world analogy: the hospital's paper intake form has "Age must be between 0 and 150" printed right on it. The CHECK constraint is that printed instruction — built directly into the structure.

create table LAB_RESULTS (
	
	result_id bigint generated always as identity primary key , 
	patient_id bigint not null references patients(patient_id) , 
	test_name varchar(100) not null , 
	
	--single column check 
	
	result_value	numeric(8,3) not null check(result_value>=0) , 
	severity		varchar(20) check (severity in ('normal' , 'mild' , 'moderate' , 'critical')),
	
	collected_at	timestamptz not null , 
	processed_at 	timestamptz , 
	
	-- Multi-column check : processed_at must come after collected_at 
	-- the database enforces this rule on every insert and update 
	check (processed_at is null or processed_at >= collected_at)

);


-- ============================================
-- 4) NOT NULL AND DEFAULT 
-- ============================================

 
create table pipeline_audit_log (

	log_id		bigint generated always as identity primary key , 
	
	--not null , every log entry must have these 
	
	pipeine_name	varchar(200) not null , 
	run_status		varchar(20) not null default 'started' , 
					-- default means -- if you dont specify run_status , its started 
	
	started_at 		timestamptz not null default now() ,  
					--default now() means if you dont provide a timestamp use right now time 
	
	-- Nullable intentionally: we don't know finished_at until the pipeline finishes
    finished_at     TIMESTAMPTZ,

    rows_processed  INT          NOT NULL DEFAULT 0,
    error_message   TEXT         -- intentionally nullable: only has value on failure
	


)

-- ============================================
-- 5) Unique constraint 
-- ============================================

 ALTER TABLE patients ADD CONSTRAINT unique_email UNIQUE(email);




--##########################################################33
-- # ALTER TABLE -- CHANGING SCHEMAS WITHOUT DESTROYING DATA 
--##############################################################


-- ADD A COLUMN (SAFE -- EXISTING ROWS GET THE DEFAULT VALUE )

alter table patients 
	add column referral_source varchar(50) default 'direct';


-- add a column without a constraint 
alter table lab_results 
	add column reviewed_by varchar(100);

-- rename a column 
alter table patients 
	rename column referral_source to acquisation_channel;

-- add a constraint to an existing table 

alter table lab_results 
	add constraint chk_severity 
	check (severity in ('normal', 'mild', 'moderate', 'critical', 'life-threatening'));

--drop a contraint (when a business rule changes)
alter table lab_results 
	drop constraint chk_severity;

--drop a column( destructive - data is permanently gone )

alter table patiesnts 
	drop column acquisition_channel; 



-- Alter Operation which are safe in production 

-- safe (non-locking in postgrss 11+) : adding a column with a default

alter table patients add column is_vip boolean not null default false;
--postgrassql storres the default in the catalog , doesn't rewrite the table 

--dangerous (rewrites the entire table , locks it for reads and writes):
alter table patients 
	alter column weight_kg type float;

-- safer production approach ( usually safe (no full rewrite)
-- compatible type changes ex( INT --> BIGINT )
--instead of direct change :
alter table patients add column weight_kg_new float;

update patients 
set weight_kg_new = weight_kg; -- this will copy the data from old to new col

-- then swap the columns later ( swapping here means swapping  the col name so that now it points to new col)



--################################################################33
--  DROP AND TRUNCATE DESTRUCTIVE OPERATION 
--#################################################################


--DROP TABLE  : remove the table structure and all data . Permanent 

drop table if exists staging_raw_events; 
--always use if exists in pipeline scripts -- prevents errors on re-runs

--TRUNCATE -- remove all rows , keeps the table structure 
truncate table staging_lab_results; 
--much faster than delete for clearing a staging table 
-- not easily rolled back -- treat if as permanent 

--DELETE : removes specific rows , row by row , fully transactional 


--“Delete everything older than 7 years from today”
delete from lab_results 
where collected_at < Now() - interval '7 years'; 
--slower than truncate , but you can roll it back and use where conditions 



--###########################################################
--INDEXES
--#######################################################3##

--The Problem Indexes Solve
--Imagine the hospital has 10 million lab results. You run:
--sqlSELECT * FROM lab_results WHERE patient_id = 1001;
--Without an index, the database has to read every single one of the 10 million rows and check if patient_id = 1001. This is called a full table scan. It takes seconds. In a pipeline running millions of such queries, it's catastrophic.
--An index solves this by maintaining a separate, sorted lookup structure — like the index at the back of a textbook — so the database can jump directly to the relevant rows.


-- The index internally uses the B-Tree ( a tree like structure divided in nodes )
--									root node (is 1001<5000 or >= 5000)
--						
--				yes <5000															no >=5000
--			branch node is 1001<2500 or >=2500								branch node 5000-10000
--			
--yes <2500								no>= 2500


-- B-tree is a sorted structure it stores the sorted (col_value == index_value, pointer) and search for the indexed value in btree.
-- So instead of looking for the whole row it sees it in the b-tree , once found use the pointer to point to exact row and then display the result.



--#### TYPES OF INDEXES ##########

--1. Standard b-tree index -- the default , works for = , < , > , between , order by 

create index idx_lab_results_patient_id
	on lab_results(patiend_id);

-- 2. Composite index — when your WHERE clause filters on multiple columns together
-- Order matters: put the most selective column first
-- This index helps: WHERE patient_id = 1001 AND status = 'pending'
-- This index also helps: WHERE patient_id = 1001 (uses the first column)
-- This index does NOT help: WHERE status = 'pending' (skips the first column)
CREATE INDEX idx_lab_results_patient_status
    ON lab_results(patient_id, status);


-- 3. Partial index — only indexes rows matching a condition
-- If 95% of appointments are 'completed', only indexing 'scheduled' is much smaller and faster
CREATE INDEX idx_appointments_scheduled
    ON appointments(scheduled_at)
    WHERE status = 'scheduled';

-- 4. Unique index — enforces uniqueness AND speeds up lookups
-- Same effect as UNIQUE constraint, but you can make it partial
CREATE UNIQUE INDEX idx_patients_email
    ON patients(email)
    WHERE is_active = TRUE;  -- only one active account per email
    
    
--  ############3The Decision Framework: When to Create an index#####################3
--Here's the mental model to use every time you're considering adding an index:
--Create an index when:
--
--The column appears in WHERE, JOIN ON, or ORDER BY in frequently-run queries
--The column is a Foreign Key (always index these — they appear in every JOIN)
--The column has high cardinality (many distinct values — patient_id is perfect; is_active with only 2 values is not)

--###############Don't create an index when:##################33
--
--The column has very low cardinality (TRUE/FALSE, M/F, status with 3 values) — the database may just scan the table anyway
--The table is small (under ~10,000 rows) — full scans are fast enough
--The table has very high write volume — every index is a write tax on every INSERT/UPDATE/DELETE


			
	

















