import 'package:flutter/material.dart';
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key}); // ✅ Costruttore const aggiunto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coming Soon")),
      body: const Center(
        child: Text(
          '🚧 Funzionalità in arrivo!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
