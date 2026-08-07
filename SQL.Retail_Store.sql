sql
-- =========================================================
-- E-COMMERCE ONLINE RETAIL - SQL BUSINESS ANALYSIS
-- =========================================================

-- =========================================================
-- 1. CREATE AND SELECT DATABASE
-- =========================================================

CREATE DATABASE IF NOT EXISTS ecommerce;

USE ecommerce;


-- =========================================================
-- 2. BASIC PROFILING
-- =========================================================

-- Check table structure
DESCRIBE online_retail;


-- Check sample dates
SELECT
    InvoiceDate
FROM online_retail
LIMIT 20;


-- Total orders
SELECT
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM online_retail;


-- Total customers
SELECT
    COUNT(DISTINCT CustomerID) AS total_customers
FROM online_retail;


-- Date range
SELECT
    MIN(InvoiceDate) AS first_invoice,
    MAX(InvoiceDate) AS last_invoice
FROM online_retail;


-- Total number of rows
SELECT
    COUNT(*) AS total_rows
FROM online_retail;


-- =========================================================
-- 3. TOP 10 PRODUCTS BY QUANTITY SOLD
-- =========================================================

SELECT
    Description,
    SUM(Quantity) AS total_qty

FROM online_retail

WHERE Quantity > 0

GROUP BY Description

ORDER BY total_qty DESC

LIMIT 10;


-- =========================================================
-- 4. REVENUE BY COUNTRY
-- =========================================================

SELECT
    Country,
    ROUND(
        SUM(Quantity * UnitPrice),
        2
    ) AS revenue

FROM online_retail

WHERE Quantity > 0

GROUP BY Country

ORDER BY revenue DESC;


-- =========================================================
-- 5. MONTHLY REVENUE TREND
-- =========================================================

SELECT
    DATE_FORMAT(
        InvoiceDate,
        '%Y-%m'
    ) AS month,

    ROUND(
        SUM(Quantity * UnitPrice),
        2
    ) AS revenue

FROM online_retail

WHERE Quantity > 0

GROUP BY month

ORDER BY month;


-- =========================================================
-- 6. SANITY CHECK FOR DATE
-- =========================================================

-- InvoiceDate is already a DATETIME,
-- so no STR_TO_DATE() is needed.

SELECT
    InvoiceDate

FROM online_retail

LIMIT 20;


-- =========================================================
-- 7. CHECK AVAILABLE MONTHS
-- =========================================================

SELECT DISTINCT
    DATE_FORMAT(
        InvoiceDate,
        '%Y-%m'
    ) AS month

FROM online_retail

ORDER BY month;


-- =========================================================
-- 8. AVERAGE ORDER VALUE
-- =========================================================

SELECT
    ROUND(
        AVG(order_total),
        2
    ) AS avg_order_value

FROM
(
    SELECT
        InvoiceNo,

        SUM(
            Quantity * UnitPrice
        ) AS order_total

    FROM online_retail

    WHERE Quantity > 0

    GROUP BY InvoiceNo

) AS order_summary;


-- =========================================================
-- 9. MONTH-OVER-MONTH REVENUE
-- =========================================================

SELECT
    month,
    revenue,

    LAG(revenue) OVER (
        ORDER BY month
    ) AS prev_month

FROM
(
    SELECT
        DATE_FORMAT(
            InvoiceDate,
            '%Y-%m'
        ) AS month,

        ROUND(
            SUM(Quantity * UnitPrice),
            2
        ) AS revenue

    FROM online_retail

    WHERE Quantity > 0

    GROUP BY month

) AS monthly

ORDER BY month;


-- =========================================================
-- 10. MONTH-OVER-MONTH GROWTH RATE
-- =========================================================

WITH monthly_revenue AS
(
    SELECT
        DATE_FORMAT(
            InvoiceDate,
            '%Y-%m'
        ) AS month,

        ROUND(
            SUM(Quantity * UnitPrice),
            2
        ) AS revenue

    FROM online_retail

    WHERE Quantity > 0

    GROUP BY month
),

monthly_with_previous AS
(
    SELECT
        month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY month
        ) AS prev_month

    FROM monthly_revenue
)

SELECT
    month,
    revenue,
    prev_month,

    ROUND(
        (
            (revenue - prev_month)
            / NULLIF(prev_month, 0)
        ) * 100,
        1
    ) AS growth_pct

FROM monthly_with_previous

ORDER BY month;


-- =========================================================
-- 10. RANK PRODUCTS BY REVENUE
-- =========================================================

SELECT
    Description,

    ROUND(
        SUM(Quantity * UnitPrice),
        2
    ) AS revenue,

    RANK() OVER (
        ORDER BY SUM(Quantity * UnitPrice) DESC
    ) AS product_rank

FROM online_retail

WHERE Quantity > 0

GROUP BY Description

ORDER BY product_rank

LIMIT 20;


-- 11. Customers who spent more than average
WITH customer_spending AS (
    SELECT CustomerID, SUM(Quantity * UnitPrice) as total_spent
    FROM online_retail 
    WHERE Quantity > 0 
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT * 
FROM customer_spending
WHERE total_spent > (
    SELECT AVG(total_spent) 
    FROM customer_spending
)
ORDER BY total_spent DESC;

-- 12 How many customers are one-time, regular, or loyal customers based on how many orders they made?
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Regular'
        ELSE 'Loyal'
    END AS segment,
    COUNT(*) AS num_customers
FROM (
    SELECT 
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count
    FROM online_retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_orders
GROUP BY segment;


SELECT count(*) as total_rows
FROM online_retail;

DESCRIBE online_retail;


-- WHERE → filter individual rows

-- HAVING → filter groups








-- Products frequently bought together
SELECT 
    a.Description AS product_1,
    b.Description AS product_2,
    COUNT(*) AS times_together
FROM online_retail a
JOIN online_retail b
    ON a.InvoiceNo = b.InvoiceNo
    AND a.StockCode < b.StockCode
WHERE a.Quantity > 0
  AND b.Quantity > 0
GROUP BY a.Description, b.Description
HAVING COUNT(*) > 50
ORDER BY times_together DESC
LIMIT 10;










-- Customer retention — repeat purchase rate
SELECT
    ROUND(
        100.0 * COUNT(CASE WHEN order_count > 1 THEN 1 END)
        / COUNT(*),
        2
    ) AS repeat_purchase_rate
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND Quantity > 0
    GROUP BY CustomerID
) AS customer_orders;








-- Revenue by day of week
SELECT
    DAYNAME(InvoiceDate) AS day_of_week,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue
FROM online_retail
WHERE Quantity > 0
GROUP BY DAYOFWEEK(InvoiceDate), DAYNAME(InvoiceDate)
ORDER BY DAYOFWEEK(InvoiceDate);
