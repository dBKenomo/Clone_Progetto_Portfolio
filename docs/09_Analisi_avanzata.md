# Analisi Avanzata dei Dati

Oltre alla creazione di un Warehouse e all'analisi esplorativa (EDA), un pilastro fondamentale del lavoro del Data Analyst è l'**Advanced Analytics**. Questo processo si spinge oltre la semplice comprensione dei dati per rispondere a specifiche domande di business, identificare trend nel tempo, confrontare performance e segmentare utenti o prodotti utilizzando tecniche SQL avanzate come le **window functions**, le **CTE** (Common Table Expressions) e le **subquery**.

L'obiettivo finale è trasformare dati grezzi in insight strategici pronti per essere consumati dagli stakeholder attraverso report consolidati.

## Analisi dei Cambiamenti nel Tempo

Questa tecnica analizza l'evoluzione di una misura (es. vendite, costi) attraverso una dimensione temporale per tracciare i trend e identificare la **stagionalità** dei dati. La formula prevede l'aggregazione di una misura basata su una data (anno, mese, giorno).

- **Utilità:** Permette di visualizzare immediatamente se il business è in crescita o in declino e quali periodi dell'anno (es. Dicembre per le festività) sono più proficui.

- **Tecnica SQL:** Si utilizzano funzioni di estrazione della data o funzioni di troncamento per regolare la granularità dell'analisi.

## Analisi Cumulativa

L'analisi cumulativa aggrega i dati progressivamente nel tempo. A differenza dell'aggregazione standard, ogni riga aggiunge il proprio valore alla somma di tutte le righe precedenti.

- **Utilità:** È essenziale per comprendere la **progressione** e la crescita totale del business nel lungo periodo, evidenziando come i risultati si accumulino.

- **Tecnica SQL:** Si implementa tipicamente con funzioni di aggregazione applicate come window functions (es. `SUM(...) OVER (ORDER BY date)`), che permettono di calcolare il **Running Total** o la **Media Mobile**.

## Analisi delle Performance

Questa analisi consiste nel confrontare il valore attuale di una metrica con un valore target o di riferimento per misurarne il successo.

- **Confronti comuni:** Il valore attuale può essere comparato con la media globale, con il record più alto/basso o con il periodo precedente (analisi **Year-over-Year** o **Month-over-Month**).

- **Indicatori:** Attraverso il calcolo della differenza, è possibile creare dei "flag" o indicatori (es. "Sopra la media", "In aumento", "In diminuzione") per identificare rapidamente i top e i bottom performer.

- **Tecnica SQL:** Vengono utilizzate window functions di valore come `LAG()` (per accedere al record precedente) o aggregazioni pesate su partizioni specifiche.

## Analisi Part-to-Whole

L'analisi "dal particolare al tutto" determina la proporzione di una singola categoria rispetto al totale complessivo.

- **Utilità:** Aiuta a capire il peso specifico di ogni elemento (es. quanto una categoria di prodotti incide sul fatturato totale).

- **Insight strategico:** Identificare se un'azienda dipende eccessivamente da una sola categoria (es. se le biciclette generano il 69% delle vendite) permette di valutare i rischi di concentrazione del business.

- **Tecnica SQL:** Si divide la misura della categoria per la misura totale calcolata tramite una window function senza partizione (`SUM(...) OVER()`), moltiplicando poi per 100 per ottenere la percentuale.

## Segmentazione dei Dati

La segmentazione consiste nel raggruppare i dati in nuove categorie basate su intervalli di valori numerici. In questo processo, **una misura viene trasformata in una dimensione**.

- **Esempi:** Classificare i prodotti in fasce di costo (Basso, Medio, Alto) o i clienti in base al loro comportamento d'acquisto (es. **VIP**, Clienti Regolari, Nuovi Clienti).

- **Tecnica SQL:** Si utilizza l'istruzione `CASE WHEN` per definire le regole logiche di segmentazione basate su misure come il totale speso o la longevità del cliente (*lifespan*).

## Reporting e Consolidamento

L'ultima fase dell'analisi avanzata è il consolidamento di tutte le metriche (KPI, segmenti, aggregazioni) in un'unica struttura logica, spesso salvata nel database come **View**.

- **Visione a 360 gradi:** Un report efficace (es. *Customer Report*) deve unire dettagli anagrafici, metriche comportamentali (Recency, valore medio degli ordini) e segmentazioni in un unico punto di accesso.

- **Vantaggi:** Questo approccio modulare permette ad altri analisti o stakeholder di interrogare direttamente la View per generare insight veloci o alimentare dashboard in strumenti come Power BI o Tableau senza dover riscrivere logiche complesse.
