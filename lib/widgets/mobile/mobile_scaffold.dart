import 'package:flutter/material.dart';

/// Scaffold ottimizzato per dispositivi mobile
class MobileScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const MobileScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.bottom,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513), // Brown theme per D&D
        foregroundColor: Colors.white,
        elevation: 4,
        actions: actions,
        bottom: bottom,
        automaticallyImplyLeading: showBackButton,
      ),
      drawer: drawer,
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
    );
  }
}