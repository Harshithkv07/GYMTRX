import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/typography.dart';

/// Cardio has no muscles to light, so it shows as a small pill instead.
class CardioPill extends StatelessWidget {
  const CardioPill({super.key, this.label = 'Cardio'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(color: c.tag.withValues(alpha: 0.12), shape: const StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(GtIcons.cardio, size: 15, color: c.tag),
          const SizedBox(width: 6),
          Text(label, style: GtText.label.weight(600).colored(c.tag)),
        ],
      ),
    );
  }
}
