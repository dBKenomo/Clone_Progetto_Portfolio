/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    Questa stored procedure carica i dati nello schema 'bronze' dai file CSV esterni.
    - Svuota le tabelle bronze prima del caricamento (TRUNCATE).
    - Utilizza il comando `COPY` nativo di Postgres per caricare i file.
    - Calcola i tempi di esecuzione e conta le righe caricate.

Usage Example:
    CALL bronze.load_storage_bronze();

*/

DROP PROCEDURE IF EXISTS bronze.load_storage_bronze();

CREATE OR REPLACE PROCEDURE bronze.load_storage_bronze()
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
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- 1. Table: bronze.crm_cust_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info
    FROM '/var/lib/postgresql/datasets/source_crm/cust_info.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 2. Table: bronze.crm_prd_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM '/var/lib/postgresql/datasets/source_crm/prd_info.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 3. Table: bronze.crm_sales_details
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM '/var/lib/postgresql/datasets/source_crm/sales_details.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';
    
    -- 4. Table: bronze.erp_loc_a101 
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101
    FROM '/var/lib/postgresql/datasets/source_erp/LOC_A101.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 5. Table: bronze.erp_cust_az12 
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12
    FROM '/var/lib/postgresql/datasets/source_erp/CUST_AZ12.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    -- 6. Table: bronze.erp_px_cat_g1v2
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2
    FROM '/var/lib/postgresql/datasets/source_erp/PX_CAT_G1V2.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Rows Loaded: %', v_row_count;
    RAISE NOTICE '>> Load Duration: %', v_end_time - v_start_time;
    RAISE NOTICE '>> -------------';

    v_batch_end_time := clock_timestamp();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: %', v_batch_end_time - v_batch_start_time;
    RAISE NOTICE '==========================================';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'ERROR OCCURED DURING LOADING BRONZE LAYER';
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'SQLERRM: %', SQLERRM;
    RAISE NOTICE '==========================================';
END;
$$;

CALL bronze.load_storage_bronze();

-- ============================================
--              VERIFICA DEI DATI
-- ============================================
-- Per verificare che i dati siano stati inseriti correttamente all'interno delle tabelle basta fare
-- una semplice query di selezione per vedere se i dati sono presenti
SELECT * FROM bronze.crm_cust_info LIMIT 5;
SELECT * FROM bronze.crm_prd_info LIMIT 5;
SELECT * FROM bronze.crm_sales_details LIMIT 5;
SELECT * FROM bronze.erp_cust_az12 LIMIT 5;
SELECT * FROM bronze.erp_loc_a101 LIMIT 5;
SELECT * FROM bronze.erp_px_cat_g1v2 LIMIT 5;