# DnD_MasterAid

🎲 **DnD_MasterAid** è un'app modulare per la creazione e gestione di personaggi Dungeons & Dragons 5.5e, pensata per essere leggera, responsive e perfetta sia per nuovi giocatori che per veterani del gioco di ruolo.

## 🚀 Stato Attuale

Il progetto è scritto in **Dart** con **Flutter** e supporta completamente **Flutter Web**. Dispone di un'architettura robusta con state management (Provider), logging strutturato, gestione errori avanzata e separazione tra business logic e UI.

### 🏗️ Architettura

```
lib/
├── core/              # Utilities base (logger, exceptions)
├── data/              # Database statici + enums standardizzati
├── services/          # Business logic e validazione
├── repositories/      # Accesso dati con cache
├── providers/         # State management (Provider pattern)
├── widgets/           # Widget riutilizzabili
└── screens/           # UI screens
```

**Attualmente si sta sviluppando il modulo **PG Base**, che permette la generazione guidata di un personaggio con i parametri fondamentali:**

### ✅ Moduli completati o in corso:
- **Generatore Nome**: combinazione di prefissi/suffissi fantasy.
- **Step Specie & Sottospecie**: selezione tra le specie principali della 5.5e con riepilogo abilità e bonus.
- **Step Classe**: selezione della classe base con tiri salvezza, competenze, abilità e dado vita.
- **Step Livello**: gestione livello personaggio e sue implicazioni.
- **Step Caratteristiche**: inserimento caratteristiche base, evidenziazione delle principali in base alla classe scelta, supporto ASI.
- **Step Equipaggiamento**: selezione di armi, armature e oggetti compatibili con la classe.
- **Riepilogo Personaggio**: visione completa delle scelte effettuate (in corso di completamento).
- **Database centralizzati**: per specie, classi, background, talenti, equipaggiamento, incantesimi e slot.


```

### 📦 Requisiti
- Dart >= 3.2.0
- Compatibile con Flutter Web (in corso di test)
- Git per la gestione delle versioni
- Editor consigliato: Visual Studio Code

---

## 🧭 Roadmap & Implementazioni Future

### 🔧 A breve
- [ ] Completamento del riepilogo finale del PG
- [ ] Gestione dei punti ferita in base a classe e livello
- [ ] Gestione della Classe Armatura (CA)
- [ ] Esportazione del personaggio in **PDF** su base grafica (`scheda_pg_blank_base.png`)
- [ ] Modalità “Avanzata” per utenti esperti

### 📘 Regole & Meccaniche
- [ ] Implementazione ASI automatica in base al livello
- [ ] Gestione dei talenti alternativi agli ASI
- [ ] Calcolo incantesimi, trucchetti e slot in base a classe e livello
- [ ] Background: selezione e impatto su competenze e linguaggi
- [ ] Supporto multilingua (🇮🇹 / 🇺🇸)

### 🎮 Tool aggiuntivi (extra modulabili)
- [ ] **TiraDadi** con supporto a più dadi (es. 8d6)
- [ ] **Gestione Campagna** (giocatori, sessioni, loot)
- [ ] **Bestiario Interattivo** per master
- [ ] **Foglio Note** e diario digitale

---

## 🤝 Contribuire

Il progetto è aperto a contributi! Puoi:
- Aprire una Issue
- Inviare una Pull Request
- Segnalare bug o richieste via [GitHub Issues](https://github.com/tuo-username/DnD_MasterAid/issues)

🎯 Issue "good first contribution"

Stiamo creando una serie di issue etichettate come good first contribution, ideali per chi vuole iniziare a contribuire al progetto. Ecco alcune che puoi aprire:

📌 [good first issue] Aggiungi nuove armi

Popola db_equipaggiamento.dart con armi mancanti secondo lo schema esistente. Puoi includere anche armi homebrew.

📌 [good first issue] Aggiungi nuove armature

Inserisci nuove voci nel db_equipaggiamento.dart per completare le categorie di armature (leggere, medie, pesanti, scudi).

📌 [good first issue] Estendi le specie disponibili

Aggiungi specie o sottospecie mancanti al db_specie.dart, inclusi contenuti homebrew bilanciati.

📌 [good first issue] Estendi le classi disponibili

Integra nuove classi o sottoclassi nel db_classi.dart seguendo lo schema di quelle esistenti.

📌 [good first issue] Inserisci talenti o background

Completa il db_talenti.dart o db_background.dart con voci mancanti, utilizzando i dati ufficiali o homebrew coerenti.

📌 [good first issue] Aggiungi trucchetti e incantesimi

Popola db_incantesimi.dart con trucchetti (cantrip) e magie di livello 1, organizzati per classe.

Ci sono ancora tanti bug da risolvere e fix da fare, non abbiate timore, aprite issues e cerchiamo di risolvere!

Per ogni issue:

Segui la struttura dati esistente nel file corrispondente

Assicurati che le modifiche non rompano il flusso PG Base

Apri una PR chiara e motivata (screenshot benvenuti!)


---

## 📜 Licenza

Questo progetto è distribuito sotto licenza **MIT**. Consulta il file `LICENSE` per i dettagli.

---

## 👑 Credits

---

> Realizzato con passione da William "willskymaker" e la community Nerd Friends 🧠❤️
