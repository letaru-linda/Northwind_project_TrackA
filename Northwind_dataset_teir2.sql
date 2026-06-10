use northwind;

-- TEIR 2
-- QUESTION 13
-- Calculate the total revenue for each customer. Show company name and total revenue, sorted highest first.

-- SELECT * from customers
-- SELECT * from order_details
-- SELECT * from orders

-- SELECT c.company,
-- SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
-- FROM customers c
-- JOIN orders o
-- ON c.id = o.customer_id
-- JOIN order_details od
-- ON o.id = od.order_id
-- GROUP BY c.company
-- ORDER BY total_revenue DESC;

-- Question 14
-- Which orders were placed in 1997? Show order_id, customer company name, and order date.

-- select o.id, c.company,
-- year (o.order_date) as Year 
-- from orders o
-- join customers c
-- on c.id = o.customer_id 
-- where year(o.order_date) = 2006;

-- Question 15
-- Which employees have processed more than 80 orders? Show full name and order count.
-- (since number of orders is 48 i reduced the order count to 10)
-- select * from employees
-- select * from orders

-- SELECT 
--     CONCAT(e.first_name, ' ', e.last_name) AS full_name,
--     COUNT(o.id) AS order_count 
-- FROM employees e
-- JOIN orders o
--     ON e.id = o.employee_id
-- GROUP BY e.id
-- HAVING order_count > 8;

-- Question 16
-- Find all orders that were shipped AFTER the required date — i.e., they were delivered late. no column for required date

-- (“The query retrieves orders that took more than 7 days to ship.
--  I used DATEDIFF to calculate shipping duration, DATE to remove time from datetime fields, 
--  and filtered the results using a WHERE clause.”)

-- SELECT 
--     id AS order_id,
--     DATE(order_date) AS order_date,
--     DATE(shipped_date) AS shipped_date,
--     DATEDIFF(shipped_date, order_date) AS late_delivery
-- FROM orders
-- WHERE DATEDIFF(shipped_date, order_date) > 7;


-- Question 17
-- Which suppliers provide the most products? Show supplier name and product count.

-- select * from suppliers 
-- select * from products 

-- select s.company,
-- count(p.id) AS product_count
-- from suppliers s
-- join products p
-- on p.supplier_ids = s.id
-- group by s.company
-- order by product_count desc; 

-- Question 18
-- List all products where the unit price is above the average unit price across all products.

-- SELECT ROUND(AVG(list_price), 1) AS avg_price FROM products

-- SELECT 
--     product_name,
--     list_price,
--     (SELECT ROUND(AVG(list_price), 1) FROM products) AS avg_price
-- FROM products
-- WHERE list_price > (
--     SELECT AVG(list_price)
--     FROM products
-- );


-- Question 19
-- For each order, calculate the total order value (sum of all line items). 
-- Show order_id, customer, order date, and total value. List the top 10 highest-value orders.


-- SELECT 
--     o.id AS order_id,
--     c.company AS customer_name,
--     DATE(o.order_date) AS order_date,
--     ROUND(
--         SUM(od.unit_price * od.quantity * (1 - od.discount)),
--         2
--     ) AS total_order_value
-- FROM orders o
-- JOIN customers c
--     ON o.customer_id = c.id
-- JOIN order_details od
--     ON o.id = od.order_id
-- GROUP BY od.id, c.company, o.order_date
-- ORDER BY total_order_value DESC
-- LIMIT 10;

-- Question20
-- Which customers have NEVER placed an order? (This reveals at-risk or churned accounts.)
-- 💡 LEFT JOIN customers to orders, filter WHERE order_id IS NULL.

-- SELECT 
--     c.id,
--     c.company
-- FROM customers c
-- LEFT JOIN orders o
--     ON c.id = o.customer_id
-- WHERE o.id IS NULL;

-- Question 21


-- Question 22
-- Calculate the average number of days between order date and shipped date, per employee. Who ships the fastest?

-- SELECT 
--     p.product_name,
--     s.company AS supplier,
--     s.country_region
-- FROM products p
-- JOIN suppliers s
--     ON p.supplier_ids = s.id
-- WHERE s.country_region = 'USA';

-- SELECT* FROM suppliers


-- Question 24
-- How many orders were placed per quarter each year? Show year, quarter, and order count.



-- SELECT 
--     YEAR(order_date) AS order_year,
--     QUARTER(order_date) AS order_quarter,
--     COUNT(o.id) AS order_count
-- FROM orders o
-- GROUP BY 
--     YEAR(order_date),
--     QUARTER(order_date)
-- ORDER BY 
--     order_year,
--     order_quarter;


-- Question 26
-- Show each employee's manager (reports_to). List employee full name and their manager's full name.

NO MANAGER COLUMN
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id;