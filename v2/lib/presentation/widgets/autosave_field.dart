import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

/// Collects the pending saves of every [AutosaveField] below it, so a sheet
/// can flush them all the moment it closes.
class FlushController {
  final _pending = <VoidCallback>{};

  void flushAll() {
    for (final flush in [..._pending]) {
      flush();
    }
  }
}

class FlushScope extends InheritedWidget {
  const FlushScope({super.key, required this.controller, required super.child});

  final FlushController controller;

  static FlushController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<FlushScope>()?.controller;

  @override
  bool updateShouldNotify(FlushScope oldWidget) => false;
}

/// Parses user-typed numbers, accepting a comma as the decimal separator.
double? parseNumber(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

/// A text field that saves itself: debounced while typing, right away when it
/// loses focus, and when its [FlushScope] flushes. There is no Save button.
class AutosaveField extends StatefulWidget {
  const AutosaveField({
    super.key,
    required this.value,
    required this.onSave,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.fillColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 14),
    this.radius = GtRadius.md,
    this.textInputAction,
    this.semanticLabel,
  });

  /// The stored value. Applied to the field only while it isn't being edited.
  final String value;
  final ValueChanged<String> onSave;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  /// Defaults to the card surface.
  final Color? fillColor;
  final EdgeInsetsGeometry contentPadding;
  final double radius;
  final TextInputAction? textInputAction;
  final String? semanticLabel;

  @override
  State<AutosaveField> createState() => _AutosaveFieldState();
}

class _AutosaveFieldState extends State<AutosaveField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  late String _saved = widget.value;
  Timer? _debounce;
  FlushController? _scope;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _flush();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = FlushScope.maybeOf(context);
    if (scope != _scope) {
      _scope?._pending.remove(_flush);
      _scope = scope?.._pending.add(_flush);
    }
  }

  @override
  void didUpdateWidget(AutosaveField old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && !_focus.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
      _saved = widget.value;
    }
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _flush);
  }

  void _flush() {
    _debounce?.cancel();
    final text = _controller.text;
    if (text == _saved) return;
    _saved = text;
    widget.onSave(text);
  }

  @override
  void dispose() {
    _flush();
    _scope?._pending.remove(_flush);
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        onChanged: _onChanged,
        onSubmitted: (_) => _flush(),
        onTapOutside: (_) => _focus.unfocus(),
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        style: widget.style ?? GtText.body,
        textCapitalization: widget.keyboardType == null ? TextCapitalization.sentences : TextCapitalization.none,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: (widget.style ?? GtText.body).colored(c.text3),
          filled: true,
          fillColor: widget.fillColor ?? c.surface,
          isDense: true,
          contentPadding: widget.contentPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: widget.fillColor == null ? BorderSide(color: c.hairline) : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(color: c.text1.withValues(alpha: 0.45)),
          ),
        ),
      ),
    );
  }
}

/// Digits plus one decimal separator.
final decimalInput = [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}'))];
final integerInput = [FilteringTextInputFormatter.digitsOnly];
