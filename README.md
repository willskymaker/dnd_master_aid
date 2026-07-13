# Master Aid

🎲 **Master Aid** è un'app open source pensata per essere un aiuto concreto ai master di giochi di ruolo. Al momento supporta **Dungeons & Dragons 5e** (creazione personaggi, scheda viva, tracker di combattimento), con l'obiettivo di aggiungere altri giochi in futuro, uno alla volta. Funziona **100% offline**: nessun account, nessuna raccolta dati.

## 🚀 Prova l'app

**Versione Web (consigliata, sempre aggiornata)**: **https://willskymaker.github.io/master_aid/**

Funziona da browser desktop o mobile, senza installare nulla.

Per Android/iOS/desktop non ci sono ancora build precompilate distribuite: vedi la sezione [Per sviluppatori](#-per-sviluppatori) per compilare l'app dal sorgente.

---

## 📖 Guida utente

### 🧙 Creazione personaggio

Un wizard guidato passo-passo crea un personaggio D&D 5e completo:

1. **Nome** — generatore automatico con temi (fantasy classico, piratesco, lovecraftiano, ecc.) o inserimento manuale
2. **Specie** — 30+ razze ufficiali con sottospecie
3. **Classe** — 12 classi con sottoclassi
4. **Livello** — punti ferita, ASI (Ability Score Improvement) calcolati automaticamente in base a classe e livello
5. **Caratteristiche** — inserimento con modificatori automatici
6. **Background** — sfondi con competenze e linguaggi
7. **Equipaggiamento** — scelta manuale o **randomizzazione automatica coerente con la classe** (arma, armatura, kit e strumenti consigliati in base alle competenze reali della classe scelta)
8. **Riepilogo ed esportazione PDF** — scheda finale stampabile

### 📋 Scheda viva (Personaggi salvati)

I personaggi creati si salvano localmente sul dispositivo. Da qui puoi:

- Aggiornare PF, condizioni e altri valori durante il gioco
- **Salire o scendere di livello** (utile per correggere un errore)
- **Correggere le caratteristiche** dopo la creazione
- **Eliminare** un personaggio salvato

### ⚔️ Tracker di combattimento

Il centro di controllo del master durante un combattimento:

- Ordine di iniziativa, PF, CA/CD, condizioni per ogni combattente
- Azioni leggendarie e tiri salvezza contro la morte per i PG a 0 PF
- **Generatore di incontri casuali** in base alla soglia XP del party
- **Incontri preparati**: salva un gruppo di mostri con un nome e ricaricalo in futuro (utile per incontri ricorrenti)
- **Danni tipizzati**: applica un danno con un tipo specifico (fuoco, freddo, veleno, ecc.) e il tracker calcola automaticamente resistenze/immunità/vulnerabilità del mostro
- **Suggerimento tattico**: nella vista dettagli di un mostro, un breve suggerimento testuale su come potrebbe comportarsi questo turno (non è un'IA, solo un'euristica basata su Saggezza/Intelligenza/PF)
- **Generatore di bottino**
- Scorciatoie dirette a tiradadi e card incantesimi

### 🎲 Dadi

Roller completo con supporto a **più tipi di dado contemporaneamente** (es. 1d20 + 1d6), **preset salvabili** (nome, quantità, tipo, modificatore — impostabili liberamente), skin cosmetiche e feedback audio su critici/fallimenti.

### 📛 Generatore di nomi

Nomi a tema per PNG e personaggi, con stili diversi oltre alla specie del personaggio.

### 📚 Card incantesimi

Consultazione rapida degli incantesimi in formato scheda.

---

## 🛠️ Per sviluppatori

Setup rapido:

```bash
git clone https://github.com/willskymaker/master_aid.git
cd master_aid
flutter pub get
flutter run -d chrome   # oppure -d linux, -d android...
```

Requisiti: Dart >= 3.7.2, Flutter >= 3.32.

Per il flusso di lavoro completo (issue → branch → PR → merge), le convenzioni di stile e come trovare una prima issue da risolvere, vedi **[CONTRIBUTING.md](CONTRIBUTING.md)**.

### Architettura

```
lib/
├── core/              # Utilities base (tema, logger)
├── data/              # Database statici D&D 5e (specie, classi, incantesimi, equip, ecc.)
├── services/          # Business logic e validazione
├── repositories/       # Accesso dati (JSON statici + personaggi salvati)
├── providers/         # State management (Provider)
├── pg_base/            # Wizard di creazione personaggio (uno step per file)
├── utils/             # Funzioni pure riutilizzabili (generatore incontri, danni tipizzati, suggerimenti tattici, ecc.)
├── widgets/           # Widget riutilizzabili
└── screens/           # Schermate principali (tracker, dadi, personaggi salvati, ecc.)
```

---

## 🤝 Contribuire

Il progetto è aperto a contributi — apri una issue, proponi una PR, o segnala un bug. Per iniziare, guarda le issue con la label [`good first issue`](https://github.com/willskymaker/master_aid/labels/good%20first%20issue) e leggi **[CONTRIBUTING.md](CONTRIBUTING.md)**.

---

## 📜 Licenza

Questo progetto è distribuito sotto licenza **MIT**. Consulta il file [`LICENSE`](LICENSE) per i dettagli.

---

## 👑 Credits

**Sviluppatore**: William Donzelli (alias **Willskymaker**)
**Grafica e design**: Gianluca (alias **Stronka2112**), grafico e master di giochi di ruolo
**Collaborazione**: **APS FareZero Makers FabLab**
**Community**: Contributori GitHub e beta testers

**🔗 Collegamenti**:
- **App Web**: https://willskymaker.github.io/master_aid/
- **GitHub**: https://github.com/willskymaker/master_aid

---

> Realizzato con passione dalla community open source per i giocatori di D&D 🎲❤️
