import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta "cozy + literária + moderna" do Clube do Livro
class AppColors {
  static const creme = Color(0xFFFBF3EA); // fundo principal
  static const cremeEscuro = Color(0xFFF3E6D8); // cards
  static const rosaQueimado = Color(0xFFC97B84); // cor primária
  static const marrom = Color(0xFF6B4A3A); // textos secundários / detalhes
  static const rosaClaro = Color(0xFFF3D6DA); // realces suaves
  static const pretoTexto = Color(0xFF2B2320); // textos principais
  static const dourado = Color(0xFFD9A65C); // detalhes de destaque (estrelas)
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.creme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.rosaQueimado,
        secondary: AppColors.marrom,
        surface: AppColors.cremeEscuro,
      ),
      textTheme: GoogleFonts.latoTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.pretoTexto,
        ),
        titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: AppColors.pretoTexto,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: AppColors.pretoTexto,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creme,
        elevation: 0,
        foregroundColor: AppColors.pretoTexto,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.pretoTexto,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: AppColors.marrom.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosaQueimado,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.rosaClaro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.rosaClaro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rosaQueimado, width: 1.6),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.rosaClaro,
        labelStyle: const TextStyle(color: AppColors.marrom, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.rosaQueimado,
        unselectedItemColor: AppColors.marrom.withOpacity(0.5),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.rosaQueimado,
        foregroundColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }
}
