import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'controls.dart';
import 'gt_button.dart';

/// Says in plain words what's about to happen (usually right before one of
/// Android's own permission prompts) and asks to go ahead. True = go ahead.
Future<bool> showExplainerSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  List<String> points = const [],
  String action = 'Continue',
  String dismiss = 'Not now',
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: GtSpace.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(color: context.gt.accentMuted, shape: squircle(15)),
                child: Icon(icon, size: 24, color: context.accent),
              ),
            ),
            const SizedBox(height: GtSpace.lg),
            Text(title, style: GtText.title),
            const SizedBox(height: GtSpace.sm),
            Text(body, style: GtText.body.colored(GtColors.text2)),
            if (points.isNotEmpty) ...[
              const SizedBox(height: GtSpace.md),
              for (final p in points)
                Padding(
                  padding: const EdgeInsets.only(top: GtSpace.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7, right: GtSpace.md),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(color: context.accent, shape: BoxShape.circle),
                        ),
                      ),
                      Expanded(child: Text(p, style: GtText.body)),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: GtSpace.xxl),
            GtButton(label: action, expand: true, onTap: () => Navigator.pop(context, true)),
            const SizedBox(height: GtSpace.sm),
            GtButton(
              label: dismiss,
              kind: GtButtonKind.ghost,
              expand: true,
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    ),
  );
  return ok ?? false;
}
