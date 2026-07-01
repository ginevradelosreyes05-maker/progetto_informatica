# Sistema Automatico di Triage Medico e Gestione Logistica

Questo progetto è un'applicazione software avanzata sviluppata in **MATLAB App Designer** per la simulazione, il triage e la gestione logistica dei flussi di pazienti all'interno di un Pronto Soccorso. 

Il sistema automatizza l'assegnazione dei codici colore di priorità clinica analizzando i parametri vitali e la sintomatologia. Integra un controllo incrociato con l'anamnesi del paziente e **alloca dinamicamente il reparto di destinazione** calcolando una stima in tempo reale dei **minuti di attesa** basata sul carico effettivo delle risorse ospedaliere.

---

## 🚀 Funzionalità Chiave

* **Calcolo Algoritmico della Gravità:** Assegnazione istantanea del codice di priorità (*Rosso, Giallo, Verde*) basata sui range fisiologici dei parametri vitali.
* **Controllo Incrociato di Sicurezza:** Verifica in tempo reale se la sintomatologia corrente contiene sostanze, allergeni o farmaci a cui il paziente è storicamente vulnerabile.
* **Allocazione Logistica Intelligente:** Smistamento dinamico del paziente nei reparti di *Medicina Generale*, *Cardiologia* o *Pediatria*. 
* **Algoritmo di Calcolo delle Code:** Stima dei minuti di attesa pesata in base al codice colore assegnato, al numero di medici attualmente in turno e al tasso di saturazione delle stanze del reparto specifico.
* **Persistenza Dati Unificata (Database Relazionale):**  Il sistema si appoggia a un database relazionale locale simulato (`database_ospedale.mat`) composto dalle tabelle strutturate `PAZIENTE` (anagrafica e storico clinico) e `TRIAGE` (registro storico degli accessi).
* **Feedback Multimediale:** Indicatori visivi cromatici dinamici e allarmi acustici d'emergenza modulati in frequenza per i Codici Rossi.

---

## 📊 Criteri Clinici di Assegnazione

Il sistema applica la seguente logica decisionale basata su score di urgenza:

| Parametro | Codice Verde 🟢 | Codice Giallo 🟡 | Codice Rosso 🔴 |
| :--- | :--- | :--- | :--- |
| **Saturazione ($SpO_2$)** | $\ge 95\%$ | $90\% - 94\%$ | $< 90\%$ |
| **Frequenza Cardiaca (FC)** | $50 - 110 \text{ bpm}$ | $40 - 49$ o $111 - 130 \text{ bpm}$ | $< 40$ o $> 130 \text{ bpm}$ |
| **Pressione Sistolica (PA)** | $90 - 160 \text{ mmHg}$ | $80 - 89$ o $161 - 200 \text{ mmHg}$ | $< 80$ o $> 200 \text{ mmHg}$ |
| **Sintomi Critici** | Assenti / Lavorabili | Dolore, dispnea, febbre alta | Arresto, incoscienza, dolore toracico forte |

---

## 📁 Struttura del Repository

```text
├── applicazioneBottone.mlapp   # File sorgente dell'interfaccia grafica (App Designer) con logica e callback
├── valutaTriage.m              # Algoritmo puro di calcolo clinico e sottomodulo di formattazione del testo
├── creaDatabase.m              # Script di inizializzazione per generare la struttura vuota del database relazionale
└── README.md                   # Documentazione del progetto
