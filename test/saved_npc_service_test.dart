import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:master_aid/services/saved_npc_service.dart';
import 'package:master_aid/utils/npc_generator.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Png creaPng({String id = 'png-1'}) => Png(
    id: id,
    nome: 'Elandra',
    aspetto: 'Occhi eterocromatici',
    personalita: 'Diretta fino alla scortesia',
    occupazione: 'Locandiera',
    ganceTrama: 'Cerca un oggetto rubato',
  );

  test(
    'caricaTutti restituisce lista vuota se non c\'e\' nulla salvato',
    () async {
      expect(await SavedNpcService.caricaTutti(), isEmpty);
    },
  );

  test('salva/caricaTutti fanno un round-trip fedele', () async {
    final png = creaPng();
    await SavedNpcService.salva(png);

    final tutti = await SavedNpcService.caricaTutti();
    expect(tutti, hasLength(1));
    expect(tutti.first.id, png.id);
    expect(tutti.first.nome, png.nome);
    expect(tutti.first.occupazione, png.occupazione);
  });

  test('salva con lo stesso id aggiorna invece di duplicare', () async {
    await SavedNpcService.salva(creaPng());
    await SavedNpcService.salva(creaPng());

    final tutti = await SavedNpcService.caricaTutti();
    expect(tutti, hasLength(1));
  });

  test('elimina rimuove il PNG salvato', () async {
    final png = creaPng();
    await SavedNpcService.salva(png);
    await SavedNpcService.elimina(png.id);

    expect(await SavedNpcService.caricaTutti(), isEmpty);
  });
}
