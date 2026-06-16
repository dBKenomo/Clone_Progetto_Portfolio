/*
Data: 16/06/2026
Titolo: 11_Query_segmentazione.sql

Descrizione: 
    Quando si crea una query per fare la segmentazione vuole dire che andiamo a ragruppare i dati in un specifico
    range in questo modo ci permette di vedere le cose in modo migliore.

Aggiornamento:
 

*/

-- Segmenta i prodotti secondo il loro livello di costo e conta quanti prodotti sono per ogni segmento
WITH product_segments AS(
SELECT
    product_key,
    product_name,
    cost,
    CASE WHEN cost < 100 THEN 'Below 100 Cost'
         WHEN cost BETWEEN 100 AND 500 THEN '100-500 Cost'
         WHEN cost BETWEEN 500 AND 1000 THEN '500-1000 Cost'
         ELSE 'Above 1000 Cost'
    END AS cost_range
FROM gold.dim_products)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


/*
    Segmenta i customers in tre segmenti seguendo il criterio che dipende dalla loro spesa:
        - VIP: presente da 12 mesi e spesa maggiore di 5000.
        - Regular: presente da 12 mesi e spesa minore o uguale a 5000.
        - New: presente da meno di 12 mesi.
    Infine trova il numero totale di custommers per ogni guppo.

*/
WITH customer_spending AS(
SELECT
    c.customer_key,
    SUM(f.sales_amount) AS total_spending,
    MIN(f.order_date) AS first_order,
    MAX(f.order_date) AS last_order,
    (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date)))*12) +
    EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key)
SELECT
    CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
         WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
         ELSE 'New'
    END AS customer_segment,
    COUNT(customer_key) AS total_customers
FROM customer_spending
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- Alternativa
WITH customer_spending AS(
SELECT
    c.customer_key,
    SUM(f.sales_amount) AS total_spending,
    MIN(f.order_date) AS first_order,
    MAX(f.order_date) AS last_order,
    (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date)))*12) +
    EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key)
SELECT  -- Query principale
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM(
    SELECT
        customer_key,
        CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending 
    ) t
GROUP BY customer_segment
ORDER BY total_customers DESC;
