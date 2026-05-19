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
-- Q31 Build a customer RFM (Recency, Frequency, Monetary) analysis: for each customer 
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
-- Q32. Use a CASE statement to assign each customer to a spending tier: Platinum 
-- (>$10,000), Gold ($5,000–$10,000), Silver ($1,000–$5,000), Bronze (<$1,000). Show count of customers per tier.
WITH customer_revenue AS (
    SELECT 
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM orders o
    JOIN order_details od
        ON o.id = od.order_id
    GROUP BY o.customer_id
)

SELECT 
    CASE
        WHEN total_revenue > 10000 THEN 'Platinum'
        WHEN total_revenue BETWEEN 5000 AND 10000 THEN 'Gold'
        WHEN total_revenue BETWEEN 1000 AND 4999.99 THEN 'Silver'
        ELSE 'Bronze'
    END AS spending_tier,

    COUNT(*) AS customer_count

FROM customer_revenue
GROUP BY spending_tier
ORDER BY customer_count DESC;

-- (“The CASE statement categorizes customers into spending tiers based on their total revenue contribution) 
-- Q33. Calculate each employee's share of total company revenue as a percentage. Which employee is responsible for the highest share?
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)),2) AS employee_revenue,
    ROUND(
        (
            SUM(od.unit_price * od.quantity * (1 - od.discount))
            /
            (
                SELECT 
                    SUM(unit_price * quantity * (1 - discount))
                FROM order_details
            )
        ) * 100,
        2
    ) AS revenue_share_percentage
FROM employees e
JOIN orders o
    ON e.id = o.employee_id
JOIN order_details od
    ON o.id = od.order_id
GROUP BY 
    e.id,
    e.first_name,
    e.last_name
ORDER BY revenue_share_percentage DESC;

