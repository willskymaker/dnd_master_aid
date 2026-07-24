import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/utils/encounter_generator.dart';

void main() {
  group('sogliaXpParty', () {
    test(
      'calcola soglia per party di 4 giocatori livello 1 con difficoltà media',
      () {
        final soglia = sogliaXpParty(
          numeroGiocatori: 4,
          livelloMedio: 1,
          difficolta: DifficoltaIncontro.media,
        );
        expect(soglia, 200);
      },
    );

    test(
      'calcola soglia per party di 4 giocatori livello 1 con difficoltà facile',
      () {
        final soglia = sogliaXpParty(
          numeroGiocatori: 4,
          livelloMedio: 1,
          difficolta: DifficoltaIncontro.facile,
        );
        expect(soglia, 100);
      },
    );

    test(
      'calcola soglia per party di 4 giocatori livello 1 con difficoltà difficile',
      () {
        final soglia = sogliaXpParty(
          numeroGiocatori: 4,
          livelloMedio: 1,
          difficolta: DifficoltaIncontro.difficile,
        );
        expect(soglia, 300);
      },
    );

    test(
      'calcola soglia per party di 4 giocatori livello 1 con difficoltà letale',
      () {
        final soglia = sogliaXpParty(
          numeroGiocatori: 4,
          livelloMedio: 1,
          difficolta: DifficoltaIncontro.mortale,
        );
        expect(soglia, 400);
      },
    );

    test(
      'calcola soglia per party di 3 giocatori livello 3 con difficoltà media',
      () {
        final soglia = sogliaXpParty(
          numeroGiocatori: 3,
          livelloMedio: 3,
          difficolta: DifficoltaIncontro.media,
        );
        expect(soglia, 450);
      },
    );
  });

  group('moltiplicatoreXp', () {
    test('restituisce moltiplicatore corretto per 1 mostro', () {
      expect(moltiplicatoreXp(1), 1.0);
    });

    test('restituisce moltiplicatore corretto per 2 mostri', () {
      expect(moltiplicatoreXp(2), 1.5);
    });

    test('restituisce moltiplicatore corretto per 3 mostri', () {
      expect(moltiplicatoreXp(3), 2.0);
    });

    test('restituisce moltiplicatore corretto per 4-6 mostri', () {
      expect(moltiplicatoreXp(4), 2.0);
      expect(moltiplicatoreXp(6), 2.0);
    });

    test('restituisce moltiplicatore corretto per 7-10 mostri', () {
      expect(moltiplicatoreXp(7), 2.5);
      expect(moltiplicatoreXp(10), 2.5);
    });

    test('restituisce 1.0 per 0 mostri', () {
      expect(moltiplicatoreXp(0), 1.0);
    });
  });

  group('parseCr', () {
    test('converte CR da stringa a numero', () {
      expect(parseCr('0'), 0);
      expect(parseCr('1/8'), 0.125);
      expect(parseCr('1/4'), 0.25);
      expect(parseCr('1/2'), 0.5);
      expect(parseCr('1'), 1);
      expect(parseCr('3'), 3);
      expect(parseCr('10'), 10);
    });

    test('gestisce input non validi restituendo 0', () {
      expect(parseCr(''), 0);
      expect(parseCr('invalid'), 0);
    });
  });
}
