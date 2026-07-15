import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/pg_base/utils/pf_helper.dart';

void main() {
  group('calcolaPuntiFerita', () {
    test('calcola PF correttamente per livello 1', () {
      final pf = calcolaPuntiFerita(
        livello: 1,
        dadoVita: 10,
        modCostituzione: 2,
      );
      expect(pf, 12);
    });

    test('calcola PF correttamente per livello 3', () {
      final pf = calcolaPuntiFerita(
        livello: 3,
        dadoVita: 10,
        modCostituzione: 2,
      );
      expect(pf, 28);
    });

    test('calcola PF correttamente per livello 5 con d6 (Mago)', () {
      final pf = calcolaPuntiFerita(
        livello: 5,
        dadoVita: 6,
        modCostituzione: 1,
      );
      expect(pf, 27);
    });

    test('gestisce costituzione negativa (mod -1)', () {
      final pf = calcolaPuntiFerita(
        livello: 2,
        dadoVita: 10,
        modCostituzione: -1,
      );
      expect(pf, 14);
    });

    test('gestisce costituzione negativa', () {
      final pf = calcolaPuntiFerita(
        livello: 1,
        dadoVita: 10,
        modCostituzione: -5,
      );
      expect(pf, isPositive);
    });

    test('gestisce livello 0 o negativo restituendo 0', () {
      final pf = calcolaPuntiFerita(
        livello: 0,
        dadoVita: 10,
        modCostituzione: 2,
      );
      expect(pf, 0);
    });

    test('gestisce dadoVita 0 o negativo restituendo 0', () {
      final pf = calcolaPuntiFerita(
        livello: 1,
        dadoVita: 0,
        modCostituzione: 2,
      );
      expect(pf, 0);
    });

    test('limita PF massimo a 999', () {
      final pf = calcolaPuntiFerita(
        livello: 100,
        dadoVita: 20,
        modCostituzione: 10,
      );
      expect(pf, 999);
    });
  });
}
