import 'dart:math';

import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_specie.dart'; //importa il database specie
import '../../widgets/mobile/mobile_scaffold.dart';

class StepSpecieScreen extends StatelessWidget {
  final PGBaseFactory factory;

  const StepSpecieScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: "Step 1: Seleziona la Specie",
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _randomizza(context),
                icon: const Icon(Icons.casino),
                label: const Text('Specie casuale'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                      "Resistenze: ${specie.resistenze.join(', ')}\n"
                      "Linguaggi: ${specie.linguaggi.join(', ')}",
                    ),
                    onTap: () {
                      _selezionaSpecie(context, specie);
                    },
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: TextButton(
              onPressed: () => _saltaStep(context),
              child: const Text('Salta Step'),
            ),
          ),
        ],
      ),
    );
  }

  void _saltaStep(BuildContext context) {
    Navigator.pop(context, true);
  }

  void _randomizza(BuildContext context) {
    final specie = specieCoreList[Random().nextInt(specieCoreList.length)];
    _selezionaSpecie(context, specie);
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
