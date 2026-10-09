import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'tokens.dart';
import 'typography.dart';

/// Builds the light or dark theme around one [GtColors] set.
ThemeData buildGtTheme(GtColors c) {
  final dark = c.isDark;
  final scheme = (dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
    primary: c.accentStrong,
    onPrimary: c.onAccent,
    secondary: c.accent,
    onSecondary: c.onAccent,
    surface: c.bg,
    onSurface: c.text1,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surface2,
    surfaceContainerHighest: c.surface3,
    onSurfaceVariant: c.text2,
    outline: c.hairlineStrong,
    outlineVariant: c.hairline,
    error: c.danger,
    onError: Colors.white,
  );

  TextStyle t(TextStyle s) => s.colored(c.text1);
  final textTheme = TextTheme(
    displayLarge: t(GtText.display),
    headlineMedium: t(GtText.display.sized(26)),
    titleLarge: t(GtText.title),
    titleMedium: t(GtText.titleSmall),
    titleSmall: t(GtText.label),
    bodyLarge: t(GtText.body),
    bodyMedium: t(GtText.body),
    bodySmall: GtText.caption.colored(c.text2),
    labelLarge: t(GtText.label),
    labelMedium: t(GtText.label),
    labelSmall: GtText.caption.colored(c.text2),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: GtFonts.sans,
    textTheme: textTheme,
    // No Material ripples: presses are expressed with spring scale instead.
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder()},
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.text1,
      selectionColor: c.accent.withValues(alpha: 0.45),
      selectionHandleColor: c.ink,
    ),
    iconTheme: IconThemeData(color: c.text1, size: 22),
    dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.bg,
      modalBackgroundColor: c.bg,
      modalBarrierColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.28),
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GtRadius.xl)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      isDense: true,
      hintStyle: GtText.body.colored(c.text3),
      contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(GtRadius.md), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GtRadius.md),
        borderSide: BorderSide(color: c.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GtRadius.md),
        borderSide: BorderSide(color: c.text1.withValues(alpha: 0.5)),
      ),
    ),
    scrollbarTheme: const ScrollbarThemeData(thickness: WidgetStatePropertyAll(3)),
    tooltipTheme: TooltipThemeData(
      decoration: ShapeDecoration(color: c.ink, shape: squircle(GtRadius.sm)),
      textStyle: GtText.label.colored(c.onInk),
    ),
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      brightness: c.brightness,
      primaryColor: c.accentStrong,
      scaffoldBackgroundColor: c.bg,
      barBackgroundColor: c.surface,
    ),
    extensions: [c],
  );
}

/// Transparent system bars with icons that suit the theme.
SystemUiOverlayStyle gtOverlayStyle(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );
}
