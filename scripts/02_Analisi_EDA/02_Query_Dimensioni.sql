/*
Data: 15/06/2026
Titolo: 02_Query_Dimensioni.sql

Descrizione: Per quanto riguarda questa parte di esplorazione del Database andiamo a vedere in modo distinto 
    quali sono le dimensioni delle notre tabelle.

Aggiornamento:
 

*/

-- ========================
--     dim_customers
-- ========================
SELECT DISTINCT country 
FROM gold.dim_customers;

-- ========================
--     dim_products
-- ========================
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY 1,2,3;

