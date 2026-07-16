import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/utils/npc_generator.dart';
import 'package:master_aid/utils/side_quest_generator.dart';

void main() {
  group('generaSideQuest', () {
    test('genera tutti i campi non vuoti con committente casuale', () {
      final quest = generaSideQuest(random: Random(42));
      expect(quest.obiettivo, isNotEmpty);
      expect(quest.complicazione, isNotEmpty);
      expect(quest.ricompensa, isNotEmpty);
      expect(quest.committente.nome, isNotEmpty);
    });

    test('usa il committente passato invece di generarne uno nuovo', () {
      final png = generaPng(fonteNomi: 'Elfo', random: Random(1));
      final quest = generaSideQuest(committente: png, random: Random(42));
      expect(quest.committente.id, png.id);
      expect(quest.committente.nome, png.nome);
    });

    test('con lo stesso seed produce lo stesso risultato', () {
      final quest1 = generaSideQuest(random: Random(7));
      final quest2 = generaSideQuest(random: Random(7));
      expect(quest1.obiettivo, quest2.obiettivo);
      expect(quest1.complicazione, quest2.complicazione);
      expect(quest1.ricompensa, quest2.ricompensa);
      expect(quest1.committente.nome, quest2.committente.nome);
    });

    test('seed diversi producono variazione', () {
      final risultati = <String>{};
      for (var i = 0; i < 10; i++) {
        risultati.add(generaSideQuest(random: Random(i)).obiettivo);
      }
      expect(risultati.length, greaterThan(1));
    });
  });
}
