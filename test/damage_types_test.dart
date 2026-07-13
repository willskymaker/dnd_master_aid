import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/utils/damage_types.dart';

void main() {
  group('applicaResistenze', () {
    test('nessun dato mostro -> danno pieno', () {
      final r = applicaResistenze(
        danno: 10,
        tipoDannoItaliano: 'Fuoco',
        datiMostro: null,
      );
      expect(r.dannoApplicato, 10);
      expect(r.messaggio, isNull);
    });

    test('immunità -> nessun danno', () {
      final r = applicaResistenze(
        danno: 10,
        tipoDannoItaliano: 'Veleno',
        datiMostro: {
          'damage_immunities': ['poison'],
        },
      );
      expect(r.dannoApplicato, 0);
      expect(r.messaggio, contains('Immune'));
    });

    test('resistenza -> danno dimezzato arrotondato per difetto', () {
      final r = applicaResistenze(
        danno: 11,
        tipoDannoItaliano: 'Fuoco',
        datiMostro: {
          'damage_resistances': ['fire'],
        },
      );
      expect(r.dannoApplicato, 5);
      expect(r.messaggio, contains('dimezzato'));
    });

    test('vulnerabilità -> danno raddoppiato', () {
      final r = applicaResistenze(
        danno: 6,
        tipoDannoItaliano: 'Contundente',
        datiMostro: {
          'damage_vulnerabilities': ['bludgeoning'],
        },
      );
      expect(r.dannoApplicato, 12);
      expect(r.messaggio, contains('raddoppiato'));
    });

    test('resistenza + vulnerabilità stesso tipo -> si annullano', () {
      final r = applicaResistenze(
        danno: 8,
        tipoDannoItaliano: 'Freddo',
        datiMostro: {
          'damage_resistances': ['cold'],
          'damage_vulnerabilities': ['cold'],
        },
      );
      expect(r.dannoApplicato, 8);
      expect(r.messaggio, contains('annullano'));
    });

    test('resistenza con testo import "sporco" (virgole spezzate)', () {
      final r = applicaResistenze(
        danno: 10,
        tipoDannoItaliano: 'Tagliente',
        datiMostro: {
          'damage_resistances': [
            'lightning',
            'thunder; bludgeoning',
            'piercing',
            'and slashing from nonmagical attacks',
          ],
        },
      );
      expect(r.dannoApplicato, 5);
    });

    test('tipo di danno non riconosciuto -> danno pieno', () {
      final r = applicaResistenze(
        danno: 10,
        tipoDannoItaliano: 'Sconosciuto',
        datiMostro: {
          'damage_immunities': ['fire'],
        },
      );
      expect(r.dannoApplicato, 10);
    });

    test(
      'nessuna resistenza/immunità/vulnerabilità per quel tipo -> danno pieno',
      () {
        final r = applicaResistenze(
          danno: 10,
          tipoDannoItaliano: 'Fuoco',
          datiMostro: {
            'damage_immunities': ['poison'],
          },
        );
        expect(r.dannoApplicato, 10);
        expect(r.messaggio, isNull);
      },
    );
  });
}
