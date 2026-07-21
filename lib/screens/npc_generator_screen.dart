import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/db_nomi.dart';
import '../services/saved_npc_service.dart';
import '../utils/npc_generator.dart';
import '../utils/clipboard_helper.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import 'saved_npcs_screen.dart';

class NpcGeneratorScreen extends StatefulWidget {
  const NpcGeneratorScreen({super.key});

  @override
  State<NpcGeneratorScreen> createState() => _NpcGeneratorScreenState();
}

class _NpcGeneratorScreenState extends State<NpcGeneratorScreen> {
  String _fonteNomi = nomiPerSpecie.keys.first;
  Png? _png;
  bool _salvato = false;

  void _genera() {
    setState(() {
      _png = generaPng(fonteNomi: _fonteNomi);
      _salvato = false;
    });
  }

  Future<void> _salvaPng() async {
    final png = _png;
    if (png == null) return;
    await SavedNpcService.salva(png);
    if (!mounted) return;
    setState(() => _salvato = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${png.nome} salvato tra i PNG della campagna')),
    );
  }

  String _formatNpcText(Png npc) {
    final buffer = StringBuffer();
    buffer.writeln('=== PNG Generato ===');
    buffer.writeln();
    buffer.writeln('👤 Nome: ${npc.nome}');
    buffer.writeln('📝 Aspetto: ${npc.aspetto}');
    buffer.writeln('🎭 Personalità: ${npc.personalita}');
    buffer.writeln('💼 Occupazione: ${npc.occupazione}');
    buffer.writeln('🎯 Gancio di Trama: ${npc.ganceTrama}');
    buffer.writeln();
    buffer.writeln('=== Fine PNG ===');
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
      actions: [
        IconButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedNpcsScreen()),
              ),
          icon: const Icon(Icons.people_alt_outlined),
          tooltip: 'PNG salvati',
        ),
      ],
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
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _salvato ? null : _salvaPng,
                              icon: Icon(
                                _salvato ? Icons.check : Icons.bookmark_add_outlined,
                              ),
                              label: Text(
                                _salvato
                                    ? 'Salvato tra i PNG della campagna'
                                    : 'Salva per riusarlo in altre sessioni',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copia PNG',
                            onPressed: () {
                              final text = _formatNpcText(png);
                              ClipboardHelper.copyToClipboard(context, text, 'PNG');
                            },
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
