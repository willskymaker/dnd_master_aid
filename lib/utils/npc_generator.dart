import 'dart:math';

import '../data/db_npc.dart';
import '../data/db_nomi.dart';

class Png {
  final String nome;
  final String aspetto;
  final String personalita;
  final String occupazione;
  final String ganceTrama;

  const Png({
    required this.nome,
    required this.aspetto,
    required this.personalita,
    required this.occupazione,
    required this.ganceTrama,
  });
}

/// Genera un PNG "usa e getta" combinando un nome a tema (vedi
/// [nomiPerTema]) con aspetto fisico, personalità, occupazione e un gancio
/// di trama pescati casualmente dalle tabelle in db_npc.dart.
Png generaPng({required String tema, Random? random}) {
  final rnd = random ?? Random();
  return Png(
    nome: _generaNome(tema, rnd),
    aspetto: aspettiFisiciNpc[rnd.nextInt(aspettiFisiciNpc.length)],
    personalita: trattiPersonalitaNpc[rnd.nextInt(trattiPersonalitaNpc.length)],
    occupazione: occupazioniNpc[rnd.nextInt(occupazioniNpc.length)],
    ganceTrama: ganciTramaNpc[rnd.nextInt(ganciTramaNpc.length)],
  );
}

String _generaNome(String tema, Random rnd) {
  final nomiBase = nomiPerTema[tema];
  if (nomiBase == null) return 'Sconosciuto';

  final lista = rnd.nextBool() ? nomiBase.maschili : nomiBase.femminili;
  final nome = lista.isNotEmpty ? lista[rnd.nextInt(lista.length)] : '???';
  if (nomiBase.cognomi.isEmpty) return nome;
  return '$nome ${nomiBase.cognomi[rnd.nextInt(nomiBase.cognomi.length)]}';
}
