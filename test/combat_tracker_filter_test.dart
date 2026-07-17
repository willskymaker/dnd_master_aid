import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/screens/combat_tracker_screen.dart';

void main() {
  group('Combat Tracker CR Filter Tests', () {
    final List<Map<String, dynamic>> mockMonsters = [
      {'name': 'Goblin', 'challenge_rating': '1/4'},
      {'name': 'Orc', 'challenge_rating': '1'},
      {'name': 'Troll', 'challenge_rating': '5'},
      {'name': 'Dragon', 'challenge_rating': '17'},
      {'name': 'Commoner', 'challenge_rating': '0'},
    ];

    test('All filter returns all monsters', () {
      final selectedFilter = 'All';
      final filtered =
          mockMonsters
              .where(
                (m) => mostroNelFiltroCr(
                  m['challenge_rating']?.toString() ?? '',
                  selectedFilter,
                ),
              )
              .toList();

      expect(filtered.length, equals(5));
    });

    test('CR 0 filter returns only CR 0 monsters', () {
      final selectedFilter = 'CR 0';
      final filtered =
          mockMonsters
              .where(
                (m) => mostroNelFiltroCr(
                  m['challenge_rating']?.toString() ?? '',
                  selectedFilter,
                ),
              )
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Commoner'));
    });

    test('CR 1/8 – 1/2 filter returns correct monsters', () {
      final selectedFilter = 'CR 1/8 – 1/2';
      final filtered =
          mockMonsters
              .where(
                (m) => mostroNelFiltroCr(
                  m['challenge_rating']?.toString() ?? '',
                  selectedFilter,
                ),
              )
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Goblin'));
    });

    test('CR 1 – 4 filter returns correct monsters', () {
      final selectedFilter = 'CR 1 – 4';
      final filtered =
          mockMonsters
              .where(
                (m) => mostroNelFiltroCr(
                  m['challenge_rating']?.toString() ?? '',
                  selectedFilter,
                ),
              )
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Orc'));
    });

    test('CR 5 – 10 filter returns correct monsters', () {
      final selectedFilter = 'CR 5 – 10';
      final filtered =
          mockMonsters
              .where(
                (m) => mostroNelFiltroCr(
                  m['challenge_rating']?.toString() ?? '',
                  selectedFilter,
                ),
              )
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Troll'));
    });

    test('CR 11+ filter returns correct monsters', () {
      final selectedFilter = 'CR 11+';
      final filtered =
          mockMonsters
              .where(
                (m) => mostroNelFiltroCr(
                  m['challenge_rating']?.toString() ?? '',
                  selectedFilter,
                ),
              )
              .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first['name'], equals('Dragon'));
    });
  });
}
