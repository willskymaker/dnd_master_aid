import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_background.dart';
import '../../data/db_allineamenti.dart';

class StepBackgroundScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepBackgroundScreen({super.key, required this.factory});

  @override
  State<StepBackgroundScreen> createState() => _StepBackgroundScreenState();
}

class _StepBackgroundScreenState extends State<StepBackgroundScreen> {
  Background? _backgroundSelezionato;
  String? _allineamentoSelezionato;

  void _conferma() {
    if (_backgroundSelezionato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona un background prima di continuare.')),
      );
      return;
    }
    if (_allineamentoSelezionato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona un allineamento prima di continuare.')),
      );
      return;
    }

    final bg = _backgroundSelezionato!;
    widget.factory.setBackground(bg.nome);
    widget.factory.setAllineamento(_allineamentoSelezionato!);

    // Aggiungi competenze abilità dal background
    for (final comp in bg.competenzeAbilita) {
      widget.factory.addCompetenza(comp);
    }
    // Aggiungi competenze strumenti
    for (final strumento in bg.competenzeStrumenti) {
      widget.factory.addCompetenza(strumento);
    }
    // Aggiungi linguaggi (escludi "A scelta" generici)
    final linguaggiReali = bg.linguaggi.where((l) => l != 'A scelta').toList();
    if (linguaggiReali.isNotEmpty) {
      widget.factory.addLinguaggi(linguaggiReali);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(title: const Text('Step: Background e Allineamento')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Scegli il background del personaggio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Il background definisce la storia passata, le competenze e la personalità.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ...backgroundList.map((bg) => _BackgroundCard(
                      bg: bg,
                      selezionato: _backgroundSelezionato?.nome == bg.nome,
                      onTap: () => setState(() => _backgroundSelezionato = bg),
                    )),
                const Divider(height: 32),
                const Text(
                  'Allineamento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allineamentiList.map((a) {
                    final sel = _allineamentoSelezionato == a.nome;
                    return GestureDetector(
                      onTap: () => setState(() => _allineamentoSelezionato = a.nome),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF8B4513).withValues(alpha: 0.12) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? const Color(0xFF8B4513) : Colors.grey.shade300,
                            width: sel ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          a.nome,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                            color: sel ? const Color(0xFF8B4513) : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Bottone conferma fisso in basso
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _conferma,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(
                    _backgroundSelezionato == null
                        ? 'Seleziona un background'
                        : 'Conferma: ${_backgroundSelezionato!.nome}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundCard extends StatelessWidget {
  final Background bg;
  final bool selezionato;
  final VoidCallback onTap;

  const _BackgroundCard({required this.bg, required this.selezionato, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selezionato ? const Color(0xFF8B4513).withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selezionato ? const Color(0xFF8B4513) : Colors.grey.shade200,
            width: selezionato ? 2 : 1,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: selezionato
                ? const Icon(Icons.check_circle, color: Color(0xFF8B4513))
                : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            title: Text(
              bg.nome,
              style: TextStyle(
                fontWeight: selezionato ? FontWeight.bold : FontWeight.normal,
                color: selezionato ? const Color(0xFF8B4513) : Colors.black87,
              ),
            ),
            subtitle: Text(
              bg.competenzeAbilita.join(', '),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bg.descrizione, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    const SizedBox(height: 10),
                    if (bg.competenzeAbilita.isNotEmpty)
                      _chip('Abilità', bg.competenzeAbilita.join(', '), Icons.star),
                    if (bg.competenzeStrumenti.isNotEmpty)
                      _chip('Strumenti', bg.competenzeStrumenti.join(', '), Icons.build),
                    if (bg.linguaggi.isNotEmpty)
                      _chip('Linguaggi', bg.linguaggi.join(', '), Icons.language),
                    _chip('Equipaggiamento', bg.equipaggiamento, Icons.backpack),
                    const Divider(height: 16),
                    _tratto('💡 Tratto', bg.tratto),
                    _tratto('⚖️ Ideale', bg.ideali),
                    _tratto('🔗 Legame', bg.legami),
                    _tratto('⚠️ Difetto', bg.difetti),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(selezionato ? '✓ Selezionato' : 'Scegli questo background'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, String valore, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF8B4513)),
            const SizedBox(width: 6),
            Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Expanded(child: Text(valore, style: const TextStyle(fontSize: 12))),
          ],
        ),
      );

  Widget _tratto(String label, String testo) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            children: [
              TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: testo, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      );
}
