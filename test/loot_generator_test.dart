import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/utils/loot_generator.dart';

void main() {
  group('tierDaCr', () {
    test('determina tier per CR', () {
      final tier = tierDaCr(1);
      expect(tier, isNotNull);
      // The function should return some TierBottino value
      expect(tier.runtimeType, TierBottino);
    });
  });

  group('generaBottino', () {
    test('genera bottino per tier 1', () {
      // Use TierBottino.values.first to get the first value
      final tier = TierBottino.values.first;
      final bottino = generaBottino(tier: tier, oggettiDisponibili: []);
      expect(bottino, isNotNull);
    });

    test('genera bottino per tier 4', () {
      // Use TierBottino.values.last to get the last value
      final tier = TierBottino.values.last;
      final bottino = generaBottino(tier: tier, oggettiDisponibili: []);
      expect(bottino, isNotNull);
    });
  });
}
