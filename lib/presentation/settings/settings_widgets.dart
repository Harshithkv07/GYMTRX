import 'package:flutter/material.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// A titled card of rows separated by hairlines.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children, this.footer});

  final String title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: GtCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(indent: 52, endIndent: GtSpace.lg),
                  children[i],
                ],
              ],
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter + 4, GtSpace.sm, GtSpace.gutter, 0),
            child: Text(footer!, style: GtText.caption),
          ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? GtColors.danger : GtColors.text1;
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, 12, GtSpace.lg, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: destructive ? GtColors.danger : GtColors.text2),
          const SizedBox(width: GtSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GtText.body.colored(color)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: GtText.caption),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: GtSpace.md), trailing!],
          if (trailing == null && onTap != null) const Icon(GtIcons.chevronRight, size: 14, color: GtColors.text3),
        ],
      ),
    );
    if (onTap == null) return row;
    return Pressable(onTap: onTap, scale: 0.98, haptic: PressHaptic.selection, child: row);
  }
}

/// Asks for one line of text in a sheet. Returns null when cancelled.
Future<String?> showTextInputSheet(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  String action = 'Save',
}) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => _TextInputSheet(title: title, initial: initial, hint: hint, action: action),
  );
}

class _TextInputSheet extends StatefulWidget {
  const _TextInputSheet({required this.title, required this.initial, required this.hint, required this.action});

  final String title;
  final String initial;
  final String hint;
  final String action;

  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: GtSpace.xs),
              Text(widget.title, style: GtText.title),
              const SizedBox(height: GtSpace.lg),
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _submit(),
                style: GtText.body,
                decoration: InputDecoration(hintText: widget.hint),
              ),
              const SizedBox(height: GtSpace.lg),
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => GtButton(
                  label: widget.action,
                  onTap: _controller.text.trim().isEmpty ? null : _submit,
                  expand: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accent swatches with an animated ring around the chosen one.
class AccentSwatch extends StatelessWidget {
  const AccentSwatch({super.key, required this.color, required this.selected, required this.onTap, required this.label});

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      scale: 0.88,
      semanticLabel: '$label${selected ? ', selected' : ''}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: ShapeDecoration(
          shape: squircle(14, side: BorderSide(color: selected ? context.accent : Colors.transparent, width: 2)),
        ),
        child: DecoratedBox(decoration: ShapeDecoration(color: color, shape: squircle(10))),
      ),
    );
  }
}
