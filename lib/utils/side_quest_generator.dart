import 'dart:math';

import '../data/db_nomi.dart';
import '../data/db_side_quest.dart';
import 'npc_generator.dart';

/// Una side quest generata: obiettivo, chi la affida, una complicazione e
/// una ricompensa, pronta per l'improvvisazione.
class SideQuest {
  final String obiettivo;
  final Png committente;
  final String complicazione;
  final String ricompensa;

  const SideQuest({
    required this.obiettivo,
    required this.committente,
    required this.complicazione,
    required this.ricompensa,
  });
}

/// Genera una side quest casuale. Se [committente] non e' passato, ne viene
/// generato uno nuovo "usa e getta" (vedi [generaPng]); passandone uno gia'
/// salvato (vedi SavedNpcService) la stessa persona puo' ricomparire come
/// committente in altre sessioni della campagna.
SideQuest generaSideQuest({Png? committente, Random? random}) {
  final rnd = random ?? Random();
  return SideQuest(
    obiettivo: obiettiviSideQuest[rnd.nextInt(obiettiviSideQuest.length)],
    committente:
        committente ??
        generaPng(
          fonteNomi: nomiPerSpecie.keys.elementAt(
            rnd.nextInt(nomiPerSpecie.length),
          ),
          random: rnd,
        ),
    complicazione:
        complicazioniSideQuest[rnd.nextInt(complicazioniSideQuest.length)],
    ricompensa: ricompenseSideQuest[rnd.nextInt(ricompenseSideQuest.length)],
  );
}
