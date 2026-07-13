import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/factory_pg_base.dart';
import 'package:master_aid/utils/character_share.dart';

void main() {
  PGBase creaPersonaggio() => PGBase(
    nome: 'Elarion',
    specie: 'Elfo',
    classe: 'Mago',
    livello: 3,
    background: 'Saggio',
    allineamento: 'Neutrale Buono',
    competenze: const ['Arcano'],
    caratteristiche: const {
      'FOR': 8,
      'DES': 14,
      'COS': 12,
      'INT': 16,
      'SAG': 10,
      'CAR': 10,
    },
    modificatori: const {
      'FOR': -1,
      'DES': 2,
      'COS': 1,
      'INT': 3,
      'SAG': 0,
      'CAR': 0,
    },
    caratteristicheImpostate: true,
    velocita: 9,
    linguaggi: const ['Comune', 'Elfico'],
    capacitaSpeciali: const [],
    dadoVita: 6,
    puntiVita: 18,
    tiriSalvezza: const ['Intelligenza', 'Saggezza'],
    competenzeArmi: const [],
    competenzeArmature: const [],
    competenzeStrumenti: const [],
    abilitaClasse: const [],
    equipaggiamento: const ['Bastone Ferrato'],
    denaroOro: 15,
    proprietario: 'Marco',
  );

  test('esportaPersonaggio/importaPersonaggio fanno un round-trip fedele', () {
    final originale = creaPersonaggio();
    final codice = esportaPersonaggio(originale);
    final importato = importaPersonaggio(codice);

    expect(importato.id, originale.id);
    expect(importato.nome, originale.nome);
    expect(importato.classe, originale.classe);
    expect(importato.livello, originale.livello);
    expect(importato.caratteristiche, originale.caratteristiche);
    expect(importato.proprietario, 'Marco');
    expect(importato.denaroOro, 15);
    expect(importato.equipaggiamento, originale.equipaggiamento);
  });

  test('esportaPersonaggio produce un codice con il prefisso atteso', () {
    final codice = esportaPersonaggio(creaPersonaggio());
    expect(codice.startsWith('DNDMA1:'), isTrue);
  });

  test('importaPersonaggio rifiuta un codice senza prefisso valido', () {
    expect(
      () => importaPersonaggio('qualcosa di a caso'),
      throwsA(isA<FormatException>()),
    );
  });

  test('importaPersonaggio rifiuta un base64 corrotto', () {
    expect(
      () => importaPersonaggio('DNDMA1:non-e-base64-valido!!!'),
      throwsA(isA<FormatException>()),
    );
  });
}
