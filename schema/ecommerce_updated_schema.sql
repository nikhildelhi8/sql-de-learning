-- =============================================================================
-- PRODUCTION-STYLE E-COMMERCE DATABASE FOR SQL PRACTICE (FIXED)
-- PostgreSQL Compatible | DBeaver Ready
-- =============================================================================

DROP SCHEMA IF EXISTS ecom CASCADE;
CREATE SCHEMA ecom;
SET search_path TO ecom;

-- =============================================================================
-- SECTION 1: LOOKUP / DIMENSION TABLES
-- =============================================================================

CREATE TABLE regions (
    region_id     SERIAL PRIMARY KEY,
    region_name   VARCHAR(100) NOT NULL,
    country       VARCHAR(100) NOT NULL DEFAULT 'India',
    created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id     INT REFERENCES categories(category_id) ON DELETE SET NULL,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    contact_email VARCHAR(150),
    phone         VARCHAR(20),
    country       VARCHAR(100),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP
);

CREATE TABLE warehouses (
    warehouse_id   SERIAL PRIMARY KEY,
    warehouse_name VARCHAR(150) NOT NULL,
    region_id      INT REFERENCES regions(region_id),
    address        TEXT,
    capacity       INT CHECK (capacity > 0),
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    department    VARCHAR(100),
    role          VARCHAR(100),
    manager_id    INT REFERENCES employees(employee_id) ON DELETE SET NULL,
    region_id     INT REFERENCES regions(region_id),
    hire_date     DATE NOT NULL,
    salary        NUMERIC(12,2) CHECK (salary >= 0),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 2: CORE TRANSACTIONAL TABLES
-- =============================================================================

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    phone         VARCHAR(20),
    region_id     INT REFERENCES regions(region_id),
    signup_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP
);

CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(200) NOT NULL,
    category_id   INT REFERENCES categories(category_id),
    supplier_id   INT REFERENCES suppliers(supplier_id),
    sku           VARCHAR(100) UNIQUE NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    cost_price    NUMERIC(10,2) CHECK (cost_price >= 0),
    weight_kg     NUMERIC(6,2),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP
);

CREATE TABLE inventory (
    inventory_id     SERIAL PRIMARY KEY,
    product_id       INT NOT NULL REFERENCES products(product_id),
    warehouse_id     INT NOT NULL REFERENCES warehouses(warehouse_id),
    quantity_on_hand INT NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    reorder_level    INT NOT NULL DEFAULT 10,
    last_restocked   TIMESTAMP,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP,
    UNIQUE (product_id, warehouse_id)
);

CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    employee_id   INT REFERENCES employees(employee_id),
    order_date    TIMESTAMP NOT NULL DEFAULT NOW(),
    status        VARCHAR(50) NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','processing','shipped',
                                      'delivered','cancelled','returned')),
    shipping_address TEXT,
    total_amount  NUMERIC(12,2),
    discount_pct  NUMERIC(5,2) DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100),
    notes         TEXT,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP
);

