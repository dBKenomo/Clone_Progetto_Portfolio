/*
Data: 16/06/2026
Titolo: 10_Query_percentuale.sql

Descrizione: 
    Lo scopo di utilizzare query per questo scopo è quello di le performance per individuali parti del business.
    

Aggiornamento:
 

*/

-- Quale categoria è più impatante nelle vendite?
WITH category_sales AS(
SELECT
    category,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND((total_sales::NUMERIC / SUM(total_sales) OVER()) * 100, 2), ' %') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
