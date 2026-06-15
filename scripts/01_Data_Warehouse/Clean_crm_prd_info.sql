/*
 Data: 2026-06-10
 Titolo: Clean_crm_prd_info.sql
 Descrizione: Questo script esegue la pulizia dei dati nella tabella "crm_prd_info" del database. 

 Aggiornamenti:
  
 
 */
-- =====================================
--    Fase di controllo Generale
-- =====================================
-- Controllo dei dati prima della pulizia nel casi di dupplicati
SELECT
    prod_id,
    COUNT(*) AS count
FROM bronze.crm_prd_info
GROUP BY prod_id
HAVING COUNT(*) > 1 OR prod_id IS NULL;

-- Nota che la colonna prod_key deve essere separata dato che contiene diverse informazioni utili viste quando
-- creato il Modello di integration
-- Utilizzata la funzione REPLACE dato che nellla tabella erp_px_cat_g1v2 non c'è il "-", ma "_"
-- Fatto anche il controllo se ci sono dei casi particolari
SELECT
    prod_key,
    REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prod_key, 7) AS prod_key
FROM bronze.crm_prd_info

SELECT
    prod_key,
    REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prod_key, 7) AS prod_key
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') NOT IN
(SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)

SELECT
    prod_key,
    REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prod_key, 7) AS prod_key
FROM bronze.crm_prd_info
WHERE SUBSTRING(prod_key, 7) NOT IN
(SELECT sls_prd_key FROM bronze.crm_sales_details )

-- Controllo della qualità degli spazi
SELECT
    prod_name
FROM bronze.crm_prd_info
WHERE prod_name != TRIM(prod_name)


-- Controllo della qualità di certi dati Colonna prod_line
SELECT DISTINCT 
    prod_line
FROM bronze.crm_prd_info

-- Controllo delle Date
-- In questo caso ci si può lavorare in modo esterno per prendere bene le misure e capire come funziona.
-- per questo specifico caso utilizziamo la questione di prendere la data di start e sottrarre un giorno
-- per creare quella di end date.
SELECT
    *
FROM bronze.crm_prd_info
WHERE prod_end_date < prod_start_date;
-- Metodo preciso per caso specifico
SELECT
    prod_id,
    prod_key,
    prod_name,
    prod_start_date,
    lEAD(prod_start_date) OVER (PARTITION BY prod_key ORDER BY prod_start_date)-INTERVAL '1 day' AS prod_end_date_test
FROM bronze.crm_prd_info
WHERE prod_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');



-- =====================================
--         QUERY PULIZIA
-- =====================================
/*
Dopo aver fatto dei vari tentativi ecco arrivato ad creare la QUERY Completa per questa tabella con però
alcuni accorgimenti:
- Dati Duplicati rimossi usando la Window Function
- Utilizzata la funzione TRIM per rimuovere spazi vuoti
- Generato dei dati più semplici da leggere non abbreviazioni (Consinderando casi particolari)

*/ 
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


-- =====================================
--       Validazione dei dati
-- =====================================
-- Controllo dei dati prima della pulizia nel casi di dupplicati
SELECT
    prod_id,
    COUNT(*) AS count
FROM silver.crm_prd_info
GROUP BY prod_id
HAVING COUNT(*) > 1 OR prod_id IS NULL;

-- Nota che la colonna prod_key deve essere separata dato che contiene diverse informazioni utili viste quando
-- creato il Modello di integration
-- Utilizzata la funzione REPLACE dato che nellla tabella erp_px_cat_g1v2 non c'è il "-", ma "_"
-- Fatto anche il controllo se ci sono dei casi particolari
SELECT
    prod_key,
    REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prod_key, 7) AS prod_key
FROM silver.crm_prd_info

SELECT
    prod_key,
    REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prod_key, 7) AS prod_key
FROM silver.crm_prd_info
WHERE REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') NOT IN
(SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)

SELECT
    prod_key,
    REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prod_key, 7) AS prod_key
FROM silver.crm_prd_info
WHERE SUBSTRING(prod_key, 7) NOT IN
(SELECT sls_prd_key FROM bronze.crm_sales_details )

-- Controllo della qualità degli spazi
SELECT
    prod_name
FROM silver.crm_prd_info
WHERE prod_name != TRIM(prod_name)


-- Controllo della qualità di certi dati Colonna prod_line
SELECT DISTINCT 
    prod_line
FROM silver.crm_prd_info

-- Controllo delle Date
-- In questo caso ci si può lavorare in modo esterno per prendere bene le misure e capire come funziona.
-- per questo specifico caso utilizziamo la questione di prendere la data di start e sottrarre un giorno
-- per creare quella di end date.
SELECT
    *
FROM silver.crm_prd_info
WHERE prod_end_date < prod_start_date;

