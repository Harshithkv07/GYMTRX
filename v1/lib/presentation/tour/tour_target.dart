import 'package:flutter/widgets.dart';

/// The parts of the home screen the tour points at.
enum TourSpot { add, calendar, tabs, settings }

/// Marks [child] as the [spot] the home tour highlights.
class TourTarget extends StatefulWidget {
  const TourTarget({super.key, required this.spot, required this.child});

  final TourSpot spot;
  final Widget child;

  static final _keys = <TourSpot, GlobalKey>{};

  @override
  State<TourTarget> createState() => _TourTargetState();
}

class _TourTargetState extends State<TourTarget> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    TourTarget._keys[widget.spot] = _key;
  }

  @override
  void didUpdateWidget(TourTarget old) {
    super.didUpdateWidget(old);
    if (old.spot != widget.spot) {
      if (TourTarget._keys[old.spot] == _key) TourTarget._keys.remove(old.spot);
      TourTarget._keys[widget.spot] = _key;
    }
  }

  @override
  void dispose() {
    if (TourTarget._keys[widget.spot] == _key) TourTarget._keys.remove(widget.spot);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(key: _key, child: widget.child);
}

/// Where [spot] is on screen, or null when it isn't laid out.
Rect? tourRectOf(TourSpot spot) {
  final box = TourTarget._keys[spot]?.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
