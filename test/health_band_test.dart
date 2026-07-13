import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/utils/health_band.dart';

void main() {
  group('fasciaSalute', () {
    test('PF pieni -> Sano', () {
      final info = fasciaSalute(pfCorrenti: 10, pfMax: 10);
      expect(info.fascia, FasciaSalute.sano);
      expect(info.etichetta, 'Sano');
      expect(info.frazione, 1.0);
    });

    test('PF appena sopra 66% -> Sano', () {
      final info = fasciaSalute(pfCorrenti: 7, pfMax: 10);
      expect(info.fascia, FasciaSalute.sano);
    });

    test('PF al 50% -> Ferito', () {
      final info = fasciaSalute(pfCorrenti: 5, pfMax: 10);
      expect(info.fascia, FasciaSalute.ferito);
      expect(info.etichetta, 'Ferito');
    });

    test('PF al 20% -> Gravemente ferito', () {
      final info = fasciaSalute(pfCorrenti: 2, pfMax: 10);
      expect(info.fascia, FasciaSalute.gravementeFerito);
      expect(info.etichetta, 'Gravemente ferito');
    });

    test('PF a 0 -> Morente/A terra', () {
      final info = fasciaSalute(pfCorrenti: 0, pfMax: 10);
      expect(info.fascia, FasciaSalute.morente);
      expect(info.etichetta, 'Morente/A terra');
      expect(info.frazione, 0.0);
    });

    test('pfMax 0 non genera errori', () {
      final info = fasciaSalute(pfCorrenti: 0, pfMax: 0);
      expect(info.frazione, 0.0);
    });
  });
}
