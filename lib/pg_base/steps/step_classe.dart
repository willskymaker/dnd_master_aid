import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_classi.dart';

final List<String> classiCore = [
  "Barbaro", "Bardo", "Chierico", "Druido",
  "Guerriero", "Ladro", "Mago", "Monaco",
  "Paladino", "Ranger", "Stregone", "Warlock"
];

class StepClasseScreen extends StatelessWidget {
  final PGBaseFactory factory;

  const StepClasseScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    final classiDisponibili = classiList
        .where((c) => classiCore.contains(c.nome))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Step 3: Scegli la Classe")),
      body: ListView.builder(
        itemCount: classiDisponibili.length,
        itemBuilder: (context, index) {
          final classe = classiDisponibili[index];

          return Card(
            margin: const EdgeInsets.all(8),
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
    );
  }

  void _selezionaClasse(BuildContext context, Classe classe) {
    factory.setClasse(classe.nome);
    factory.setDadoVita(classe.dadoVita);
    factory.setTiriSalvezza(classe.tiriSalvezza);
    factory.setCompetenzeArmi(classe.competenzeArmi);
    factory.setCompetenzeArmature(classe.competenzeArmature);
    factory.setCompetenzeStrumenti(classe.competenzeStrumenti);

    // Per ora scegliamo automaticamente le prime X abilità
    final abilitaScelte = classe.abilitaSelezionabili.take(classe.abilitaDaSelezionare).toList();
    factory.setAbilitaClasse(abilitaScelte);

    // Calcolo HP iniziali = dado vita + mod COS (valutiamo dopo)
    final modCos = factory.getModificatore("COS");
    final hp = classe.dadoVita + modCos;
    factory.setPuntiVita(hp);

    Navigator.pop(context);
  }
}

Future<void> vaiAStepClasse(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepClasseScreen(factory: factory),
    ),
  );
}
