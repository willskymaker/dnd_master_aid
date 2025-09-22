import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_abilita.dart';
import '../../data/db_classi.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';

class StepAbilitaScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepAbilitaScreen({super.key, required this.factory});

  @override
  State<StepAbilitaScreen> createState() => _StepAbilitaScreenState();
}

class _StepAbilitaScreenState extends State<StepAbilitaScreen> {
  List<String> abilitaSelezionate = [];
  late List<String> suggeriteClasse;
  late int maxAbilita;

  @override
  void initState() {
    super.initState();

    final pg = widget.factory.build();
    final classe = classiList.firstWhere((c) => c.nome == pg.classe);
    suggeriteClasse = classe.abilitaSelezionabili;
    maxAbilita = classe.abilitaDaSelezionare;
  }

  void _toggleAbilita(String nome) {
    setState(() {
      if (abilitaSelezionate.contains(nome)) {
        abilitaSelezionate.remove(nome);
      } else {
        if (abilitaSelezionate.length < maxAbilita) {
          abilitaSelezionate.add(nome);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Puoi selezionare solo $maxAbilita abilità.")),
          );
        }
      }
    });
  }

  void _conferma() {
    try {
      if (!_validaAbilita()) return;

      widget.factory.setAbilitaClasse(abilitaSelezionate);
      AppLogger.info("Abilità selezionate: $abilitaSelezionate");
      Navigator.pop(context, true);
    } catch (e) {
      AppLogger.error("Errore nella selezione abilità", e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validaAbilita() {
    if (abilitaSelezionate.length != maxAbilita) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Seleziona esattamente $maxAbilita abilità."),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    // Verifica che tutte le abilità selezionate siano valide per la classe
    for (var abilita in abilitaSelezionate) {
      if (!suggeriteClasse.contains(abilita)) {
        throw ValidationException(
          "L'abilità $abilita non è disponibile per questa classe",
          "Abilità"
        );
      }
    }

    return true;
  }

  void _saltaStep() {
    widget.factory.setAbilitaClasse([]);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info("Step Abilità caricato");

    return Scaffold(
      appBar: AppBar(title: const Text("Step: Abilità")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Seleziona fino a $maxAbilita abilità", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: abilitaList.length,
                itemBuilder: (context, index) {
                  final abilita = abilitaList[index];
                  final selezionata = abilitaSelezionate.contains(abilita.nome);
                  final suggerita = suggeriteClasse.contains(abilita.nome);

                  return Card(
                    color: suggerita ? Colors.lightGreen[50] : null,
                    child: CheckboxListTile(
                      title: Text(abilita.nome),
                      subtitle: Text("${abilita.caratteristicaAssociata} - ${abilita.descrizione}"),
                      value: selezionata,
                      onChanged: (_) => _toggleAbilita(abilita.nome),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _conferma,
              child: const Text("Conferma Abilità"),
            ),
            TextButton(
              onPressed: _saltaStep,
              child: const Text("Salta Step"),
            )
          ],
        ),
      ),
    );
  }
}

Future<bool> vaiAStepAbilita(BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepAbilitaScreen(factory: factory),
    ),
  ) ?? false;
}
