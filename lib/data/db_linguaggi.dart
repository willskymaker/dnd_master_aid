// lib/data/db_linguaggi.dart

class Linguaggio {
  final String nome;
  final String tipo; // "comune", "esotico", "segreto"
  final String descrizione;

  Linguaggio({
    required this.nome,
    required this.tipo,
    required this.descrizione,
  });
}

final List<Linguaggio> linguaggiList = [
  Linguaggio(
    nome: "Comune",
    tipo: "comune",
    descrizione: "Il linguaggio più diffuso tra le razze civilizzate. Tutti i personaggi lo conoscono all'inizio."
  ),
  Linguaggio(
    nome: "Nanico",
    tipo: "comune",
    descrizione: "Parlato dai nani e scritto con l’alfabeto nanico. Caratterizzato da precisione e tradizione."
  ),
  Linguaggio(
    nome: "Elfico",
    tipo: "comune",
    descrizione: "Lingua melodiosa e antica, parlata dagli elfi. Usa l’alfabeto elfico."
  ),
  Linguaggio(
    nome: "Goblin",
    tipo: "comune",
    descrizione: "Lingua aspra usata da goblin, bugbear e hobgoblin. Scritta con l’alfabeto nanico."
  ),
  Linguaggio(
    nome: "Orchesco",
    tipo: "comune",
    descrizione: "Lingua gutturale usata da orchi e mezzorchi. Deriva dal nanico e ne condivide l’alfabeto."
  ),
  Linguaggio(
    nome: "Draconico",
    tipo: "esotico",
    descrizione: "Lingua degli antichi draghi e degli studiosi di magia. Scritta con l’alfabeto draconico."
  ),
  Linguaggio(
    nome: "Infernale",
    tipo: "esotico",
    descrizione: "Lingua strutturata e formale parlata dai diavoli. Usa l’alfabeto infernale."
  ),
  Linguaggio(
    nome: "Celestiale",
    tipo: "esotico",
    descrizione: "Linguaggio armonioso degli esseri celesti. Usa l’alfabeto celestiale."
  ),
  Linguaggio(
    nome: "Abissale",
    tipo: "esotico",
    descrizione: "Lingua aspra e caotica usata dai demoni. Usa l’alfabeto infernale."
  ),
  Linguaggio(
    nome: "Primordiale",
    tipo: "esotico",
    descrizione: "Lingua degli elementali, suddivisa in dialetti (Auran, Ignan, Terran, Aquan)."
  ),
  Linguaggio(
    nome: "Cant Thieves",
    tipo: "segreto",
    descrizione: "Linguaggio segreto usato da ladri e criminali per comunicare senza essere capiti."
  ),
];