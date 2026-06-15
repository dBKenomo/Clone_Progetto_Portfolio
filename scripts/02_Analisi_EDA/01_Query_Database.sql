/*
Data: 15/06/2026
Titolo: 01_Query_Database.sql

Descrizione: Questo file permette la analisi del Database dopo aver creato la Warehouse seguendo quello fatto
    dallo YouTuber Data With Baraa.
    Per questo quello che vediamo di fare in questa prima fase dipende molto dalla condizione generale di pensiero
    prendiamo caso che tu abbia per la prima volta avuto acesso a questo Database ecco quindi che le prime cose 
    da fare sono quelle di esplorare il Database.

Aggiornamento:
 Nel Video corso sono state introdote alcune informazioni importati però da quanto ho capito a seconda del tipo 
 di Database usato ci sono delle differenze. Ecco quindi che dopo averle esplorate un poco ho creato delle query 
 "migliori" almeno per questo mio caso di Database.

*/

-- Esplorare gli oggetti del Database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT * FROM pg_tables;
SELECT * FROM pg_views;

-- ==========================================
--        Esplorazione Otimale TABELLE
-- ==========================================
-- Per vedere il tipo (Tabella o Vista)
SELECT table_schema, table_name, table_type 
FROM information_schema.tables 
WHERE table_schema IN ('bronze', 'silver', 'gold');

-- Per vedere solo le Tabelle e se hanno indici
SELECT schemaname, tablename, hasindexes 
FROM pg_tables 
WHERE schemaname IN ('bronze', 'silver');

-- Per vedere solo le Viste e il loro codice sorgente
SELECT schemaname, viewname, definition 
FROM pg_views 
WHERE schemaname = 'gold';

--- ======================================================================================

-- Esplorazione delle colonni presenti nel Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema IN ('bronze', 'silver', 'gold');
-- Oppure utilizzare la colonna table_name se conosci il nome della tabella


-- ==========================================
--        Esplorazione Ottimale Colonne
-- ==========================================
SELECT 
    table_schema, 
    table_name, 
    column_name, 
    data_type, 
    character_maximum_length AS max_lunghezza,
    is_nullable AS accetta_null
FROM information_schema.columns
WHERE table_schema IN ('bronze', 'silver', 'gold')
ORDER BY table_schema, table_name, ordinal_position;

