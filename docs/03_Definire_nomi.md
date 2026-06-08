# Nomeclature nel Progetto

Uno dei più grandi problemi durante lo svolgimento del progetto che in questo caso è da solo quindi non è detto che avenga è la possibilita di come vengono chiamati e/o definiti i vari nomi delle cose.

Ecco quindi che è sempre buona cosa da fare è quella da fare per ovviare problemi è di decidere il tutto dal punto iniziale e poi andare passo per passo nel rispettare queste regole.

## Regole generali

- **Nomeclature**: Si usa il metodo snake_case, cioè sempre lettere minuscole e parole separate da un trattino basso.
- **Lingua**: nel progetto per ora la parte descittiva in Italiano, invece termini e parole chiave in Inglese.
- **Parole da evitare**: non usare parole che possono confondere nel uso di SQL.

## Tabelle Nomeclatura

Dato che ho deciso di usare il modello dei Layer ora voglio speigare un poco meglio come questa procedura deve essere fatta per ogni Layer.

### Bronze

Tutti i nomi del debono iniziare con il nome del sistema, e ogni cosa deve essere rinominato a come sono i file originali.
Esempio : `<sourcesystem>_<entity>` dove questi stanno per:

- `<sourcesystem>` : Nome del sistema (CRM e/o ERP);
- `<entity>` : Nome della tabella nel sistema;

Risultato : `crm_customer_info` -> Colonna customer_info del sistema crm.

### Silver

Tutti i nomi del debono iniziare con il nome del sistema, e ogni cosa deve essere rinominato a come sono i file originali.
Esempio : `<sourcesystem>_<entity>` dove questi stanno per:

- `<sourcesystem>` : Nome del sistema (CRM e/o ERP);
- `<entity>` : Nome della tabella nel sistema;

Risultato : `crm_customer_info` -> Colonna customer_info del sistema crm.

### Gold

Tutti i nomi devono riferisi alla nuova tabella di riferimento e abbinati alla loro realtà.
Esempio : `<category>_<entity>` dove questi stanno ad indicare:

- `<category>` : Descrive il ruolo della tabella `dim` (dimensione) o `fact` (fatti);
- `<entity>` : Nome della colonna dato in modo da essere utile in ambiente Business (`customers`, `products`, `sales`);

Risultato : `dim_customer` -> Colonna customer della tabella `dim`. `fact_sales` -> Colonna sales della tabella `fact`.

## Colonne Nomeclatura

Per quanto invece riguarda la nomenclatura delle colonne è pari a quella delle tabelle però ci sono delle piccole differenze da tenere conto come le chiavi primarie.
Non solo dato che oltre a questo ci sono colonne particolari che servono al livello di controllo quindi vediamo più di preciso cosa intendo.

### Colonne Keys

Tutte le primari Keys delle tabelle devono terminare in questo modo `_key`.

Risultato : `customer_id_key` -> che è la keys primaria della tabella `dim_customer`.

### Colonne Tecniche

Tutte le colonne tecniche devono iniziare con il prefisso `dwh_`, sono utilizzate per creare i cosi detti metadati della tabella non sono presenti nelle tabelle finali, ma sono utili nel progesso fra layer.

Risultato : `dwh_load_date` -> il sistema genera una data di caricamento nella tabella.

### Colonne Storage

Nel creare questo tipo di processo dobbiamo anche poter verificare come funzionano i caricamenti nella procedura di caricamento e queste devono avere il prefisso `load_` prima del indicare il nome del layer.

Risultato : `load_bronze` -> il sistema identifica che in quel momento è stato fatto un caricamento.
