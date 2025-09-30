import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal - Morados y complementarios
  static const primary = Color(0xFF6A1B9A); // Morado oscuro
  static const primaryLight = Color(0xFF9C4DCC); // Morado medio
  static const primaryDark = Color(0xFF4A148C); // Morado muy oscuro
  static const accent = Color(0xFFAB47BC); // Morado claro

  // Colores de estado
  static const success = Color(0xFF4CAF50); // Verde
  static const warning = Color(0xFFFFA726); // Naranja
  static const error = Color(0xFFEF5350); // Rojo
  static const info = Color(0xFF42A5F5); // Azul

  // Grises
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);

  // Específicos por módulo
  static const expenses = Color(0xFF7E57C2); // Morado expensas
  static const reservations = Color(0xFF9575CD); // Morado reservas
  static const announcements = Color(0xFFBA68C8); // Morado comunicados
  static const visitors = Color(0xFFCE93D8); // Morado visitantes
  static const guard = Color(0xFF8E24AA); // Morado guardia
  static const admin = Color(0xFF6A1B9A); // Morado admin
}

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.primaryDark,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF1E1E1E),
          margin: EdgeInsets.zero,
        ),
      );
}
