/*
Data : 2026-06-10
Dopo aver fatto la procedura iniziale di analisi delle sorgenti di dati e aver creato anche un file di 
Data Integration in modo da capire quali sono i collegamenti da fare passiamo alla fase di codice.
In questo caso la copia del codice base scritto per il livello bronze rimane quasi lo stesso quindi fare una copia
e metterlo in utilizzo per il livello silver è una procedura normale.

Ci sono però delle cose da fare per completare tale script ed è quello di utilizzare le colonne di metadata,
che non dipendono dalla sorgente dei dati, ma sono delle colonne che servono per tenere traccia di certe 
azioni e/o informazioni che possono essere utili per la gestione dei dati all'interno del database.

Aggiornamenti:
 

*/

-- 1. Elimina la vecchia procedura se esiste (equivale all'ALTER del video)
DROP PROCEDURE IF EXISTS silver.load_silver();

-- 2. Crea la nuova procedura da zero
CREATE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
BEGIN

    -- ============================================
    --              DATATYPE DELLE TABELLE
    -- ============================================
    DROP TABLE IF EXISTS silver.crm_cust_info;
    CREATE TABLE silver.crm_cust_info (
        cst_id INT,
        cst_key VARCHAR(50),
        cst_firstname VARCHAR(50),
        cst_lastname VARCHAR(50),
        cst_marital_status VARCHAR(50),
        cst_gndr VARCHAR(50),
        cst_create_date DATE,
        dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    DROP TABLE IF EXISTS silver.crm_prd_info;
    CREATE TABLE silver.crm_prd_info (
        prod_id INT,
        cat_id VARCHAR(50),
        prod_key VARCHAR(50),
        prod_name VARCHAR(50),
        prod_cost INT,
        prod_line VARCHAR(50),
        prod_start_date DATE,
        prod_end_date DATE,
        dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    DROP TABLE IF EXISTS silver.crm_sales_details;
    CREATE TABLE silver.crm_sales_details (
        sls_ord_num VARCHAR(50),
        sls_prd_key VARCHAR(50),
        sls_cust_id INT,
        sls_order_dt DATE,
        sls_ship_dt DATE,
        sls_due_dt DATE,
        sls_sales INT,
        sls_quantity INT,
        sls_price INT,
        dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    DROP TABLE IF EXISTS silver.erp_cust_az12;
    CREATE TABLE silver.erp_cust_az12 (
        cid VARCHAR(50),
        bdate DATE,
        gen VARCHAR(50),
        dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    DROP TABLE IF EXISTS silver.erp_loc_a101;
    CREATE TABLE silver.erp_loc_a101 (
        cid VARCHAR(50),
        cntry VARCHAR(50),
        dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
    CREATE TABLE silver.erp_px_cat_g1v2 (
        id VARCHAR(50),
        cat VARCHAR(50),
        subcat VARCHAR(50),
        maintenance VARCHAR(50),
        dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );


END;
$$;

