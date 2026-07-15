import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/utils/cr_calculator.dart';

void main() {
  group('formattaGs', () {
    test('restituisce "0" per GS 0', () {
      expect(formattaGs(0), '0');
    });

    test('restituisce "1/8" per GS 0.125', () {
      expect(formattaGs(0.125), '1/8');
    });

    test('restituisce "1/4" per GS 0.25', () {
      expect(formattaGs(0.25), '1/4');
    });

    test('restituisce "1/2" per GS 0.5', () {
      expect(formattaGs(0.5), '1/2');
    });

    test('restituisce "1" per GS 1', () {
      expect(formattaGs(1), '1');
    });

    test('restituisce "5" per GS 5', () {
      expect(formattaGs(5), '5');
    });
  });

  group('calcolaGsDifensivo', () {
    const nessuna = ResistenzeImmunita();

    test('5 HP senza resistenze → GS 0', () {
      expect(calcolaGsDifensivo(5, nessuna), 0.0);
    });

    test('20 HP senza resistenze → GS 1/8', () {
      expect(calcolaGsDifensivo(20, nessuna), 0.125);
    });

    test('40 HP senza resistenze → GS 1/4', () {
      expect(calcolaGsDifensivo(40, nessuna), 0.25);
    });

    test('100 HP senza resistenze → GS 2', () {
      expect(calcolaGsDifensivo(100, nessuna), 2.0);
    });

    test('40 HP con resistenze → GS 1/2 (40 × 1.5 = 60 → fascia CR 1/2)', () {
      const resistenze = ResistenzeImmunita(haResistenze: true);
      expect(calcolaGsDifensivo(40, resistenze), 0.5);
    });

    test('40 HP con immunità → GS 1 (40 × 2.0 = 80 → fascia CR 1)', () {
      const immunita = ResistenzeImmunita(haImmunita: true);
      expect(calcolaGsDifensivo(40, immunita), 1.0);
    });
  });

  group('calcolaGsOffensivo', () {
    test('3 danni/round → GS 0', () {
      expect(calcolaGsOffensivo(3, 3), 0.0);
    });

    test('7 danni/round → GS 1/8', () {
      expect(calcolaGsOffensivo(7, 3), 0.125);
    });

    test('12 danni/round → GS 1/4', () {
      expect(calcolaGsOffensivo(12, 3), 0.25);
    });

    test('18 danni/round → GS 1/2', () {
      expect(calcolaGsOffensivo(18, 3), 0.5);
    });

    test(
      '23 danni/round con bonus +3 → GS 1 (bonus atteso +3, nessun aggiustamento)',
      () {
        expect(calcolaGsOffensivo(23, 3), 1.0);
      },
    );
  });

  group('calcolaGs', () {
    test('hp=85 dmg=25 bonusAttacco=3 → gsFinale=1.0, gsFormattato="1"', () {
      final risultato = calcolaGs(
        hp: 85,
        dannoMedioPerRound: 25,
        bonusAttacco: 3,
      );
      expect(risultato.gsFinale, 1.0);
      expect(risultato.gsFormattato, '1');
    });
  });
}
