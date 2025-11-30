-- 1. Simple SELECT with WHERE and ORDER BY: recent orders
SELECT o.order_id, o.order_date, c.customer_id, c.first_name || ' ' || c.last_name AS customer_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2021-10-01'
ORDER BY o.order_date DESC
LIMIT 10;

-- 2. Aggregate: total sales per product (SUM) and ORDER BY
SELECT p.product_id, p.product_name, p.category, SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sales DESC
LIMIT 10;

-- 3. AVG revenue per user (ARPU) using aggregate and GROUP BY
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name, 
SUM(oi.quantity * oi.unit_price) as total_spent,
AVG(oi.quantity * oi.unit_price) as avg_order_item_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 4. LEFT JOIN to find customers with no orders
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 5. Subquery: products with above-average sales
SELECT p.product_id, p.product_name, product_sales FROM (
  SELECT p.product_id, p.product_name, SUM(oi.quantity * oi.unit_price) AS product_sales
  FROM products p JOIN order_items oi ON p.product_id = oi.product_id
  GROUP BY p.product_id
) WHERE product_sales > (SELECT AVG(prod_sum) FROM (SELECT SUM(oi2.quantity * oi2.unit_price) AS prod_sum FROM order_items oi2 GROUP BY oi2.product_id));

-- 6. Create view: monthly_sales
CREATE VIEW IF NOT EXISTS monthly_sales AS
SELECT strftime('%Y-%m', o.order_date) AS year_month, SUM(oi.quantity * oi.unit_price) AS sales
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY year_month;

-- 7. Query the view
SELECT * FROM monthly_sales ORDER BY year_month LIMIT 12;

-- 8. Index creation to optimize queries (on orders.order_date)
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);

-- 9. Emulate RIGHT JOIN using LEFT JOIN (SQLite doesn't support RIGHT JOIN directly)
/* RIGHT JOIN equivalent: show orders for which there is no matching customer (hypothetical) - using LEFT JOIN on customers */
SELECT o.order_id, o.customer_id, c.customer_id is NOT NULL AS has_customer
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 10. Complex query: top 5 customers by total spent
SELECT customer_id, customer_name, total_spent FROM (
  SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name, SUM(oi.quantity * oi.unit_price) AS total_spent
  FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id
  ORDER BY total_spent DESC
) LIMIT 5;

