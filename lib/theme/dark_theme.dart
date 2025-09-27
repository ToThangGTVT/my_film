import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData dark = ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.beVietnamPro().fontFamily,
      colorScheme: const ColorScheme(
            brightness: Brightness.dark,

            // NỀN ĐEN + CHỮ TRẮNG
            primary: Color(0xFF0B0B0F),          // nền chính (scaffold/background)
            onPrimary: Color(0xFFFFFFFF),        // chữ/icon trên nền chính
            primaryContainer: Color(0xFF15161C), // khối/section trên nền
            onPrimaryContainer: Color(0xFFECECF1),

            // ACCENT XANH LAM (điểm nhấn)
            secondary: Color(0xFF376AED),
            onSecondary: Color(0xFFFFFFFF),
            secondaryContainer: Color(0xFF213258),
            onSecondaryContainer: Color(0xFFDCE6FF),

            // XÁM TRUNG TÍNH (dùng cho text/icon phụ)
            tertiary: Color(0xFF9AA4AF),
            onTertiary: Color(0xFF0F1115),
            tertiaryContainer: Color(0xFF20242B),
            onTertiaryContainer: Color(0xFFE2E6EC),

            // ERROR
            error: Color(0xFFEF5350),
            onError: Color(0xFFFFFFFF),
            errorContainer: Color(0xFF8C1D18),
            onErrorContainer: Color(0xFFF9DEDC),

            // NỀN & BỀ MẶT
            background: Color(0xFF0B0B0F),
            onBackground: Color(0xFFE6E6EA),
            surface: Color(0xFF111317),          // card/container
            onSurface: Color(0xFFE6E1E5),
            surfaceVariant: Color(0xFF1A1D23),   // card phụ/khung
            onSurfaceVariant: Color(0xFFB0B6C0),

            // VIỀN / DIVIDER
            outline: Color(0xFF3C414B),
            outlineVariant: Color(0xFF252A32),

            // MISC
            shadow: Color(0xFF000000),
            scrim: Color(0xFF000000),
            inverseSurface: Color(0xFFE6E1E5),
            onInverseSurface: Color(0xFF111317),
            inversePrimary: Color(0xFF89A6FF),
            surfaceTint: Color(0xFF376AED), // dùng accent làm tint
      ),
);
