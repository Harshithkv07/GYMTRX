import 'package:flutter/material.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'controls.dart';
import 'pressable.dart';

/// A bottom sheet listing [options]; returns the tapped one, or null.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  String? caption,
  required List<T> options,
  required String Function(T) labelOf,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      final maxHeight = MediaQuery.sizeOf(context).height * 0.8;
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(GtSpace.sm, GtSpace.xs, GtSpace.sm, GtSpace.xs),
                  child: Text(title, style: GtText.title),
                ),
                if (caption != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GtSpace.sm, 0, GtSpace.sm, GtSpace.md),
                    child: Text(caption, style: GtText.caption),
                  ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final o in options)
                        Pressable(
                          onTap: () => Navigator.pop(context, o),
                          haptic: PressHaptic.selection,
                          scale: 0.98,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: GtSpace.sm),
                            child: Row(
                              children: [
                                Expanded(child: Text(labelOf(o), style: GtText.body)),
                                if (o == selected) Icon(GtIcons.check, size: 18, color: context.accent),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
