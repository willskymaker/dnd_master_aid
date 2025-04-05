// lib/utils/pdf_generator.dart

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:printing/printing.dart';

Future<void> generaSchedaPersonaggioPDF(Map<String, dynamic> datiPG) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Scheda del Personaggio", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text("Nome: \${datiPG['nome'] ?? '-'}"),
            pw.Text("Specie: \${datiPG['specie'] ?? '-'}"),
            pw.Text("Classe: \${datiPG['classe'] ?? '-'}"),
            pw.Text("Livello: \${datiPG['livello'] ?? 1}"),
            pw.Text("Bonus Competenza: \${datiPG['bonusCompetenza'] ?? 2}"),
            pw.SizedBox(height: 12),
            pw.Text("Caratteristiche:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...((datiPG['caratteristiche'] as Map<String, int>?)?.entries.map((e) =>
              pw.Text("- \${e.key}: \${e.value} (mod: \${((e.value - 10) ~/ 2)})")) ?? []),
            pw.SizedBox(height: 12),
            pw.Text("Competenze:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text((datiPG['competenze'] as List<String>?)?.join(", ") ?? "-"),
            pw.SizedBox(height: 12),
            pw.Text("Armi:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text((datiPG['armi'] as List<String>?)?.join(", ") ?? "-"),
            pw.SizedBox(height: 12),
            pw.Text("Armatura: \${datiPG['armatura'] ?? '-'}"),
            pw.SizedBox(height: 12),
            pw.Text("Statistiche finali:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("CA: \${datiPG['ca'] ?? '-'}"),
            pw.Text("HP: \${datiPG['hp'] ?? '-'}"),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}

