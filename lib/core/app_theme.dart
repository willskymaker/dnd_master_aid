import 'package:flutter/material.dart';

/// Palette dei colori dell'app, allineata al branding (icona D20 rosso/oro
/// su sfondo navy). Unica fonte di verità: non usare Color(0x...) altrove.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF8B4513);
  static const Color background = Color(0xFFFAF7F2);
  static const Color accent = Color(0xFFD4AF37);

  static final Color success = Colors.green.shade600;
  static final Color warning = Colors.orange.shade700;
  static final Color error = Colors.red.shade600;

  static final Color textSecondary = Colors.grey.shade600;
  static final Color disabledBackground = Colors.grey.shade300;
  static final Color disabledText = Colors.grey.shade400;
}

/// Scala di spaziature standard, da usare al posto di EdgeInsets/SizedBox
/// con valori inventati caso per caso.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Raggi di bordo standard.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

/// Tema Material 3 dell'app, con tipografia e colori centralizzati.
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: Colors.white,
  );

  const textTheme = TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );
}
