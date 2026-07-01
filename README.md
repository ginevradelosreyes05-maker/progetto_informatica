# TriageAutomation & LogisticOsp

Applicazione software desktop per l'automazione del triage medico e la gestione decisionale della logistica ospedaliera, sviluppata come elaborato progettuale per il corso di Fondamenti di Informatica.

Il sistema acquisisce i parametri vitali del paziente e la sintomatologia corrente, esegue l'analisi incrociata con l'anamnesi storica salvata su un database relazionale locale, assegna i codici colore di urgenza clinica, smista il flusso dei pazienti verso i reparti dedicati e stima dinamicamente i tempi di attesa basandosi sulla saturazione logistica delle risorse in tempo reale.

---

## 🔗 Obiettivo del progetto

L'obiettivo è modellare un workflow realistico di accoglienza, valutazione e smistamento dei pazienti all'interno di un dipartimento di emergenza-urgenza (Pronto Soccorso):

* **Acquisizione guidata e controllo di integrità dei parametri vitali** del paziente.
* **Storicizzazione persistente degli accessi** correlati a uno stesso identificativo univoco.
* **Analisi clinica multimodale** basata su soglie fisiologiche combinate (Saturazione, Frequenza Cardiaca, Pressione Sistolica).
* **Generazione di alert ed attivazione di routine multimediali** per i codici ad alta priorità.
* **Supporto alle decisioni logistiche** tramite algoritmi di queuing teorico per il calcolo dei tempi d'attesa.

---

## 🔗 Contesto scientifico

Il progetto si colloca nel filone dell'informatica medica applicata ai sistemi di supporto alle decisioni cliniche (CDSS - *Clinical Decision Support Systems*) e all'ottimizzazione dei processi organizzativi sanitari (*Healthcare Operations Management*), con particolare attenzione all'integrità del dato e alla riduzione dei tempi di sosta critica.

---

## 🔗 Funzionalità principali

| Area | Implementazione |
| :--- | :--- |
| **Gestione pazienti** | Identificazione univoca tramite Codice Fiscale, rilevamento automatico dell'età, gestione automatizzata dell'anonimato. |
| **Acquisizione dati** | Input interattivo via GUI (*App Designer*) dei parametri vitali e campo note testuale per la sintomatologia. |
| **Persistenza dati** | Database relazionale locale simulato su tabelle strutturate (`PAZIENTE` e `TRIAGE`) con vincoli di integrità e chiavi esterne. |
| **Analisi clinica** | Valutazione algoritmica combinata dei parametri vitali con classificazione in Codice Verde, Giallo o Rosso. |
| **Logistica e Smistamento** | Algoritmo di instradamento automatico verso i reparti (*Medicina*, *Cardiologia*, *Pediatria*) basato su vincoli di età e parole chiave testuali. |
| **Stima delle code** | Calcolo dinamico dei tempi di attesa pesato sui medici in turno, occupazione delle stanze ed effetto stocastico del codice colore. |
| **Feedback e Allarmi** | Modulo multimediale per l'attivazione di riscontri cromatici (lampade grafiche) e segnali acustici d'emergenza in frequenza. |

---

## 🔗 Stack tecnologico

* **MATLAB R2020a+** (Ambiente di sviluppo principale)
* **MATLAB App Designer** (Framework per lo sviluppo dell'interfaccia utente)
* **MATLAB Table Object Engine** (Motore relazionale per la gestione dei dataset locali)
* **Audio and Graphic Interface Toolbox** (Generazione di segnali d'allarme acustici e visivi)

---

## 🔗 Flusso logico del sistema

```mermaid
graph TD
    A[Nuova Sessione Triage] --> B{Controllo Integrità CF}
    B -- Errato --> C[Notifica Errore UI]
    B -- Valido --> D[Caricamento Database .mat]
    D --> E{Verifica Esistenza Paziente}
    E -- No --> F[Creazione record PAZIENTE Anonimo]
    E -- Sì --> G[Recupero Allergie e Storico Clinico]
    F --> H[Esecuzione Algoritmo valutaTriage]
    G --> H
    H --> I[Assegnazione Codice Colore]
    I --> J[Smistamento Logistico Reparto ed Età]
    J --> K[Calcolo Dinamico Minuti di Attesa]
    K --> L[Aggiornamento GUI Table, Lamp e Audio]
    L --> M[Salvataggio Record Accesso in Tabella TRIAGE]
    M --> N[Commit delle modifiche sul file .mat] ```

---

## 🔗 Criteri di Triage e Gestione Clinica

Il modulo di processamento e classificazione implementa le seguenti logiche:

* **Classificazione della Gravità:** Analisi su finestre di tolleranza rigide per $SpO_2$, Frequenza Cardiaca e Pressione Sistolica.
* **Controllo di Sicurezza Incrociato:** La sintomatologia introdotta a testo libero viene scansionata e confrontata in tempo reale con le stringhe delle allergie storiche del paziente estratte dal database.
* **Logica Pediatrica Avanzata:** Reindirizzamento tassativo al reparto di *Pediatria* in presenza di età inferiore ai 14 anni o in caso di match testuale con keyword dedicate (*"bambino"*, *"bambina"*).

### 📊 Criteri Clinici di Assegnazione

| Parametro | Codice Verde 🟢 | Codice Giallo 🟡 | Codice Rosso 🔴 |
| :--- | :--- | :--- | :--- |
| **Saturazione ($SpO_2$)** | $\ge 95\%$ | $90\% - 94\%$ | $< 90\%$ |
| **Frequenza Cardiaca (FC)** | $50 - 110 \text{ bpm}$ | $40 - 49$ o $111 - 130 \text{ bpm}$ | $< 40$ o $> 130 \text{ bpm}$ |
| **Pressione Sistolica (PA)** | $90 - 160 \text{ mmHg}$ | $80 - 89$ o $161 - 200 \text{ mmHg}$ | $< 80$ o $> 200 \text{ mmHg}$ |
| **Sintomi Critici** | Assenti / Lavorabili | Dolore, dispnea, febbre alta | Arresto, incoscienza, dolore toracico forte |

---

## 🔗 Architettura del Database Locale

Il sistema gestisce l'archiviazione mediante un file strutturato unico `database_ospedale.mat`, il quale riproduce le logiche di un database relazionale attraverso due tabelle principali collegate da una relazione $1:N$ (*Uno a Molti*):

```mermaid
erDiagram
    PAZIENTE {
        string CodiceFiscale PK
        string NomeCognome
        int Eta
        string Allergie
        string StoricoClinico
    }
    TRIAGE {
        int ID_Triage PK
        string FK_Paziente FK
        float FrequenzaCardiaca
        float PressioneSistolica
        float SaturazioneOssigeno
        string Sintomi
        string CodiceAssegnato
        string DataOra
        string RepartoAssegnato
        int MinutiAttesa
    }
    PAZIENTE ||--|{ TRIAGE : "effettua (1,N)"
        int MinutiAttesa
    }
    PAZIENTE ||--|{ TRIAGE : "effettua (1,N)"
