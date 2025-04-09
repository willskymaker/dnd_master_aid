import 'package:flutter/material.dart';
import '../factory_pg_base.dart';
import 'steps/step_nome.dart';
import 'steps/step_specie.dart';
import 'steps/step_classe.dart';

class PGBaseWizard extends StatefulWidget {
  const PGBaseWizard({super.key});

  @override
  State<PGBaseWizard> createState() => _PGBaseWizardState();
}

class _PGBaseWizardState extends State<PGBaseWizard> {
  final PGBaseFactory factory = PGBaseFactory();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Creazione Personaggio Base")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "🧙‍♂️ Benvenuto nel generatore rapido di PG!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // STEP 1: Nome
                await vaiAStepNome(context, factory);

                // STEP 2: Specie
                await vaiAStepSpecie(context, factory);

                // STEP 3: Classe
                await vaiAStepClasse(context, factory);

                // Costruzione finale del PG
                final PGBase pg = factory.build();
                _mostraScheda(pg);
              },
              child: const Text("Inizia la creazione"),
            ),
          ],
        ),
      ),
    );
  }

  void _mostraScheda(PGBase pg) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Personaggio Generato"),
      content: SingleChildScrollView(
        child: Text(
          '''
📝 Nome: ${pg.nome}
🧬 Specie: ${pg.specie}
🧙 Classe: ${pg.classe}
👣 Velocità: ${pg.velocita} m
💬 Linguaggi: ${pg.linguaggi.join(', ')}
🎯 Modificatori: ${pg.modificatori.entries.map((e) => "${e.key}+${e.value}").join(', ')}
🎓 Competenze: ${pg.competenze.join(', ')}
✨ Abilità Innate: ${pg.capacitaSpeciali.join(', ')}
          ''',
          textAlign: TextAlign.left,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Chiudi"),
        )
      ],
    ),
  );
}

}