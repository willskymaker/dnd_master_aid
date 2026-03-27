import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../../factory_pg_base.dart';
import '../../utils/web_pdf_saver.dart';
import '../../core/logger.dart';
import '../../providers/saved_characters_provider.dart';

class StepExportScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepExportScreen({super.key, required this.factory});

  @override
  State<StepExportScreen> createState() => _StepExportScreenState();
}

class _StepExportScreenState extends State<StepExportScreen> {
  bool _salvataggioInCorso = false;
  bool _personaggioSalvato = false;

  String _classeEmoji(String classe) {
    switch (classe.toLowerCase()) {
      case 'barbaro': return '⚔️';
      case 'bardo': return '🎵';
      case 'chierico': return '✝️';
      case 'druido': return '🌿';
      case 'guerriero': return '🛡️';
      case 'ladro': return '🗡️';
      case 'mago': return '🔮';
      case 'monaco': return '👊';
      case 'paladino': return '⚜️';
      case 'ranger': return '🏹';
      case 'stregone': return '✨';
      case 'warlock': return '👁️';
      default: return '🧙';
    }
  }

  Future<void> _salvaPersonaggio(PGBase pg) async {
    setState(() => _salvataggioInCorso = true);
    try {
      await context.read<SavedCharactersProvider>().save(pg);
      setState(() => _personaggioSalvato = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${pg.nome} salvato!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante il salvataggio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvataggioInCorso = false);
    }
  }

  Future<void> _esportaPDF(PGBase pg) async {
    try {
      final filename =
          '${pg.nome}_liv${pg.livello}.pdf'.replaceAll(' ', '_');
      final pdfData = await _generaPDF(pg);

      if (kIsWeb) {
        downloadPdfWeb(pdfData, filename);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📥 PDF scaricato nel browser')),
          );
        }
        return;
      }

