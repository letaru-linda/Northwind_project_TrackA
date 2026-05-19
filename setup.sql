-- TIER 1 — Foundational Queries  (Q1–12) 
-- CREATING DATABASE
CREATE database Northwind;
-- To use the datebase created
USE Northwind;
--  Q1. How many total orders are in the database? 
SHOW tables;
 SELECT COUNT(*) FROM orders;
-- Q2. List all product names and their unit prices, sorted from most expensive to least.
SELECT * FROM products;
SELECT list_price,product_name
 FROM productS
 ORDER BY list_price DESC;
-- Q3. How many products belong to each category? Show category name and product count.
SELECT category,
COUNT(id) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC
-- Q4. Which countries do Northwind's customers come from? List each country once.
SELECT DISTINCT  country_region
FROM customers;
-- Q5. What is the total quantity of each product ordered across all orders? Show product
SELECT 
  p.product_name, 
 SUM(od.quantity) AS total_quantity
FROM products p
JOIN order_details od ON p.id = od.product_id
GROUP BY p.product_name;
-- Q6. Which 5 customers have placed the most orders? Show company name and ordercount. 
SELECT * FROM customers;
 SELECT
 c.company,
count(o.id) AS order_count
from orders o
join customers c
ON o.customer_id = c.id
 group by c.company
order by order_count desc
LIMIT 5;
-- Q7. What is the average unit price of products in each category?
SELECT category,
avg(list_price) As product_avg
from products
group by category
limit 10;
-- Q8. List all employees with their full name, title, and the year they were hired.
SELECT * FROM employees;
 SELECT  concat(first_name,"  ",last_name) as full_name,job_title
FROM employees
--  Q9. How many orders were placed each year? Show year and order count. 
year(order_date) AS order_year,
	  count(id) AS order_count
 from orders
group by order_year
-- Qn 10. What is the total revenue generated per product category?
SELECT * FROM order_details
SELECT p.category,
sum(unit_price * quantity * (1 - discount)) As total_revenue
FROM  order_details od
JOIN products p
 ON od.product_id = p.id
group by  p.category
-- Q11. Which shipper has handled the most orders? 
SELECT * FROM shippers
SELECT s.company,
count(o.id) AS order_count
FROM orders o
JOIN shippers s
ON o.shipper_id = s.id
GROUP BY s.company
ORDER BY order_count DESC;
--  Q12.List all products that are currently discontinued. How many are there? 
SELECT * FROM products
SELECT 
product_name,
category,
list_price
FROM products
WHERE discontinued = 0;
SELECT 
COUNT(*) AS discontinued_count
FROM products
WHERE discontinued = 0;
-- TIER 2 — Intermediate Queries  (Q13–28)
-- Q13. Calculate the total revenue for each customer. Show company name and total.
SELECT 
    c.company,
    SUM(od.quantity * od.unit_price * (1 - od.discount)) AS total_revenue
FROM 
    customers c
JOIN 
    orders o ON c.id = o.customer_id
JOIN 
    order_details od ON o.id = od.order_id
GROUP BY 
    c.id, c.company
ORDER BY 
    total_revenue DESC;


