import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';

/// Asks for the name the home screen greets. Returns the trimmed name
/// (possibly empty when skipped), or null when the sheet is dismissed.
Future<String?> showNameSheet(
  BuildContext context, {
  required String title,
  String initial = '',
  bool skippable = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _NameSheet(title: title, initial: initial, skippable: skippable),
  );
}

class _NameSheet extends StatefulWidget {
  const _NameSheet({required this.title, required this.initial, required this.skippable});

  final String title;
  final String initial;
  final bool skippable;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: GtSpace.sm),
              Text(widget.title, style: GtText.title),
              const SizedBox(height: 6),
              Text('Shown on the home screen. You can change it in Settings.', style: GtText.caption.colored(c.text2)),
              const SizedBox(height: GtSpace.lg),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 24,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                style: GtText.body.sized(17),
                decoration: const InputDecoration(hintText: 'Your name', counterText: ''),
              ),
              const SizedBox(height: GtSpace.lg),
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => GtButton(
                  label: 'Continue',
                  expand: true,
                  onTap: _controller.text.trim().isEmpty && !widget.skippable ? null : _submit,
                ),
              ),
              if (widget.skippable) ...[
                const SizedBox(height: GtSpace.xs),
                GtButton(
                  label: 'Skip',
                  kind: GtButtonKind.ghost,
                  expand: true,
                  height: 46,
                  onTap: () => Navigator.pop(context, ''),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
