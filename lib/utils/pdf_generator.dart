// lib/utils/pdf_generator.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generaSchedaPersonaggioPDF(Map<String, dynamic> scheda) async {
  final pdf = pw.Document();

  final ByteData imageData = await rootBundle.load('assets/images/scheda_pg_blank_base.png');
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final image = pw.MemoryImage(imageBytes);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Stack(
          children: [
            pw.Positioned.fill(
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),

            // Intestazione
            pw.Positioned(
              left: 72,
              top: 45,
              child: pw.Text(scheda['nome'] ?? '', style: pw.TextStyle(fontSize: 12)),
            ),
            pw.Positioned(
              left: 240,
              top: 65,
              child: pw.Text(scheda['specie'] ?? '', style: pw.TextStyle(fontSize: 12)),
            ),
            pw.Positioned(
              left: 210,
              top: 35,
              child: pw.Text(scheda['classe'] ?? '', style: pw.TextStyle(fontSize: 12)),
            ),
            pw.Positioned(
              left: 250,
              top: 35,
              child: pw.Text("Liv. ${scheda['livello']}", style: pw.TextStyle(fontSize: 12)),
            ),

            // Caratteristiche (FOR, DES, COS, INT, SAG, CAR)
            ...['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'].asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;
              final value = scheda['caratteristiche'][stat];
              return pw.Positioned(
                left: 10,
                top: 145 + (index * 65),
                child: pw.Text("$value", style: pw.TextStyle(fontSize: 14)),
              );
            }),

            // Classe Armatura e HP
            pw.Positioned(
              left: 180,
              top: 135,
              child: pw.Text("${scheda['ca']}", style: pw.TextStyle(fontSize: 14)),
            ),
            pw.Positioned(
              left: 240,
              top: 180,
              child: pw.Text("${scheda['hp']}", style: pw.TextStyle(fontSize: 14)),
            ),

            // Competenze
            pw.Positioned(
              left: 210,
              top: 460,
              child: pw.Text(scheda['competenze'].join(", "), style: pw.TextStyle(fontSize: 10)),
            ),

            // Equipaggiamento
            pw.Positioned(
              left: 210,
              top: 485,
              child: pw.Text("Armi: ${scheda['armi'].join(", ")}\nArmatura: ${scheda['armatura']}", style: pw.TextStyle(fontSize: 10)),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
