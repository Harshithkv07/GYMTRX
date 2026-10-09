import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
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
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter + 4, GtSpace.xxl, GtSpace.gutter, GtSpace.sm),
          child: Text(title.toUpperCase(), style: context.tx.overline),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: GtCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(indent: 62, endIndent: GtSpace.lg, color: c.hairline),
                  children[i],
                ],
              ],
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter + 4, GtSpace.sm, GtSpace.gutter, 0),
            child: Text(footer!, style: context.tx.caption),
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
    final c = context.c;
    final color = destructive ? c.danger : c.text1;
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.md, 10, GtSpace.lg, 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: ShapeDecoration(color: c.surface2, shape: const CircleBorder()),
            child: Icon(icon, size: 18, color: destructive ? c.danger : c.text1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GtText.body.colored(color)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: context.tx.caption),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: GtSpace.md), trailing!],
          if (trailing == null && onTap != null) Icon(GtIcons.chevronRight, size: 14, color: c.text3),
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

/// A round accent swatch with an animated ring around the chosen one.
class AccentSwatch extends StatelessWidget {
  const AccentSwatch({super.key, required this.color, required this.selected, required this.onTap, required this.label});

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
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
          shape: CircleBorder(side: BorderSide(color: selected ? c.text1 : Colors.transparent, width: 2)),
        ),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: color,
            shape: CircleBorder(side: BorderSide(color: c.hairlineStrong)),
          ),
        ),
      ),
    );
  }
}
