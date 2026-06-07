-- =============================================================================
-- Superstore Sales Analysis
-- Topics: Subqueries, CTEs, and Window Functions
-- Dataset: Sample Superstore (9,994 rows, 2014–2017)
-- =============================================================================


-- =============================================================================
-- STEP 1: SETUP DATA
-- =============================================================================

-- 1a. Load the Superstore dataset into superstore_raw
-- (Run this in DuckDB / Python before executing the rest of the script)
--
--   CREATE OR REPLACE TABLE superstore_raw AS
--   SELECT * FROM read_csv_auto('superstore.csv', header=True);


-- 1b. Create normalised tables using SELECT DISTINCT
-- ─────────────────────────────────────────────────

-- customers table
CREATE OR REPLACE TABLE customers AS
SELECT DISTINCT
    "Customer ID"    AS customer_id,
    "Customer Name"  AS customer_name,
    "Segment"        AS segment,
    "Region"         AS region
FROM superstore_raw;

-- products table
CREATE OR REPLACE TABLE products AS
SELECT DISTINCT
    "Product ID"    AS product_id,
    "Product Name"  AS product_name,
    "Category"      AS category,
    "Sub-Category"  AS sub_category
FROM superstore_raw;

-- orders table
CREATE OR REPLACE TABLE orders AS
SELECT
    "Row ID"      AS row_id,
    "Order ID"    AS order_id,
    "Order Date"  AS order_date,
    "Ship Date"   AS ship_date,
    "Ship Mode"   AS ship_mode,
    "Customer ID" AS customer_id,
    "Product ID"  AS product_id,
    "Sales"       AS sales,
    "Quantity"    AS quantity,
    "Discount"    AS discount,
    "Profit"      AS profit
FROM superstore_raw;


-- =============================================================================
-- STEP 2: REQUIRED QUERIES
-- =============================================================================

-- ----------------------------------------------------------------------------
-- Query 1: Find all orders where sales are GREATER THAN the average sales
--          Technique: Subquery
-- ----------------------------------------------------------------------------
SELECT
    order_id,
    customer_id,
    ROUND(sales, 2) AS sales
FROM orders
WHERE sales > (
    SELECT AVG(sales)
    FROM orders
)
ORDER BY sales DESC;

-- ----------------------------------------------------------------------------
-- Query 2: Find the HIGHEST sales order for each customer
--          Technique: Correlated Subquery
-- ----------------------------------------------------------------------------
SELECT
    o.customer_id,
    c.customer_name,
    o.order_id,
    ROUND(o.sales, 2) AS highest_order_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.sales = (
    SELECT MAX(o2.sales)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY o.sales DESC;

-- ----------------------------------------------------------------------------
-- Query 3: Calculate total sales for each customer
--          Technique: CTE
-- ----------------------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT *
FROM customer_sales
ORDER BY total_sales DESC;

-- ----------------------------------------------------------------------------
-- Query 4: Find customers whose total sales are ABOVE AVERAGE
--          Technique: CTE + Subquery
-- ----------------------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_sales
FROM customer_sales
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM customer_sales
)
ORDER BY total_sales DESC;

-- ----------------------------------------------------------------------------
-- Query 5: Rank all customers based on total sales
--          Technique: Window Function – RANK()
-- ----------------------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales
ORDER BY sales_rank;

-- ----------------------------------------------------------------------------
-- Query 6: Assign row numbers to each order within a customer
--          Technique: Window Function – ROW_NUMBER() + PARTITION BY
-- ----------------------------------------------------------------------------
SELECT
    order_id,
    customer_id,
    order_date,
    ROUND(sales, 2) AS sales,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS order_row_num
FROM orders
ORDER BY customer_id, order_row_num;

-- ----------------------------------------------------------------------------
-- Query 7: Display top 3 customers based on total sales
--          Technique: Window Function – DENSE_RANK()
-- ----------------------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
),
ranked AS (
    SELECT
        customer_id,
        customer_name,
        total_sales,
        DENSE_RANK() OVER (ORDER BY total_sales DESC) AS rnk
    FROM customer_sales
)
SELECT
    customer_id,
    customer_name,
    total_sales,
    rnk AS rank
FROM ranked
WHERE rnk <= 3
ORDER BY rnk;


-- =============================================================================
-- STEP 3: FINAL COMBINED QUERY
-- Customer Name | Total Sales | Rank
-- Technique: JOIN + CTE + Window Function
-- =============================================================================
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_name            AS "Customer Name",
    total_sales              AS "Total Sales",
    RANK() OVER (
        ORDER BY total_sales DESC
    )                        AS "Rank"
FROM customer_sales
ORDER BY "Rank";


-- =============================================================================
-- MINI PROJECT: CUSTOMER SALES INSIGHTS
-- =============================================================================

-- ----------------------------------------------------------------------------
-- Mini Q1: Who are the top 5 customers?
-- ----------------------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS rank
FROM customer_sales
ORDER BY total_sales DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- Mini Q2: Who are the bottom 5 customers?
-- ----------------------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_sales,
    RANK() OVER (ORDER BY total_sales ASC) AS rank_from_bottom
FROM customer_sales
ORDER BY total_sales ASC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- Mini Q3: Which customers made only one order?
-- ----------------------------------------------------------------------------
SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
HAVING COUNT(DISTINCT o.order_id) = 1
ORDER BY c.customer_name;

-- ----------------------------------------------------------------------------
-- Mini Q4: Which customers have above-average sales?
-- ----------------------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(o.sales), 2) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_sales
FROM customer_sales
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM customer_sales
)
ORDER BY total_sales DESC;

-- ----------------------------------------------------------------------------
-- Mini Q5: What is the highest order value per customer?
-- ----------------------------------------------------------------------------
SELECT
    c.customer_name,
    o.order_id,
    ROUND(o.sales, 2) AS highest_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.sales = (
    SELECT MAX(o2.sales)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY highest_order_value DESC;

-- =============================================================================
-- END OF SCRIPT
-- =============================================================================
