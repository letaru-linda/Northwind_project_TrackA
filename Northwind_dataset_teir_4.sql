Use Northwind;

-- Q43. Build the monthly sales report: for each month show total orders, total revenue, 
-- average order value, and number of unique customers. Identify the single best performing month.

-- I joined the orders and order_details tables using order_id, grouped the data by year and month using 
-- GROUP BY, then used aggregate functions  to calculate total orders, total revenue, average order value, and unique customers. 
-- Results are sorted from the highest revenue month to the lowest revenue month to quickly identify peak sales periods.

-- SELECT
--     YEAR(o.order_date) AS order_year,
--     MONTH(o.order_date) AS order_month,

--     COUNT(DISTINCT o.id) AS total_orders,

--     ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue,

--     ROUND(
--         SUM(od.quantity * od.unit_price) 
--         / COUNT(DISTINCT o.id),
--     2) AS average_order_value,

--     COUNT(DISTINCT o.customer_id) AS unique_customers

-- FROM orders o
-- JOIN order_details od
--     ON o.id = od.order_id

-- GROUP BY 
--     YEAR(o.order_date),
--     MONTH(o.order_date)

-- ORDER BY total_revenue DESC;

-- 44. Produce a product reorder report: list all products where the units_in_stock is less than 
--  the reorder_level AND the product is not discontinued. Flag urgency as 'Critical' (stock = 0), 
-- 'Low' (stock < reorder), or 'OK'. 
--  CASE on units_in_stock vs reorder_level. Filter discontinued = 0. (No value output, rechecked)

-- ( Dataset doesnt contain unit_in_stock, that is real inventory quantities, 
-- so I adapted the reorder analysis using reorder thresholds and target stock levels instead.)

-- SELECT 
--     id AS product_id,

--     product_name,

--     reorder_level,

--     target_level,

--     minimum_reorder_quantity,

--     CASE
--         WHEN reorder_level = 0 THEN 'Critical'

--         WHEN reorder_level < target_level THEN 'Low'

--         ELSE 'OK'
--     END AS urgency_status

-- FROM products

-- WHERE discontinued = 0

-- ORDER BY reorder_level ASC;

-- DESCRIBE products;

-- -- Question 45
-- -- Segment customers into three groups by order frequency: Loyal (6+ orders), 
-- -- Regular (3–5 orders), Occasional (1–2 orders). 
-- -- Show how much total revenue each segment generates.

-- ( i Counts how many orders each customer placed
-- Segments customers into groups
-- Calculates how much revenue each group generated)

--  WITH customer_orders AS (
--     SELECT 
--        o.customer_id,
--      COUNT(DISTINCT o.id) AS total_orders,
--  ROUND ( SUM(od.unit_price * od.quantity * (1 - od.discount)),2) AS total_revenue
--     FROM orders o
--    JOIN order_details od
--       ON o.id = od.order_id
--     GROUP BY o.customer_id
-- ),
-- customer_segments AS (
--     SELECT 
--         customer_id,
--         total_orders,
--         total_revenue,
--         CASE
--             WHEN total_orders >= 6 THEN 'Loyal'
--             WHEN total_orders BETWEEN 3 AND 5 THEN 'Regular'
--             ELSE 'Occasional'
--         END AS customer_segment
--     FROM customer_orders
--     )
-- SELECT 
-- customer_segment,
-- COUNT(customer_id) AS total_customers,
-- ROUND (SUM(total_revenue),  2 ) AS segment_total_revenue
-- FROM customer_segments
-- GROUP BY customer_segment
-- ORDER BY segment_total_revenue DESC;

-- Question 46
-- Build a geographic revenue heatmap query: for each country, 
-- show total customers, total orders, total revenue, and average order value. Sort by total revenue.
-- 💡 JOIN customers → orders → order_details. GROUP BY customers.country.

-- (I creates a geographic revenue report For each country, WHICH shows total customers, total orders,total revenue ,average order value,
-- the i join the customers → orders → order_details table to determine the country with the most revenue,
--  although the dataset has just one region)

-- SELECT 
--     c.country_region,
--     COUNT(DISTINCT c.id) AS total_customers,
--     COUNT(DISTINCT o.id) AS total_orders,
--     ROUND(
--         SUM(od.unit_price * od.quantity * (1 - od.discount)),2) AS total_revenue,
--     ROUND(
--         SUM(od.unit_price * od.quantity * (1 - od.discount))
--         / COUNT(DISTINCT o.id),2) AS average_order_value
-- FROM customers c
-- JOIN orders o
--     ON c.id = o.customer_id
-- JOIN order_details od
--     ON o.id = od.order_id
-- GROUP BY c.country_region
-- ORDER BY total_revenue DESC;


-- Question 47
-- Which product categories show declining revenue year-over-year? Calculate revenue per category per year and 
-- flag categories where the most recent year is lower than the previous year.
-- 💡 Use LAG() within a CTE to compare years. Flag with CASE.

-- (“The dataset only contained one year of revenue data for those categories, 
-- so the LAG function had no previous year record available for comparison, reason for null previous year”)

-- WITH category_revenue AS (
--     SELECT 
--         p.category,

--         YEAR(o.order_date) AS order_year,
--         ROUND(
--             SUM(od.unit_price * od.quantity * (1 - od.discount)),
--             2
--         ) AS total_revenue
--     FROM products p
--     JOIN order_details od
--         ON p.id = od.product_id
--     JOIN orders o
--         ON od.order_id = o.id
--     GROUP BY 
--         p.category,
--         YEAR(o.order_date)
-- ),

