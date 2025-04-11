import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_equip.dart';

class StepEquipScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepEquipScreen({super.key, required this.factory});

  @override
  State<StepEquipScreen> createState() => _StepEquipScreenState();
}

class _StepEquipScreenState extends State<StepEquipScreen> {
  OggettoEquip? armaSelezionata;
  OggettoEquip? armaturaSelezionata;
  OggettoEquip? oggettoMagicoSelezionato;
  OggettoEquip? kitSelezionato;

  @override
  Widget build(BuildContext context) {
    final classePG = widget.factory.build().classe;

    // Armi, armature, oggetti magici e kit
    final armi = oggettiEquipList.where((o) => o.tipo == 'arma').toList();
    final armature = oggettiEquipList.where((o) => o.tipo == 'armatura').toList();
    final oggettiMagici = oggettiEquipList.where((o) => o.tipo == 'oggetto' && o.proprieta.contains("magico")).toList();
    final kit = oggettiEquipList.where((o) => o.tipo == 'oggetto' && o.categoria == "strumento").toList();

    // Evidenziazione delle armi e armature compatibili
    final armiCompatibili = armi.where((o) => o.classiConsigliate.isEmpty || o.classiConsigliate.contains(classePG)).toList();
    final armatureCompatibili = armature.where((o) => o.classiConsigliate.isEmpty || o.classiConsigliate.contains(classePG)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Step: Equipaggiamento")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Scegli arma, armatura, oggetto magico e kit", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            const Text("Arma", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<OggettoEquip>(
              hint: const Text("Seleziona un'arma"),
              value: armaSelezionata,
              isExpanded: true,
              items: armi.map((o) {
                bool compatibile = armiCompatibili.contains(o);
                return DropdownMenuItem(
                  value: o,
                  child: Text(
                    "${o.nome} (${o.danno ?? "-"})",
                    style: TextStyle(
                      color: compatibile ? Colors.green : Colors.black, // Evidenzia compatibili
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => armaSelezionata = val),
            ),
            const SizedBox(height: 20),

            const Text("Armatura", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<OggettoEquip>(
              hint: const Text("Seleziona un'armatura"),
              value: armaturaSelezionata,
              isExpanded: true,
              items: armature.map((o) {
                bool compatibile = armatureCompatibili.contains(o);
                return DropdownMenuItem(
                  value: o,
                  child: Text(
                    "${o.nome} (${o.categoria})",
                    style: TextStyle(
                      color: compatibile ? Colors.green : Colors.black, // Evidenzia compatibili
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => armaturaSelezionata = val),
            ),
            const SizedBox(height: 20),

            const Text("Oggetto Magico", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<OggettoEquip>(
              hint: const Text("Seleziona un oggetto magico"),
              value: oggettoMagicoSelezionato,
              isExpanded: true,
              items: oggettiMagici.isEmpty
                  ? [const DropdownMenuItem(value: null, child: Text("Nessun oggetto magico"))]
                  : oggettiMagici.map((o) {
                      return DropdownMenuItem(
                        value: o,
                        child: Text("${o.nome} (${o.descrizione})"),
                      );
                    }).toList(),
              onChanged: (val) => setState(() => oggettoMagicoSelezionato = val),
            ),
            const SizedBox(height: 20),

            const Text("Kit", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<OggettoEquip>(
              hint: const Text("Seleziona un kit"),
              value: kitSelezionato,
              isExpanded: true,
              items: kit.isEmpty
                  ? [const DropdownMenuItem(value: null, child: Text("Nessun kit"))]
                  : kit.map((o) {
                      return DropdownMenuItem(
                        value: o,
                        child: Text("${o.nome} (${o.descrizione})"),
                      );
                    }).toList(),
              onChanged: (val) => setState(() => kitSelezionato = val),
            ),
            const Spacer(),

            ElevatedButton(
              onPressed: _conferma,
              child: const Text("Conferma Equipaggiamento"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Salta Step"),
            ),
          ],
        ),
      ),
    );
  }

  void _conferma() {
    final equipaggiamentoSelezionato = <String>[];

    if (armaSelezionata != null) equipaggiamentoSelezionato.add(armaSelezionata!.nome);
    if (armaturaSelezionata != null) equipaggiamentoSelezionato.add(armaturaSelezionata!.nome);
    if (oggettoMagicoSelezionato != null) equipaggiamentoSelezionato.add(oggettoMagicoSelezionato!.nome);
    if (kitSelezionato != null) equipaggiamentoSelezionato.add(kitSelezionato!.nome);

    widget.factory.addEquipaggiamento(equipaggiamentoSelezionato);

    if (equipaggiamentoSelezionato.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nessun equipaggiamento selezionato.")),
      );
    }

    Navigator.pop(context, true);
  }
}

Future<void> vaiAStepEquipaggiamento(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepEquipScreen(factory: factory),
    ),
  );
}
