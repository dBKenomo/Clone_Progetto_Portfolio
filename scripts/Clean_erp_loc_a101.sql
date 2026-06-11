/*
 Data: 2026-06-11
 Titolo: Clean_erp_loc_a101.sql
 Descrizione: Questo script esegue la pulizia dei dati nella tabella "erp_loc_a101" del database. 

 Aggiornamenti:
  
 
 */
-- =====================================
--    Fase di controllo Generale
-- =====================================
-- Qui c'è il collegamento tra cid e la tabella crm_cust_info colonna cst_key quindi andiamo a renderla tale
SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Ora per colonna cntry dobbbiamo guardare la loro unicità
SELECT DISTINCT
    cntry,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
         WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
         ELSE TRIM(cntry)
    END AS cntry_new
FROM bronze.erp_loc_a101
ORDER BY cntry


-- =====================================
--         QUERY PULIZIA
-- =====================================

-- Query da usare per inserire i dati nel Layer Silver da quello Bronze

SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
         WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
         ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101


-- =====================================
--       Validazione dei dati
-- =====================================

SELECT * FROM silver.erp_loc_a101

-- Controllo per colonna cntry
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry
