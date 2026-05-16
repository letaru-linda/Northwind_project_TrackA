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


