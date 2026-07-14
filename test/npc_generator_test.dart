import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/data/db_nomi.dart';
import 'package:master_aid/utils/npc_generator.dart';

void main() {
  group('generaPng', () {
    test('genera tutti i campi non vuoti per ogni tema disponibile', () {
      for (final tema in nomiPerTema.keys) {
        final png = generaPng(tema: tema, random: Random(42));
        expect(png.nome, isNotEmpty);
        expect(png.aspetto, isNotEmpty);
        expect(png.personalita, isNotEmpty);
        expect(png.occupazione, isNotEmpty);
        expect(png.ganceTrama, isNotEmpty);
      }
    });

    test('tema sconosciuto -> nome di fallback, resto sempre popolato', () {
      final png = generaPng(tema: 'Non Esiste', random: Random(1));
      expect(png.nome, 'Sconosciuto');
      expect(png.aspetto, isNotEmpty);
    });

    test('con lo stesso seed produce sempre lo stesso risultato', () {
      final png1 = generaPng(tema: 'Pirata', random: Random(7));
      final png2 = generaPng(tema: 'Pirata', random: Random(7));
      expect(png1.nome, png2.nome);
      expect(png1.aspetto, png2.aspetto);
      expect(png1.personalita, png2.personalita);
      expect(png1.occupazione, png2.occupazione);
      expect(png1.ganceTrama, png2.ganceTrama);
    });

    test('seed diversi producono variazione', () {
      final risultati = <String>{};
      for (var i = 0; i < 10; i++) {
        risultati.add(generaPng(tema: 'Fantascienza', random: Random(i)).nome);
      }
      expect(risultati.length, greaterThan(1));
    });
  });
}
