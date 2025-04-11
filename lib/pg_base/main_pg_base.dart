import 'package:flutter/material.dart';
import '../factory_pg_base.dart';
import 'steps/step_nome.dart';
import 'steps/step_specie.dart';
import 'steps/step_classe.dart';
import 'steps/step_livello.dart';
import 'steps/step_caratteristiche.dart';
import 'steps/step_equip.dart';
import 'steps/step_export.dart';

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
                 if (!(await vaiAStepNome(context, factory) ?? false)) return;
                 if (!(await vaiAStepSpecie(context, factory) ?? false)) return;
                 if (!(await vaiAStepClasse(context, factory) ?? false)) return;
                 if (!(await vaiAStepLivello(context, factory) ?? false)) return;
                 if (!(await vaiAStepCaratteristiche(context, factory) ?? false)) return;
                 if (!(await vaiAStepEquipaggiamento(context, factory) ?? false)) return;

                 PGBase pg = factory.build();
                 print(pg.nome); // Verifica che il personaggio sia generato correttamente
                 _mostraScheda(pg);

                // 👉 Step per esportazione PDF
                 await vaiAStepExportPDF(context, factory);
              },

              child: const Text("Inizia la creazione"),
            ),
          ],
        ),
      ),
    );
  }

  void _mostraScheda(PGBase pg) {
    print("Mostrando la scheda del personaggio...");  // Debugging
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
🔢 Livello: ${pg.livello}
❤️ Punti Vita: ${pg.puntiVita} (d${pg.dadoVita}, COS ${pg.modificatori['COS']! >= 0 ? '+' : ''}${pg.modificatori['COS']})
👣 Velocità: ${pg.velocita} m
💬 Linguaggi: ${pg.linguaggi.join(', ')}

📊 Caratteristiche:
${pg.caratteristiche.entries.map((e) {
  final mod = pg.modificatori[e.key] ?? 0;
  final segno = mod >= 0 ? '+' : '';
  return "${e.key}: ${e.value} ($segno$mod)";
}).join(', ')}

🎓 Competenze: ${pg.competenze.join(', ')}
✨ Abilità Innate: ${pg.capacitaSpeciali.join(', ')}
🧰 Equipaggiamento: ${pg.equipaggiamento.isNotEmpty ? pg.equipaggiamento.map((e) => '• $e').join('\n') : '—'}
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

Future<bool> vaiAStepNome(BuildContext context, PGBaseFactory factory) async {
  bool result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepNomeScreen(factory: factory),
    ),
  ) ?? false;  // Restituisce false se il risultato è null
  return result;
}

Future<bool> vaiAStepSpecie(BuildContext context, PGBaseFactory factory) async {
  bool result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepSpecieScreen(factory: factory),
    ),
  ) ?? false;
  return result;
}

Future<bool> vaiAStepClasse(BuildContext context, PGBaseFactory factory) async {
  bool result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepClasseScreen(factory: factory),
    ),
  ) ?? false;
  return result;
}

Future<bool> vaiAStepLivello(BuildContext context, PGBaseFactory factory) async {
  bool result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepLivelloScreen(factory: factory),
    ),
  ) ?? false;
  return result;
}

Future<bool> vaiAStepCaratteristiche(BuildContext context, PGBaseFactory factory) async {
  bool result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepCaratteristicheScreen(factory: factory),
    ),
  ) ?? false;
  return result;
}

Future<bool> vaiAStepEquipaggiamento(BuildContext context, PGBaseFactory factory) async {
  bool result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepEquipScreen(factory: factory),
    ),
  ) ?? false;
  return result;
}
