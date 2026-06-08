# Cosa bisogna decidere

Segliere cosa bisogna costruire in questo caso una Data Warehouse utilizzando il metodo della archittetura a medaglia dove al posto di passare ad un approccio poco chiaro si preferisce la scelta di usare un metodo a passi.

## Design del Layer

Dato che abbiamo definito di utilizzare il metodo del processo ora vediamo a modo come viene definito il livello di layer un poco più nello specifico.

| | Bronze Layer | Silver Layer | Gold Layer |
| ---- | -------------- | -------------- | ------------ |
| Definizione | Dati non processati e diretti dalla sorgente | Pulire e standerdizzare i dati | Dati Finali |
| Oggetto | Tracciabilità e Debugging | Preparazione per Data Analysis | Dati pronti per essere consumati nei report |
| Tipi di Ogetto | Tabelle | Tabelle | Visualizzazione |
| Metodo di caricamento | Full Load (Truncate & Insert) | Full Load (Truncate & Insert) | None |
| Data Trasformazione | None | - Data Cleaning - Data Standardization - Data Normalization - Derived Columns - Data Enrichement | - Data Integration - Data Aggregation - Business Logic & Rules |
| Modello dei Dati | None | None | -Start Schema - Aggregated Objects - Flat Tables |
| Target | Data Engineers | Data Analysts & Data Engineers | Data Analysts & Business Users |

![Data Warehouse Architecture](Diagramma%20Achittetura.drawio.png)
