-- E-Commerce Sales Database
-- Answers: Section A to Section E (Q1 to Q27)


-- ============================================================
-- SECTION A: SQL Basics
-- ============================================================

-- Q1. display all columns and rows from customers table
SELECT * FROM customers;


-- Q2. retrieve only first_name, last_name, and city of all customers
SELECT first_name, last_name, city
FROM customers;


-- Q3. list all unique categories from products table
SELECT DISTINCT category
FROM products;


-- Q4. Primary Keys of each table:
-- customers  -> customer_id
-- products   -> product_id
-- orders     -> order_id
-- order_items -> item_id
--
-- A Primary Key must be UNIQUE so that every row can be identified separately.
-- It must be NOT NULL because if the value is null, we can't uniquely identify that row.
-- Without a primary key, we wouldn't be able to tell rows apart or create foreign key references.


-- Q5. Constraints on email column in customers table:
-- UNIQUE - no two customers can have the same email
-- NOT NULL - email cannot be left empty
--
-- If we try to insert a duplicate email, MySQL will throw an error like:
-- ERROR 1062 (23000): Duplicate entry 'aarav.s@email.com' for key 'email'
-- The row will not be inserted.


-- Q6. inserting a product with negative unit_price to see what happens
INSERT INTO products VALUES (209, 'Test Product', 'Electronics', 'TestBrand', -50, 100);
-- this will throw an error because of the CHECK constraint: unit_price > 0
-- MySQL Error: ERROR 3819 (HY000): Check constraint 'products_chk_1' is violated.
-- the CHECK (unit_price > 0) constraint prevents any negative or zero price from being inserted.


-- ============================================================
-- SECTION B: Filtering & Optimization
-- ============================================================

-- Q7. retrieve all orders with status = 'Delivered'
SELECT *
FROM orders
WHERE status = 'Delivered';


-- Q8. products in Electronics category with unit_price > 2000
SELECT *
FROM products
WHERE category = 'Electronics'
  AND unit_price > 2000;


-- Q9. customers who joined in 2024 and belong to Maharashtra
SELECT *
FROM customers
WHERE join_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND state = 'Maharashtra';


-- Q10. orders placed between 2024-08-10 and 2024-08-25 that are not cancelled
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-08-10' AND '2024-08-25'
  AND status != 'Cancelled';


-- Q11. what idx_orders_date does:
-- idx_orders_date is an index created on the order_date column of the orders table.
-- without an index, MySQL scans every row to find matching dates (full table scan).
-- with this index, MySQL can directly jump to the relevant rows, making date-based queries much faster.
-- this is especially helpful when the table has millions of rows.
--
-- sample query that benefits from this index:
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-08-01' AND '2024-08-31';


-- Q12. would the index be used for YEAR(join_date) = 2024?
-- No, it would not. When we wrap a column inside a function like YEAR(), MySQL cannot use the index
-- because the index is built on the raw column value, not the result of the function.
-- This makes the query non-SARGable (Search ARGument Able).
--
-- rewritten as SARGable (index-friendly):
SELECT *
FROM customers
WHERE join_date BETWEEN '2024-01-01' AND '2024-12-31';
-- now MySQL can use the index directly on join_date values.


-- ============================================================
-- SECTION C: Aggregation
-- ============================================================

-- Q13. total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;


-- Q14. total revenue from Delivered orders
SELECT SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'Delivered';


-- Q15. average unit_price of products in each category
SELECT category, ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category;


-- Q16. count of orders and total revenue per status, sorted by revenue descending
SELECT status,
       COUNT(*) AS order_count,
       SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;


-- Q17. most expensive and cheapest product in each category
SELECT category,
       MAX(unit_price) AS most_expensive,
       MIN(unit_price) AS cheapest
FROM products
GROUP BY category;


-- Q18. categories where average unit_price is greater than 2000
SELECT category, ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(unit_price) > 2000;


-- ============================================================
-- SECTION D: Joins & Relationships
-- ============================================================

