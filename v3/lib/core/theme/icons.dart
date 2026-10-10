import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Every icon the app uses, in one place, so the visual language stays
/// consistent (regular weight by default, fill for active states).
abstract final class GtIcons {
  static const settings = PhosphorIconsRegular.gear;
  static const add = PhosphorIconsBold.plus;
  static const close = PhosphorIconsRegular.x;
  static const check = PhosphorIconsBold.check;
  static const back = PhosphorIconsRegular.caretLeft;
  static const chevronLeft = PhosphorIconsBold.caretLeft;
  static const chevronRight = PhosphorIconsBold.caretRight;
  static const chevronDown = PhosphorIconsBold.caretDown;

  static const calendar = PhosphorIconsRegular.calendarBlank;
  static const calendarActive = PhosphorIconsFill.calendarBlank;
  static const calendarPlus = PhosphorIconsRegular.calendarPlus;
  static const insights = PhosphorIconsRegular.chartBar;
  static const insightsActive = PhosphorIconsFill.chartBar;
  static const progress = PhosphorIconsRegular.trendUp;
  static const progressActive = PhosphorIconsFill.trendUp;

  static const edit = PhosphorIconsRegular.pencilSimple;
  static const delete = PhosphorIconsRegular.trash;
  static const note = PhosphorIconsRegular.notePencil;
  static const search = PhosphorIconsRegular.magnifyingGlass;
  static const drag = PhosphorIconsRegular.dotsSixVertical;
  static const undo = PhosphorIconsRegular.arrowCounterClockwise;

  static const exercise = PhosphorIconsRegular.barbell;
  static const duration = PhosphorIconsRegular.timer;
  static const weight = PhosphorIconsRegular.scales;
  static const cardio = PhosphorIconsFill.heartbeat;
  static const body = PhosphorIconsRegular.personSimple;

  static const lock = PhosphorIconsRegular.lockSimple;
  static const fingerprint = PhosphorIconsRegular.fingerprint;
  static const export = PhosphorIconsRegular.export;
  static const import = PhosphorIconsRegular.downloadSimple;
  static const palette = PhosphorIconsRegular.palette;
  static const ruler = PhosphorIconsRegular.ruler;
  static const clock = PhosphorIconsRegular.clock;
  static const info = PhosphorIconsRegular.info;
  static const library = PhosphorIconsRegular.squaresFour;
  static const haptics = PhosphorIconsRegular.vibrate;
  static const night = PhosphorIconsRegular.moonStars;
  static const share = PhosphorIconsRegular.shareNetwork;
  static const folder = PhosphorIconsRegular.folderSimple;
  static const eye = PhosphorIconsRegular.eye;
  static const eyeOff = PhosphorIconsRegular.eyeSlash;

  static const flame = PhosphorIconsFill.flame;
  static const trophy = PhosphorIconsFill.trophy;
  static const medal = PhosphorIconsFill.medal;
  static const target = PhosphorIconsRegular.target;
  static const camera = PhosphorIconsRegular.camera;
  static const images = PhosphorIconsRegular.images;
  static const compare = PhosphorIconsRegular.squareSplitHorizontal;
  static const bell = PhosphorIconsRegular.bell;
  static const bellOff = PhosphorIconsRegular.bellSlash;
  static const program = PhosphorIconsRegular.calendarDots;
  static const missed = PhosphorIconsRegular.calendarX;
  static const warning = PhosphorIconsRegular.warningCircle;
}
