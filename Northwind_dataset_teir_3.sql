-- use northwind;

-- Question 29
-- Using a CTE, calculate the monthly revenue trend for the entire dataset. 
-- Show year, month, total revenue, and month-over-month change in revenue.

-- (“I used a CTE to first aggregate monthly revenue, then applied the LAG window function to 
-- compare each month’s revenue against the previous month and calculate month-over-month change.)
-- (A CTE (Common Table Expression) is like:a temporary table created only for this query)
-- (LAG() is a window function that lets you look at a value from a previous row without using a self-join.)

-- WITH monthly_revenue AS (
--     SELECT 
--         YEAR(o.order_date) AS order_year,
--         MONTH(o.order_date) AS order_month,
--         ROUND(
--             SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue
--     FROM orders o
--     JOIN order_details od
--         ON o.id = od.order_id
--     GROUP BY 
--         YEAR(o.order_date),
--         MONTH(o.order_date)
-- )
-- SELECT 
--     order_year,
--     order_month,
--     total_revenue,
--     ROUND(
--         total_revenue - LAG(total_revenue, 1)
--         OVER (ORDER BY order_year, order_month),
--         2
--     ) AS revenue_change
-- FROM monthly_revenue
-- ORDER BY order_year, order_month;
-- (“This query calculates monthly revenue and shows how each month compares to the previous month.”)

-- Question 30
-- Use RANK() to rank products by total revenue within each category. 
-- Show the top 3 revenue-generating products per category.

-- ( “I first calculated total revenue per product using aggregation,(CTE) 
-- then applied RANK() partitioned by category to rank products within each category based on revenue,
--  and finally filtered to keep only the top 3 ranks.”)

-- WITH product_revenue AS (
--     SELECT 
--         p.category,
--         p.product_name,
--         SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
--     FROM products p
--     JOIN order_details od
--         ON p.id = od.product_id
--     GROUP BY 
--         p.category,
--         p.product_name
-- ),
-- ranked_products AS (
--     SELECT 
--         category,
--         product_name,
--         total_revenue,
--         RANK() OVER (
--             PARTITION BY category
--             ORDER BY total_revenue DESC
--         ) AS revenue_rank
--     FROM product_revenue
-- )
-- SELECT 
--     category,
--     product_name,
--     total_revenue,
--     revenue_rank
-- FROM ranked_products
-- WHERE revenue_rank <= 3
-- ORDER BY category, revenue_rank;

-- Question 31
-- Build a customer RFM (Recency, Frequency, Monetary) analysis: for each customer calculate (1) days since last order, 
-- (2) total number of orders, (3) total revenue. Show all three metrics per customer.

-- (Recency: How recently a customer bought
-- Frequency: How often they buy
-- Monetary :How much money they spent)

-- WITH customer_revenue AS (
--     SELECT 
--         o.customer_id,
--         MAX(o.order_date) AS last_order_date,
--         COUNT(o.id) AS frequency,
--         SUM(od.unit_price * od.quantity * (1 - od.discount)) AS monetary
--     FROM orders o
--     JOIN order_details od
--         ON o.id = od.order_id
--     GROUP BY o.customer_id
-- )
-- SELECT 
--     customer_id,
--     -- 1. Recency (days since last order)
--     DATEDIFF(CURRENT_DATE, last_order_date) AS recency_days,
--     -- 2. Frequency
--     frequency,
--     -- 3. Monetary value
--     ROUND(monetary, 2) AS total_revenue

-- FROM customer_revenue
-- ORDER BY monetary DESC;

-- (“I aggregate customer-level data using a CTE to calculate frequency, monetary value, 
-- and last purchase date. Then I compute recency using DATEDIFF between current date and last order date,
--  producing a complete RFM profile per customer.”)

-- Question 32
-- Use a CASE statement to assign each customer to a spending tier: Platinum (>$10,000), 
-- Gold ($5,000–$10,000), Silver ($1,000–$5,000), Bronze (<$1,000).
--  Show count of customers per tier.

-- WITH customer_revenue AS (
--     SELECT 
--         o.customer_id,
--         SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
--     FROM orders o
--     JOIN order_details od
--         ON o.id = od.order_id
--     GROUP BY o.customer_id
-- )

-- SELECT 
--     CASE
--         WHEN total_revenue > 10000 THEN 'Platinum'
--         WHEN total_revenue BETWEEN 5000 AND 10000 THEN 'Gold'
--         WHEN total_revenue BETWEEN 1000 AND 4999.99 THEN 'Silver'
--         ELSE 'Bronze'
--     END AS spending_tier,

--     COUNT(*) AS customer_count

-- FROM customer_revenue
-- GROUP BY spending_tier
-- ORDER BY customer_count DESC;

-- (“The CASE statement categorizes customers into spending tiers based on their total revenue contribution)


-- Question 33
-- Calculate each employee's share of total company revenue as a percentage. 
-- Which employee is responsible for the highest share?


-- SELECT 
--     CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
--     ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)),2) AS employee_revenue,
--     ROUND(
--         (
--             SUM(od.unit_price * od.quantity * (1 - od.discount))
--             /
--             (
--                 SELECT 
--                     SUM(unit_price * quantity * (1 - discount))
--                 FROM order_details
--             )
--         ) * 100,
--         2
--     ) AS revenue_share_percentage
-- FROM employees e
-- JOIN orders o
--     ON e.id = o.employee_id
-- JOIN order_details od
--     ON o.id = od.order_id
-- GROUP BY 
--     e.id,
--     e.first_name,
--     e.last_name
-- ORDER BY revenue_share_percentage DESC;

