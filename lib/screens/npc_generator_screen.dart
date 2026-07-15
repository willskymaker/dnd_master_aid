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
  String _fonteNomi = nomiPerSpecie.keys.first;
  Png? _png;

  void _genera() {
    setState(() => _png = generaPng(fonteNomi: _fonteNomi));
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

  Widget _gruppoChip(String etichetta, Iterable<String> voci) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etichetta,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final voce in voci)
              ChoiceChip(
                label: Text(voce),
                selected: _fonteNomi == voce,
                onSelected: (_) => setState(() => _fonteNomi = voce),
              ),
          ],
        ),
      ],
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
            _gruppoChip('Specie D&D', nomiPerSpecie.keys),
            const SizedBox(height: AppSpacing.md),
            _gruppoChip('Temi extra', nomiPerTema.keys),
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
