/*
 Data: 2026-06-10
 Titolo: Clean_crm_sales_details.sql
 Descrizione: Questo script esegue la pulizia dei dati nella tabella "crm_sales_details" del database. 

 Aggiornamenti:
  
 
 */
-- =====================================
--    Fase di controllo Generale
-- =====================================
-- Controllo dei dati nel caso di spazi vuoti
SELECT
    sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Controllo delle key individuate nel Data integration sls_prd_key e per sls_cust_id
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Ora notiamo che ci sono dei valori che alla fine paiono proprio delle date quindi andiamo a ripristinarli
-- ci focalizziamo su una colonna poi il processo si ripete
SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE LENGTH(sls_order_dt::VARCHAR) != 8

-- Controllo che le date siano in un certo ordine
SELECT
    *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt

-- Ora per le ultime due colonne c'è una regola del Business da rispettare cioé che SALES = Quantity * Price
-- e non ci devono essere NULL, zeri e Negativi. Qundi vediamo:
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price
-- Purtroppo come vediamo la situazione non è proprio ideale dato che sono in una situazione non molto chiara
-- la soluzione dipende molto qui se si trova un FIX a sorgente cioè dalla risorsa dei dati oppure il FIX viene
-- fatto al interno della Warehouse.
-- Il processo richiede delle regole da essere scritte:
-- 1. Se Sales sono Negative, Zero o NULL usare la formula usando Quantità e Prezzo
-- 2. Se il Prezzo è NULL o Zero calcolare usando Sales e Quantità
-- 3. Se il Prezzo è Negativo va convertito in positivo

SELECT DISTINCT
    sls_sales AS old_sales,
    sls_quantity,
    sls_price AS old_price,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price



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
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE WHEN sls_order_dt = 0 AND LENGTH(sls_order_dt::VARCHAR) != 8 THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE WHEN sls_ship_dt = 0 AND LENGTH(sls_ship_dt::VARCHAR) != 8 THEN NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE WHEN sls_due_dt = 0 AND LENGTH(sls_due_dt::VARCHAR) != 8 THEN NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details


-- =====================================
--       Validazione dei dati
-- =====================================
-- Purtroppo la validazione non è stata potuta fare dato che per questa cosa c'è un piccolo errore che è da
-- capire come risolvere per poter inserire i dati in modalità veloce sono dovuto passare a chiedere a Gemini
-- un consiglio su come scrivere il codice in modo da riuscire a caricare i dati nello schema Silver di questa
-- tabella. IL problema a quanto pare si trova nel file CSV di Origine dato la riga 46699 e la riga 46700 hanno
-- il valore della colonna sls_order_dt sballato.
-- A quanto pare la procedura identica al interno del video mi ha dato lo stesso errore non capisco come mai 

SELECT * FROM silver.crm_sales_details WHERE sls_ord_num = 'SO69215'