CREATE TABLE order_items (
    order_item_id  SERIAL PRIMARY KEY,
    order_id       INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id     INT NOT NULL REFERENCES products(product_id),
    quantity       INT NOT NULL CHECK (quantity > 0),
    unit_price     NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    discount_pct   NUMERIC(5,2) DEFAULT 0,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payments (
    payment_id     SERIAL PRIMARY KEY,
    order_id       INT NOT NULL REFERENCES orders(order_id),
    payment_date   TIMESTAMP NOT NULL DEFAULT NOW(),
    amount         NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    method         VARCHAR(50) CHECK (method IN ('credit_card','debit_card',
                                                  'upi','net_banking','wallet','cod')),
    status         VARCHAR(50) NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending','success','failed','refunded')),
    transaction_id VARCHAR(100) UNIQUE,
    gateway        VARCHAR(100),
    failure_reason TEXT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE shipments (
    shipment_id       SERIAL PRIMARY KEY,
    order_id          INT NOT NULL REFERENCES orders(order_id),
    warehouse_id      INT REFERENCES warehouses(warehouse_id),
    carrier           VARCHAR(100),
    tracking_number   VARCHAR(100),
    shipped_date      TIMESTAMP,
    estimated_delivery TIMESTAMP,
    actual_delivery   TIMESTAMP,
    status            VARCHAR(50) DEFAULT 'pending'
                        CHECK (status IN ('pending','in_transit','delivered',
                                          'failed','returned')),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP
);

CREATE TABLE returns (
    return_id      SERIAL PRIMARY KEY,
    order_id       INT NOT NULL REFERENCES orders(order_id),
    order_item_id  INT REFERENCES order_items(order_item_id),
    return_date    TIMESTAMP NOT NULL DEFAULT NOW(),
    reason         VARCHAR(200),
    status         VARCHAR(50) DEFAULT 'pending'
                     CHECK (status IN ('pending','approved','rejected','refunded')),
    refund_amount  NUMERIC(12,2),
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE reviews (
    review_id    SERIAL PRIMARY KEY,
    product_id   INT NOT NULL REFERENCES products(product_id),
    customer_id  INT NOT NULL REFERENCES customers(customer_id),
    order_id     INT REFERENCES orders(order_id),
    rating       SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title        VARCHAR(200),
    body         TEXT,
    is_verified  BOOLEAN DEFAULT FALSE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 3: SEED DATA
-- =============================================================================

INSERT INTO regions (region_name, country) VALUES
('North India', 'India'), ('South India', 'India'), ('East India', 'India'),
('West India', 'India'), ('Central India','India'), ('Northeast India','India');

INSERT INTO categories (category_name, parent_id, is_active) VALUES
('Electronics',    NULL, TRUE), ('Clothing',       NULL, TRUE),
('Home & Kitchen', NULL, TRUE), ('Books',          NULL, TRUE),
('Sports',         NULL, TRUE), ('Mobile Phones',  1, TRUE),
('Laptops',        1, TRUE),    ('Accessories',    1, TRUE),
('Men''s Wear',    2, TRUE),    ('Women''s Wear',  2, TRUE),
('Cookware',       3, TRUE),    ('Furniture',      3, FALSE),
('Fiction',        4, TRUE),    ('Non-Fiction',    4, TRUE),
('Cricket',        5, TRUE),    ('Fitness',        5, TRUE);

INSERT INTO suppliers (supplier_name, contact_email, phone, country, is_active) VALUES
('TechSource Pvt Ltd',    'supply@techsource.in',   '9810001111', 'India',  TRUE),
('FashionHub Exports',    'exports@fashionhub.com', '9820002222', 'India',  TRUE),
('HomeGoods Wholesale',   'info@homegoods.in',      '9830003333', 'India',  TRUE),
('PageTurner Publishers', 'orders@pageturner.in',   '9840004444', 'India',  TRUE),
('SportsPro Supplies',    'bulk@sportspro.in',      '9850005555', 'India',  TRUE),
('GlobalElec Ltd',        'sales@globalelec.com',   NULL,         'China',  TRUE),
('FastFashion Co',        NULL,                     '9860006666', 'Bangladesh', FALSE);

INSERT INTO warehouses (warehouse_name, region_id, address, capacity, is_active) VALUES
('Delhi Central WH',    1, '12 Industrial Area, New Delhi',        50000, TRUE),
('Bangalore Tech WH',   2, '45 Electronic City, Bangalore',        40000, TRUE),
('Mumbai Port WH',      4, '7 JNPT Road, Navi Mumbai',             60000, TRUE),
('Kolkata East WH',     3, '23 Salt Lake, Kolkata',                30000, TRUE),
('Chennai South WH',    2, '88 Mount Road, Chennai',               35000, TRUE),
('Hyderabad Hub WH',    2, '101 Cyber Towers, Hyderabad',          45000, TRUE),
('Pune Overflow WH',    4, '34 Hinjewadi, Pune',                   20000, FALSE);

INSERT INTO employees (first_name, last_name, email, department, role, manager_id, region_id, hire_date, salary, is_active) VALUES
('Arjun',   'Sharma', 'arjun.sharma@ecom.in', 'Executive', 'CEO', NULL, 1, '2018-01-15', 2500000, TRUE),
('Priya',   'Mehta',  'priya.mehta@ecom.in',  'Sales', 'VP Sales', 1, 1, '2018-06-01', 1800000, TRUE),
('Ravi',    'Kumar',  'ravi.kumar@ecom.in',   'Operations', 'VP Operations', 1, 2, '2019-03-10', 1700000, TRUE),
('Sunita',  'Patel',  'sunita.patel@ecom.in', 'Finance', 'CFO', 1, 4, '2018-08-20', 2000000, TRUE),
('Amit',    'Verma',  'amit.verma@ecom.in',   'Sales', 'Sales Manager', 2, 1, '2019-07-01', 900000,  TRUE),
('Kavya',   'Reddy',  'kavya.reddy@ecom.in',  'Sales', 'Sales Manager', 2, 2, '2020-01-15', 850000,  TRUE),
('Deepak',  'Singh',  'deepak.singh@ecom.in', 'Operations', 'Ops Manager', 3, 3, '2019-11-01', 800000,  TRUE),
('Nisha',   'Joshi',  'nisha.joshi@ecom.in',  'Operations', 'Ops Manager', 3, 4, '2020-04-01', 780000,  FALSE),
('Rahul',   'Gupta',  'rahul.gupta@ecom.in',  'Sales', 'Sales Executive', 5, 1, '2021-02-01', 450000,  TRUE),
('Anjali',  'Das',    'anjali.das@ecom.in',   'Sales', 'Sales Executive', 5, 1, '2021-06-15', 430000,  TRUE),
('Vikram',  'Nair',   'vikram.nair@ecom.in',  'Sales', 'Sales Executive', 6, 2, '2022-01-10', 420000,  TRUE),
('Meena',   'Iyer',   'meena.iyer@ecom.in',   'Operations', 'Warehouse Lead', 7, 3, '2021-09-01', 380000,  TRUE),
('Suresh',  'Rao',    'suresh.rao@ecom.in',   'Operations', 'Warehouse Lead', 7, 4, '2022-03-15', 370000,  TRUE);

INSERT INTO customers (first_name, last_name, email, phone, region_id, signup_date, is_active) VALUES
('Rohan', 'Sharma', 'rohan.sharma@gmail.com', '9911001100', 1, '2021-01-10', TRUE),
('Priya', 'Singh', 'priya.singh@gmail.com', '9911002200', 2, '2021-02-14', TRUE),
('Amit', 'Patel', 'amit.patel@gmail.com', NULL, 4, '2021-03-22', TRUE),
('Sunita', 'Mehta', 'sunita.mehta@yahoo.com', '9911004400', 1, '2021-04-05', TRUE),
('Ravi', 'Kumar', 'ravi.kumar@hotmail.com', '9911005500', 2, '2021-05-18', TRUE),
('Kavya', 'Reddy', 'kavya.reddy@gmail.com', '9911006600', 2, '2021-06-30', TRUE),
('Deepak', 'Joshi', 'deepak.joshi@gmail.com', NULL, 3, '2021-07-12', TRUE),
('Nisha', 'Gupta', 'nisha.gupta@gmail.com', '9911008800', 4, '2021-08-25', TRUE),
('Rahul', 'Sharma', 'rahul.sharma2@gmail.com', '9911009900', 1, '2021-09-08', TRUE),
('Anjali', 'Das', 'anjali.das@gmail.com', '9911010100', 3, '2021-10-20', TRUE),
('Vikram', 'Nair', 'vikram.nair@gmail.com', '9911011100', 2, '2021-11-05', TRUE),
('Meena', 'Iyer', 'meena.iyer@gmail.com', NULL, 2, '2021-12-18', FALSE),
('Suresh', 'Rao', 'suresh.rao@gmail.com', '9911013300', 2, '2022-01-30', TRUE),
('Lakshmi', 'Pillai', 'lakshmi.pillai@gmail.com', '9911014400', 2, '2022-02-14', TRUE),
('Arjun', 'Verma', 'arjun.verma@gmail.com', '9911015500', 1, '2022-03-28', TRUE),
('Pooja', 'Sharma', 'pooja.sharma@gmail.com', '9911016600', 1, '2022-04-10', TRUE),
('Sanjay', 'Malhotra', 'sanjay.malhotra@gmail.com', '9911017700', 1, '2022-05-22', TRUE),
('Rina', 'Bose', 'rina.bose@gmail.com', '9911018800', 3, '2022-06-15', TRUE),
('Tarun', 'Chaudhary', 'tarun.chaudhary@gmail.com', NULL, 1, '2022-07-08', TRUE),
('Geeta', 'Menon', 'geeta.menon@gmail.com', '9911020200', 2, '2022-08-20', TRUE),
('Naveen', 'Tiwari', 'naveen.tiwari@gmail.com', '9911021100', 5, '2023-01-15', TRUE),
('Divya', 'Saxena', 'divya.saxena@gmail.com', '9911022200', 5, '2023-02-28', TRUE),
('Harsh', 'Agarwal', 'harsh.agarwal@gmail.com', NULL, 6, '2023-03-10', TRUE),
('Swati', 'Pandey', 'swati.pandey@gmail.com', '9911024400', 1, '2023-04-05', FALSE),
('Manoj', 'Tiwari', 'manoj.tiwari@gmail.com', '9911025500', 1, '2023-05-18', TRUE);

INSERT INTO products (product_name, category_id, supplier_id, sku, unit_price, cost_price, weight_kg, is_active) VALUES
('Samsung Galaxy S24', 6, 1, 'MOB-SG-S24-001', 79999, 62000, 0.17, TRUE),
('iPhone 15 Pro', 6, 1, 'MOB-IP-15P-001', 134999, 105000, 0.19, TRUE),
('OnePlus 12', 6, 1, 'MOB-OP-12-001', 64999, 50000, 0.22, TRUE),
('Redmi Note 13 Pro', 6, 6, 'MOB-RM-13P-001', 24999, 18000, 0.19, TRUE),
('Realme 12 Pro', 6, 6, 'MOB-RL-12P-001', 19999, 14000, 0.20, TRUE),
('Dell XPS 15', 7, 1, 'LAP-DL-XPS-001', 139999, 110000, 1.86, TRUE),
('MacBook Air M3', 7, 1, 'LAP-AP-M3-001', 114999, 90000, 1.24, TRUE),
('HP Pavilion 15', 7, 6, 'LAP-HP-P15-001', 54999, 42000, 1.75, TRUE),
('Lenovo IdeaPad Slim 5', 7, 6, 'LAP-LN-IP5-001', 47999, 36000, 1.62, TRUE),
('Asus VivoBook 16', 7, 6, 'LAP-AS-VB-001', 44999, 33000, 1.90, TRUE),
('boAt Airdopes 141', 8, 1, 'ACC-BT-AD-001', 1299, 800, 0.05, TRUE),
('Anker PowerBank 20000mAh', 8, 1, 'ACC-ANK-PB-001', 2499, 1600, 0.45, TRUE),
('Logitech MX Master 3', 8, 1, 'ACC-LG-MX3-001', 9999, 7000, 0.14, TRUE),
('Portronics Charging Hub', 8, 6, 'ACC-PT-CH-001', 1899, 1100, 0.18, FALSE),
('Levi''s 511 Slim Jeans', 9, 2, 'CLT-LV-511-001', 3499, 2000, 0.50, TRUE),
('Allen Solly Formal Shirt', 9, 2, 'CLT-AS-FS-001', 1999, 1100, 0.25, TRUE),
('Nike Air Max 270', 9, 2, 'CLT-NK-AM-001', 12999, 9000, 0.80, TRUE),
('W Brand Kurta Set', 10, 2, 'CLT-WB-KS-001', 2499, 1400, 0.35, TRUE),
('Biba Ethnic Dress', 10, 2, 'CLT-BB-ED-001', 3299, 1900, 0.40, TRUE),
('Prestige Pressure Cooker', 11, 3, 'HK-PRE-PC-001', 3499, 2100, 2.50, TRUE),
('Hawkins Tri-Ply Pan', 11, 3, 'HK-HWK-TP-001', 2999, 1800, 1.20, TRUE),
('Milton Steel Bottle', 11, 3, 'HK-MLT-SB-001', 699, 350, 0.30, TRUE),
('Atomic Habits', 14, 4, 'BK-AH-001', 499, 180, 0.30, TRUE),
('The Alchemist', 13, 4, 'BK-TA-001', 299, 100, 0.22, TRUE),
('Rich Dad Poor Dad', 14, 4, 'BK-RDPD-001', 399, 140, 0.28, TRUE),
('SG Cricket Bat', 15, 5, 'SPT-SG-CB-001', 3499, 2200, 1.20, TRUE),
('Nivia Football', 15, 5, 'SPT-NV-FB-001', 1299, 700, 0.45, TRUE),
('Boldfit Resistance Bands', 16, 5, 'SPT-BF-RB-001', 599, 280, 0.30, TRUE),
('Zebronics BT Speaker', 8, 1, 'ACC-ZB-BTS-001', 2999, 1800, 0.60, TRUE),
('Proline Tracksuit', 9, 7, 'CLT-PL-TS-001', 1499, 800, 0.55, FALSE);

INSERT INTO inventory (product_id, warehouse_id, quantity_on_hand, reorder_level, last_restocked) VALUES
(1, 1, 150, 20, '2024-01-10'), (2, 1, 80, 15, '2024-01-15'), (3, 1, 120, 20, '2024-02-01'),
(4, 1, 300, 50, '2024-02-10'), (6, 1, 60, 10, '2024-01-20'), (7, 1, 40, 10, '2024-01-25'),
(11, 1, 500, 100,'2024-03-01'), (15, 1, 200, 30, '2024-02-20'), (23, 1, 1000, 200,'2024-03-05'),
(27, 1, 80, 20, '2024-02-15'), (5, 1, 0, 30, NULL), (1, 2, 90, 20, '2024-01-12'),
(2, 2, 50, 15, '2024-01-18'), (4, 2, 250, 50, '2024-02-12'), (8, 2, 100, 20, '2024-01-22'),
(9, 2, 80, 15, '2024-01-28'), (12, 2, 300, 60, '2024-03-02'), (18, 2, 150, 30, '2024-02-22'),
(20, 2, 75, 15, '2024-02-18'), (3, 2, 0, 20, NULL), (2, 3, 70, 15, '2024-01-20'),
(6, 3, 45, 10, '2024-01-24'), (7, 3, 30, 10, '2024-01-30'), (10, 3, 60, 10, '2024-02-05'),
(13, 3, 120, 25, '2024-03-03'), (16, 3, 180, 35, '2024-02-25'), (21, 3, 90, 20, '2024-02-19'),
(25, 3, 400, 80, '2024-03-06'), (17, 3, 0, 15, NULL), (4, 4, 200, 50, '2024-02-14'),
(15, 4, 160, 30, '2024-02-23'), (19, 4, 110, 25, '2024-02-20'), (22, 4, 250, 50, '2024-03-04'),
(24, 4, 600, 100,'2024-03-07'), (26, 4, 180, 40, '2024-02-16'), (28, 4, 120, 25, '2024-02-17'),
(29, 4, 0, 20, NULL);

INSERT INTO orders (customer_id, employee_id, order_date, status, total_amount, discount_pct) VALUES
(1, 9, '2022-03-15', 'delivered', 82498, 0), (2, 11, '2022-04-20', 'delivered', 79999, 5),
(3, 9, '2022-05-10', 'delivered', 26298, 0), (4, 10, '2022-06-18', 'cancelled', 139999, 10),
(5, 11, '2022-07-22', 'delivered', 3798, 0), (6, 11, '2022-08-05', 'delivered', 25998, 0),
(7, 9, '2022-09-12', 'returned', 3498, 0), (8, 10, '2022-10-25', 'delivered', 54999, 5),
(9, 9, '2022-11-11', 'delivered', 114999, 0), (10, 12, '2022-12-28', 'delivered', 2997, 0),
(1, 9, '2023-01-14', 'delivered', 9999, 0), (2, 11, '2023-02-20', 'delivered', 64999, 0),
(11, 11, '2023-03-08', 'delivered', 1299, 0), (12, 9, '2023-04-15', 'cancelled', 134999, 0),
(13, 11, '2023-05-22', 'delivered', 2998, 0), (14, 11, '2023-06-10', 'delivered', 3499, 10),
(15, 9, '2023-07-18', 'delivered', 114999, 5), (16, 10, '2023-08-25', 'returned', 24999, 0),
(17, 9, '2023-09-12', 'delivered', 79999, 0), (18, 12, '2023-10-05', 'delivered', 1498, 0),
(19, 9, '2023-11-20', 'delivered', 47999, 0), (20, 11, '2023-12-08', 'delivered', 44999, 5),
(1, 9, '2024-01-05', 'delivered', 2498, 0), (2, 11, '2024-01-18', 'delivered', 47999, 0),
(3, 9, '2024-01-25', 'shipped', 599, 0), (5, 11, '2024-02-08', 'delivered', 13999, 0),
(6, 11, '2024-02-14', 'delivered', 134999, 0), (8, 10, '2024-02-20', 'cancelled', 114999, 0),
(9, 9, '2024-03-01', 'delivered', 3498, 5), (10, 12, '2024-03-10', 'delivered', 1299, 0),
(13, 11, '2024-03-18', 'processing', 79999, 0), (15, 9, '2024-03-25', 'delivered', 3499, 0),
(4, 10, '2024-04-02', 'delivered', 64999, 0), (7, 9, '2024-04-10', 'delivered', 899, 0),
(11, 11, '2024-04-18', 'delivered', 19999, 5), (14, 11, '2024-05-05', 'shipped', 2499, 0),
(16, 10, '2024-05-12', 'delivered', 1299, 0), (17, 9, '2024-05-20', 'delivered', 54999, 0),
(18, 12, '2024-06-01', 'returned', 3299, 0), (19, 9, '2024-06-08', 'delivered', 9999, 0),
(20, 11, '2024-06-15', 'cancelled', 79999, 0), (1, 9, '2024-07-04', 'delivered', 139999, 5),
(2, 11, '2024-07-20', 'delivered', 1299, 0), (5, 11, '2024-08-05', 'delivered', 3498, 0),
(6, 11, '2024-08-18', 'delivered', 47999, 0), (9, 9, '2024-09-02', 'delivered', 114999, 0),
(13, 11, '2024-09-15', 'shipped', 2499, 0), (15, 9, '2024-09-28', 'delivered', 24999, 0),
(3, 9, '2024-10-10', 'delivered', 3499, 0), (4, 10, '2024-10-22', 'delivered', 79999, 0),
(7, 9, '2024-11-05', 'delivered', 2998, 0), (8, 10, '2024-11-18', 'cancelled', 134999, 0),
(10, 12, '2024-12-01', 'delivered', 499, 0), (11, 11, '2024-12-15', 'delivered', 64999, 0),
(14, 11, '2024-12-22', 'processing', 134999, 0), (17, 9, '2024-12-28', 'delivered', 3499, 0);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 79999), (1, 11, 2, 1299), (2, 1, 1, 79999), (3, 4, 1, 24999),
(3, 11, 1, 1299), (4, 6, 1, 139999), (5, 15, 1, 3499), (5, 11, 1, 1299),
(6, 4, 1, 24999), (6, 11, 1, 1299), (7, 22, 5, 699), (8, 8, 1, 54999),
(9, 7, 1, 114999), (10, 23, 2, 499), (10, 25, 1, 399), (10, 24, 1, 299),
(11, 13, 1, 9999), (12, 3, 1, 64999), (13, 11, 1, 1299), (14, 2, 1, 134999),
(15, 22, 2, 699), (15, 21, 1, 1299), (16, 17, 1, 3499), (17, 7, 1, 114999),
(18, 4, 1, 24999), (19, 1, 1, 79999), (20, 27, 2, 599), (20, 26, 1, 1299),
(21, 9, 1, 47999), (22, 10, 1, 44999), (23, 12, 1, 2499), (24, 9, 1, 47999),
(25, 28, 1, 599), (26, 17, 1, 12999), (26, 11, 1, 1299), (27, 2, 1, 134999),
(28, 7, 1, 114999), (29, 15, 1, 3499), (30, 11, 1, 1299), (31, 1, 1, 79999),
(32, 17, 1, 3499), (33, 3, 1, 64999), (34, 27, 1, 599), (34, 28, 1, 599),
(35, 5, 1, 19999), (36, 12, 1, 2499), (37, 11, 1, 1299), (38, 8, 1, 54999),
(39, 19, 1, 3299), (40, 13, 1, 9999), (41, 1, 1, 79999), (42, 6, 1, 139999),
(43, 11, 1, 1299), (44, 15, 1, 3499), (44, 16, 1, 1999), (45, 9, 1, 47999),
(46, 7, 1, 114999), (47, 12, 1, 2499), (48, 4, 1, 24999), (49, 17, 1, 3499),
(50, 1, 1, 79999), (51, 24, 1, 299), (51, 23, 1, 499), (52, 2, 1, 134999),
(53, 11, 1, 1299), (54, 3, 1, 64999), (55, 2, 1, 134999), (56, 17, 1, 3499);

-- FIXED: returns mapping to existing serial order_item_id
INSERT INTO returns (order_id, order_item_id, return_date, reason, status, refund_amount) VALUES
(7,  11, '2022-09-20', 'Product damaged on arrival', 'refunded', 3498),
(16, 23, '2023-09-01', 'Item not as described', 'approved', 3499),
(18, 25, '2023-09-05', 'Wrong size delivered', 'refunded', 24999),
(39, 49, '2024-06-10', 'Changed mind after delivery', 'refunded', 3299),
(52, 64, '2024-11-20', 'Duplicate order placed', 'pending', NULL);

-- Verification: Row counts
SELECT 'regions' as tbl, COUNT(*) FROM regions UNION ALL
SELECT 'orders', COUNT(*) FROM orders UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items UNION ALL
SELECT 'returns', COUNT(*) FROM returns;