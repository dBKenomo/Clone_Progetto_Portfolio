/*
Data: 16/06/2026
Titolo: 12_Query_report.sql

Descrizione: 
    Ora questo file contiene un insieme di tutte le cose che abbiamo visto fino ad ora solamente che questo sono
    divise in report per ogni tabella. L'utilità di fare questa cosa sta nel presentare alle persone delle cose 
    veloci da poter esaminare.
    Ogni query poi è stata caricata come view sul layer Gold:
        - gold.report_customers
        - gold.report_products
    Quindi ora possono essere qeusti richiamate con delle semplici query.


Aggiornamento: Differenze tra SQL Server e PostgreSQL:
    DATEDIFF(year, ...) / DATEDIFF(month, ...): Non esistono in Postgres. Si sostituiscono con l'estrazione 
    matematica basata su AGE(data_1, data_2), esattamente come hai intuito tu nelle query precedenti.

    GETDATE(): In Postgres si usa CURRENT_DATE o NOW().

    IF OBJECT_ID... DROP VIEW / GO: La sintassi GO è un comando specifico di SQL Server (SSMS). 
    In Postgres si usa il comando standard e pulito CREATE OR REPLACE VIEW.


*/

/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- In Postgres "CREATE OR REPLACE" sostituisce automaticamente la vista se esiste già
CREATE OR REPLACE VIEW gold.report_customers AS (

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Query Base: Recupera le colonne principali dalle tabelle
---------------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    -- Conversione DATEDIFF per l'età in anni
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.birthdate)) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
WHERE f.order_date IS NOT NULL
), 
customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Aggregazioni Cliente: Riassume le metriche chiave a livello di cliente
---------------------------------------------------------------------------*/
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    -- La tua formula corretta per calcolare il lifespan totale in mesi
    (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12) +
     EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
         WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    -- Calcolo recency in mesi (differenza tra oggi e l'ultimo ordine)
    (EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order_date)) * 12) +
     EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order_date)) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Calcolo AOV (forzato a NUMERIC per evitare la divisione intera)
    CASE WHEN total_orders = 0 THEN 0
         ELSE (total_sales::NUMERIC / total_orders)::NUMERIC(10,2)
    END AS avg_order_value,
    -- Calcolo spesa media mensile
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE (total_sales::NUMERIC / lifespan)::NUMERIC(10,2)
    END AS avg_monthly_spend
FROM customer_aggregation
);

SELECT * FROM gold.report_customers;


/*
===============================================================================
Report Prodotti (Product Report)
===============================================================================
Scopo:
    - Questo report consolida le metriche chiave e i comportamenti dei prodotti.

Punti salienti:
    1. Raccoglie i campi essenziali come nome prodotto, categoria, sottocategoria e costo.
    2. Segmenta i prodotti in base ai ricavi per identificare High-Performers, Mid-Range o Low-Performers.
    3. Aggrega le metriche a livello di prodotto:
       - ordini totali (total orders)
       - vendite totali (total sales)
       - quantità totale venduta (total quantity sold)
       - clienti totali (total customers - univoci)
       - ciclo di vita in mesi (lifespan)
    4. Calcola KPI di valore:
       - recency (mesi trascorsi dall'ultima vendita)
       - ricavo medio per ordine (Average Order Revenue - AOR)
       - ricavo medio mensile (average monthly revenue)
===============================================================================
*/

CREATE OR REPLACE VIEW gold.report_products AS (

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Query Base: Recupera le colonne principali da fact_sales e dim_products
---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Aggregazioni Prodotto: Riassume le metriche chiave a livello di prodotto
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    -- Calcolo lifespan del prodotto in mesi
    (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12) +
     EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    -- Ottimizzato usando ::NUMERIC invece di CAST AS FLOAT
    ROUND((AVG(sales_amount::NUMERIC / NULLIF(quantity, 0))), 1) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)
/*---------------------------------------------------------------------------
  3) Query Finale: Combina tutti i risultati dei prodotti in un unico output
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    -- Calcolo recency del prodotto in mesi
    (EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_sale_date)) * 12) +
     EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_sale_date)) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Calcola il ricavo medio per ordine (AOR) con gestione divisione intera
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE (total_sales::NUMERIC / total_orders)::NUMERIC(10,2)
    END AS avg_order_revenue,
    -- Calcola il ricavo medio mensile
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE (total_sales::NUMERIC / lifespan)::NUMERIC(10,2)
    END AS avg_monthly_revenue
FROM product_aggregations
);

SELECT * FROM gold.report_products;

