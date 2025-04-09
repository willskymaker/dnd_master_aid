// lib/data/db_competenze.dart

class Competenza {
  final String nome;
  final String tipo; // "arma", "armatura", "strumento", "linguaggio"
  final String descrizione;

  Competenza({
    required this.nome,
    required this.tipo,
    required this.descrizione,
  });
}

final List<Competenza> competenzeList = [
  Competenza(
    nome: "Armi semplici",
    tipo: "arma",
    descrizione: "Include clave, lance, daghe, balestre leggere e armi di uso comune."
  ),
  Competenza(
    nome: "Armi da guerra",
    tipo: "arma",
    descrizione: "Include spade lunghe, asce bipenne, martelli da guerra e altre armi avanzate."
  ),
  Competenza(
    nome: "Armature leggere",
    tipo: "armatura",
    descrizione: "Include giacche di cuoio e altre armature leggere, che non limitano la mobilità."
  ),
  Competenza(
    nome: "Armature medie",
    tipo: "armatura",
    descrizione: "Include cotte di maglia e armature a scaglie, che offrono protezione bilanciata."
  ),
  Competenza(
    nome: "Armature pesanti",
    tipo: "armatura",
    descrizione: "Include armature a piastre e simili, che forniscono massima protezione ma limitano i movimenti."
  ),
  Competenza(
    nome: "Scudi",
    tipo: "armatura",
    descrizione: "Permette l’uso efficace degli scudi per aumentare la Classe Armatura."
  ),
  Competenza(
    nome: "Strumenti da artigiano",
    tipo: "strumento",
    descrizione: "Include strumenti come martello e scalpello, attrezzi da fabbro, vetraio, falegname, ecc."
  ),
  Competenza(
    nome: "Strumenti musicali",
    tipo: "strumento",
    descrizione: "Include liuti, flauti, tamburi, cornamuse e altri strumenti da performance."
  ),
  Competenza(
    nome: "Attrezzi da ladro",
    tipo: "strumento",
    descrizione: "Contengono grimaldelli, lime e strumenti per scassinare serrature."
  ),
  Competenza(
    nome: "Kit da erborista",
    tipo: "strumento",
    descrizione: "Strumenti per creare pozioni base, antidoti e identificare piante."
  ),
  Competenza(
    nome: "Tutte le lingue",
    tipo: "linguaggio",
    descrizione: "Conoscenza universale di ogni lingua parlata e scritta."
  ),
];