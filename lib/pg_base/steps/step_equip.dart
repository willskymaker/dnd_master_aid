import 'dart:math';

import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_equip.dart';
import '../../repositories/json_data_repository.dart';

class StepEquipScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepEquipScreen({super.key, required this.factory});

  @override
  State<StepEquipScreen> createState() => _StepEquipScreenState();
}

class _StepEquipScreenState extends State<StepEquipScreen> {
  OggettoEquip? armaSelezionata;
  OggettoEquip? armaturaSelezionata;
  OggettoEquip? kitSelezionato;
  OggettoEquip? strumentoSelezionato;

  List<OggettoEquip> armi = [];
  List<OggettoEquip> armature = [];
  List<OggettoEquip> kit = [];
  List<OggettoEquip> strumenti = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final equipment = await JsonDataRepository.loadEquipment();

    final List<OggettoEquip> loadedArmi = [];
    final List<OggettoEquip> loadedArmature = [];
    final List<OggettoEquip> loadedKit = [];
    final List<OggettoEquip> loadedStrumenti = [];

    if (equipment.containsKey('weapons')) {
      final weapons = equipment['weapons'] as Map<String, dynamic>;
      for (final entry in weapons.entries) {
        final items = entry.value as List;
        for (final item in items) {
          loadedArmi.add(
            OggettoEquip.fromWeaponJson(
              item as Map<String, dynamic>,
              entry.key,
            ),
          );
        }
      }
    }

    if (equipment.containsKey('armor')) {
      final armor = equipment['armor'] as Map<String, dynamic>;
      for (final entry in armor.entries) {
        final items = entry.value as List;
        for (final item in items) {
          loadedArmature.add(
            OggettoEquip.fromArmorJson(item as Map<String, dynamic>, entry.key),
          );
        }
      }
    }

    if (equipment.containsKey('kits')) {
      final kits = equipment['kits'] as List;
      for (final item in kits) {
        loadedKit.add(OggettoEquip.fromKitJson(item as Map<String, dynamic>));
      }
    }

    if (equipment.containsKey('tools')) {
      final tools = equipment['tools'] as List;
      for (final item in tools) {
        loadedStrumenti.add(
          OggettoEquip.fromToolJson(item as Map<String, dynamic>),
        );
      }
    }

    setState(() {
      armi = loadedArmi;
      armature = loadedArmature;
      kit = loadedKit;
      strumenti = loadedStrumenti;
      _loading = false;
    });
  }

  T? _casuale<T>(List<T> lista) =>
      lista.isEmpty ? null : lista[Random().nextInt(lista.length)];

  /// Come [_casuale], ma pesca solo tra gli oggetti consigliati per
  /// [classe] quando ce ne sono (un oggetto senza classi consigliate resta
  /// disponibile per tutti). Se nessun oggetto e' consigliato per la
  /// classe scelta, ripiega sull'intera lista per non lasciare lo slot
  /// vuoto.
  OggettoEquip? _casualeCompatibile(List<OggettoEquip> lista, String classe) {
    final compatibili =
        lista
            .where(
              (o) =>
                  o.classiConsigliate.isEmpty ||
                  o.classiConsigliate.contains(classe),
            )
            .toList();
    return _casuale(compatibili.isNotEmpty ? compatibili : lista);
  }

  void _randomizza() {
    final classePG = widget.factory.build().classe;
    setState(() {
      armaSelezionata = _casualeCompatibile(armi, classePG);
      armaturaSelezionata = _casualeCompatibile(armature, classePG);
      kitSelezionato = _casuale(kit);
      strumentoSelezionato = _casuale(strumenti);
    });
  }

  @override
  Widget build(BuildContext context) {
    final classePG = widget.factory.build().classe;

    return Scaffold(
      appBar: AppBar(title: const Text("Step: Equipaggiamento")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Scegli arma, armatura, kit e strumento",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Arma",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<OggettoEquip>(
                        hint: const Text("Seleziona un'arma"),
                        value: armaSelezionata,
                        isExpanded: true,
                        items:
                            armi.map((o) {
                              final compatibile =
                                  o.classiConsigliate.isEmpty ||
                                  o.classiConsigliate.contains(classePG);
                              return DropdownMenuItem(
                                value: o,
                                child: Text(
                                  "${o.nome} (${o.danno ?? '-'})",
                                  style: TextStyle(
                                    color:
                                        compatibile
                                            ? Colors.green
                                            : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (val) => setState(() => armaSelezionata = val),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Armatura",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<OggettoEquip>(
                        hint: const Text("Seleziona un'armatura"),
                        value: armaturaSelezionata,
                        isExpanded: true,
                        items:
                            armature.map((o) {
                              final compatibile =
                                  o.classiConsigliate.isEmpty ||
                                  o.classiConsigliate.contains(classePG);
                              return DropdownMenuItem(
                                value: o,
                                child: Text(
                                  "${o.nome} (${o.descrizione})",
                                  style: TextStyle(
                                    color:
                                        compatibile
                                            ? Colors.green
                                            : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (val) => setState(() => armaturaSelezionata = val),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Kit di avventura",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<OggettoEquip>(
                        hint: const Text("Seleziona un kit"),
                        value: kitSelezionato,
                        isExpanded: true,
                        items:
                            kit.isEmpty
                                ? [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text("Nessun kit"),
                                  ),
                                ]
                                : kit.map((o) {
                                  return DropdownMenuItem(
                                    value: o,
                                    child: Text(o.nome),
                                  );
                                }).toList(),
                        onChanged:
                            (val) => setState(() => kitSelezionato = val),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Strumenti",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<OggettoEquip>(
                        hint: const Text("Seleziona uno strumento"),
                        value: strumentoSelezionato,
                        isExpanded: true,
                        items:
                            strumenti.isEmpty
                                ? [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text("Nessuno strumento"),
                                  ),
                                ]
                                : strumenti.map((o) {
                                  return DropdownMenuItem(
                                    value: o,
                                    child: Text(o.nome),
                                  );
                                }).toList(),
                        onChanged:
                            (val) => setState(() => strumentoSelezionato = val),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _randomizza,
                          icon: const Icon(Icons.casino),
                          label: const Text("Equipaggiamento casuale"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _conferma,
                          child: const Text("Conferma Equipaggiamento"),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Salta Step"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  void _conferma() {
    final equipaggiamentoSelezionato = <String>[];

    if (armaSelezionata != null) {
      equipaggiamentoSelezionato.add(armaSelezionata!.nome);
    }
    if (armaturaSelezionata != null) {
      equipaggiamentoSelezionato.add(armaturaSelezionata!.nome);
    }
    if (kitSelezionato != null) {
      equipaggiamentoSelezionato.add(kitSelezionato!.nome);
    }
    if (strumentoSelezionato != null) {
      equipaggiamentoSelezionato.add(strumentoSelezionato!.nome);
    }

    widget.factory.addEquipaggiamento(equipaggiamentoSelezionato);

    if (equipaggiamentoSelezionato.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nessun equipaggiamento selezionato.")),
      );
    }

    Navigator.pop(context, true);
  }
}
