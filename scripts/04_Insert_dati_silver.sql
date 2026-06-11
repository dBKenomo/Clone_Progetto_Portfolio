/*
 Data: 2026-06-10
 Titolo: Insert_dati_silver.sql
 Descrizione: Questo script esegue la fase di insermento dei dati dal Bronze Layer al Silver Layer. 
 In questa fase viene fatta una pulizia, garantendo l'integrità dei dati e migliorando le prestazioni 
 della qualità dei dati.
 
Note: Questo script è parte integrante del processo di gestione dei dati e dovrebbe essere eseguito 
 regolarmente per mantenere la qualità dei dati nel database.
 
 
 Aggiornamenti:
  - Per maggiori info su le query di caricamento dei dati guardare file che iniziano con Clean_'tabella';
  
 
 */

-- =================================================
--      INSERIMENTO DEI DATI Layer SILVER
-- =================================================

-- Svuota la tabella Silver prima di ricaricarla (Best practice per lo sviluppo)
TRUNCATE TABLE silver.crm_cust_info;
-- Inserisce i dati puliti e trasformati
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
         WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
         ELSE 'n/a'
    END AS cst_marital_status,
    CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
         WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
         ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1;


-- Svuota la tabella Silver prima di ricaricarla (Best practice per lo sviluppo)
TRUNCATE TABLE silver.crm_prd_info;
-- Inserisce i dati puliti e trasformati
INSERT INTO silver.crm_prd_info (
    prod_id,
    cat_id,
    prod_key,
    prod_name,
    prod_cost,
    prod_line,
    prod_start_date,
    prod_end_date
)
SELECT
    prod_id,
    REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prod_key, 7) AS prod_key,
    prod_name,
    COALESCE(prod_cost, 0) AS prod_cost,
    CASE UPPER(TRIM(prod_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other Sales'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a'
    END prod_line,
    CAST(prod_start_date AS DATE) AS prod_start_date,
    CAST(lEAD(prod_start_date) OVER (PARTITION BY prod_key ORDER BY prod_start_date)-INTERVAL '1 day' AS DATE) AS prod_end_date
FROM bronze.crm_prd_info

-- Svuota la tabella Silver prima di ricaricarla (Best practice per lo sviluppo)
TRUNCATE TABLE silver.crm_sales_details;
-- Inserisce i dati puliti e trasformati
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL
         ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
    END AS sls_order_dt,
    CASE WHEN sls_ship_dt <= 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL
         ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
    END AS sls_ship_dt,
    CASE WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL
         ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
    END AS sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
    

-- Svuota la tabella Silver prima di ricaricarla (Best practice per lo sviluppo)
TRUNCATE TABLE silver.erp_cust_az12;
-- Inserisce i dati puliti e trasformati
INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    CASE WHEN cid LIKE 'NAS%'THEN SUBSTRING(cid, 4)
         ELSE cid
    END AS cid,
    CASE WHEN bdate > CURRENT_DATE THEN NULL
         ELSE bdate
    END AS bdate,
    CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
         WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
         ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12


-- Svuota la tabella Silver prima di ricaricarla (Best practice per lo sviluppo)
TRUNCATE TABLE silver.erp_loc_a101;
-- Inserisce i dati puliti e trasformati
INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
         WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
         ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101


-- Svuota la tabella Silver prima di ricaricarla (Best practice per lo sviluppo)
TRUNCATE TABLE silver.erp_px_cat_g1v2;
-- Inserisce i dati puliti e trasformati
INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2
