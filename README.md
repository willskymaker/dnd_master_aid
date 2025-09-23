# D&D Master Aid

🎲 **D&D Master Aid** è un'app modulare OPEN SOURCE BETA per la creazione e gestione di personaggi Dungeons & Dragons 5e, pensata per essere leggera, responsive e perfetta sia per nuovi giocatori che per veterani del gioco di ruolo.

⚠️ **VERSIONE BETA** - App in sviluppo attivo con la community! Contributi benvenuti su GitHub.

## 📱 Download Android APK

**🚀 Ultima versione: v1.0.4 BETA**

🎯 **Google Play Store**: In fase di pubblicazione (account sviluppatore in verifica)

📥 **Download diretto APK**:
- [**dnd-master-aid-v1.0.4-balanced.apk**](https://github.com/willskymaker/dnd_master_aid/releases/latest/download/dnd-master-aid-v1.0.4-balanced.apk) (25.8 MB) - **CONSIGLIATA**
- [**dnd-master-aid-v1.0.4-googleplay-final.apk**](https://github.com/willskymaker/dnd_master_aid/releases/latest/download/dnd-master-aid-v1.0.4-googleplay-final.apk) (25.9 MB) - **Google Play Version**

### 📋 Installazione Android

1. **Scarica l'APK** dal link sopra
2. **Abilita installazione da fonti sconosciute**:
   - Vai in `Impostazioni > Sicurezza > Installa app sconosciute`
   - Abilita per il browser o file manager che stai usando
3. **Installa l'APK** toccando il file scaricato
4. **Goditi l'app!** 🎉

### ⚠️ Note di Sicurezza
- L'APK è firmato e sicuro da installare
- Android mostrerà un avviso per le "app non verificate" - è normale per APK non distribuiti via Play Store
- Tocca "Installa comunque" per procedere

### 🔄 Aggiornamenti
Gli aggiornamenti verranno rilasciati come nuove release su GitHub. Controlla regolarmente per le nuove versioni!

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

### ✅ Funzionalità Disponibili:

#### 🧙‍♂️ **Creazione Personaggi**
- **Generatore Nome**: combinazione di prefissi/suffissi fantasy
- **Selezione Specie**: 30+ razze con sottospecie e abilità complete
- **Selezione Classe**: 12 classi con 80+ sottoclassi ufficiali
- **Gestione Livello**: progression e abilità per livello
- **Caratteristiche**: inserimento con ASI e modificatori automatici
- **Equipaggiamento**: 200+ oggetti (armi, armature, gear)
- **Riepilogo & Export PDF**: personaggio completo in formato stampabile

#### 📚 **Database D&D 5e Completo**
- **500+ Incantesimi**: cantrip fino a 9° livello con meccaniche complete
- **30+ Specie**: tutte le razze ufficiali con sottospecie
- **12 Classi**: tutti gli archetipi e sottoclassi del Player's Handbook
- **200+ Equipaggiamento**: armi, armature, oggetti avventura, kit
- **25+ Background**: sfondi con competenze e caratteristiche
- **35+ Talenti**: abilità speciali con prerequisiti
- **Bestiary**: creature e mostri per i DM

#### 🎲 **Strumenti Utility**
- **Dadi Digitali**: roller completo per tutti i tipi di dado
- **Generatore Nomi**: per personaggi e NPC fantasy
- **Browser Database**: interfaccia mobile per esplorare tutto il contenuto D&D 5e

#### 📱 **Mobile-First Design**
- **UI Responsive**: ottimizzata per smartphone e tablet
- **Touch-Friendly**: controlli pensati per schermi touch
- **Offline-Ready**: database locale, funziona senza internet
- **Performance**: build ottimizzati per dispositivi mobili


```

### 📦 Requisiti (Solo per Sviluppatori)

Per utilizzare l'app, scarica semplicemente l'APK Android! Per lo sviluppo:

- **Dart** >= 3.7.2
- **Flutter** >= 3.32.8
- **Dipendenze principali**: `provider`, `logger`, `pdf`, `path_provider`
- **Piattaforme supportate**: ✅ Android, ✅ Web, iOS (in sviluppo), Desktop
- Git per la gestione delle versioni
- Editor consigliato: Visual Studio Code

### 🛠️ Installazione e Avvio

```bash
# Clone del repository
git clone https://github.com/tuo-username/DnD_MasterAid.git
cd DnD_MasterAid

# Installazione dipendenze
flutter pub get

# Avvio in modalità debug
flutter run -d chrome  # Per web
flutter run -d linux   # Per desktop Linux
flutter run -d android # Per Android

# Build di produzione
flutter build web --release
```

---

## 🧭 Roadmap & Implementazioni Future

### 🔧 A breve
- [x] ~~Completamento del riepilogo finale del PG~~
- [x] ~~Gestione dei punti ferita in base a classe e livello~~
- [x] ~~Gestione della Classe Armatura (CA)~~
- [x] ~~Esportazione del personaggio in **PDF**~~
- [ ] Layout PDF migliorato con grafica (`scheda_pg_blank_base.png`)
- [ ] Modalità "Avanzata" per utenti esperti
- [ ] Salvataggio persistente dei personaggi
- [ ] Sistema di undo/redo negli step

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

**Sviluppatore**: William Donzelli (alias **Willskymaker**)
**Collaborazione**: **APS FareZero Makers FabLab**
**Community**: Contributori GitHub e beta testers
**Status**: Progetto Open Source in sviluppo attivo

**🔗 Collegamenti**:
- **GitHub**: https://github.com/willskymaker/dnd_master_aid
- **Google Play Store**: In pubblicazione
- **FareZero Makers**: Supporto tecnico e community
- **Licenza**: MIT License - Libero per tutti

---

> Realizzato con passione dalla community open source per i giocatori di D&D 🎲❤️
