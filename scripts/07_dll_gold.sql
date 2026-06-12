/*
Data: 2026-06-11
Titolo: 07_dll_gold.sql

Descrizione: Dopo aver lavorato alla procedura di creazione di come deve essere il Data Model di questa 
 Warehouse si deve procedere con la fase di caricamento dei dati e delle nuove tabelle da dare alle persone
 per visualizzare le informazioni.

 Nota: Per arrivare a costruire la query per ogni tabella del gold layer lo sviluppo è avvenuto nel file 
 06_Creazione_Modello.sql quindi se si vuole vedere la procedura andare in quel file.

Aggiornamenti:
 

*/

-- ==================================
--        Costumers VIEW
-- ==================================

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
         ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid

-- ==================================
--        Products VIEW
-- ==================================

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prod_start_date, pn.prod_key) AS product_key,
    pn.prod_id AS product_id,
    pn.prod_key AS product_number,
    pn.prod_name AS product_name,
    pn.cat_id AS category_id,
    px.cat AS category,
    px.subcat AS subcategory,
    px.maintenance AS maintenance,
    pn.prod_cost AS cost,
    pn.prod_line AS product_line,
    pn.prod_start_date AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 px ON pn.cat_id = px.id
WHERE pn.prod_end_date IS NULL

-- ==================================
--             Sales VIEW
-- ==================================

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products dp ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers dc ON sd.sls_cust_id = dc.customer_id



-- =================================
--    VALIDAZIONE GOLD LAYER
-- =================================

-- Per fare una migliore validazione se tutto funziona al meglio provo ad unire tutte le colonne in un unica 
-- grande tabella

SELECT * FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
WHERE dc.customer_key IS NULL OR dp.product_key IS NULL;

