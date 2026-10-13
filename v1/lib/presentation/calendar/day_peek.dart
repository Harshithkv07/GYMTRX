import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
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

  /// [entry] is null for a rest day; [lines] add steps, sleep or a holiday.
  static void show(
    BuildContext context, {
    required Rect anchor,
    required int dayKey,
    required EntrySummary? entry,
    required Map<int, MuscleGroup> groups,
    List<String> lines = const [],
  }) {
    _remove();
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (_) => _PeekCard(key: _key, anchor: anchor, dayKey: dayKey, entry: entry, groups: groups, lines: lines),
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
  const _PeekCard({
    super.key,
    required this.anchor,
    required this.dayKey,
    required this.entry,
    required this.groups,
    required this.lines,
  });

  final Rect anchor;
  final int dayKey;
  final EntrySummary? entry;
  final Map<int, MuscleGroup> groups;
  final List<String> lines;

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
    final entry = widget.entry;
    final label = entry == null ? 'Rest day' : groupLabel(entry.groupIds, widget.groups);
    final meta = entry == null ? '' : entryMeta(entry);
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
                    tint: const Color(0xF01C1C1F),
                    child: Padding(
                      padding: const EdgeInsets.all(GtSpace.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Fmt.weekdayDayMonth(widget.dayKey).toUpperCase(), style: GtText.overline),
                          const SizedBox(height: GtSpace.sm),
                          Text(label.isEmpty ? 'Logged' : label, style: GtText.titleSmall),
                          if (meta.isNotEmpty) ...[const SizedBox(height: 4), Text(meta, style: GtText.caption)],
                          for (final line in widget.lines) ...[
                            const SizedBox(height: 4),
                            Text(line, style: GtText.caption),
                          ],
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
