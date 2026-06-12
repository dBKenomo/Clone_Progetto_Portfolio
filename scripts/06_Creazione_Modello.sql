/*
Data: 2026-06-11
Titolo: 06_Creazione_Modello.sql

Descrizione: In questa fase andiamo passo per passo a costuire le nostre nuove tabelle che poi devono essere
 caricate nel Layer Gold ecco quindi come facciamo.


Aggiornamenti:
 

*/

-- ====================================
--            CLIENTE
-- ====================================

-- In questo modo dopo aver creato la tabella con JOIN controlliamo se non ci sono dati dupplici
SELECT cst_id, COUNT(*) 
FROM(
    SELECT 
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
)t
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Si nota che nella tabella ci sono casi di doppio genere e se si nota in modo più approfondito a
-- seconda di quale tabella si guarda il genere della persona cambia
-- Il processo è qui chiedere quale sia quello preciso e da qeusto veniamo a sapere che i dati dal crm sono
-- i valore più importanti
SELECT DISTINCT
        ci.cst_gndr,
        ca.gen,
        CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
             ELSE COALESCE(ca.gen, 'n/a')
        END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
ORDER BY 1,2;

-- ====================================
-- Ora le colonne sono uniche quindi possiamo passare alla fase finale di costruzione della tabella finale
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
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;


-- ====================================
--            PRODOTTI
-- ====================================
-- In questo primo processo vediamo di rimuovere tutti i dati storici dei prodotti
SELECT
    pn.prod_id,
    pn.cat_id,
    pn.prod_key,
    pn.prod_name,
    pn.prod_cost,
    pn.prod_line,
    pn.prod_start_date,
    pn.prod_end_date
FROM silver.crm_prd_info pn
WHERE pn.prod_end_date IS NULL;

-- Attraverso il JOIN poi sono andato a vedere se i dati sono unici
SELECT prod_key, COUNT(*) FROM(
SELECT
    pn.prod_id,
    pn.cat_id,
    pn.prod_key,
    pn.prod_name,
    pn.prod_cost,
    pn.prod_line,
    pn.prod_start_date,
    px.cat,
    px.subcat,
    px.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 px ON pn.cat_id = px.id
WHERE pn.prod_end_date IS NULL
)t
GROUP BY prod_key
HAVING COUNT(*) > 1;

-- ====================================
-- Assegnamo ora nomi più convenzionali
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
WHERE pn.prod_end_date IS NULL;


-- ====================================
--            VENDITE
-- ====================================
-- Dato come ormai l'ultima tabella è formata questa è una ottima candidata a diventare una fact table solo
-- che la procedura non è cosi tanto semplice da fare. Ecco quindi dopo averla analizzata possiamo vedere di
-- fatto che prd_key e cust_id sono quelli che possiamo sostituire con le chiave delle altre tabelle. 
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
LEFT JOIN gold.dim_customers dc ON sd.sls_cust_id = dc.customer_id;