-- revenue_comparison AS (
--     SELECT 
--         category,
--         order_year,
--         total_revenue,
--         LAG(total_revenue, 1) OVER (
--             PARTITION BY category
--             ORDER BY order_year
--         ) AS previous_year_revenue
--     FROM category_revenue
-- )
-- SELECT 
--     category,
--     order_year,
--     total_revenue,
--     previous_year_revenue,
--     CASE
--         WHEN total_revenue < previous_year_revenue
--             THEN 'Declining'
--         ELSE 'Growing/Stable'
--     END AS revenue_trend
-- FROM revenue_comparison
-- ORDER BY 
--     category,
--     order_year;

-- Question 48
-- Compute the Employee Performance Dashboard in one query: employee name, total 
-- orders processed, total revenue managed, average order value, on-time delivery rate, and 
-- revenue rank among all employees. 
--  Combine multiple aggregates with a RANK() window function.

-- (I aggregated employee-level sales data, 
-- calculated performance metrics including on-time delivery rate, and used a 
-- rank window function to rank employees by total revenue.)

-- WITH employee_metrics AS (
--     SELECT 
--         e.id AS employee_id,
--         CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
--         COUNT(DISTINCT o.id) AS total_orders,
--         ROUND(SUM(od.quantity * od.unit_price *( 1- od.discount)),2 )AS total_revenue,
--         ROUND (SUM(od.quantity * od.unit_price *(1- od.discount)),2 / COUNT(DISTINCT o.id)) AS avg_order_value,

--         SUM(
--             CASE 
--                 WHEN o.shipped_date <= DATE_ADD(o.order_date, INTERVAL 3 DAY)
--                 THEN 1 
--                 ELSE 0 
--             END
--         ) * 1.0 / COUNT(DISTINCT o.id) AS on_time_rate

--     FROM employees e
--     JOIN orders o ON e.id = o.employee_id
--     JOIN order_details od ON o.id = od.order_id
--     GROUP BY e.id, employee_name
-- )

-- SELECT *,
--     RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
-- FROM employee_metrics;


-- 49.Identify cross-selling opportunities: find pairs of products that are frequently ordered 
-- together in the same order. Show the product pair and how many times they co-occur.

-- (I performed a self-join on the order details table to match products within the same order, 
-- avoided duplicates using a product ID condition, and 
-- counted how often each product pair co-occurs.)

-- SELECT 
-- od1.product_id AS product_1,
-- od2.product_id AS product_2,
-- COUNT(*) AS times_ordered_together
-- FROM order_details od1
-- JOIN order_details od2
--     ON od1.order_id = od2.order_id
--     AND od1.product_id < od2.product_id
-- GROUP BY 
--     od1.product_id,
--     od2.product_id
-- ORDER BY times_ordered_together DESC;

--  50.CEO Summary Report — Produce a single result set of 8 key business metrics in one 
-- query using UNION ALL: (1) Total Revenue, (2) Total Orders, (3) Best Selling Product, (4) 
-- Top Customer by Revenue, (5) Top Employee by Revenue, (6) Average Order Value, (7) 
-- On-Time Delivery Rate %, (8) Total Customers. 
-- 8 single-row subqueries joined with UNION ALL. Two columns: metric_name, metric_value.

-- (This query builds a CEO-level summary dashboard
-- It combines 8 key business metrics into one result using UNION ALL.
-- Each row is a separate KPI (Key Performance Indicator).)

SELECT 
    'Total Revenue' AS metric_name,
    ROUND(
        SUM(od.unit_price * od.quantity * (1 - od.discount)),
        2
    ) AS metric_value

FROM order_details od

UNION ALL

SELECT 
    'Total Orders',
    COUNT(DISTINCT id)
FROM orders

UNION ALL
SELECT *
FROM (

    SELECT 
        'Best Selling Product' AS metric_name,
        p.product_name AS metric_value
    FROM products p
    JOIN order_details od
        ON p.id = od.product_id
    GROUP BY p.product_name
    ORDER BY SUM(od.quantity) DESC
    LIMIT 1
) AS best_selling_product

UNION ALL

SELECT *
FROM (
    SELECT 
        'Top Customer by Revenue' AS metric_name,
        c.company AS metric_value
    FROM customers c
    JOIN orders o
        ON c.id = o.customer_id
    JOIN order_details od
        ON o.id = od.order_id
    GROUP BY c.company
    ORDER BY 
        SUM(od.unit_price * od.quantity * (1 - od.discount)) DESC
    LIMIT 1
) AS top_customer
UNION ALL

SELECT *
FROM (

    SELECT 
        'Top Employee by Revenue' AS metric_name,
        CONCAT(e.first_name, ' ', e.last_name) AS metric_value
    FROM employees e
    JOIN orders o
        ON e.id = o.employee_id
    JOIN order_details od
        ON o.id = od.order_id
    GROUP BY 
        e.first_name,
        e.last_name
    ORDER BY 
        SUM(od.unit_price * od.quantity * (1 - od.discount)) DESC
    LIMIT 1
) AS top_employee
UNION ALL

SELECT 
    'Average Order Value',
    ROUND(
        SUM(od.unit_price * od.quantity * (1 - od.discount))
        / COUNT(DISTINCT o.id),
        2
    )
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
UNION ALL
SELECT 
    'On-Time Delivery Rate %',
    ROUND(
        (
            SUM(
                CASE
                    WHEN shipped_date <= DATE_ADD(order_date, INTERVAL 3 DAY)
                    THEN 1
                    ELSE 0
                END
            ) * 100.0
        ) / COUNT(*),
        2
    )

FROM orders
UNION ALL
SELECT 
    'Total Customers',
    COUNT(*)
FROM customers;