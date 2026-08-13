import 'package:flutter/material.dart';

/// Paleta e tema visual do InduSense.
/// Conceito: clean, moderno, industrial — tons de azul/grafite com
/// cores de status (normal / atenção / crítico) bem destacadas.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0B5FFF);
  static const Color primaryDark = Color(0xFF0A3D8F);
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B2430);
  static const Color textSecondary = Color(0xFF6B7684);
  static const Color divider = Color(0xFFE3E7ED);

  // Status dos sensores / alertas
  static const Color statusNormal = Color(0xFF1FAE64);
  static const Color statusAtencao = Color(0xFFF5A623);
  static const Color statusCritico = Color(0xFFE23D3D);
  static const Color statusOffline = Color(0xFF9AA4B2);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}

/// Mapeia o status de um sensor/alerta para a cor correspondente.
Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'normal':
      return AppColors.statusNormal;
    case 'atencao':
    case 'atenção':
      return AppColors.statusAtencao;
    case 'critico':
    case 'crítico':
      return AppColors.statusCritico;
    case 'offline':
      return AppColors.statusOffline;
    default:
      return AppColors.statusOffline;
  }
}
