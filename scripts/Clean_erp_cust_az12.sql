/*
 Data: 2026-06-11
 Titolo: Clean_erp_cust_az12.sql
 Descrizione: Questo script esegue la pulizia dei dati nella tabella "erp_cust_az12" del database. 

 Aggiornamenti:
  
 
 */
-- =====================================
--    Fase di controllo Generale
-- =====================================
-- Allora la prima colonna cid è collegata con (cst_key.crm_cust_info) solo che bisogna un attimo lavorarla un 
-- poco datto che ci sono in questa tabella info in più
SELECT
    cid,
    CASE WHEN cid LIKE 'NAS%'THEN SUBSTRING(cid, 4)
         ELSE cid
    END AS cid_new
FROM bronze.erp_cust_az12

SELECT * FROM silver.crm_cust_info

-- Controllo dopo la trasformazione fra le due tabelle
SELECT
    cid,
    CASE WHEN cid LIKE 'NAS%'THEN SUBSTRING(cid, 4)
         ELSE cid
    END AS cid_new
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%'THEN SUBSTRING(cid, 4)
         ELSE cid
    END NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Controllo della colonna bdate
SELECT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > CURRENT_DATE;
-- Al massimo nella fase di inserimento mettiamo che la data di inserimento non sia maggiore della corrente
-- sia NULL e per il resto si segnala di dati poco chiari.

-- controllo della colonna gen
SELECT DISTINCT
    gen,
    CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
         WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
         ELSE 'n/a'
    END AS gen_new
FROM bronze.erp_cust_az12




-- =====================================
--         QUERY PULIZIA
-- =====================================

-- Query da usare per inserire i dati nel Layer Silver da quello Bronze

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


-- =====================================
--       Validazione dei dati
-- =====================================

-- Controlliamo la tabella nello schema silver
SELECT
    *
FROM silver.erp_cust_az12
WHERE cid = 'NAS%';

-- Controllo della data di nascita
SELECT
    bdate
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE OR bdate IS NULL;

-- Controllo della colonna gen
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;