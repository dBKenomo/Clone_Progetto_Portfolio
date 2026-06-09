/*
Data : 2026-06-09
Dopo aver fatto la inizzializzazione del database ora bisogna passare alla creazione delle tabelle e quindi
per quanto riguarda la creazione per lo schema bronze il codice da scrivere è quello che segue.

Infine la procedura poi finale è il fatto di inserire i dati all'interno di queste tabelle che però nel mio
caso ci sono delle accortezze da fare dato che sto usando docker per il mio database.
E in fine c'è il processo per verificare se tutti i passi fatti sono stati fatti nel modo corretto, semplicemente
chiamando una query e verificando che i dati sono nelle giuste colonne.

Aggiornamenti:


*/

-- 1. Elimina la vecchia procedura se esiste (equivale all'ALTER del video)
DROP PROCEDURE IF EXISTS bronze.load_bronze();

-- 2. Crea la nuova procedura da zero
CREATE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN

    -- ============================================
    --              DATATYPE DELLE TABELLE
    -- ============================================
    DROP TABLE IF EXISTS bronze.crm_cust_info;
    CREATE TABLE bronze.crm_cust_info (
        cst_id INT,
        cst_key VARCHAR(50),
        cst_firstname VARCHAR(50),
        cst_lastname VARCHAR(50),
        cst_marital_status VARCHAR(50),
        cst_gndr VARCHAR(50),
        cst_create_date DATE
    );

    DROP TABLE IF EXISTS bronze.crm_prd_info;
    CREATE TABLE bronze.crm_prd_info (
        prod_id INT,
        prod_key VARCHAR(50),
        prod_name VARCHAR(50),
        prod_cost INT,
        prod_line VARCHAR(50),
        prod_start_date TIMESTAMP,
        prod_end_date TIMESTAMP
    );

    DROP TABLE IF EXISTS bronze.crm_sales_dettails;
    CREATE TABLE bronze.crm_sales_dettails (
        sls_ord_num VARCHAR(50),
        sls_prd_key VARCHAR(50),
        sls_cust_id INT,
        sls_order_dt INT,
        sls_ship_dt INT,
        sls_due_dt INT,
        sls_sales INT,
        sls_quantity INT,
        sls_price INT
    );

    DROP TABLE IF EXISTS bronze.erp_cust_az12;
    CREATE TABLE bronze.erp_cust_az12 (
        cid VARCHAR(50),
        bdate DATE,
        gen VARCHAR(50)
    );

    DROP TABLE IF EXISTS bronze.erp_loc_a101;
    CREATE TABLE bronze.erp_loc_a101 (
        cid VARCHAR(50),
        cntry VARCHAR(50)
    );

    DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        id VARCHAR(50),
        cat VARCHAR(50),
        subcat VARCHAR(50),
        maintenance VARCHAR(50)
    );


    -- ============================================
    --              INSERIMENTO DEI DATI
    -- ============================================
    -- Prima c'è la fase TRUNCATE per scuotare le tabelle e poi c'è la fase di Copy per inserire i dati
    -- l'utilizzo di Truncate è necessario per evitare di avere dei dati duplicati all'interno delle tabelle


    TRUNCATE TABLE bronze.crm_cust_info;
    COPY bronze.crm_cust_info
    FROM '/var/lib/postgresql/datasets/source_crm/cust_info.csv'
    WITH (
        FORMAT CSV,
        HEADER true,
        DELIMITER ',',
        QUOTE '"',
        ENCODING 'UTF8'
    );

    TRUNCATE TABLE bronze.crm_prd_info;
    COPY bronze.crm_prd_info
    FROM '/var/lib/postgresql/datasets/source_crm/prd_info.csv'
    WITH (
        FORMAT CSV,
        HEADER true,
        DELIMITER ',',
        QUOTE '"',
        ENCODING 'UTF8'
    );

    TRUNCATE TABLE bronze.crm_sales_dettails;
    COPY bronze.crm_sales_dettails
    FROM '/var/lib/postgresql/datasets/source_crm/sales_details.csv'
    WITH (
        FORMAT CSV,
        HEADER true,
        DELIMITER ',',
        QUOTE '"',
        ENCODING 'UTF8'
    );

    TRUNCATE TABLE bronze.erp_cust_az12;
    COPY bronze.erp_cust_az12
    FROM '/var/lib/postgresql/datasets/source_erp/CUST_AZ12.csv'
    WITH (
        FORMAT CSV,
        HEADER true,
        DELIMITER ',',
        QUOTE '"',
        ENCODING 'UTF8'
    );

    TRUNCATE TABLE bronze.erp_loc_a101;
    COPY bronze.erp_loc_a101
    FROM '/var/lib/postgresql/datasets/source_erp/LOC_A101.csv'
    WITH (
        FORMAT CSV,
        HEADER true,
        DELIMITER ',',
        QUOTE '"',
        ENCODING 'UTF8'
    );

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    COPY bronze.erp_px_cat_g1v2
    FROM '/var/lib/postgresql/datasets/source_erp/PX_CAT_G1V2.csv'
    WITH (
        FORMAT CSV,
        HEADER true,
        DELIMITER ',',
        QUOTE '"',
        ENCODING 'UTF8'
    );

END;
$$;

CALL bronze.load_bronze();

-- ============================================
--              VERIFICA DEI DATI
-- ============================================
-- Per verificare che i dati siano stati inseriti correttamente all'interno delle tabelle basta fare
-- una semplice query di selezione per vedere se i dati sono presenti
SELECT * FROM bronze.crm_cust_info LIMIT 5;
SELECT * FROM bronze.crm_prd_info LIMIT 5;
SELECT * FROM bronze.crm_sales_dettails LIMIT 5;
SELECT * FROM bronze.erp_cust_az12 LIMIT 5;
SELECT * FROM bronze.erp_loc_a101 LIMIT 5;
SELECT * FROM bronze.erp_px_cat_g1v2 LIMIT 5;
