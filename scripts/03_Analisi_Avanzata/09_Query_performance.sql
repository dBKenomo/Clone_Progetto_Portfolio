/*
Data: 16/06/2026
Titolo: 09_Query_performance.sql

Descrizione: 
    Con qeste query andiamo a vedere come le performance di un certo valore si comporta rispetto ad un altro.
    Questo ci permette di individuare se è un successo in termini di performance o meno.
    Ecco che le WINDOW FUNCTIONS sono quelle che vengono usate in questo campo.

Aggiornamento:
 

*/

-- Analizza l'andamento dei prodotti in comparizione con le vendite secondo una media delle vendite e confronta
-- con il precedente anno di vendite

WITH yearly_product_sales AS(
SELECT
    DATE_TRUNC('year', f.order_date) AS order_year,
    p.product_name,
    SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY order_year, p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER(PARTITION BY product_name)::NUMERIC(10,2) AS avg_sales,
    current_sales - AVG(current_sales) OVER(PARTITION BY product_name)::NUMERIC(10,2) AS diff_sales,
    CASE 
      WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name)::NUMERIC(10,2) > 0 
            THEN 'Above Average'
      WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name)::NUMERIC(10,2) < 0 
            THEN 'Below Average'
      ELSE 'Equal Average'
    END AS avg_change,
    -- Year-over-Year analysis
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_sales,
    CASE 
      WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 
            THEN 'Increase'
      WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 
            THEN 'Decrease'
      ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;


