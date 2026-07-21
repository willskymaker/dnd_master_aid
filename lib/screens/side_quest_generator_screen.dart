import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/saved_npc_service.dart';
import '../utils/npc_generator.dart';
import '../utils/side_quest_generator.dart';
import '../utils/clipboard_helper.dart';
import '../widgets/mobile/mobile_scaffold.dart';

class SideQuestGeneratorScreen extends StatefulWidget {
  const SideQuestGeneratorScreen({super.key});

  @override
  State<SideQuestGeneratorScreen> createState() =>
      _SideQuestGeneratorScreenState();
}

class _SideQuestGeneratorScreenState extends State<SideQuestGeneratorScreen> {
  List<Png> _pngSalvati = [];
  Png? _committenteScelto;
  SideQuest? _quest;

  @override
  void initState() {
    super.initState();
    _caricaPngSalvati();
  }

  Future<void> _caricaPngSalvati() async {
    final png = await SavedNpcService.caricaTutti();
    if (!mounted) return;
    setState(() => _pngSalvati = png);
  }

  void _genera() {
    setState(() => _quest = generaSideQuest(committente: _committenteScelto));
  }

  String _formatSideQuestText(SideQuest quest) {
    final buffer = StringBuffer();
    buffer.writeln('=== Side Quest Generata ===');
    buffer.writeln();
    buffer.writeln('🎯 Obiettivo: ${quest.obiettivo}');
    buffer.writeln('👤 Committente: ${quest.committente.nome} (${quest.committente.occupazione})');
    buffer.writeln('⚡ Complicazione: ${quest.complicazione}');
    buffer.writeln('💰 Ricompensa: ${quest.ricompensa}');
    buffer.writeln();
    buffer.writeln('=== Fine Side Quest ===');
    return buffer.toString();
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
    final quest = _quest;

    return MobileScaffold(
      title: 'Generatore Side Quest',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_pngSalvati.isNotEmpty) ...[
              Text(
                'Committente',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Casuale'),
                    selected: _committenteScelto == null,
                    onSelected:
                        (_) => setState(() => _committenteScelto = null),
                  ),
                  for (final png in _pngSalvati)
                    ChoiceChip(
                      label: Text(png.nome),
                      selected: _committenteScelto?.id == png.id,
                      onSelected:
                          (_) => setState(() => _committenteScelto = png),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            ElevatedButton.icon(
              onPressed: _genera,
              icon: const Icon(Icons.casino),
              label: const Text('Genera side quest'),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (quest == null)
              const Text('Premi il pulsante per generare una side quest.')
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sezione('Obiettivo', quest.obiettivo),
                      _sezione(
                        'Committente',
                        '${quest.committente.nome} '
                            '(${quest.committente.occupazione})',
                      ),
                      _sezione('Complicazione', quest.complicazione),
                      _sezione('Ricompensa', quest.ricompensa),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final text = _formatSideQuestText(quest);
                                ClipboardHelper.copyToClipboard(
                                  context,
                                  text,
                                  'Side Quest',
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('Copia Side Quest'),
                            ),
                          ),
                        ],
                      ),
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
