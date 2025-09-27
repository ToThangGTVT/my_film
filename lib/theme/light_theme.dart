import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData light = ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.beVietnamPro().fontFamily,
      scaffoldBackgroundColor: Colors.white, // nền chính trắng
      colorScheme: const ColorScheme(
            brightness: Brightness.light,

            // --- Màu nhấn (Primary) ---
            primary: Color(0xFF1E88E5),          // xanh lam nhấn nhẹ
            onPrimary: Colors.white,
            primaryContainer: Color(0xFFE3F2FD), // nền nhạt xanh
            onPrimaryContainer: Color(0xFF0D47A1),

            // --- Secondary (nhấn phụ) ---
            secondary: Color(0xFFEC407A),        // hồng nhấn
            onSecondary: Colors.white,
            secondaryContainer: Color(0xFFFCE4EC),
            onSecondaryContainer: Color(0xFF880E4F),

            // --- Text/icon ---
            tertiary: Colors.black,              // chữ đen
            onTertiary: Colors.white,

            // --- Error ---
            error: Color(0xFFB3261E),
            onError: Colors.white,
            errorContainer: Color(0xFFF9DEDC),
            onErrorContainer: Color(0xFF410E0B),

            // --- Nền & surface: toàn trắng ---
            background: Colors.white,
            onBackground: Colors.black,
            surface: Colors.white,               // card / appbar cũng trắng
            onSurface: Colors.black,
            surfaceVariant: Colors.white,
            onSurfaceVariant: Colors.black87,

            // --- Viền / outline ---
            outline: Color(0xFFBDBDBD),
            outlineVariant: Color(0xFFE0E0E0),

            // Misc
            shadow: Color(0x1F000000),
            scrim: Colors.black,
            inverseSurface: Color(0xFF121212),
            onInverseSurface: Colors.white,
            inversePrimary: Color(0xFF90CAF9),

            // Tắt tint để card không bị overlay màu
            surfaceTint: Colors.transparent,
      ),
);
