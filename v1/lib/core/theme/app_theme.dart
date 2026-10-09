import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'palette.dart';
import 'tokens.dart';
import 'typography.dart';

/// Builds the single dark theme around the chosen accent colour.
ThemeData buildGtTheme(Color accent) {
  final scheme = ColorScheme.dark(
    primary: accent,
    onPrimary: GtColors.onAccent,
    secondary: accent,
    onSecondary: GtColors.onAccent,
    surface: GtColors.bg,
    onSurface: GtColors.text1,
    surfaceContainerLowest: GtColors.bg,
    surfaceContainerLow: GtColors.s1,
    surfaceContainer: GtColors.s1,
    surfaceContainerHigh: GtColors.s2,
    surfaceContainerHighest: GtColors.s3,
    onSurfaceVariant: GtColors.text2,
    outline: GtColors.hairlineStrong,
    outlineVariant: GtColors.hairline,
    error: GtColors.danger,
    onError: GtColors.onAccent,
  );

  const textTheme = TextTheme(
    displayLarge: GtText.display,
    headlineMedium: GtText.headline,
    titleLarge: GtText.title,
    titleMedium: GtText.titleSmall,
    titleSmall: GtText.label,
    bodyLarge: GtText.body,
    bodyMedium: GtText.body,
    bodySmall: GtText.caption,
    labelLarge: GtText.label,
    labelMedium: GtText.label,
    labelSmall: GtText.caption,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: GtColors.bg,
    canvasColor: GtColors.bg,
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
      cursorColor: accent,
      selectionColor: accent.withValues(alpha: 0.3),
      selectionHandleColor: accent,
    ),
    iconTheme: const IconThemeData(color: GtColors.text1, size: 22),
    dividerTheme: const DividerThemeData(color: GtColors.hairline, thickness: 1, space: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: GtColors.s1,
      modalBackgroundColor: GtColors.s1,
      modalBarrierColor: Colors.black.withValues(alpha: 0.6),
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GtRadius.xl)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GtColors.s2,
      isDense: true,
      hintStyle: GtText.body.colored(GtColors.text3),
      contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GtRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GtRadius.md),
        borderSide: BorderSide(color: accent.withValues(alpha: 0.5)),
      ),
    ),
    scrollbarTheme: const ScrollbarThemeData(thickness: WidgetStatePropertyAll(3)),
    tooltipTheme: TooltipThemeData(
      decoration: ShapeDecoration(color: GtColors.s3, shape: squircle(GtRadius.sm)),
      textStyle: GtText.label,
    ),
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: accent,
      scaffoldBackgroundColor: GtColors.bg,
      barBackgroundColor: GtColors.s1,
    ),
    extensions: [GtPalette(accent: accent)],
  );
}
