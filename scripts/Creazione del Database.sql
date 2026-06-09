/*
Data : 2026-06-09
Creato file docker-compose.yml per creare il conteiner del database PostgreSQL, con una image
data da Gemini per lavorare in modo veloce e senza avere troppi problemi di creazione del database.

A differenza del video il procedimento in questo caso è un poco diverso quindi dopo aver fatto le
procedure di avvio e connessione al giusto database ecco quindi che posso dire di poter procedere.
Poi per il resto la creazione dei vari layer come si è deciso nella fase di progettazione rimane uguale
a quella del video.

Aggiornamenti:
- Conforntata la versione scritta di prima mano con un opzione migliorata con Gemini e le parti pericolose
    sono state commentate e messe come opzionali da eseguire, prima però è meglio leggere cosa fanno.
 Nota: Nella versione Aggiornata c'è la verifica della esistenza degli schema in query.


*/

-- Creazione del Database
--CREATE DATABASE data_warehouse;

-- Dato che però questa operazione è stata già eseguita, utilizzando Docker e poi usando la estensione
-- SQL Tools per connetersi al database creato, è stata messa solo di convenzione invece in questo caso
-- una buona alternativa è questa:


-- Per essere sicuri di essere sicuri di essere connessi al database corretto.
-- @block SQL Data Warehouse

-- Creazione dei SCHEMA
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;



-- ================== AGGIORNAMENTI =============================
--@block SQL Data Warehouse

/*
=============================================================
Pulizia dei Dati (Opzionale ma consigliata per lo sviluppo)
=============================================================
Se vuoi resettare l'ambiente per ripartire da zero durante i test, 
puoi decommentare i comandi DROP sottostanti. 
L'opzione CASCADE elimina automaticamente anche tutte le tabelle dentro lo schema.
*/
-- DROP SCHEMA IF EXISTS bronze CASCADE;
-- DROP SCHEMA IF EXISTS silver CASCADE;
-- DROP SCHEMA IF EXISTS gold CASCADE;


/*
=============================================================
Create Schemas
=============================================================
Script Purpose:
    Questo script si assicura che l'ambiente del Data Warehouse sia pronto.
    Crea i tre layer logici (schemi) fondamentali per l'architettura dei dati:
    'bronze', 'silver', e 'gold'.
*/

-- Creazione degli Schemi con controllo di sicurezza
-- CREATE SCHEMA IF NOT EXISTS bronze;
-- CREATE SCHEMA IF NOT EXISTS silver;
-- CREATE SCHEMA IF NOT EXISTS gold;

/*
=============================================================
Verifica e Controllo (Il valore aggiunto rispetto al video)
=============================================================
Questo comando ti permette di verificare istantaneamente se gli schemi 
sono stati creati correttamente nel database di Postgres.
*/
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('bronze', 'silver', 'gold');