-- (“I calculated each employee’s revenue using aggregation, 
-- then divided it by total company revenue from a subquery and multiplied 
-- by 100 to obtain percentage contribution.”)
-- Q34. Using a window function, calculate the running total of orders placed each month 
-- across the full dataset. 
WITH monthly_orders AS (
 SELECT 
 YEAR(order_date) AS order_year,
 MONTH(order_date) AS order_month,
COUNT(o.id) AS order_count
FROM orders o
GROUP BY 
YEAR(order_date),
 MONTH(order_date)
  SELECT 
order_year,
order_month,
order_count,
SUM(order_count) OVER (
ORDER BY order_year, order_month
 ROWS UNBOUNDED PRECEDING
  ) AS running_total_orders
FROM monthly_orders
ORDER BY order_year, order_month;
-- Q35. Create a VIEW called vw_order_summary that combines order ID, customer name, 
-- employee name,shipper name,order date,shipped date,days to ship and total order value.
 CREATE VIEW vw_order_summary AS
 SELECT 
 o.id AS order_id,
 c.company AS customer_name,
CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
 s.company AS shipper_name,
DATE(o.order_date) AS order_date,
DATE(o.shipped_date) AS shipped_date,
DATEDIFF(o.shipped_date, o.order_date) AS days_to_ship,

 ROUND(
 SUM(od.unit_price * od.quantity * (1 - od.discount)),
  2
 ) AS total_order_value

FROM orders o

JOIN customers c
 ON o.customer_id = c.id

JOIN employees e
 ON o.employee_id = e.id

JOIN shippers s
 ON o.shipper_id = s.id

JOIN order_details od
 ON o.id = od.order_id

GROUP BY 
 o.id,
c.company,
e.first_name,
e.last_name,
s.company,
o.order_date,
o.shipped_date;
-- Q36. Write a stored procedure called get_customer_report that accepts a customer_id and returns their: total orders,total revenue,average order value and date of last order.
DELIMITER $$
 CREATE PROCEDURE get_customer_report(IN p_customer_id INT)

 BEGIN

SELECT 
 o.customer_id,

COUNT(DISTINCT o.id) AS total_orders,

 ROUND(
     SUM(od.unit_price * od.quantity * (1 - od.discount)),
        2
  ) AS total_revenue,

  ROUND(
   SUM(od.unit_price * od.quantity * (1 - od.discount))
  / COUNT(DISTINCT o.id),
    2
  ) AS average_order_value,

 MAX(o.order_date) AS last_order_date
 FROM orders o
JOIN order_details od   ON o.id = od.order_id
WHERE o.customer_id = p_customer_id
GROUP BY o.customer_id; END $$
DELIMITER ;

-- Q37. Find the top 3 best-selling products per country (based on customer country). This requires a window function and a join chain
 WITH product_sales AS (
 SELECT 
  c.country_region,
 p.product_name,
SUM(od.quantity) AS total_quantity_sold
FROM customers c
 JOIN orders o
 ON c.id = o.customer_id
JOIN order_details od
ON o.id = od.order_id
JOIN products p
 ON od.product_id = p.id
GROUP BY 
c.country_region,
p.product_name
 ),
ranked_products AS (
SELECT 
 country_region,
 product_name,
 total_quantity_sold,
 RANK() OVER (
 PARTITION BY country_region
ORDER BY total_quantity_sold DESC
 ) AS product_rank
FROM product_sales )
SELECT 
country_region,
product_name,
total_quantity_sold,
product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY 
 country_region,
 product_rank;
--  Q38. Identify products that have not been ordered in the last 12 months of the dataset. These are slow moving items.
WITH latest_date AS (

 SELECT 
 MAX(order_date) AS max_order_date
FROM orders
 )

SELECT 
p.id AS product_id,
 p.product_name
FROM products p
WHERE p.id NOT IN (
SELECT DISTINCT od.product_id
 FROM order_details od
 JOIN orders o
 ON od.order_id = o.id
 CROSS JOIN latest_date ld
WHERE o.order_date >= DATE_SUB(ld.max_order_date, INTERVAL 12 MONTH) )
ORDER BY p.product_name;
-- Q39. Using a CTE, calculate the quarter-over-quarter revenue growth rate for each year. 
WITH quarterly_revenue AS (

SELECT 
YEAR(o.order_date) AS order_year,
 QUARTER(o.order_date) AS order_quarter,
 ROUND(
 SUM(od.unit_price * od.quantity * (1 - od.discount)),
    2
  ) AS total_revenue

 FROM orders o

 JOIN order_details od
 ON o.id = od.order_id

 GROUP BY 
 YEAR(o.order_date),
 QUARTER(o.order_date)
)
SELECT 
order_year,
order_quarter,
total_revenue,
LAG(total_revenue, 1) OVER (
  PARTITION BY order_year
 ORDER BY order_quarter
-) AS previous_quarter_revenue,
 ROUND(
 (
 (
 total_revenue LAG(total_revenue, 1) OVER (
 PARTITION BY order_year
 ORDER BY order_quarter
)) /LAG(total_revenue, 1) OVER (
 PARTITION BY order_year
ORDER BY order_quarter
      )
 ) * 100, 2
) AS qoq_growth_rate
FROM quarterly_revenue
 ORDER BY 
 order_year,
 order_quarter;
--  Q40. Detect potentially fraudulent orders: orders where the same customer placed 3 or more orders within a single 7 day window.

SELECT 
 o1.customer_id,
 o1.id AS base_order_id,
 DATE(o1.order_date) AS base_order_date,
COUNT(o2.id) AS orders_in_7_days
 FROM orders o1
 JOIN orders o2
 ON o1.customer_id = o2.customer_id
 AND o2.order_date BETWEEN 
 o1.order_date
 AND DATE_ADD(o1.order_date, INTERVAL 7 DAY)
 GROUP BY 
 o1.customer_id,
 o1.id,
 o1.order_date
 HAVING COUNT(o2.id) >= 3
 ORDER BY 
 orders_in_7_days DESC;
--   Q41. Produce a supplier performance scorecard: for each supplier show total products 
-- supplied, total quantity ordered, total revenue generated, and average days from order to 
-- shipment. 
SELECT 
s.company AS supplier_name,
COUNT(DISTINCT p.id) AS total_products_supplied,
SUM(od.quantity) AS total_quantity_ordered,
ROUND(
SUM(od.unit_price * od.quantity * (1 - od.discount)),
 2  ) AS total_revenue_generated,
ROUND(
AVG(DATEDIFF(o.shipped_date, o.order_date)),
  2
 ) AS avg_days_to_ship

FROM suppliers 
JOIN products p
 ON s.id = p.supplier_ids
 JOIN order_details od
 ON p.id = od.product_id
 JOIN orders o
 ON od.order_id = o.id
 GROUP BY 
 s.id,
 s.company
 ORDER BY total_revenue_generated DESC;
--  Q42. Using a CTE chain (two or more CTEs), identify which sales territory generated the most revenue and which employee in that territory contributed the most.
WITH territory_revenue AS (

    -- Total revenue per territory

    SELECT 
        e.country_region AS sales_territory,

        ROUND(
            SUM(od.unit_price * od.quantity * (1 - od.discount)),
            2
        ) AS territory_total_revenue

    FROM employees e

    JOIN orders o
        ON e.id = o.employee_id

    JOIN order_details od
        ON o.id = od.order_id

    GROUP BY e.country_region
),

employee_territory_revenue AS (

    -- Revenue per employee inside each territory

    SELECT 
        e.country_region AS sales_territory,

        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,

        ROUND(
            SUM(od.unit_price * od.quantity * (1 - od.discount)),
            2
        ) AS employee_revenue

    FROM employees e

    JOIN orders o
        ON e.id = o.employee_id

    JOIN order_details od
        ON o.id = od.order_id

    GROUP BY 
        e.country_region,
        e.first_name,
        e.last_name
),

ranked_employees AS (

    -- Rank employees within each territory

    SELECT 
        sales_territory,
        employee_name,
        employee_revenue,

        RANK() OVER (
            PARTITION BY sales_territory
            ORDER BY employee_revenue DESC
        ) AS employee_rank

    FROM employee_territory_revenue
)

SELECT 
    tr.sales_territory,

    tr.territory_total_revenue,

    re.employee_name,

    re.employee_revenue

FROM territory_revenue tr

JOIN ranked_employees re
    ON tr.sales_territory = re.sales_territory

WHERE re.employee_rank = 1

ORDER BY tr.territory_total_revenue DESC
LIMIT 1;