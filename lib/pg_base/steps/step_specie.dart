import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_specie.dart'; //importa il database specie

class StepSpecieScreen extends StatelessWidget {
  final PGBaseFactory factory;

  const StepSpecieScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step 2: Seleziona la Specie")),
      body: ListView.builder(
        itemCount: specieCoreList.length,
        itemBuilder: (context, index) {
          final specie = specieCoreList[index];

          return Card(
            child: ListTile(
              title: Text(specie.nome),
              subtitle: Text(
                "Velocità: ${specie.velocita} m\n"
                "Competenze: ${specie.competenze.join(', ')}\n"
                "Abilità innate: ${specie.abilitaInnate.join(', ')}\n"
                "Linguaggi: ${specie.linguaggi.join(', ')}"
                "Competenze: ${specie.competenze.join(', ')}\n"
                "Resistenze: ${specie.resistenze.join(', ')}\n"
                "Linguaggi: ${specie.linguaggi.join(', ')}"
              ),
              onTap: () {
                _selezionaSpecie(context, specie);
              },
            ),
          );
        },
      ),
    );
  }

  void _selezionaSpecie(BuildContext context, Specie specie) {
  factory.setSpecie(specie.nome);

  // Aggiungi le abilità innate come "tratti"
  factory.addTrattiSpecie(specie.abilitaInnate);

  // Aggiungi le competenze (una per una)
  for (var comp in specie.competenze) {
    factory.addCompetenza(comp);
  }

  // Imposta velocità
  factory.setVelocita(specie.velocita);

  // Aggiungi linguaggi, evitando duplicati
  factory.addLinguaggi(specie.linguaggi);

  Navigator.pop(context, true); // Torna al wizard
}
}
Future<void> vaiAStepSpecie(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepSpecieScreen(factory: factory),
    ),
  );
}