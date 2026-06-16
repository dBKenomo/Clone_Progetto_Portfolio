/*
Data: 16/06/2026
Titolo: 07_Query_tempo.sql

Descrizione: 
    Ora andiamo ad analizzare la evoluzione del tempo per i nostri dati. Questo ripo di query viene utilizzato
    per ottenere informzioni su quanto certi trends sono andati bene o male.

Aggiornamento:
 

*/

-- Analizzare le vendite per il periodo di tempo
SELECT
    EXTRACT(MONTH FROM order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_year
ORDER BY order_year;

-- ALTERNATIVE
SELECT
    DATE_PART('year', order_date) AS order_year,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_year
ORDER BY order_year;

-- Un'altra alternativa è usare questa funzione che lavora in modo particolare con le date e particolarmente 
-- per la sua flessibilità con anche i mesi.
SELECT
    DATE_TRUNC('month', order_date) AS order_month,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;

-- Se si volesse avere una data più personale al posto di usare quella di sistema la cosa che viene in mente è 
-- usare la funzione FORMAT(), ma c'è una migliore alternativa:
SELECT
    TO_CHAR(order_date, 'YYYY-Month') AS date_pers,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY date_pers, TO_CHAR(order_date, 'MM')
ORDER BY TO_CHAR(order_date, 'MM'), date_pers;
