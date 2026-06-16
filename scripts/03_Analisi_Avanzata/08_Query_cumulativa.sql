/*
Data: 16/06/2026
Titolo: 08_Query_cumulativa.sql

Descrizione: 
    Con questa query quello che voliamo andare a vedere è come il agreggare i dati in modo progressivo. Questo 
    può aiutare per capire se il business sta crescendo oppure è in declino. Ecco quindi che per fare questa 
    cosa bisogna utilizzare le WINDOW FUNCTION.

Aggiornamento:
 

*/

-- Calcolare le vendite totali per ogni mese e calcolare le vendite totali fino ad ora
SELECT
    order_month,
    total_sales,
    -- WINDOW FUNCTION Totale vendite fino ad ora
    SUM(total_sales) OVER(ORDER BY order_month) AS cumulative_sales
FROM(
    SELECT
        DATE_TRUNC('month', order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY order_month
) t


-- Uno dei grossi vantaggi in questo caso di query in PostgreSQL è il fatto che mi basta cambiare la variabile 
-- di 'month' e se ls colonne vossero chiamate in modo comune avrei modo di fare un'analisi sulle date.