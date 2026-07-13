import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/utils/tactical_hints.dart';

void main() {
  group('suggerimentiTattici', () {
    test('nessun dato mostro -> nessun suggerimento', () {
      expect(
        suggerimentiTattici(datiMostro: null, pfCorrenti: 5, pfMax: 10),
        isEmpty,
      );
    });

    test('SAG alta e PF sotto il 30% -> suggerisce fuga', () {
      final suggerimenti = suggerimentiTattici(
        datiMostro: {
          'ability_scores': {'wisdom': 14, 'intelligence': 6},
        },
        pfCorrenti: 2,
        pfMax: 10,
      );
      expect(
        suggerimenti,
        contains('Potrebbe tentare di fuggire o rifugiarsi'),
      );
    });

    test('SAG alta ma PF sopra il 30% -> non suggerisce fuga', () {
      final suggerimenti = suggerimentiTattici(
        datiMostro: {
          'ability_scores': {'wisdom': 14, 'intelligence': 6},
        },
        pfCorrenti: 8,
        pfMax: 10,
      );
      expect(
        suggerimenti,
        isNot(contains('Potrebbe tentare di fuggire o rifugiarsi')),
      );
    });

    test('INT >= 8 -> suggerisce targeting intelligente', () {
      final suggerimenti = suggerimentiTattici(
        datiMostro: {
          'ability_scores': {'wisdom': 10, 'intelligence': 10},
        },
        pfCorrenti: 10,
        pfMax: 10,
      );
      expect(
        suggerimenti,
        contains('Punterebbe al PG più ferito/debole a portata'),
      );
    });

    test('INT < 8 -> suggerisce bersaglio più vicino', () {
      final suggerimenti = suggerimentiTattici(
        datiMostro: {
          'ability_scores': {'wisdom': 10, 'intelligence': 4},
        },
        pfCorrenti: 10,
        pfMax: 10,
      );
      expect(
        suggerimenti,
        contains('Attacca semplicemente il bersaglio più vicino'),
      );
    });

    test('azione con gittata -> suggerisce di mantenere le distanze', () {
      final suggerimenti = suggerimentiTattici(
        datiMostro: {
          'ability_scores': {'wisdom': 10, 'intelligence': 10},
          'actions': [
            {
              'name': 'Shortbow',
              'range': '80/320 ft',
              'description': 'Attacco con arma a distanza: gittata 80/320 ft.',
            },
          ],
        },
        pfCorrenti: 10,
        pfMax: 10,
      );
      expect(suggerimenti, contains('Cerca di mantenere le distanze dai PG'));
    });

    test('al massimo 2 suggerimenti', () {
      final suggerimenti = suggerimentiTattici(
        datiMostro: {
          'ability_scores': {'wisdom': 16, 'intelligence': 10},
          'actions': [
            {'name': 'Shortbow', 'range': '80/320 ft', 'description': ''},
          ],
        },
        pfCorrenti: 1,
        pfMax: 10,
      );
      expect(suggerimenti.length, lessThanOrEqualTo(2));
    });
  });
}
