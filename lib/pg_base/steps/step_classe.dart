import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../factory_pg_base.dart';
import '../../data/db_classi.dart';
import '../../widgets/mobile/mobile_scaffold.dart';

final List<String> classiCore = [
  "Barbaro",
  "Bardo",
  "Chierico",
  "Druido",
  "Guerriero",
  "Ladro",
  "Mago",
  "Monaco",
  "Paladino",
  "Ranger",
  "Stregone",
  "Warlock",
];

class StepClasseScreen extends StatelessWidget {
  final PGBaseFactory factory;

  const StepClasseScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    final classiDisponibili =
        classiList.where((c) => classiCore.contains(c.nome)).toList();

    return MobileScaffold(
      title: "Step 3: Scegli la Classe",
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _randomizza(context, classiDisponibili),
                icon: const Icon(Icons.casino),
                label: const Text('Classe casuale'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: classiDisponibili.length,
              itemBuilder: (context, index) {
                final classe = classiDisponibili[index];

                return Card(
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  child: ListTile(
                    title: Text(classe.nome),
                    subtitle: Text(classe.descrizione),
                    onTap: () {
                      _selezionaClasse(context, classe);
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

  void _randomizza(BuildContext context, List<Classe> classiDisponibili) {
    final classe =
        classiDisponibili[Random().nextInt(classiDisponibili.length)];
    _selezionaClasse(context, classe);
  }

  void _selezionaClasse(BuildContext context, Classe classe) {
    factory.setClasse(classe.nome);
    factory.setDadoVita(classe.dadoVita);
    factory.setTiriSalvezza(classe.tiriSalvezza);
    factory.setCompetenzeArmi(classe.competenzeArmi);
    factory.setCompetenzeArmature(classe.competenzeArmature);
    factory.setCompetenzeStrumenti(classe.competenzeStrumenti);

    final abilitaScelte =
        classe.abilitaSelezionabili.take(classe.abilitaDaSelezionare).toList();
    factory.setAbilitaClasse(abilitaScelte);

    Navigator.pop(context, true);
  }
}
