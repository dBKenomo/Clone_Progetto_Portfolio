/*
 Data: 2026-06-11
 Titolo: Clean_erp_px_cat_g1v2.sql
 Descrizione: Questo script esegue la pulizia dei dati nella tabella "erp_px_cat_g1v2" del database. 

 Aggiornamenti:
  
 
 */
-- =====================================
--    Fase di controllo Generale
-- =====================================
-- Per questa tabella la colonna id è collegata a cat_id che è stata creata nel silver.crm_prd_info
-- dato che questo è già stato fatto il controllo nel file 'Clean_crm_prd_info.sql'

-- Ora passiamo al controllo se ci sono spazi vuoti
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE TRIM(cat) != cat OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Controlliamo ogni colonna
SELECT DISTINCT
    cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
    subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
    maintenance
FROM bronze.erp_px_cat_g1v2



-- =====================================
--         QUERY PULIZIA
-- =====================================

-- Query da usare per inserire i dati nel Layer Silver da quello Bronze

SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2


-- =====================================
--       Validazione dei dati
-- =====================================

-- Dato che non dovuto fare nessuna modifica posso dire che l'unica cosa da confermare è che se la tabella,
-- rispetta le regole per il silver layer cioè che ci sia la colonna di metadata
SELECT * FROM silver.erp_px_cat_g1v2

