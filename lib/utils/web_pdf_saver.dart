// lib/utils/web_pdf_saver.dart
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

void downloadPdfWeb(Uint8List data, String filename) {
  final blob = html.Blob([data]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
