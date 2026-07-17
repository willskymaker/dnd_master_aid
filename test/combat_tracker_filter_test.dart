import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Combat Tracker CR Filter Tests', () {
    final Map<String, List<String>> crRanges = {
      'All': [],
      'CR 0': ['0'],
      'CR 1/8 – 1/2': ['1/8', '1/4', '1/2'],
      'CR 1 – 4': ['1', '2', '3', '4'],
      'CR 5 – 10': ['5', '6', '7', '8', '9', '10'],
      'CR 11+': [
        '11',
        '12',
        '13',
        '14',
        '15',
        '16',
        '17',
        '18',
        '19',
        '20',
        '21',
        '22',
        '23',
        '24',
        '25',
        '26',
        '27',
        '28',
        '29',
        '30',
      ],
    };

    final List<Map<String, dynamic>> mockMonsters = [
      {'name': 'Goblin', 'challenge_rating': '1/4'},
      {'name': 'Orc', 'challenge_rating': '1'},
      {'name': 'Troll', 'challenge_rating': '5'},
      {'name': 'Dragon', 'challenge_rating': '17'},
      {'name': 'Commoner', 'challenge_rating': '0'},
    ];

    test('All filter returns all monsters', () {
      final selectedFilter = 'All';
      final allowedCrs = crRanges[selectedFilter] ?? [];

      final filtered =
          allowedCrs.isEmpty
              ? mockMonsters
              : mockMonsters
                  .where((m) => allowedCrs.contains(m['challenge_rating']))
                  .toList();

      expect(filtered.length, equals(5));
    });

    test('CR 0 filter returns only CR 0 monsters', () {
      final selectedFilter = 'CR 0';
      final allowedCrs = crRanges[selectedFilter] ?? [];

      final filtered =
          mockMonsters
              .where((m) => allowedCrs.contains(m['challenge_rating']))
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Commoner'));
    });

    test('CR 1/8 – 1/2 filter returns correct monsters', () {
      final selectedFilter = 'CR 1/8 – 1/2';
      final allowedCrs = crRanges[selectedFilter] ?? [];

      final filtered =
          mockMonsters
              .where((m) => allowedCrs.contains(m['challenge_rating']))
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Goblin'));
    });

    test('CR 1 – 4 filter returns correct monsters', () {
      final selectedFilter = 'CR 1 – 4';
      final allowedCrs = crRanges[selectedFilter] ?? [];

      final filtered =
          mockMonsters
              .where((m) => allowedCrs.contains(m['challenge_rating']))
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Orc'));
    });

    test('CR 5 – 10 filter returns correct monsters', () {
      final selectedFilter = 'CR 5 – 10';
      final allowedCrs = crRanges[selectedFilter] ?? [];

      final filtered =
          mockMonsters
              .where((m) => allowedCrs.contains(m['challenge_rating']))
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Troll'));
    });

    test('CR 11+ filter returns correct monsters', () {
      final selectedFilter = 'CR 11+';
      final allowedCrs = crRanges[selectedFilter] ?? [];

      final filtered =
          mockMonsters
              .where((m) => allowedCrs.contains(m['challenge_rating']))
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Dragon'));
    });
  });
}
