import 'package:flutter/material.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/database/app_database.dart';
import '../body_map/body_map.dart';
import '../body_map/muscle_regions.dart';
import '../widgets/surface.dart';

/// The day's muscle groups lit up on the body.
class EntryBodyMap extends StatelessWidget {
  const EntryBodyMap({super.key, required this.groups});

  final List<MuscleGroup> groups;

  @override
  Widget build(BuildContext context) {
    final strength = regionsForGroups(groups);
    final cardio = includesCardio(groups);
    if (strength.isEmpty && !cardio) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.xxl, GtSpace.lg, 0),
      child: GtCard(
        padding: const EdgeInsets.symmetric(vertical: GtSpace.xxl),
        child: Column(
          children: [
            if (strength.isNotEmpty) BodyMap(strength: strength, height: 280),
            if (cardio) ...[
              if (strength.isNotEmpty) const SizedBox(height: GtSpace.xl),
              const CardioPill(),
            ],
          ],
        ),
      ),
    );
  }
}

class CardioPill extends StatelessWidget {
  const CardioPill({super.key, this.label = 'Cardio'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
      decoration: ShapeDecoration(color: context.gt.accentMuted, shape: squircle(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(GtIcons.cardio, size: 15, color: context.accent),
          const SizedBox(width: 6),
          Text(label, style: GtText.label.weight(600).colored(context.accent)),
        ],
      ),
    );
  }
}
