import 'package:flutter/material.dart';

class AppTheme {
  // Enhanced color constants for a modern light theme
  static const Color _primaryLight = Color(0xFFE67E22); // Warm orange
  static const Color _primaryVariant = Color(0xFFD35400); // Darker orange
  static const Color _secondaryLight = Color(0xFF27AE60); // Fresh green
  static const Color _secondaryVariant = Color(0xFF229954); // Darker green
  static const Color _accentLight = Color(0xFF8E44AD); // Purple accent
  static const Color _accentVariant = Color(0xFF7D3C98); // Darker purple
  
  static const Color _backgroundLight = Color(0xFFFAFAFA); // Soft off-white
  static const Color _surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color _surfaceVariant = Color(0xFFF5F5F5); // Light gray
  
  static const Color _textPrimary = Color(0xFF2C3E50); // Dark blue-gray
  static const Color _textSecondary = Color(0xFF7F8C8D); // Medium gray
  static const Color _textMuted = Color(0xFFBDC3C7); // Light gray
  
  static const Color _borderColor = Color(0xFF34495E); // Dark border
  static const Color _borderLight = Color(0xFFECF0F1); // Light border
  
  static const Color _successColor = Color(0xFF27AE60); // Green
  static const Color _warningColor = Color(0xFFF39C12); // Orange
  static const Color _errorColor = Color(0xFFE74C3C); // Red

  // Text themes with DM Sans font family
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
    displayMedium: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
    ),
    labelLarge: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    labelSmall: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
  );

  // Enhanced light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'DM Sans',
      
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFFFE5D1), // Light orange container
        onPrimaryContainer: _primaryVariant,
        
        secondary: _secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8F8F5), // Light green container
        onSecondaryContainer: _secondaryVariant,
        
        tertiary: _accentLight,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFF3E5F5), // Light purple container
        onTertiaryContainer: _accentVariant,
        
        surface: _backgroundLight,
        onSurface: _textPrimary,
        surfaceContainerHighest: _surfaceVariant,
        onSurfaceVariant: _textSecondary,
        
        error: _errorColor,
        onError: Colors.white,
        errorContainer: Color(0xFFFFEBEE), // Light red container
        onErrorContainer: Color(0xFFB71C1C),
        
        outline: _borderLight,
        outlineVariant: _textMuted,
        shadow: _borderColor,
        
        inverseSurface: _textPrimary,
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFFFFB74D),
      ),
      
      textTheme: _textTheme.apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ),
      
      // Enhanced button themes with modern styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _borderColor, width: 2),
          ),
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.2)),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: _borderColor, width: 2),
          foregroundColor: _textPrimary,
          textStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryLight,
          textStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Enhanced input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderLight, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        filled: true,
        fillColor: _surfaceLight,
        labelStyle: TextStyle(
          fontFamily: 'DM Sans',
          color: _textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontFamily: 'DM Sans',
          color: _textMuted,
        ),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
      ),
      
      // Enhanced card theme
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: _borderLight, width: 2),
        ),
        color: _surfaceLight,
        shadowColor: _borderColor,
        margin: EdgeInsets.all(8),
      ),
      
      // Enhanced app bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceLight,
        foregroundColor: _textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        iconTheme: IconThemeData(
          color: _textPrimary,
          size: 24,
        ),
      ),
      
      // Scaffold theme
      scaffoldBackgroundColor: _backgroundLight,
      
      // Dialog theme
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: _borderLight, width: 2),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _textSecondary,
        ),
      ),
      
      // Snackbar theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _textPrimary,
        contentTextStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }

  // Card decorations with enhanced shadows - similar to the dashboard image
  static BoxDecoration get cardShadow => BoxDecoration(
    color: _surfaceLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _borderLight, width: 1),
    boxShadow: const [
      // Main shadow for depth
      BoxShadow(
        color: Color(0x1A2C3E50),
        blurRadius: 24,
        offset: Offset(0, 8),
        spreadRadius: 0,
      ),
      // Secondary shadow for layered effect
      BoxShadow(
        color: Color(0x0D2C3E50),
        blurRadius: 16,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
      // Subtle inner highlight
      BoxShadow(
        color: Color(0x40FFFFFF),
        blurRadius: 1,
        offset: Offset(0, 1),
        spreadRadius: 0,
      ),
    ],
  );

  // Primary card decoration with enhanced shadow and accent border
  static BoxDecoration get primaryCardShadow => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _primaryLight, width: 2),
    boxShadow: const [
      // Primary shadow with brand color tint
      BoxShadow(
        color: Color(0x20E67E22), // Primary color shadow with more opacity
        offset: Offset(0, 12),
        blurRadius: 32,
        spreadRadius: 0,
      ),
      // Secondary depth shadow
      BoxShadow(
        color: Color(0x1A2C3E50),
        offset: Offset(0, 6),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      // Soft top highlight
      BoxShadow(
        color: Color(0x60FFFFFF),
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ],
  );

  // Error card decoration with enhanced shadow
  static BoxDecoration get errorCardShadow => BoxDecoration(
    color: const Color(0xFFFFEBEE),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _errorColor, width: 1.5),
    boxShadow: const [
      // Error shadow with red tint
      BoxShadow(
        color: Color(0x20E74C3C), // Error color shadow
        offset: Offset(0, 8),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      // Secondary depth shadow
      BoxShadow(
        color: Color(0x1A2C3E50),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
  );

  // Success card decoration
  static BoxDecoration get successCardShadow => BoxDecoration(
    color: const Color(0xFFE8F8F5),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _successColor, width: 2),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A27AE60), // Success color shadow
        offset: Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );
}