/*
Data: 15/06/2026
Titolo: 03_Query_Date.sql

Descrizione: Ora in qeusto file andiamo ad esplorare le date presenti all'interno del nostro database.

Aggiornamento:
 

*/

-- ==========================
--       fact_sales
-- ==========================
-- Domanda: Torva la data del primo e ultimo ordine
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS years_between,
    EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS months_between,
    EXTRACT(DAY FROM AGE(MAX(order_date), MIN(order_date))) AS days_between
FROM gold.fact_sales;
-- Da notare è che questa query funziona bene fino a quando si parlano di Anni di differenza, ma le cose cambiano
-- quando bisogna parlare di Mesi e Giorni per quello bisogna usare un altro metodo
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS years_between,
    (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date)))*12) +
    EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS months_between,
    MAX(order_date) - MIN(order_date) AS days_between
FROM gold.fact_sales
-- In questo modo non solo abbiamo trovato la distanza tra il primo e ultimo ordine diviso per Anni, Mesi e Giorni
-- però ecco bisogna fare attenzione alle parantesi.

-- NOTA: il primo metodo non è sbagliato è solo che non risponde in chiaro alla domanda che ci si può fare dato
-- che prima viene mostrato un intervallo di tempo non la distanza tra una data e l'altra.


-- ==========================
--       dim_customers
-- ==========================
-- Trovare il più vecchio e il più giovane nella tabella customers
SELECT
    MIN(birthdate) AS oldest_birthdate,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MIN(birthdate))) AS age_oldest,
    MAX(birthdate) AS youngest_birthdate,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAX(birthdate))) AS age_youngest
FROM gold.dim_customers;





