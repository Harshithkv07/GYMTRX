import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../widgets/labels.dart';
import '../widgets/surface.dart';

/// Hold a gym day to peek at it; release to dismiss.
abstract final class DayPeek {
  static OverlayEntry? _entry;
  static final _key = GlobalKey<_PeekCardState>();

  static void show(
    BuildContext context, {
    required Rect anchor,
    required EntrySummary entry,
    required Map<int, MuscleGroup> groups,
  }) {
    _remove();
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (_) => _PeekCard(key: _key, anchor: anchor, entry: entry, groups: groups),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    final state = _key.currentState;
    if (state == null) {
      _remove();
    } else {
      state.dismiss().then((_) => _remove());
    }
  }

  static void _remove() {
    _entry?.remove();
    _entry = null;
  }
}

class _PeekCard extends StatefulWidget {
  const _PeekCard({super.key, required this.anchor, required this.entry, required this.groups});

  final Rect anchor;
  final EntrySummary entry;
  final Map<int, MuscleGroup> groups;

  @override
  State<_PeekCard> createState() => _PeekCardState();
}

class _PeekCardState extends State<_PeekCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 160),
  )..forward();

  Future<void> dismiss() => _c.reverse();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const width = 248.0;
    final screen = MediaQuery.sizeOf(context);
    final left = (widget.anchor.center.dx - width / 2).clamp(GtSpace.lg, screen.width - width - GtSpace.lg);
    final above = widget.anchor.top > 220;
    final label = groupLabel(widget.entry.groupIds, widget.groups);
    final meta = entryMeta(widget.entry);
    final curved = CurvedAnimation(parent: _c, curve: GtMotion.emphasized, reverseCurve: Curves.easeIn);

    // Lives in the root overlay, outside any Material, so it brings its own.
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: left,
              width: width,
              top: above ? null : widget.anchor.bottom + GtSpace.sm,
              bottom: above ? screen.height - widget.anchor.top + GtSpace.sm : null,
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.0).animate(curved),
                  alignment: above ? Alignment.bottomCenter : Alignment.topCenter,
                  child: Glass(
                    radius: GtRadius.lg,
                    shadow: true,
                    tint: context.c.isDark ? context.c.surface2.withValues(alpha: 0.94) : Colors.white.withValues(alpha: 0.94),
                    child: Padding(
                      padding: const EdgeInsets.all(GtSpace.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Fmt.weekdayDayMonth(widget.entry.dayKey).toUpperCase(), style: context.tx.overline),
                          const SizedBox(height: GtSpace.sm),
                          Text(label.isEmpty ? 'Logged' : label, style: GtText.titleSmall.colored(context.c.text1)),
                          if (meta.isNotEmpty) ...[const SizedBox(height: 4), Text(meta, style: context.tx.caption)],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
