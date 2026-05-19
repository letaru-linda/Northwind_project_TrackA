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
-- Q13. Calculate the total revenue for each customer. Show company name and total revenue,sorted highest first.
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
--     Q14. Which orders were placed in 1997? Show order_id, customer company name, and 
-- order date.
SELECT 
    o.id AS order_id, 
    c.company AS customer_company_name, 
    o.order_date
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.id
WHERE 
    o.order_date >= '1997-01-01' AND o.order_date <= '1997-12-31'
ORDER BY 
    o.order_date;
--     Q15. Which employees have processed more than 80 orders? Show full name and order 
-- count.
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name, 
    COUNT(o.id) AS order_count
FROM 
    employees e
JOIN 
    orders o ON e.id = o.employee_id
GROUP BY 
    e.id, e.first_name, e.last_name
HAVING 
    order_count > 80
ORDER BY 
    order_count DESC;
--Q16. Find all orders that were shipped AFTER the required date — i.e., they were delivered 
-- late
SELECT 
    o.id AS order_id, 
    o.order_date, 
    o.shipped_date, 
    i.due_date AS required_date
FROM 
    orders o
JOIN 
    invoices i ON o.id = i.order_id
WHERE 
    o.shipped_date > i.due_date
ORDER BY 
    o.shipped_date DESC;
    -- Q17. Which suppliers provide the most products? Show supplier name and product count. 
    SELECT 
    s.company AS supplier_name, 
    COUNT(p.id) AS product_count
FROM 
    suppliers s
JOIN 
    products p ON s.id = p.supplier_ids
GROUP BY 
    s.id, s.company
ORDER BY 
    product_count DESC;
    -- Q18. List all products where the unit price is above the average unit price across all
    SELECT 
    product_name, 
    list_price
FROM 
    products
WHERE 
    list_price > (SELECT AVG(list_price) FROM products)
ORDER BY 
    list_price DESC;
    -- Q19. For each order, calculate the total order value (sum of all line items). Show order_id,customer,orderdate,and total revenue .List the top 10 highest-value orders.
    SELECT 
    o.id AS order_id, 
    c.company AS customer, 
    o.order_date, 
    SUM(od.quantity * od.unit_price * (1 - od.discount)) AS total_value
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.id
JOIN 
    order_details od ON o.id = od.order_id
GROUP BY 
    o.id, c.company, o.order_date
ORDER BY 
    total_value DESC
LIMIT 10;
-- Q20. Which customers have NEVER placed an order? (This reveals at-risk or churned accounts)
SELECT 
    c.id, 
    c.company
FROM 
    customers c
LEFT JOIN 
    orders o ON c.id = o.customer_id
WHERE 
    o.id IS NULL;
-- Q21. Calculate the average number of days between order date and shipped date, per 
-- employee. Who ships the fastest
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    AVG(DATEDIFF(o.shipped_date, o.order_date)) AS avg_days_to_ship
FROM 
    employees e
JOIN 
    orders o ON e.id = o.employee_id
WHERE 
    o.shipped_date IS NOT NULL
GROUP BY 
    e.id, e.first_name, e.last_name
ORDER BY 
    avg_days_to_ship ASC;
    LIMIT 1;
  -- Q22. List all products supplied by companies in Germany. 
  SELECT 
    p.product_name, 
    s.company AS supplier_name,
    s.country_region
FROM 
    products p
JOIN 
    suppliers s ON p.supplier_ids = s.id
WHERE 
    s.country_region = 'Germany';
  -- Q23. For each category, show the most expensive product (name and price). 
  SELECT 
    p1.category, 
    p1.product_name, 
    p1.list_price AS max_price
FROM 
    products p1
INNER JOIN (
    SELECT 
        category, 
        MAX(list_price) AS max_price
    FROM 
        products
    GROUP BY 
        category
) p2 ON p1.category = p2.category AND p1.list_price = p2.max_price
ORDER BY 
    p1.category;
--Q24. How many orders were placed per quarter each year? Show year, quarter, and order 
-- count.
SELECT 
    YEAR(order_date) AS order_year, 
    QUARTER(order_date) AS order_quarter, 
    COUNT(id) AS order_count
FROM 
    orders
GROUP BY 
    order_year, 
    order_quarter
ORDER BY 
    order_year, 
    order_quarter;
  -- Q25. Which customers placed orders in 1996 but NOT in 1997? Use a set-based approach.

