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
      case 'barbaro':
        return '⚔️';
      case 'bardo':
        return '🎵';
      case 'chierico':
        return '✝️';
      case 'druido':
        return '🌿';
      case 'guerriero':
        return '🛡️';
      case 'ladro':
        return '🗡️';
      case 'mago':
        return '🔮';
      case 'monaco':
        return '👊';
      case 'paladino':
        return '⚜️';
      case 'ranger':
        return '🏹';
      case 'stregone':
        return '✨';
      case 'warlock':
        return '👁️';
      default:
        return '🧙';
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
      final filename = '${pg.nome}_liv${pg.livello}.pdf'.replaceAll(' ', '_');
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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pg.classe}  •  ${pg.specie}  •  Livello ${pg.livello}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statoPill(
                          Icons.favorite,
                          '${pg.puntiVita} PF',
                          Colors.red,
                        ),
                        _statoPill(
                          Icons.speed,
                          '${pg.velocita} m',
                          Colors.blue,
                        ),
                        _statoPill(
                          Icons.casino,
                          'd${pg.dadoVita}',
                          const Color(0xFF8B4513),
                        ),
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
                    const Text(
                      'Caratteristiche',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (pg.caratteristicheImpostate)
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children:
                            ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'].map((s) {
                              final val = pg.caratteristiche[s] ?? 0;
                              final mod = pg.modificatori[s] ?? 0;
                              final segno = mod >= 0 ? '+' : '';
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(
                                      0xFF8B4513,
                                    ).withValues(alpha: 0.35),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      s,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B4513),
                                      ),
                                    ),
                                    Text(
                                      '$val',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$segno$mod',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            mod >= 0
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      )
                    else
                      const Text(
                        'Caratteristiche non impostate',
                        style: TextStyle(color: Colors.grey),
                      ),
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
                    const Text(
                      'Dettagli',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (pg.abilitaClasse.isNotEmpty)
                      _rigaDettaglio('Abilità', pg.abilitaClasse.join(', ')),
                    if (pg.linguaggi.isNotEmpty)
                      _rigaDettaglio('Linguaggi', pg.linguaggi.join(', ')),
                    if (pg.competenze.isNotEmpty)
                      _rigaDettaglio('Competenze', pg.competenze.join(', ')),
                    if (pg.tiriSalvezza.isNotEmpty)
                      _rigaDettaglio(
                        'Tiri Salvezza',
                        pg.tiriSalvezza.join(', '),
                      ),
                    if (pg.capacitaSpeciali.isNotEmpty)
                      _rigaDettaglio(
                        'Abilità innate',
                        pg.capacitaSpeciali.join(', '),
                      ),
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
                      const Text(
                        'Equipaggiamento',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pg.equipaggiamento.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xFF8B4513),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e)),
                            ],
                          ),
                        ),
                      ),
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
                onPressed:
                    _salvataggioInCorso ? null : () => _salvaPersonaggio(pg),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _personaggioSalvato
                          ? Colors.green.shade700
                          : const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                ),
                icon:
                    _salvataggioInCorso
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Icon(_personaggioSalvato ? Icons.check : Icons.save),
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
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
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
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(valore, style: TextStyle(color: Colors.grey.shade800)),
        ),
      ],
    ),
  );

  Future<Uint8List> _generaPDF(PGBase pg) async {
    final pdf = pw.Document();

    final accent = PdfColor.fromHex('#7B3A10');
    final accentLight = PdfColor.fromHex('#F5EDE4');
    final grey = PdfColor.fromHex('#555555');
    final borderColor = PdfColor.fromHex('#C8A882');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        build:
            (ctx) => [
              // ── HEADER ──────────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: accentLight,
                  border: pw.Border.all(color: borderColor),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            pg.nome.isNotEmpty ? pg.nome : 'Personaggio',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${pg.classe}  •  ${pg.specie}  •  Livello ${pg.livello}',
                            style: pw.TextStyle(fontSize: 12, color: grey),
                          ),
                        ],
                      ),
                    ),
                    // Pillole stats
                    _pdfPill('PF', '${pg.puntiVita}', accent, borderColor),
                    pw.SizedBox(width: 8),
                    _pdfPill('Vel.', '${pg.velocita} m', accent, borderColor),
                    pw.SizedBox(width: 8),
                    _pdfPill('Dado', 'd${pg.dadoVita}', accent, borderColor),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // ── CARATTERISTICHE ─────────────────────────────────────
              if (pg.caratteristicheImpostate &&
                  pg.caratteristiche.isNotEmpty) ...[
                _pdfSectionTitle('Caratteristiche', accent, accentLight),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children:
                      ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'].map((s) {
                        final val = pg.caratteristiche[s] ?? 0;
                        final mod = pg.modificatori[s] ?? 0;
                        final segno = mod >= 0 ? '+' : '';
                        return pw.Expanded(
                          child: pw.Container(
                            margin: const pw.EdgeInsets.symmetric(
                              horizontal: 3,
                            ),
                            padding: const pw.EdgeInsets.symmetric(vertical: 8),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: borderColor),
                              borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(5),
                              ),
                            ),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  s,
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  '$val',
                                  style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  '$segno$mod',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    color:
                                        mod >= 0
                                            ? PdfColors.green700
                                            : PdfColors.red700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
                pw.SizedBox(height: 14),
              ],

              // ── DETTAGLI ─────────────────────────────────────────────
              _pdfSectionTitle('Dettagli', accent, accentLight),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (pg.abilitaClasse.isNotEmpty)
                      _pdfRiga('Abilità', pg.abilitaClasse.join(', '), grey),
                    if (pg.linguaggi.isNotEmpty)
                      _pdfRiga('Linguaggi', pg.linguaggi.join(', '), grey),
                    if (pg.competenze.isNotEmpty)
                      _pdfRiga('Competenze', pg.competenze.join(', '), grey),
                    if (pg.tiriSalvezza.isNotEmpty)
                      _pdfRiga(
                        'Tiri Salvezza',
                        pg.tiriSalvezza.join(', '),
                        grey,
                      ),
                    if (pg.capacitaSpeciali.isNotEmpty)
                      _pdfRiga(
                        'Abilità Innate',
                        pg.capacitaSpeciali.join(', '),
                        grey,
                      ),
                    if (pg.abilitaClasse.isEmpty &&
                        pg.linguaggi.isEmpty &&
                        pg.competenze.isEmpty &&
                        pg.tiriSalvezza.isEmpty &&
                        pg.capacitaSpeciali.isEmpty)
                      pw.Text(
                        '—',
                        style: pw.TextStyle(color: grey, fontSize: 11),
                      ),
                  ],
                ),
              ),

              // ── EQUIPAGGIAMENTO ──────────────────────────────────────
              if (pg.equipaggiamento.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                _pdfSectionTitle('Equipaggiamento', accent, accentLight),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children:
                        pg.equipaggiamento
                            .map(
                              (e) => pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Container(
                                    width: 5,
                                    height: 5,
                                    decoration: pw.BoxDecoration(
                                      color: accent,
                                      shape: pw.BoxShape.circle,
                                    ),
                                  ),
                                  pw.SizedBox(width: 5),
                                  pw.Text(
                                    e,
                                    style: pw.TextStyle(
                                      fontSize: 11,
                                      color: grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],

              // Footer
              pw.SizedBox(height: 20),
              pw.Divider(color: borderColor),
              pw.SizedBox(height: 4),
              pw.Text(
                'Master Aid  •  D&D 5e',
                style: pw.TextStyle(fontSize: 8, color: grey),
              ),
            ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _pdfSectionTitle(String title, PdfColor accent, PdfColor bg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border(left: pw.BorderSide(color: accent, width: 3)),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: accent,
          letterSpacing: 1,
        ),
      ),
    );
  }

  pw.Widget _pdfPill(
    String label,
    String value,
    PdfColor accent,
    PdfColor border,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: border),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, color: accent)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfRiga(String label, String valore, PdfColor grey) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              valore,
              style: pw.TextStyle(fontSize: 11, color: grey),
            ),
          ),
        ],
      ),
    );
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
  BuildContext context,
  PGBaseFactory factory,
) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => StepExportScreen(factory: factory)),
  );
  return result ?? true;
}