      final file = await _salvaPDFLocale(pdfData, filename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📄 PDF salvato in:\n${file.path}')),
        );
      }
      await _apriPDF(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'esportazione: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pg = widget.factory.build();
    final emoji = _classeEmoji(pg.classe);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        title: const Text('Scheda Personaggio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Esporta PDF',
            onPressed: () => _esportaPDF(pg),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header personaggio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Text(
                      pg.nome.isNotEmpty ? pg.nome : 'Personaggio',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pg.classe}  •  ${pg.specie}  •  Livello ${pg.livello}',
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statoPill(
                            Icons.favorite, '${pg.puntiVita} PF', Colors.red),
                        _statoPill(Icons.speed, '${pg.velocita} m',
                            Colors.blue),
                        _statoPill(Icons.casino,
                            'd${pg.dadoVita}', const Color(0xFF8B4513)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Griglia caratteristiche
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Caratteristiche',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    if (pg.caratteristicheImpostate)
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR']
                            .map((s) {
                          final val = pg.caratteristiche[s] ?? 0;
                          final mod = pg.modificatori[s] ?? 0;
                          final segno = mod >= 0 ? '+' : '';
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF8B4513)
                                      .withValues(alpha: 0.35)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(s,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B4513))),
                                Text('$val',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                Text('$segno$mod',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: mod >= 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700)),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const Text('Caratteristiche non impostate',
                          style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dettagli
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dettagli',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    if (pg.abilitaClasse.isNotEmpty)
                      _rigaDettaglio(
                          'Abilità', pg.abilitaClasse.join(', ')),
                    if (pg.linguaggi.isNotEmpty)
                      _rigaDettaglio('Linguaggi', pg.linguaggi.join(', ')),
                    if (pg.competenze.isNotEmpty)
                      _rigaDettaglio(
                          'Competenze', pg.competenze.join(', ')),
                    if (pg.tiriSalvezza.isNotEmpty)
                      _rigaDettaglio(
                          'Tiri Salvezza', pg.tiriSalvezza.join(', ')),
                    if (pg.capacitaSpeciali.isNotEmpty)
                      _rigaDettaglio(
                          'Abilità innate', pg.capacitaSpeciali.join(', ')),
                  ],
                ),
              ),
            ),

            if (pg.equipaggiamento.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Equipaggiamento',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      ...pg.equipaggiamento.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.circle,
                                    size: 6, color: Color(0xFF8B4513)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Bottone salvataggio principale
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _salvataggioInCorso
                    ? null
                    : () => _salvaPersonaggio(pg),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _personaggioSalvato
                      ? Colors.green.shade700
                      : const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                ),
                icon: _salvataggioInCorso
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(_personaggioSalvato
                        ? Icons.check
                        : Icons.save),
                label: Text(
                  _salvataggioInCorso
                      ? 'Salvataggio...'
                      : _personaggioSalvato
                          ? 'Personaggio salvato!'
                          : 'Salva Personaggio',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _esportaPDF(pg),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Esporta PDF'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statoPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _rigaDettaglio(String label, String valore) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Expanded(
                child: Text(valore,
                    style: TextStyle(color: Colors.grey.shade800))),
          ],
        ),
      );

  Future<Uint8List> _generaPDF(PGBase pg) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _buildScheda(pg),
          ),
        ),
      ),
    );
    return pdf.save();
  }

  List<pw.Widget> _buildScheda(PGBase pg) {
    final List<pw.Widget> contenuto = [];
    contenuto.add(pw.Text('Scheda Personaggio',
        style: pw.TextStyle(fontSize: 24)));
    contenuto.add(pw.SizedBox(height: 12));
    contenuto.addAll([
      if (pg.nome.isNotEmpty) pw.Text('Nome: ${pg.nome}'),
      if (pg.specie.isNotEmpty) pw.Text('Specie: ${pg.specie}'),
      if (pg.classe.isNotEmpty) pw.Text('Classe: ${pg.classe}'),
      pw.Text('Livello: ${pg.livello}'),
      pw.Text('Punti Vita: ${pg.puntiVita} (d${pg.dadoVita})'),
      pw.Text('Velocità: ${pg.velocita} m'),
      if (pg.linguaggi.isNotEmpty)
        pw.Text('Linguaggi: ${pg.linguaggi.join(", ")}'),
      pw.SizedBox(height: 8),
    ]);
    if (pg.caratteristicheImpostate && pg.caratteristiche.isNotEmpty) {
      contenuto.add(pw.Text('Caratteristiche:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
      contenuto.add(pw.Text(
        pg.caratteristiche.entries.map((e) {
          final mod = pg.modificatori[e.key] ?? 0;
          final segno = mod >= 0 ? '+' : '';
          return '${e.key}: ${e.value} ($segno$mod)';
        }).join(', '),
      ));
    }
    if (pg.abilitaClasse.isNotEmpty)
      contenuto.add(pw.Text('Abilità: ${pg.abilitaClasse.join(", ")}'));
    if (pg.competenze.isNotEmpty)
      contenuto.add(pw.Text('Competenze: ${pg.competenze.join(", ")}'));
    if (pg.capacitaSpeciali.isNotEmpty)
      contenuto
          .add(pw.Text('Abilità Innate: ${pg.capacitaSpeciali.join(", ")}'));
    if (pg.equipaggiamento.isNotEmpty) {
      contenuto.add(pw.SizedBox(height: 8));
      contenuto.add(pw.Text('Equipaggiamento:'));
      contenuto.add(
          pw.Text(pg.equipaggiamento.map((e) => '- $e').join('\n')));
    }
    return contenuto;
  }

  Future<File> _salvaPDFLocale(Uint8List data, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(data);
    return file;
  }

  Future<void> _apriPDF(File file) async {
    final path = file.path;
    if (Platform.isLinux) {
      await Process.run('xdg-open', [path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [path]);
    } else if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', path]);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await OpenFile.open(path);
    }
  }
}

Future<bool> vaiAStepExportPDF(
    BuildContext context, PGBaseFactory factory) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepExportScreen(factory: factory),
    ),
  );
  return result ?? true;
}
