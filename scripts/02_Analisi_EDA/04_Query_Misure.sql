/*
Data: 15/06/2026
Titolo: 04_Query_Misure.sql

Descrizione: Per qaunto riguarda in questo file andiamo a vedere le magiori misure che soon presenti nel Database.

Aggiornamento:
 

*/

-- Torva il totale di vendite
SELECT
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Trova quanti oggetti sono stati venduti
SELECT
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Trova la media delle vendite
SELECT
    ROUND(AVG(price)::numeric, 0) AS average_price -- In questo modo di approsimizzare alle unità
FROM gold.fact_sales;

-- Trova il numero totale di ordini
SELECT
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT order_number) AS dist_total_orders
FROM gold.fact_sales;
-- SI nota che nel primo caso ci sono 60389 ordini invece di quelli distinti ce ne sono solo 27659
WITH ordini_duplicati AS (
    SELECT order_number
    FROM gold.fact_sales
    GROUP BY order_number
    HAVING COUNT(*) > 1
)
SELECT * FROM gold.fact_sales
WHERE order_number IN (SELECT order_number FROM ordini_duplicati)
ORDER BY order_number; 


-- Trova il numero totale di prodotti
SELECT COUNT(product_key) AS total_products
FROM gold.dim_products;

-- Trova il numero totale di clienti
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- Trova il numero totale di clienti che ha fatto un ordine
SELECT COUNT(DISTINCT customer_key) AS total_customers_order FROM gold.fact_sales;


-- ===============================
--            REPORT
-- ===============================
SELECT
    'Total Sales' AS measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Quantity' AS measure_name,
    SUM(quantity) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Average Price' AS measure_name,
    AVG(price) AS measure_price
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Orders' AS measure_name,
    COUNT(order_number) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Products' AS measure_name,
    COUNT(product_key) AS measure_value
FROM gold.dim_products
UNION ALL
SELECT
    'Total Customers' AS measure_name,
    COUNT(customer_key) AS measure_value
FROM gold.dim_customers;

