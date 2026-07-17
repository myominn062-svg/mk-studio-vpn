import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';
import 'package:hiddify/core/theme/mk_studio_colors.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class AppTheme {
  AppTheme(this.mode, this.fontFamily);
  final AppThemeMode mode;
  final String fontFamily;

  ThemeData lightTheme(ColorScheme? lightColorScheme) {
    // Always use MK Studio brand scheme — ignore system dynamic colors (often purple).
    final ColorScheme scheme = MkStudioColors.lightScheme();
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamily: fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily,
      scaffoldBackgroundColor: MkStudioColors.surface,
      extensions: const <ThemeExtension<dynamic>>{ConnectionButtonTheme.mkStudio},
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme, scheme.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: MkStudioColors.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: MkStudioColors.ink,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: MkStudioColors.tealDeep),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: MkStudioColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: MkStudioColors.surfaceElevated,
        indicatorColor: MkStudioColors.softTealWash,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? MkStudioColors.tealDeep : MkStudioColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? MkStudioColors.tealDeep : MkStudioColors.muted,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: MkStudioColors.surfaceElevated,
        indicatorColor: MkStudioColors.softTealWash,
        selectedIconTheme: const IconThemeData(color: MkStudioColors.tealDeep),
        unselectedIconTheme: const IconThemeData(color: MkStudioColors.muted),
        selectedLabelTextStyle: TextStyle(
          fontFamily: fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily,
          fontWeight: FontWeight.w700,
          color: MkStudioColors.tealDeep,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MkStudioColors.tealDeep,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MkStudioColors.tealDeep,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline.withValues(alpha: 0.4), space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: MkStudioColors.tealDeep,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MkStudioColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MkStudioColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MkStudioColors.teal, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: MkStudioColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ThemeData darkTheme(ColorScheme? darkColorScheme) {
    final ColorScheme scheme = MkStudioColors.darkScheme();
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: mode.trueBlack ? Colors.black : scheme.surface,
      fontFamily: fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily,
      extensions: const <ThemeExtension<dynamic>>{ConnectionButtonTheme.mkStudio},
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme, scheme.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: scheme.primary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: MkStudioColors.tealDeep.withValues(alpha: 0.35),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MkStudioColors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  TextTheme _textTheme(TextTheme base, Color color) {
    final family = fontFamily.isEmpty ? 'PlusJakartaSans' : fontFamily;
    return base
        .apply(fontFamily: family, bodyColor: color, displayColor: color)
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(fontFamily: family, fontWeight: FontWeight.w800, letterSpacing: -1.2),
          headlineMedium: base.headlineMedium?.copyWith(fontFamily: family, fontWeight: FontWeight.w700, letterSpacing: -0.6),
          titleLarge: base.titleLarge?.copyWith(fontFamily: family, fontWeight: FontWeight.w700, letterSpacing: -0.4),
          titleMedium: base.titleMedium?.copyWith(fontFamily: family, fontWeight: FontWeight.w600),
          bodyLarge: base.bodyLarge?.copyWith(fontFamily: family, fontWeight: FontWeight.w500),
          bodyMedium: base.bodyMedium?.copyWith(fontFamily: family),
          labelLarge: base.labelLarge?.copyWith(fontFamily: family, fontWeight: FontWeight.w700),
        );
  }

  CupertinoThemeData cupertinoThemeData(bool sysDark, ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
    final bool isDark = switch (mode) {
      AppThemeMode.system => sysDark,
      AppThemeMode.light => false,
      AppThemeMode.dark => true,
      AppThemeMode.black => true,
    };
    final def = CupertinoThemeData(brightness: isDark ? Brightness.dark : Brightness.light);
    final defaultMaterialTheme = isDark ? darkTheme(darkColorScheme) : lightTheme(lightColorScheme);
    return MaterialBasedCupertinoThemeData(
      materialTheme: defaultMaterialTheme.copyWith(
        cupertinoOverrideTheme: def.copyWith(
          textTheme: CupertinoTextThemeData(
            textStyle: def.textTheme.textStyle.copyWith(fontFamily: fontFamily),
            actionTextStyle: def.textTheme.actionTextStyle.copyWith(fontFamily: fontFamily),
            navActionTextStyle: def.textTheme.navActionTextStyle.copyWith(fontFamily: fontFamily),
            navTitleTextStyle: def.textTheme.navTitleTextStyle.copyWith(fontFamily: fontFamily),
            navLargeTitleTextStyle: def.textTheme.navLargeTitleTextStyle.copyWith(fontFamily: fontFamily),
            pickerTextStyle: def.textTheme.pickerTextStyle.copyWith(fontFamily: fontFamily),
            dateTimePickerTextStyle: def.textTheme.dateTimePickerTextStyle.copyWith(fontFamily: fontFamily),
            tabLabelTextStyle: def.textTheme.tabLabelTextStyle.copyWith(fontFamily: fontFamily),
          ).copyWith(),
          barBackgroundColor: def.barBackgroundColor,
          scaffoldBackgroundColor: def.scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
