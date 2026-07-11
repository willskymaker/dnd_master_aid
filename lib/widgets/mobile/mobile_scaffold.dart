import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Scaffold ottimizzato per dispositivi mobile
class MobileScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  /// Icona mostrata al posto del pulsante indietro (es. logo dell'app in
  /// una schermata radice, dove [showBackButton] è false).
  final Widget? leading;

  /// Badge testuale mostrato accanto al titolo (es. "BETA").
  final String? titleBadge;

  const MobileScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.bottom,
    this.showBackButton = true,
    this.leading,
    this.titleBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (titleBadge != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  titleBadge!,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: actions,
        bottom: bottom,
        automaticallyImplyLeading: showBackButton,
      ),
      drawer: drawer,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      backgroundColor: AppColors.background,
    );
  }
}
