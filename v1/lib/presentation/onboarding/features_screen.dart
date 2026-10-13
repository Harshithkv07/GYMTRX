import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/large_title_header.dart';
import 'feature_checklist.dart';
import 'feature_setup.dart';

Future<void> openFeaturesScreen(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FeaturesScreen()));

/// Settings → Features: the onboarding checklist, applied as you tap.
class FeaturesScreen extends ConsumerWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider.select((s) => s.features));
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: 'Features', topPadding: padding.top, showBack: true),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, 0),
              child: Text(
                'Only what’s ticked shows up in the app. Turning something off hides it; '
                'what you recorded stays and comes back if you turn it on again.',
                style: GtText.body.colored(GtColors.text2),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FeatureChecklist(
              selected: selected,
              onChanged: (f, on) async {
                ref.read(settingsProvider.notifier).setFeature(f, on);
                if (on) await setUpFeature(context, ref, f);
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtSpace.x4)),
        ],
      ),
    );
  }
}
