/*
Data: 15/06/2026
Titolo: 05_Query_Magnitudo.sql

Descrizione: In questo file andiamo a vedere le query un poco più generiche però delineando delle linee guida,
 che devono essere determinate proprio dalle precedenti informazioni ottenute andando a cercare le miusre e le 
 dimensioni.

Aggiornamento:
 

*/

-- Trova il numero totale di clienti per ogni nazione
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Trova il numero totale di clienti per genere (sesso)
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Trova il numero totale di prodotti per ogni categoria
SELECT
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Qual è il costo medio per ogni categoria di prodotto?
SELECT
    category,
    ROUND(AVG(cost)::numeric, 2) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Qual è il ricavo (revenue) totale generato da ciascuna categoria?
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Qual è il ricavo (revenue) totale generato da ogni singolo cliente?
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
INNER JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Qual è la distribuzione degli articoli venduti nelle diverse nazioni?
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;
