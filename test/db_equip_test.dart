import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_master_aid/data/db_equip.dart';

void main() {
  group('classiConsigliatePerArma', () {
    test('arma semplice generica e consigliata a chi ha "Armi semplici"', () {
      final classi = classiConsigliatePerArma('simple_melee', 'Club');
      expect(classi, contains('Guerriero'));
      expect(classi, contains('Chierico'));
      expect(classi, isNot(contains('Mago')));
    });

    test('arma da guerra generica esclude chi non ha "Armi da guerra"', () {
      final classi = classiConsigliatePerArma('martial_melee', 'Battleaxe');
      expect(classi, contains('Guerriero'));
      expect(classi, contains('Barbaro'));
      expect(classi, isNot(contains('Chierico')));
      expect(classi, isNot(contains('Mago')));
    });

    test('eccezioni nominali per classi senza competenza generica', () {
      final quarterstaff = classiConsigliatePerArma(
        'simple_melee',
        'Quarterstaff',
      );
      expect(quarterstaff, contains('Mago'));
      expect(quarterstaff, contains('Druido'));

      final rapier = classiConsigliatePerArma('martial_melee', 'Rapier');
      expect(rapier, contains('Bardo'));
      expect(rapier, contains('Ladro'));
      expect(rapier, isNot(contains('Mago')));
    });
  });

  group('classiConsigliatePerArmatura', () {
    test('armatura leggera disponibile anche a chi ha solo "Leggere"', () {
      final classi = classiConsigliatePerArmatura('light');
      expect(classi, contains('Bardo'));
      expect(classi, contains('Guerriero'));
      expect(classi, isNot(contains('Mago')));
    });

    test('armatura pesante solo per chi ha "Tutte le armature"', () {
      final classi = classiConsigliatePerArmatura('heavy');
      expect(classi, contains('Guerriero'));
      expect(classi, contains('Paladino'));
      expect(classi, isNot(contains('Barbaro')));
      expect(classi, isNot(contains('Chierico')));
    });

    test('scudi', () {
      final classi = classiConsigliatePerArmatura('shields');
      expect(classi, contains('Guerriero'));
      expect(classi, contains('Chierico'));
      expect(classi, isNot(contains('Mago')));
    });
  });
}
