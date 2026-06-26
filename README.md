# Sistema Automatico di Triage Medico

Questo progetto è un'applicazione software sviluppata in MATLAB App Designer per la simulazione e la gestione del Triage all'interno di un Pronto Soccorso. Il sistema automatizza l'assegnazione dei codici colore di priorità clinica analizzando i parametri vitali, la sintomatologia e integrando un controllo incrociato intelligente con l'anamnesi storica del paziente salvata su file CSV.


## Funzionalità Chiave

**Calcolo Algoritmico della Gravità:** Assegnazione istantanea del codice di priorità (**Rosso**, **Giallo**, **Verde**) in base ai range fisiologici dei parametri vitali.
**Controllo Incrociato di Sicurezza:**  Verifica se la nota sintomatologica corrente contiene sostanze/farmaci a cui il paziente è storicamente allergico.
**Anamnesi:** Rileva combinazioni critiche (es. paziente con storico di diabete che presenta stato confusionale, o storico di ipertensione con crisi pressoria in corso).
* **Persistenza dei Dati :** 'pazienti.csv': Archivio anagrafico centrale (Codice Fiscale, Età, Allergie Note, Patologie Pregresse).
  * `triage.csv`: Registro storico di tutti gli accessi e delle valutazioni effettuate.
* **Feedback Multimediale:** Indicatori visivi dinamici e allarmi acustici d'emergenza generati in frequenza per i Codici Rossi.

---

## Criteri Clinici di Assegnazione

Il sistema applica la seguente logica decisionale basata su score di urgenza:

| Parametro | Codice Verde 🟢 | Codice Giallo 🟡 | Codice Rosso 🔴 |
| :--- | :--- | :--- | :--- |
| **Saturazione (SpO_2)** | $\ge 95\%$ | $90\% - 94\%$ | $< 90\%$ |
| **Frequenza Cardiaca (FC)** | $50 - 110\text{ bpm}$ | $40-49\text{ o }111-130\text{ bpm}$ | $< 40\text{ o }> 130\text{ bpm}$ |
| **Pressione Sistolica (PA)** | $90 - 160\text{ mmHg}$ | $80-89\text{ o }161-200\text{ mmHg}$ | $< 80\text{ o }> 200\text{ mmHg}$ |
| **Sintomi Critici** | Assenti / Lavorabili | Dolore, dispnea, febbre alta | Arresto, incoscienza, dolore toracico forte |

---

## Struttura del Repository

```text
├── TriageApp.mlapp       # File sorgente dell'interfaccia grafica (App Designer)
├── valutaTriage.m        # Algoritmo puro di calcolo e sottomodulo di formattazione text
├── pazienti.csv          # Database anagrafico e clinico storico dei pazienti
└── triage.csv            # Registro storico degli accessi al Pronto Soccorso
