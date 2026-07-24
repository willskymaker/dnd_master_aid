import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardHelper {
  static void copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiato negli appunti! 📋'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
