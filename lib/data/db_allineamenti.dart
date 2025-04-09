// lib/data/db_allineamenti.dart

class Allineamento {
  final String nome;
  final String descrizione;

  Allineamento({
    required this.nome,
    required this.descrizione,
  });
}

final List<Allineamento> allineamentiList = [
  Allineamento(
    nome: "Legale Buono",
    descrizione: "Agisce con compassione secondo la legge e l'onore."
  ),
  Allineamento(
    nome: "Neutrale Buono",
    descrizione: "Fa il bene senza preoccupazioni per legge o caos."
  ),
  Allineamento(
    nome: "Caotico Buono",
    descrizione: "Segue il cuore, favorendo libertà e bontà."
  ),
  Allineamento(
    nome: "Legale Neutrale",
    descrizione: "Segue l'ordine, legge o tradizione senza giudizio morale."
  ),
  Allineamento(
    nome: "Neutrale Puro",
    descrizione: "Equilibrato tra bene, male, legge e caos."
  ),
  Allineamento(
    nome: "Caotico Neutrale",
    descrizione: "Ama la libertà e la spontaneità sopra ogni cosa."
  ),
  Allineamento(
    nome: "Legale Malvagio",
    descrizione: "Usa la legge o la struttura per dominare o distruggere."
  ),
  Allineamento(
    nome: "Neutrale Malvagio",
    descrizione: "Fa il male per beneficio personale, senza preferenze morali."
  ),
  Allineamento(
    nome: "Caotico Malvagio",
    descrizione: "Distruttivo, impulsivo e crudele per natura."
  ),
];