SELECT customer_id FROM orders WHERE YEAR(order_date) = 1996
EXCEPT
SELECT customer_id FROM orders WHERE YEAR(order_date) = 1997;
-- Q26. Show each employee's manager (reports_to). List employee full name and their 
-- manager's full name.
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM 
    employees e
LEFT JOIN 
    employees m ON e.reports_to = m.id
ORDER BY 
    manager_name;
--Q27. Calculate total discount given per customer in dollar terms (discount × unit_price × 
-- quantity). Who received the most discount? 
SELECT 
    c.company AS customer_name,
    SUM(od.unit_price * od.quantity * od.discount) AS total_discount_amount
FROM 
    customers c
JOIN 
    orders o ON c.id = o.customer_id
JOIN 
    order_details od ON o.id = od.order_id
GROUP BY 
    c.id, c.company
ORDER BY 
    total_discount_amount DESC;
-- Q28. Identify orders where the total value exceeds $5,000. List order details and customer
SELECT 
    o.id AS order_id, 
    o.order_date, 
    c.company AS customer_name,
    SUM(od.quantity * od.unit_price * (1 - od.discount)) AS total_order_value
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.id
JOIN 
    order_details od ON o.id = od.order_id
GROUP BY 
    o.id, o.order_date, c.company
HAVING 
    total_order_value > 5000
ORDER BY 
    total_order_value DESC;
-- TIER 3 — Advanced Queries  (Q29–42)
-- Q29. Using a CTE, calculate the monthly revenue trend for the entire dataset. Show year,month,total revenue,and month over month change in revenue.
-- (“I used a CTE to first aggregate monthly revenue, then applied the LAG window function to 
-- compare each month’s revenue against the previous month and calculate month-over-month change.)
-- (A CTE (Common Table Expression) is like:a temporary table created only for this query)
-- (LAG() is a window function that lets you look at a value from a previous row without using a self-join.)
 WITH monthly_revenue AS (
 SELECT 
 YEAR(o.order_date) AS order_year,
MONTH(o.order_date) AS order_month,
ROUND(
SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue
FROM orders o
JOIN order_details od
ON o.id = od.order_id
GROUP BY 
YEAR(o.order_date),
MONTH(o.order_date)
SELECT 
 order_year,
 order_month,
 total_revenue,
 ROUND(
 total_revenue - LAG(total_revenue, 1)
 OVER (ORDER BY order_year, order_month),
 2
AS revenue_change
FROM monthly_revenue
ORDER BY order_year, order_month;
(“This query calculates monthly revenue and shows how each month compares to the previous month.”) 
-- Q30. Use RANK() to rank products by total revenue within each category. Show the top 3 
--  ( “I first calculated total revenue per product using aggregation,(CTE) 
-- then applied RANK() partitioned by category to rank products within each category based on revenue,
--  and finally filtered to keep only the top 3 ranks.”)
WITH product_revenue AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM products p
    JOIN order_details od
        ON p.id = od.product_id
    GROUP BY 
        p.category,
        p.product_name
),
ranked_products AS (
    SELECT 
        category,
        product_name,
        total_revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT 
    category,
    product_name,
    total_revenue,
    revenue_rank
FROM ranked_products
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank;
-- Q31. Build a customer RFM (Recency, Frequency, Monetary) analysis: for each customer 
-- calculate (1) days since last order,(2)total number of orders,(3)total revenue.show all the three matrics per customer
-- (Recency: How recently a customer bought
-- Frequency: How often they buy
-- Monetary :How much money they spent)
 WITH customer_revenue AS (
    SELECT 
        o.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(o.id) AS frequency,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS monetary
    FROM orders o
    JOIN order_details od
        ON o.id = od.order_id
    GROUP BY o.customer_id
)
SELECT 
    customer_id,
    1. Recency (days since last order)
    DATEDIFF(CURRENT_DATE, last_order_date) AS recency_days,
    2. Frequency
    frequency,
    3. Monetary value
    ROUND(monetary, 2) AS total_revenue

FROM customer_revenue
ORDER BY monetary DESC;

-- (“I aggregate customer-level data using a CTE to calculate frequency, monetary value, 
-- and last purchase date. Then I compute recency using DATEDIFF between current date and last order date,
--  producing a complete RFM profile per customer.”)
