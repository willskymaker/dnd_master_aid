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
              onPressed: () => _saltaStep(context, classiDisponibili),
              child: const Text('Salta Step'),
            ),
          ),
        ],
      ),
    );
  }

  void _saltaStep(BuildContext context, List<Classe> classiDisponibili) {
    _selezionaClasse(context, classiDisponibili.first);
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
