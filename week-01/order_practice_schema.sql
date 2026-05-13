-- CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    age INT,
    signup_date DATE
);

-- ORDERS TABLE
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_category VARCHAR(50),
    amount DECIMAL(10,2),
    status VARCHAR(20),
    created_at TIMESTAMP
);

-- PRODUCTS TABLE
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

-- INSERT CUSTOMERS
INSERT INTO customers (name, city, country, age, signup_date) VALUES
('Alice Johnson', 'New York', 'USA', 28, '2022-01-15'),
('Bob Smith', 'London', 'UK', 35, '2022-03-22'),
('Carol White', 'Mumbai', 'India', 30, '2022-05-10'),
('David Brown', 'New York', 'USA', 45, '2021-11-08'),
('Eva Green', 'Berlin', 'Germany', 27, '2023-01-20'),
('Frank Lee', 'Mumbai', 'India', 32, '2021-08-14'),
('Grace Kim', 'Seoul', 'South Korea', 29, '2022-07-19'),
('Henry Wilson', 'London', 'UK', 41, '2021-06-30'),
('Iris Chen', 'Shanghai', 'China', 26, '2023-03-05'),
('Jack Davis', 'New York', 'USA', 38, '2020-12-12'),
('Karen Martinez', 'Mumbai', 'India', 33, '2022-09-17'),
('Leo Zhang', 'Shanghai', 'China', 31, '2021-04-25'),
('Mia Patel', 'London', 'UK', 24, '2023-06-08'),
('Noah Garcia', 'Berlin', 'Germany', 36, '2020-10-03'),
('Olivia Turner', 'New York', 'USA', 29, '2022-11-22');

-- INSERT ORDERS
INSERT INTO orders (customer_id, product_category, amount, status, created_at) VALUES
(1, 'Electronics', 1200.00, 'completed', '2024-01-05 10:30:00'),
(1, 'Clothing', 85.50, 'completed', '2024-01-20 14:15:00'),
(2, 'Electronics', 3500.00, 'completed', '2024-01-08 09:00:00'),
(2, 'Books', 45.00, 'cancelled', '2024-01-15 16:30:00'),
(3, 'Clothing', 220.00, 'completed', '2024-02-01 11:00:00'),
(3, 'Electronics', 980.00, 'completed', '2024-02-10 13:45:00'),
(3, 'Books', 60.00, 'completed', '2024-02-18 10:00:00'),
(4, 'Furniture', 4500.00, 'completed', '2024-01-25 15:00:00'),
(4, 'Electronics', 750.00, 'refunded', '2024-02-05 12:30:00'),
(5, 'Clothing', 130.00, 'completed', '2024-03-01 09:30:00'),
(5, 'Books', 95.00, 'completed', '2024-03-10 14:00:00'),
(6, 'Electronics', 2200.00, 'completed', '2024-01-12 10:00:00'),
(6, 'Furniture', 1800.00, 'completed', '2024-02-20 16:00:00'),
(7, 'Clothing', 310.00, 'completed', '2024-03-05 11:30:00'),
(7, 'Electronics', 560.00, 'completed', '2024-03-15 13:00:00'),
(8, 'Books', 120.00, 'completed', '2024-01-30 09:00:00'),
(8, 'Furniture', 3200.00, 'completed', '2024-02-15 14:30:00'),
(9, 'Electronics', 890.00, 'cancelled', '2024-03-20 10:30:00'),
(10, 'Clothing', 450.00, 'completed', '2024-01-10 12:00:00'),
(10, 'Electronics', 1750.00, 'completed', '2024-02-25 15:30:00'),
(10, 'Books', 75.00, 'completed', '2024-03-01 09:00:00'),
(11, 'Furniture', 2600.00, 'completed', '2024-02-08 11:00:00'),
(12, 'Electronics', 3100.00, 'completed', '2024-01-18 13:30:00'),
(13, 'Clothing', 175.00, 'refunded', '2024-03-12 10:00:00'),
(14, 'Books', 200.00, 'completed', '2024-02-22 16:00:00'),
(15, 'Electronics', 640.00, 'completed', '2024-03-18 14:00:00'),
(1, 'Furniture', 1100.00, 'completed', '2024-03-25 11:00:00'),
(3, 'Electronics', 500.00, 'completed', '2024-03-28 09:30:00'),
(6, 'Clothing', 290.00, 'completed', '2024-03-30 15:00:00'),
(10, 'Furniture', 980.00, 'completed', '2024-03-31 12:00:00');

-- INSERT PRODUCTS
INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('iPhone 15', 'Electronics', 999.00, 150),
('Samsung TV 55"', 'Electronics', 1200.00, 80),
('Levi Jeans', 'Clothing', 85.00, 300),
('Nike Sneakers', 'Clothing', 120.00, 200),
('Atomic Habits', 'Books', 20.00, 500),
('The Lean Startup', 'Books', 18.00, 450),
('Office Desk', 'Furniture', 850.00, 40),
('Ergonomic Chair', 'Furniture', 1200.00, 60),
('MacBook Pro', 'Electronics', 2499.00, 75),
('Winter Jacket', 'Clothing', 200.00, 180);