-- Q19. INNER JOIN - orders with customer names
SELECT o.order_id,
       o.order_date,
       c.first_name,
       c.last_name,
       o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;


-- Q20. LEFT JOIN - all customers with their orders (even if they have no orders)
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       o.order_id,
       o.order_date,
       o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;


-- Q21. 3 table JOIN - order items with product details
SELECT o.order_id,
       p.product_name,
       oi.quantity,
       oi.unit_price,
       oi.discount_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;


-- Q22. difference between LEFT JOIN and RIGHT JOIN:
-- LEFT JOIN returns all rows from the left table and matching rows from the right table.
-- if there is no match, right side columns come as NULL.
--
-- RIGHT JOIN returns all rows from the right table and matching rows from the left table.
-- if there is no match, left side columns come as NULL.
--
-- example from this schema:
-- LEFT JOIN: all customers will show up even if they haven't placed any orders
SELECT c.first_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- RIGHT JOIN: all orders will show up even if somehow the customer record is missing
SELECT c.first_name, o.order_id
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- FULL OUTER JOIN is used when we want all rows from both tables regardless of whether
-- there's a match or not. In MySQL, we simulate it using UNION of LEFT and RIGHT JOIN.
-- useful when we want to find unmatched rows on both sides at the same time.


-- Q23. Foreign Key relationships:
-- orders.customer_id -> references customers.customer_id
-- order_items.order_id -> references orders.order_id
-- order_items.product_id -> references products.product_id
--
-- if we try to insert an order with customer_id = 999 which doesn't exist in customers:
INSERT INTO orders VALUES (1011, 999, '2024-09-01', 'Pending', 500.00);
-- MySQL will throw a foreign key constraint error:
-- ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
-- the row will not be inserted because 999 doesn't exist in the customers table.


-- ============================================================
-- SECTION E: Advanced Concepts
-- ============================================================

-- Q24. classify products into price tiers using CASE
SELECT product_name,
       unit_price,
       CASE
           WHEN unit_price < 1000              THEN 'Budget'
           WHEN unit_price BETWEEN 1000 AND 3000 THEN 'Mid-Range'
           WHEN unit_price > 3000              THEN 'Premium'
       END AS price_tier
FROM products;


-- Q25. count of Delivered vs Not Delivered orders in a single row
SELECT
    SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN status != 'Delivered' THEN 1 ELSE 0 END) AS not_delivered
FROM orders;


-- Q26. ACID Properties explained with a real-world example (bank transfer):
--
-- A - Atomicity:
-- all steps in a transaction either happen completely or not at all.
-- example: in a bank transfer, if money is debited from account A but the credit to account B fails,
-- the whole transaction is rolled back. money doesn't just disappear.
--
-- C - Consistency:
-- the database must always move from one valid state to another valid state.
-- example: total money in the bank before and after a transfer should remain the same.
-- if account A has 1000 and sends 500 to B, then A should have 500 and B should gain 500.
--
-- I - Isolation:
-- two transactions happening at the same time should not interfere with each other.
-- example: if two people are transferring money simultaneously, one transaction should not
-- read incomplete or uncommitted data from the other transaction.
--
-- D - Durability:
-- once a transaction is committed, the changes are permanent even if the system crashes.
-- example: after a successful bank transfer, even if the server restarts, the updated balances
-- should still be there when it comes back up.


-- Q27. complete transaction - insert order, order items, update stock, with rollback on failure
START TRANSACTION;

-- step 1: insert a new order
INSERT INTO orders VALUES (1011, 102, CURDATE(), 'Pending', 1598.00);

-- step 2: insert two order items for that order
INSERT INTO order_items VALUES (5016, 1011, 206, 1, 1299.00, 0);
INSERT INTO order_items VALUES (5017, 1011, 208, 1,  599.00, 0);

-- step 3: update stock for the purchased products
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 206;
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 208;

-- if all steps succeeded, commit the transaction
COMMIT;

-- if any step above fails, run this instead to undo everything:
-- ROLLBACK;
