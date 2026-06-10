-- create database northwind;
 use  northwind;
-- SET FOREIGN_KEY_CHECKS = 0;
--  SET FOREIGN_KEY_CHECKS = 1
-- SELECT * FROM order_details
-- SELECT * FROM products
-- select * from customers
-- select * from orders
 -- DESCRIBE employees
-- show tables
-- TEIR 1
-- Question 1
-- How many total orders are in the database?
-- SELECT COUNT(*) AS total_customers from customers
-- SELECT COUNT(*) AS total_orders from orders

-- (calculate sum of revenue)
-- select sum(unit_price * quantity*(1- discount)) As total_revenue
-- from order_details


-- Question 2
-- list all product names and their unit prices, sorted from most expensive to least expensive.
-- select * from products
-- SELECT  product_name, list_price
--  FROM products
-- order by list_price DESC;

-- Question 3
-- How many products belong to each category? Show category name and product count.

-- SELECT category,
--     COUNT(id) AS product_count
-- FROM products
-- GROUP BY category
-- ORDER BY product_count DESC
-- limit 5;

-- question 4
-- Which countries do Northwind's customers come from? List each country once.

-- SELECT * FROM customers
-- select distinct country_region from customers

-- Question 5
-- What is the total quantity of each product ordered across all orders? Show product name and total quantity.

 -- SELECT * FROM products
-- SELECT * FROM order_details
SELECT 
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN products p 
    ON od.product_id = p.id
GROUP BY p.product_name
ORDER BY total_quantity DESC;

-- SELECT * FROM orders


-- Question6
-- Which 5 customers have placed the most orders? Show company name and order count

-- select
--      c.first_name,
--      count(o.id) AS order_count
--      from orders o
--      join customers c
--      ON o.customer_id = c.id
--      group by c.first_name
--      order by order_count desc
--      limit 5;
     
     -- Question 7
--      What is the average unit price of products in each category?

-- select category,
-- avg(list_price) As product_avg
-- from products
-- group by category
-- limit 10;

-- Question 8
-- List all employees with their full name, title, and the year they were hired.
-- select * from employees

-- select concat(first_name,"  ",last_name) as full_name,job_title
--  from employees


-- Question 9
-- How many orders were placed each year? Show year and order count.
--  select 
--  year(order_date) AS order_year,
--  count(id) AS order_count
--  from orders
--  group by order_year

-- Question 10
-- What is the total revenue generated per product category? 
-- (Revenue = unit_price × quantity × (1 - discount))

-- select * from order_details

-- select p.category,
-- sum(unit_price * quantity * (1 - discount)) As total_revenue
-- from order_details od
-- join products p
-- on od.product_id = p.id
-- group by  p.category

-- Question 11
-- Which shipper has handled the most orders?

-- select * from shippers

-- select s.company,
-- count(o.id) as order_count
-- from orders o
-- join shippers s
-- on o.shipper_id = s.id
-- group by s.company
-- ORDER BY order_count DESC;


-- Question12
-- List all products that are currently discontinued. How many are there?

-- select * from products

-- SELECT 
--     product_name,
--     category,
--     list_price
-- FROM products
-- WHERE discontinued = 0;

-- SELECT 
--     COUNT(*) AS discontinued_count
-- FROM products
-- WHERE discontinued = 0;

