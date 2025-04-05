import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Coming Soon")),
      body: Center(
        child: Text(
          '🚧 Funzionalità in arrivo!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

