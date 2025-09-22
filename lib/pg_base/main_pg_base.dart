import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../factory_pg_base.dart';
import 'steps/step_nome.dart';
import 'steps/step_specie.dart';
import 'steps/step_classe.dart';
import 'steps/step_livello.dart';
import 'steps/step_caratteristiche.dart';
import 'steps/step_abilita.dart';
import 'steps/step_equip.dart';
import 'steps/step_export.dart';
import '../core/logger.dart';
import '../providers/character_provider.dart';
import '../widgets/character_progress_indicator.dart';

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
      appBar: AppBar(
        title: const Text("Creazione Personaggio Base"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Consumer<CharacterProvider>(
            builder: (context, provider, child) {
              return const CharacterProgressIndicator();
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mostra eventuali errori del provider
            Consumer<CharacterProvider>(
              builder: (context, provider, child) {
                if (provider.errorMessage != null) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          onPressed: provider.clearError,
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            const Text(
              "🧙‍♂️ Benvenuto nel generatore rapido di PG!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _iniziaCreazione(),
              child: const Text("Inizia la creazione"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _iniziaCreazione() async {
    try {
      AppLogger.info("Iniziando creazione personaggio");

      if (!await _eseguiStep("Nome", () => vaiAStepNome(context, factory))) return;
      if (!await _eseguiStep("Specie", () => vaiAStepSpecie(context, factory))) return;
      if (!await _eseguiStep("Classe", () => vaiAStepClasse(context, factory))) return;
      if (!await _eseguiStep("Livello", () => vaiAStepLivello(context, factory))) return;
      if (!await _eseguiStep("Caratteristiche", () => vaiAStepCaratteristiche(context, factory))) return;
      if (!await _eseguiStep("Abilità", () => vaiAStepAbilita(context, factory))) return;
      if (!await _eseguiStep("Equipaggiamento", () => vaiAStepEquipaggiamento(context, factory))) return;

      final pg = factory.build();
      AppLogger.debug("Personaggio generato: ${pg.nome}");
      _mostraScheda(pg);

      await _eseguiStep("Export PDF", () => vaiAStepExportPDF(context, factory));

    } catch (e, stackTrace) {
      AppLogger.error("Errore durante la creazione del personaggio", e, stackTrace);
      _mostraErrore("Errore durante la creazione del personaggio: $e");
    }
  }

  Future<bool> _eseguiStep(String nomeStep, Future<bool> Function() stepFunction) async {
    try {
      AppLogger.debug("Eseguendo step: $nomeStep");
      final result = await stepFunction();
      if (!result) {
        AppLogger.info("Step $nomeStep annullato dall'utente");
      }
      return result;
    } catch (e, stackTrace) {
      AppLogger.error("Errore nello step $nomeStep", e, stackTrace);
      _mostraErrore("Errore nello step $nomeStep: $e");
      return false;
    }
  }

  void _mostraErrore(String messaggio) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Errore", style: TextStyle(color: Colors.red)),
          content: Text(messaggio),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  void _mostraScheda(PGBase pg) {
    AppLogger.debug("Mostrando la scheda del personaggio");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Personaggio Generato"),
        content: SingleChildScrollView(
          child: Text(
            '''
Nome: ${pg.nome}
Specie: ${pg.specie}
Classe: ${pg.classe}
Livello: ${pg.livello}
Punti Vita: ${pg.puntiVita} (d${pg.dadoVita}, COS ${pg.modificatori['COS']! >= 0 ? '+' : ''}${pg.modificatori['COS']})
Velocità: ${pg.velocita} m
Linguaggi: ${pg.linguaggi.join(', ')}

Caratteristiche:
${pg.caratteristiche.entries.map((e) {
  final mod = pg.modificatori[e.key] ?? 0;
  final segno = mod >= 0 ? '+' : '';
  return "${e.key}: ${e.value} ($segno$mod)";
}).join(', ')}

Abilità: ${pg.abilitaClasse.join(', ')}

Competenze: ${pg.competenze.join(', ')}
Abilità Innate: ${pg.capacitaSpeciali.join(', ')}
Equipaggiamento: ${pg.equipaggiamento.isNotEmpty ? pg.equipaggiamento.map((e) => '• $e').join('\n') : '—'}
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
Future<bool> vaiAStepAbilita(BuildContext context, PGBaseFactory factory) async {
  bool result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepAbilitaScreen(factory: factory),
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
