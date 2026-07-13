# Contribuire a Master Aid

Grazie per l'interesse! Questa guida spiega come proporre una modifica, dal setup dell'ambiente alla pull request.

## Setup ambiente

Serve Flutter (>= 3.32) e Dart (>= 3.7.2).

```bash
git clone https://github.com/willskymaker/master_aid.git
cd master_aid
flutter pub get
flutter run -d chrome   # per sviluppare rapidamente in web
```

Editor consigliato: Visual Studio Code con l'estensione Flutter/Dart.

## Se non hai mai usato Git

Nessun problema, ecco i comandi essenziali per questo progetto:

```bash
git clone https://github.com/willskymaker/master_aid.git
cd master_aid
git checkout -b nome-del-tuo-branch     # crea un branch dedicato alla tua modifica
# ... modifica i file ...
git add nome/del/file/modificato.dart
git commit -m "Descrizione breve di cosa hai fatto"
git push -u origin nome-del-tuo-branch
```

Poi apri una Pull Request su GitHub dal branch appena pushato (GitHub te lo propone automaticamente dopo il push). Non serve altro — non modificare mai `main` direttamente, è protetto.

## Flusso di lavoro

1. **Apri una issue prima di iniziare** (o raccogline una già aperta, magari con la label [`good first issue`](https://github.com/willskymaker/master_aid/labels/good%20first%20issue)). Serve a evitare che due persone lavorino sulla stessa cosa e a discutere l'approccio prima di scrivere codice.
2. **Crea un branch** dedicato, partendo da `main` aggiornato.
3. **Implementa** la modifica, seguendo lo stile del codice esistente nel file che stai toccando.
4. **Verifica prima di aprire la PR**:
   ```bash
   flutter analyze
   flutter test
   dart format --output=none --set-exit-if-changed .
   ```
   Se `dart format` segnala differenze, esegui semplicemente `dart format .` per applicarle. La CI blocca la PR se uno di questi tre comandi fallisce.
5. **Apri la Pull Request**, indicando quale issue chiude (es. `Chiude #123` nella descrizione) e cosa hai cambiato.
6. Un maintainer mergia dopo che la CI (`Analyze & Test`) è verde.

## Convenzioni

- **Nomi di dominio in italiano**: variabili, metodi e classi che rappresentano concetti di gioco (personaggi, incantesimi, mostri, ecc.) usano nomi italiani, coerentemente con il resto del codice (es. `_Combattente`, `pfCorrenti`, `classiConsigliate`).
- **`dart format` è obbligatorio**: la CI fallisce se il codice non è formattato. Eseguilo sempre prima di committare.
- **Test per la logica pura**: funzioni che calcolano qualcosa (es. `applicaResistenze`, `suggerimentiTattici`) dovrebbero avere un test unitario in `test/`, non serve testare i widget.
- **Niente commenti superflui**: commenta solo quando il *perché* non è ovvio dal codice (un vincolo nascosto, una scelta controintuitiva) — non descrivere cosa fa il codice se il codice stesso è già chiaro.
- Segui la struttura dati esistente quando aggiungi contenuti ai file in `lib/data/` (specie, classi, incantesimi, equipaggiamento, ecc.).

## Dati D&D 5e e traduzioni

I contenuti in `assets/data/` (mostri, oggetti magici, incantesimi) derivano dal System Reference Document (SRD) di D&D 5e, importati dall'API pubblica di [Open5e](https://api.open5e.com) (licenza OGL/SRD). Molte voci sono ancora solo in inglese: tradurle è un ottimo primo contributo, vedi la issue [`good first issue`](https://github.com/willskymaker/master_aid/labels/good%20first%20issue) dedicata per lo schema da seguire.

## Licenza

Contribuendo a questo repository accetti che il tuo contributo sia distribuito sotto la stessa licenza del progetto (MIT, vedi [`LICENSE`](LICENSE)).
