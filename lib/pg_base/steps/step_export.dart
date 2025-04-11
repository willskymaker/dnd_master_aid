import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../factory_pg_base.dart';
import '../../utils/web_pdf_saver.dart';

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
            final filename = "${pg.nome}_liv${pg.livello}.pdf".replaceAll(' ', '_');
            final pdfData = await _generaPDF(pg);

            if (kIsWeb) {
              downloadPdfWeb(pdfData, filename);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("📥 PDF scaricato nel browser")),
              );
              return;
            }

            final file = await _salvaPDFLocale(pdfData, filename);
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

  contenuto.add(pw.Text("Scheda Personaggio", style: pw.TextStyle(fontSize: 24)));
  contenuto.add(pw.SizedBox(height: 12));

  contenuto.addAll([
    if (pg.nome.isNotEmpty) pw.Text("Nome: ${pg.nome}"),
    if (pg.specie.isNotEmpty) pw.Text("Specie: ${pg.specie}"),
    if (pg.classe.isNotEmpty) pw.Text("Classe: ${pg.classe}"),
    pw.Text("Livello: ${pg.livello}"),
    pw.Text("Punti Vita: ${pg.puntiVita} (d${pg.dadoVita})"),
    pw.Text("Velocità: ${pg.velocita} m"),
    if (pg.linguaggi.isNotEmpty) pw.Text("Linguaggi: ${pg.linguaggi.join(', ')}"),
    pw.SizedBox(height: 8),
  ]);
  
print("DEBUG: caratteristicheImpostate = ${pg.caratteristicheImpostate}");

  if (pg.caratteristicheImpostate && pg.caratteristiche.isNotEmpty) {
  contenuto.add(pw.Text("Caratteristiche:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
  contenuto.add(pw.Text(
    pg.caratteristiche.entries.map((e) {
      final mod = pg.modificatori[e.key] ?? 0;
      final segno = mod >= 0 ? '+' : '';
      return "${e.key}: ${e.value} ($segno$mod)";
    }).join(', '),
  ));
}

  if (pg.abilitaClasse.isNotEmpty) {
    contenuto.add(pw.Text("Abilità: ${pg.abilitaClasse.join(', ')}"));
  }

  if (pg.competenze.isNotEmpty) {
    contenuto.add(pw.Text("Competenze: ${pg.competenze.join(', ')}"));
  }

  if (pg.capacitaSpeciali.isNotEmpty) {
    contenuto.add(pw.Text("Abilità Innate: ${pg.capacitaSpeciali.join(', ')}"));
  }

  if (pg.equipaggiamento.isNotEmpty) {
    contenuto.add(pw.SizedBox(height: 8));
    contenuto.add(pw.Text("Equipaggiamento:"));
    contenuto.add(pw.Text(pg.equipaggiamento.map((e) => '- $e').join('\n')));
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

Future<void> vaiAStepExportPDF(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepExportScreen(factory: factory),
    ),
  );
}
