import 'dart:math';

import 'package:uuid/uuid.dart';

import '../data/db_npc.dart';
import '../data/db_nomi.dart';

/// Un PNG generato. Nasce "usa e getta" (nessun salvataggio automatico),
/// ma porta comunque un [id] stabile fin dalla creazione cosi' puo' essere
/// salvato in un secondo momento (vedi [SavedNpcService]) e ricomparire in
/// sessioni future della stessa campagna, es. come committente di una side
/// quest (vedi generaSideQuest in side_quest_generator.dart).
class Png {
  final String id;
  final String nome;
  final String aspetto;
  final String personalita;
  final String occupazione;
  final String ganceTrama;

  const Png({
    required this.id,
    required this.nome,
    required this.aspetto,
    required this.personalita,
    required this.occupazione,
    required this.ganceTrama,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'aspetto': aspetto,
    'personalita': personalita,
    'occupazione': occupazione,
    'ganceTrama': ganceTrama,
  };

  factory Png.fromJson(Map<String, dynamic> json) => Png(
    id: json['id'] as String,
    nome: json['nome'] as String,
    aspetto: json['aspetto'] as String,
    personalita: json['personalita'] as String,
    occupazione: json['occupazione'] as String,
    ganceTrama: json['ganceTrama'] as String,
  );
}

/// Genera un PNG "usa e getta" combinando un nome (da una specie D&D, vedi
/// [nomiPerSpecie], o da un tema extra, vedi [nomiPerTema]) con aspetto
/// fisico, personalità, occupazione e un gancio di trama pescati
/// casualmente dalle tabelle in db_npc.dart.
Png generaPng({required String fonteNomi, Random? random}) {
  final rnd = random ?? Random();
  return Png(
    id: const Uuid().v4(),
    nome: _generaNome(fonteNomi, rnd),
    aspetto: aspettiFisiciNpc[rnd.nextInt(aspettiFisiciNpc.length)],
    personalita: trattiPersonalitaNpc[rnd.nextInt(trattiPersonalitaNpc.length)],
    occupazione: occupazioniNpc[rnd.nextInt(occupazioniNpc.length)],
    ganceTrama: ganciTramaNpc[rnd.nextInt(ganciTramaNpc.length)],
  );
}

String _generaNome(String fonteNomi, Random rnd) {
  final nomiBase = nomiPerSpecie[fonteNomi] ?? nomiPerTema[fonteNomi];
  if (nomiBase == null) return 'Sconosciuto';

  final lista = rnd.nextBool() ? nomiBase.maschili : nomiBase.femminili;
  final nome = lista.isNotEmpty ? lista[rnd.nextInt(lista.length)] : '???';
  if (nomiBase.cognomi.isEmpty) return nome;
  return '$nome ${nomiBase.cognomi[rnd.nextInt(nomiBase.cognomi.length)]}';
}
