import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../factory_pg_base.dart';
import '../../data/db_abilita.dart';
import '../../data/db_classi.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';
import '../../widgets/mobile/mobile_scaffold.dart';

class StepAbilitaScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepAbilitaScreen({super.key, required this.factory});

  @override
  State<StepAbilitaScreen> createState() => _StepAbilitaScreenState();
}

class _StepAbilitaScreenState extends State<StepAbilitaScreen> {
  List<String> abilitaSelezionate = [];
  late List<String> abilitaDisponibili;
  late int maxAbilita;

  @override
  void initState() {
    super.initState();
    final pg = widget.factory.build();
    final classe = classiList.firstWhere((c) => c.nome == pg.classe);
    abilitaDisponibili = classe.abilitaSelezionabili;
    maxAbilita = classe.abilitaDaSelezionare;
  }

  void _toggleAbilita(String nome) {
    setState(() {
      if (abilitaSelezionate.contains(nome)) {
        abilitaSelezionate.remove(nome);
      } else if (abilitaSelezionate.length < maxAbilita) {
        abilitaSelezionate.add(nome);
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
        SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red),
      );
    }
  }

  bool _validaAbilita() {
    if (abilitaSelezionate.length != maxAbilita) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Seleziona esattamente $maxAbilita abilità (${abilitaSelezionate.length}/$maxAbilita).",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    for (var abilita in abilitaSelezionate) {
      if (!abilitaDisponibili.contains(abilita)) {
        throw ValidationException(
          "L'abilità $abilita non è disponibile per questa classe",
          "Abilità",
        );
      }
    }
    return true;
  }

  void _saltaStep() {
    widget.factory.setAbilitaClasse([]);
    Navigator.pop(context, true);
  }

  void _randomizza() {
    final disponibili = List<String>.from(abilitaDisponibili)
      ..shuffle(Random());
    setState(() {
      abilitaSelezionate = disponibili.take(maxAbilita).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selezionate = abilitaSelezionate.length;
    final completo = selezionate == maxAbilita;
    final coloreCounter =
        completo
            ? Colors.green
            : (selezionate > 0 ? Colors.orange : Colors.grey);

    // Solo le abilità disponibili per questa classe
    final listaAbilita =
        abilitaList.where((a) => abilitaDisponibili.contains(a.nome)).toList();

    return MobileScaffold(
      title: "Abilità",
      body: Column(
        children: [
          // Counter visibile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            color: coloreCounter.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$selezionate',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: coloreCounter,
                  ),
                ),
                Text(
                  ' / $maxAbilita',
                  style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Text(
                  'abilità selezionate',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                if (completo) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          // Lista abilità disponibili per la classe
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: listaAbilita.length,
              itemBuilder: (context, index) {
                final abilita = listaAbilita[index];
                final selezionata = abilitaSelezionate.contains(abilita.nome);
                final puoSelezionare = selezionata || selezionate < maxAbilita;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  color:
                      selezionata
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side:
                        selezionata
                            ? const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            )
                            : BorderSide.none,
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      abilita.nome,
                      style: TextStyle(
                        fontWeight:
                            selezionata ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${abilita.caratteristicaAssociata}  •  ${abilita.descrizione}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: selezionata,
                    activeColor: AppColors.primary,
                    onChanged:
                        puoSelezionare
                            ? (_) => _toggleAbilita(abilita.nome)
                            : null,
                  ),
                );
              },
            ),
          ),
          // Bottoni
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _randomizza,
                    icon: const Icon(Icons.casino),
                    label: const Text('Abilità casuali'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: completo ? _conferma : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      completo
                          ? 'Conferma Abilità'
                          : 'Seleziona ancora ${maxAbilita - selezionate}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _saltaStep,
                  child: const Text('Salta Step'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
