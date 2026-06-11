/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
*/

DROP PROCEDURE IF EXISTS silver.load_storage_silver();

CREATE OR REPLACE PROCEDURE silver.load_storage_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_batch_start_time TIMESTAMP;
    v_batch_end_time TIMESTAMP;
    v_row_count INT;
BEGIN
    v_batch_start_time := clock_timestamp();
    
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- 1. Table: silver.crm_cust_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
    
    INSERT INTO silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname, 
        cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;
    
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 2. Table: silver.crm_prd_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';
    
    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, 
        prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        prod_id,
        REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prod_key, 7) AS prd_key, -- Ottimizzato senza LENGTH
        prod_name,
        COALESCE(prod_cost, 0) AS prd_cost, -- Tradotto ISNULL
        CASE 
            WHEN UPPER(TRIM(prod_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prod_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prod_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prod_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END,
        CAST(prod_start_date AS DATE),
        CAST((LEAD(prod_start_date) OVER (PARTITION BY prod_key ORDER BY prod_start_date)) - INTERVAL '1 day' AS DATE) -- Tradotto -1 giorno
    FROM bronze.crm_prd_info;
    
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 3. Table: silver.crm_sales_details
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
    
    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, 
        sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE 
            WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
            ELSE TO_DATE(CAST(sls_order_dt AS VARCHAR), 'YYYYMMDD') -- Conversione pulita intero->data
        END,
        CASE 
            WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) != 8 THEN NULL
            ELSE TO_DATE(CAST(sls_ship_dt AS VARCHAR), 'YYYYMMDD')
        END,
        CASE 
            WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS VARCHAR)) != 8 THEN NULL
            ELSE TO_DATE(CAST(sls_due_dt AS VARCHAR), 'YYYYMMDD')
        END,
        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,
        sls_quantity,
        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0 
                THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END
    FROM bronze.crm_sales_details;
    
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    -- 4. Table: silver.erp_cust_az12
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';
    
    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4) -- Ottimizzato senza LENGTH
            ELSE cid
        END, 
        CASE
            WHEN bdate > CURRENT_DATE THEN NULL -- Tradotto GETDATE()
            ELSE bdate
        END, 
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END
    FROM bronze.erp_cust_az12;
    
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 5. Table: silver.erp_loc_a101
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
    
    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid, 
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END
    FROM bronze.erp_loc_a101;
    
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 6. Table: silver.erp_px_cat_g1v2
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance
    FROM bronze.erp_px_cat_g1v2;
    
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    v_batch_end_time := clock_timestamp();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Silver Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: %', v_batch_end_time - v_batch_start_time;
    RAISE NOTICE '==========================================';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'ERROR OCCURED DURING LOADING SILVER LAYER';
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'SQLERRM: %', SQLERRM;
    RAISE NOTICE '==========================================';
END;
$$;

CALL silver.load_storage_silver();

-- ============================================
--              VERIFICA DEI DATI
-- ============================================
-- Per verificare che i dati siano stati inseriti correttamente all'interno
-- delle tabelle basta fare una semplice query di selezione per vedere se i dati sono
-- presenti

