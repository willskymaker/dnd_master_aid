# DnD MasterAid 🧙‍♂️🎲

> Una toolkit Flutter per aiutare giocatori e master di D&D nella creazione e gestione di personaggi, tiri di dado e generatori vari. Semplice, modulare e open source!

---

## 🔧 Funzionalità Implementate

- **🎲 Tira Dadi**: Lancio dei dadi classici (d4, d6, d8, d10, d12, d20, d100)
- **🧙 Generatore di Nomi**: Generazione di nomi fantasy con prefisso/suffisso
- **🧑‍🎓 Crea PG Base**: Sistema guidato per creare un personaggio con:
  - Selezione specie e classe
  - Point Buy semplificato
  - Calcolo automatico HP e CA
  - Scelta armi, armatura e competenze
  - Esportazione in PDF su layout grafico

## 🛠 Tecnologie

- **Flutter 3.19+** (supporto multi-piattaforma)
- **Dart**
- `pdf`, `printing` e `flutter_full_pdf_viewer` per il rendering dei PDF

## 📂 Struttura del Progetto

```
lib/
├── main.dart
├── screens/
│   ├── pg_base.dart
│   ├── dice_roller.dart
│   └── name_generator.dart
├── utils/
│   └── pdf_generator.dart
├── assets/
│   └── images/
│       └── scheda_pg_base.png
```

## 🔜 Funzionalità Future (Roadmap)

- [ ] Modalità avanzata di creazione PG (background, talenti, incantesimi)
- [ ] Generatore di PNG con tratti di personalità
- [ ] Generatore di Mostri e Mob
- [ ] Salvataggio e caricamento personaggi
- [ ] Modalità "Campagna" per gestire più personaggi insieme

## 🧑‍💻 Contribuire

1. Fai una fork del progetto
2. Crea una nuova branch: `git checkout -b feature/NomeFunzione`
3. Fai commit e push
4. Apri una Pull Request 🚀

## 📝 Licenza

Questo progetto è distribuito sotto licenza **MIT**. Vedi il file `LICENSE` per dettagli.

---

> Realizzato con passione da William "willskymaker" e la community Nerd 🧠❤️
