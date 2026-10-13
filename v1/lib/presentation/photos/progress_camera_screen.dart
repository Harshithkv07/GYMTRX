import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';

/// Takes a progress photo. With [ghost] (the latest photo), a "Ghost" switch
/// lays it faintly over the camera so you can line up the same pose and
/// distance by eye. Returns the new photo's path, or null if cancelled.
Future<String?> openProgressCamera(BuildContext context, {File? ghost}) {
  return Navigator.of(context, rootNavigator: true).push<String>(
    PageRouteBuilder(
      transitionDuration: GtMotion.of(context, const Duration(milliseconds: 320)),
      reverseTransitionDuration: GtMotion.of(context, GtMotion.medium),
      pageBuilder: (_, _, _) => ProgressCameraScreen(ghost: ghost),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

class ProgressCameraScreen extends StatefulWidget {
  const ProgressCameraScreen({super.key, this.ghost});

  final File? ghost;

  @override
  State<ProgressCameraScreen> createState() => _ProgressCameraScreenState();
}

class _ProgressCameraScreenState extends State<ProgressCameraScreen> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  var _front = false;
  var _ghostOn = false;
  var _busy = false;
  XFile? _shot;
  String? _error;
  var _denied = false;

  /// An open is under way (Android's permission prompt can interrupt it).
  var _opening = false;

  /// The camera was released because the app went to the background.
  var _paused = false;

  static const _ghostOpacity = 0.35;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(gtOverlayStyle);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.inactive) {
      // Only a running camera is released; the permission prompt also makes
      // the app inactive while the first open is still waiting on it.
      if (c != null && c.value.isInitialized) {
        _controller = null;
        _paused = true;
        c.dispose();
      }
    } else if (state == AppLifecycleState.resumed && _paused) {
      _paused = false;
      if (_shot == null) _open();
    }
  }

  Future<void> _start() async {
    try {
      _cameras = await availableCameras();
    } on CameraException {
      _cameras = const [];
    }
    if (_cameras.isEmpty) {
      setState(() => _error = 'No camera found on this phone.');
      return;
    }
    await _open();
  }

  CameraDescription get _camera {
    final want = _front ? CameraLensDirection.front : CameraLensDirection.back;
    return _cameras.firstWhere((c) => c.lensDirection == want, orElse: () => _cameras.first);
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    try {
      await _openCamera();
    } finally {
      _opening = false;
    }
  }

  Future<void> _openCamera() async {
    final old = _controller;
    _controller = null;
    if (mounted) setState(() {});
    await old?.dispose();
    final c = CameraController(
      _camera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await c.initialize();
    } on CameraException catch (e) {
      await c.dispose();
      if (!mounted) return;
      setState(() {
        _denied = e.code.contains('AccessDenied');
        _error = _denied ? 'Camera access is off for GYMTRX.' : 'Couldn’t open the camera.';
      });
      return;
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    setState(() {
      _controller = c;
      _error = null;
    });
  }

  Future<void> _flip() async {
    if (_cameras.length < 2 || _opening) return;
    Haptics.selection();
    setState(() => _front = !_front);
    await _open();
  }

  Future<void> _take() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      Haptics.medium();
      final shot = await c.takePicture();
      if (mounted) setState(() => _shot = shot);
    } on CameraException {
      Toasts.show('Couldn’t take the photo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _retake() {
    final shot = _shot;
    setState(() => _shot = null);
    if (shot != null) File(shot.path).delete().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final shot = _shot;
    final c = _controller;

    // The camera's frame in portrait: the preview's aspect ratio is landscape.
    Widget frame(Widget child) => Center(
      child: AspectRatio(aspectRatio: c == null ? 3 / 4 : 1 / c.value.aspectRatio, child: child),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (shot != null)
            frame(Image.file(File(shot.path), fit: BoxFit.cover))
          else if (c != null && c.value.isInitialized)
            frame(
              Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(c),
                  if (widget.ghost != null)
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: GtMotion.of(context, GtMotion.medium),
                        opacity: _ghostOn ? _ghostOpacity : 0,
                        // The preview is mirrored on the front camera; so is the ghost.
                        child: Transform.flip(
                          flipX: _front,
                          child: Image.file(widget.ghost!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(GtSpace.x3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center, style: GtText.body.colored(GtColors.text2)),
                    if (_denied) ...[
                      const SizedBox(height: GtSpace.lg),
                      GtButton(
                        label: 'Allow it in Android settings',
                        kind: GtButtonKind.secondary,
                        onTap: () async {
                          await const MethodChannel('gymtrx/system').invokeMethod('openAppSettings');
                          // Back from settings: try again.
                          _paused = true;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Top bar.
          Positioned(
            top: padding.top + GtSpace.sm,
            left: GtSpace.md,
            right: GtSpace.md,
            child: Row(
              children: [
                _RoundButton(icon: GtIcons.close, label: 'Close', onTap: () => Navigator.pop(context)),
                const Spacer(),
                AnimatedOpacity(
                  duration: GtMotion.of(context, GtMotion.medium),
                  opacity: _ghostOn && shot == null ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: GtSpace.md, vertical: GtSpace.sm),
                    decoration: ShapeDecoration(color: Colors.black54, shape: squircle(GtRadius.md)),
                    child: Text('Line yourself up with the outline', style: GtText.caption.colored(Colors.white)),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),

          // Bottom controls.
          Positioned(
            left: GtSpace.gutter,
            right: GtSpace.gutter,
            bottom: padding.bottom + GtSpace.xl,
            child: shot != null
                ? Row(
                    children: [
                      Expanded(
                        child: GtButton(label: 'Retake', kind: GtButtonKind.secondary, expand: true, onTap: _retake),
                      ),
                      const SizedBox(width: GtSpace.md),
                      Expanded(
                        child: GtButton(
                          label: 'Use photo',
                          expand: true,
                          haptic: PressHaptic.medium,
                          onTap: () => Navigator.pop(context, shot.path),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 96,
                        child: widget.ghost == null
                            ? null
                            : _GhostToggle(on: _ghostOn, onTap: () => setState(() => _ghostOn = !_ghostOn)),
                      ),
                      _Shutter(busy: _busy, onTap: c == null ? null : _take),
                      SizedBox(
                        width: 96,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _cameras.length < 2
                              ? null
                              : _RoundButton(icon: GtIcons.flip, label: 'Switch camera', onTap: _flip),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: busy ? null : onTap,
      haptic: PressHaptic.none,
      scale: 0.9,
      semanticLabel: 'Take photo',
      child: Container(
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(5),
        decoration: const ShapeDecoration(
          shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
        ),
        child: AnimatedContainer(
          duration: GtMotion.of(context, GtMotion.fast),
          decoration: BoxDecoration(color: busy ? Colors.white54 : Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _GhostToggle extends StatelessWidget {
  const _GhostToggle({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      scale: 0.92,
      semanticLabel: on ? 'Ghost on: your last photo is shown faintly' : 'Ghost off',
      child: AnimatedContainer(
        duration: GtMotion.of(context, GtMotion.medium),
        curve: GtMotion.emphasized,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
        decoration: ShapeDecoration(color: on ? context.accent : Colors.black54, shape: squircle(22)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(GtIcons.ghost, size: 18, color: on ? GtColors.onAccent : Colors.white),
            const SizedBox(width: 6),
            Text('Ghost', style: GtText.label.weight(600).colored(on ? GtColors.onAccent : Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      scale: 0.9,
      semanticLabel: label,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