-- (“I calculated each employee’s revenue using aggregation, 
-- then divided it by total company revenue from a subquery and multiplied 
-- by 100 to obtain percentage contribution.”)

-- QUIESTION 34
-- Using a window function, calculate the running total of orders placed each month across the full dataset.

-- WITH monthly_orders AS (
--     SELECT 
--         YEAR(order_date) AS order_year,
--         MONTH(order_date) AS order_month,
--         COUNT(o.id) AS order_count
--     FROM orders o
--     GROUP BY 
--         YEAR(order_date),
--         MONTH(order_date)
-- )
-- SELECT 
--     order_year,
--     order_month,
--     order_count,
--     SUM(order_count) OVER (
--         ORDER BY order_year, order_month
--         ROWS UNBOUNDED PRECEDING
--     ) AS running_total_orders
-- FROM monthly_orders
-- ORDER BY order_year, order_month;

-- Question 35 
-- Create a VIEW called vw_order_summary that combines order ID, customer name, 
-- employee name, shipper name, order date, shipped date, days to ship, and total order value.

--  CREATE VIEW vw_order_summary AS
-- SELECT 
--     o.id AS order_id,
--     c.company AS customer_name,
--     CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
--     s.company AS shipper_name,
--     DATE(o.order_date) AS order_date,
--     DATE(o.shipped_date) AS shipped_date,
--     DATEDIFF(o.shipped_date, o.order_date) AS days_to_ship,

--     ROUND(
--         SUM(od.unit_price * od.quantity * (1 - od.discount)),
--         2
--     ) AS total_order_value

-- FROM orders o

-- JOIN customers c
--     ON o.customer_id = c.id

-- JOIN employees e
--     ON o.employee_id = e.id

-- JOIN shippers s
--     ON o.shipper_id = s.id

-- JOIN order_details od
--     ON o.id = od.order_id

-- GROUP BY 
--     o.id,
--     c.company,
--     e.first_name,
--     e.last_name,
--     s.company,
--     o.order_date,
--     o.shipped_date;
    
-- Question 36
-- Write a stored procedure called get_customer_report that accepts a customer_id and returns their: total orders, 
-- total revenue, average order value, and date of last order.


-- DELIMITER $$

-- CREATE PROCEDURE get_customer_report(IN p_customer_id INT)

-- BEGIN

--     SELECT 
--         o.customer_id,

--         COUNT(DISTINCT o.id) AS total_orders,

--         ROUND(
--             SUM(od.unit_price * od.quantity * (1 - od.discount)),
--             2
--         ) AS total_revenue,

--         ROUND(
--             SUM(od.unit_price * od.quantity * (1 - od.discount))
--             / COUNT(DISTINCT o.id),
--             2
--         ) AS average_order_value,

--         MAX(o.order_date) AS last_order_date

--     FROM orders o

--     JOIN order_details od
--         ON o.id = od.order_id

--     WHERE o.customer_id = p_customer_id

--     GROUP BY o.customer_id;

-- END $$

-- DELIMITER ;


-- Question 37
-- Find the top 3 best-selling products per country (based on customer country). 
-- This requires a window function and a JOIN chain.

-- WITH product_sales AS (

--     SELECT 
--         c.country_region,
--         p.product_name,
--         SUM(od.quantity) AS total_quantity_sold
--     FROM customers c
--     JOIN orders o
--         ON c.id = o.customer_id
--     JOIN order_details od
--         ON o.id = od.order_id
--     JOIN products p
--         ON od.product_id = p.id
--     GROUP BY 
--         c.country_region,
--         p.product_name
-- ),
-- ranked_products AS (
--     SELECT 
--         country_region,
--         product_name,
--         total_quantity_sold,
--         RANK() OVER (
--             PARTITION BY country_region
--             ORDER BY total_quantity_sold DESC
--         ) AS product_rank

--     FROM product_sales
-- )

