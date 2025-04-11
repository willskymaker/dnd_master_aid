import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart'; // <- IMPORTANTE PER MOBILE
import '../../factory_pg_base.dart';

class StepExportScreen extends StatelessWidget {
  final PGBaseFactory factory;

  const StepExportScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    final pg = factory.build();

    return Scaffold(
      appBar: AppBar(title: const Text("Esporta Scheda PDF")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final file = await _generaPDF(pg);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("📄 PDF salvato in:\n${file.path}")),
            );

            await _apriPDF(file);
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Salva PDF"),
        ),
      ),
    );
  }

  Future<File> _generaPDF(PGBase pg) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("🧙‍♂️ Scheda del Personaggio", style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 12),
                pw.Text("Nome: ${pg.nome}"),
                pw.Text("Specie: ${pg.specie}"),
                pw.Text("Classe: ${pg.classe}"),
                pw.Text("Livello: ${pg.livello}"),
                pw.Text("Punti Vita: ${pg.puntiVita} (d${pg.dadoVita})"),
                pw.Text("Velocità: ${pg.velocita} m"),
                pw.Text("Linguaggi: ${pg.linguaggi.join(', ')}"),
                pw.SizedBox(height: 8),
                pw.Text("Caratteristiche:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(pg.caratteristiche.entries.map((e) {
                  final mod = pg.modificatori[e.key] ?? 0;
                  final segno = mod >= 0 ? '+' : '';
                  return "${e.key}: ${e.value} ($segno$mod)";
                }).join(', ')),
                pw.SizedBox(height: 8),
                pw.Text("Competenze: ${pg.competenze.join(', ')}"),
                pw.Text("Abilità Innate: ${pg.capacitaSpeciali.join(', ')}"),
                if (pg.equipaggiamento.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text("Equipaggiamento:"),
                  pw.Text(pg.equipaggiamento.map((e) => '• $e').join('\n')),
                ],
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final filename = "${pg.nome}_liv${pg.livello}.pdf".replaceAll(' ', '_');
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(await pdf.save());

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

Future<void> vaiAStepExportPDF(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepExportScreen(factory: factory),
    ),
  );
}
