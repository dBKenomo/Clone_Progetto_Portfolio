/*
 Data: 2026-06-10
 Titolo: Clean_crm_cust_info.sql
 Descrizione: Questo script esegue la pulizia dei dati nella tabella "crm_cust_info" del database. 

 Aggiornamenti:
  
 
 */
-- =====================================
--    Fase di controllo Generale
-- =====================================
-- Controllo dei dati prima della pulizia
SELECT
    cst_id,
    COUNT(*) AS count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Pulizia dei dati in caso di spazzi focalizzato
-- A seconda della colonna scelta non ottenere nessun risultato da questa query vuol dire che i dati
-- sono puliti e ordinati invece ottenere risultati vuol dire che bisogna fare pulizia.
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- Controllo della qualità di certi dati Colonna cst_gndr idem per cst_marital_status
-- Il risultato ci porta alla conclusione che [NULL, F -> Femmina, M -> Maschio], ma dobbiamo portarlo a questo
SELECT DISTINCT 
    cst_gndr
FROM bronze.crm_cust_info

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
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
         WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
         ELSE 'n/a' -- Per il valore NULL
    END cst_marital_status,
    CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
         WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
         ELSE 'n/a' -- Per il valore NULL
    END cst_gndr,
    cst_create_date
FROM (
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
)t WHERE flag_last=1;


-- =====================================
--       Validazione dei dati
-- =====================================
-- Controllo della pulizia effetuata
SELECT
    cst_id,
    COUNT(*) AS count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Pulizia dei dati in caso di spazzi focalizzato
-- A seconda della colonna scelta non ottenere nessun risultato da questa query vuol dire che i dati
-- sono puliti e ordinati invece ottenere risultati vuol dire che bisogna fare pulizia.
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- Controllo della qualità di certi dati Colonna cst_gndr idem per cst_marital_status
-- Il risultato ci porta alla conclusione che [NULL, F -> Femmina, M -> Maschio], ma dobbiamo portarlo a questo
SELECT DISTINCT 
    cst_gndr
FROM silver.crm_cust_info