-- SELECT 
--     country_region,
--     product_name,
--     total_quantity_sold,
--     product_rank

-- FROM ranked_products

-- WHERE product_rank <= 3

-- ORDER BY 
--     country_region,
--     product_rank;

-- Question 38
-- Identify products that have not been ordered in the last 12 months of the dataset. 
-- These are slow-moving items.

-- WITH latest_date AS (

--     SELECT 
--         MAX(order_date) AS max_order_date
--     FROM orders
-- )

-- SELECT 
--     p.id AS product_id,
--     p.product_name

-- FROM products p

-- WHERE p.id NOT IN (

--     SELECT DISTINCT od.product_id

--     FROM order_details od

--     JOIN orders o
--         ON od.order_id = o.id

--     CROSS JOIN latest_date ld

--     WHERE o.order_date >= DATE_SUB(ld.max_order_date, INTERVAL 12 MONTH)
-- )

-- ORDER BY p.product_name;

-- Question 39

-- Using a CTE, calculate the quarter-over-quarter revenue growth rate for each year.


-- WITH quarterly_revenue AS (

--     SELECT 
--         YEAR(o.order_date) AS order_year,

--         QUARTER(o.order_date) AS order_quarter,

--         ROUND(
--             SUM(od.unit_price * od.quantity * (1 - od.discount)),
--             2
--         ) AS total_revenue

--     FROM orders o

--     JOIN order_details od
--         ON o.id = od.order_id

--     GROUP BY 
--         YEAR(o.order_date),
--         QUARTER(o.order_date)
-- )

-- SELECT 
--     order_year,
--     order_quarter,
--     total_revenue,

--     LAG(total_revenue, 1) OVER (
--         PARTITION BY order_year
--         ORDER BY order_quarter
--     ) AS previous_quarter_revenue,

--     ROUND(
--         (
--             (
--                 total_revenue -
--                 LAG(total_revenue, 1) OVER (
--                     PARTITION BY order_year
--                     ORDER BY order_quarter
--                 )
--             )
--             /
--             LAG(total_revenue, 1) OVER (
--                 PARTITION BY order_year
--                 ORDER BY order_quarter
--             )
--         ) * 100,
--         2
--     ) AS qoq_growth_rate

-- FROM quarterly_revenue

-- ORDER BY 
--     order_year,
--     order_quarter;

-- Question 40
-- Detect potentially fraudulent orders: orders where the same customer placed 3 
-- or more orders within a single 7-day window.

-- SELECT 
--     o1.customer_id,

--     o1.id AS base_order_id,

--     DATE(o1.order_date) AS base_order_date,

--     COUNT(o2.id) AS orders_in_7_days

-- FROM orders o1

-- JOIN orders o2
--     ON o1.customer_id = o2.customer_id

--     AND o2.order_date BETWEEN 
--         o1.order_date
--         AND DATE_ADD(o1.order_date, INTERVAL 7 DAY)

-- GROUP BY 
--     o1.customer_id,
--     o1.id,
--     o1.order_date

-- HAVING COUNT(o2.id) >= 3

-- ORDER BY 
--     orders_in_7_days DESC;
    
    
-- 	Question 41
--     Produce a supplier performance scorecard: for each supplier show total products supplied, 
--     total quantity ordered, total revenue generated, and average days from order to shipment.

-- SELECT 
--     s.company AS supplier_name,

--     COUNT(DISTINCT p.id) AS total_products_supplied,

--     SUM(od.quantity) AS total_quantity_ordered,

--     ROUND(
--         SUM(od.unit_price * od.quantity * (1 - od.discount)),
--         2
--     ) AS total_revenue_generated,

--     ROUND(
--         AVG(DATEDIFF(o.shipped_date, o.order_date)),
--         2
--     ) AS avg_days_to_ship

-- FROM suppliers s

-- JOIN products p
--     ON s.id = p.supplier_ids
-- JOIN order_details od
--     ON p.id = od.product_id

-- JOIN orders o
--     ON od.order_id = o.id

-- GROUP BY 
--     s.id,
--     s.company

-- ORDER BY total_revenue_generated DESC;


-- Question 42
--     Using a CTE chain (two or more CTEs), identify which sales territory generated the most revenue 
--     and which employee in that territory contributed the most.
-- 💡 CTE1: revenue per territory. CTE2: revenue per employee per territory. Join them.

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