import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/db_nomi.dart';
import '../utils/npc_generator.dart';
import '../widgets/mobile/mobile_scaffold.dart';

class NpcGeneratorScreen extends StatefulWidget {
  const NpcGeneratorScreen({super.key});

  @override
  State<NpcGeneratorScreen> createState() => _NpcGeneratorScreenState();
}

class _NpcGeneratorScreenState extends State<NpcGeneratorScreen> {
  String _tema = nomiPerTema.keys.first;
  Png? _png;

  void _genera() {
    setState(() => _png = generaPng(tema: _tema));
  }

  Widget _sezione(String titolo, String testo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titolo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(testo),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final png = _png;

    return MobileScaffold(
      title: 'Generatore PNG',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tema in nomiPerTema.keys)
                  ChoiceChip(
                    label: Text(tema),
                    selected: _tema == tema,
                    onSelected: (_) => setState(() => _tema = tema),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _genera,
              icon: const Icon(Icons.casino),
              label: const Text('Genera scheda PNG completa'),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (png == null)
              const Text('Premi il pulsante per generare un PNG.')
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        png.nome,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _sezione('Aspetto', png.aspetto),
                      _sezione('Personalità', png.personalita),
                      _sezione('Occupazione', png.occupazione),
                      _sezione('Gancio di trama', png.ganceTrama),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
