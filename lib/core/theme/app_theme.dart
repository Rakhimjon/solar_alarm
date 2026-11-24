import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color card;
  final Color cardBorder;
  final Color primary;
  final Color accent;
  final Color textPrimary;
  final Color textMuted;
  final Color glassStroke;

  const AppColors({
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textMuted,
    required this.glassStroke,
  });

  static const dark = AppColors(
    background: Color(0xFF0F141C),
    card: Color(0xFF18202C),
    cardBorder: Color(0xFF263244),
    primary: Color(0xFFF59E0B),
    accent: Color(0xFFFBBF24),
    textPrimary: Color(0xFFF1F5F9),
    textMuted: Color(0xFF94A3B8),
    glassStroke: Color(0x40FFFFFF),
  );

  static const light = AppColors(
    background: Color(0xFFF8FAFC),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE2E8F0),
    primary: Color(0xFFD97706),
    accent: Color(0xFFF59E0B),
    textPrimary: Color(0xFF0F172A),
    textMuted: Color(0xFF64748B),
    glassStroke: Color(0x33000000),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? card,
    Color? cardBorder,
    Color? primary,
    Color? accent,
    Color? textPrimary,
    Color? textMuted,
    Color? glassStroke,
  }) {
    return AppColors(
      background: background ?? this.background,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      glassStroke: glassStroke ?? this.glassStroke,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      glassStroke: Color.lerp(glassStroke, other.glassStroke, t)!,
    );
  }
}

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => theme.brightness == Brightness.dark;
  AppColors get appColors =>
      theme.extension<AppColors>() ?? (isDark ? AppColors.dark : AppColors.light);
}

class AppTheme {
  static const Color darkBackground = Color(0xFF0F141C);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFF18202C);
  static const Color cardBorder = Color(0xFF263244);
  static const Color primaryAmber = Color(0xFFF59E0B);
  static const Color accentGold = Color(0xFFFBBF24);
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryAmber,
      cardColor: cardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryAmber,
        secondary: accentGold,
        surface: cardColor,
        onSurface: textLight,
        outline: cardBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A0E14),
        selectedItemColor: primaryAmber,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      extensions: const [AppColors.dark],
    );
  }

  static ThemeData get light {
    const lightCard = Color(0xFFFFFFFF);
    const lightBorder = Color(0xFFE2E8F0);
    const lightPrimary = Color(0xFFD97706);
    const lightTextPrimary = Color(0xFF0F172A);
    const lightTextMuted = Color(0xFF64748B);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightPrimary,
      cardColor: lightCard,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: Color(0xFFF59E0B),
        surface: lightCard,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCard,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      extensions: const [AppColors.light],
    );
  }
}
