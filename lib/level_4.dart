import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:video_player/video_player.dart';

import 'level_progress.dart';

// =============================================================================

// BAGIAN 1

// =============================================================================

const double _canvasW = 1280;

const double _canvasH = 720;

String _assetPath(String filename) => 'assets/images/assetlevel4/$filename';

const List<String> _videoCandidates = [
  'assets/images/videos/animasi_dialog.mp4',

  'assets/images/assetlevel4/animasi_dialog.mp4',

  'assets/images/videos/animasi dialog.mp4',
];

const Duration _videoTimeout = Duration(seconds: 5);

const BoxFit _videoFit = BoxFit.cover;

const bool _forceLandscape = true;

const bool _useBundledFont = false;

const bool _showSuccessPopup = false;

const int _correctCount = 5;

// ---- Tombol Popup Default ----

const double _btnW = 190;

const double _btnH = 62;

const double _btnRight = 1040;

const double _btnBottom = 590;

// ---- Warna ----

const Color _kRed = Color(0xFFE5484D);

const Color _kGreen = Color(0xFF3FA34D);

const Color _kBlue = Color(0xFF4C8DF0);

const Color _kCyan = Color(0xFF38C2EE); // Warna Cyan Tombol "Lanjut" (Foto 2)

const Color _kBrown = Color(0xFFD2A679);

const Color _kBrownText = Color(0xFF4E342E);

const Color _kOrange = Color(0xFFFDD080);

const Color _kPillDone = Color(0xFFA5D6A7);

const Color _kLineOrange = Color(0xFFF28C28);

const Color _kLineGreen = Color(0xFF3FA34D);

TextStyle _fredoka(
  double size,
  Color color, {
  FontWeight weight = FontWeight.w600,
}) {
  if (_useBundledFont) {
    return TextStyle(
      fontFamily: 'Fredoka',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  return GoogleFonts.fredoka(fontSize: size, fontWeight: weight, color: color);
}

// =============================================================================

// BAGIAN 2 - DATA POPUP

// =============================================================================

enum _BtnKind { red, green, blue, brown, cyan }

class _PopupSpec {
  const _PopupSpec(this.file, this.label, this.kind);

  final String file;

  final String label;

  final _BtnKind kind;
}

const _PopupSpec _specGuide = _PopupSpec('panduan.png', 'OK', _BtnKind.blue);

const _PopupSpec _specSelesaiDetektif = _PopupSpec(
  'popup_selesai_detektif.png',
  'OK',
  _BtnKind.blue,
);

const _PopupSpec _specTahapBerikutnya = _PopupSpec(
  'popup_tahap_berikutnya.png',
  'OK',
  _BtnKind.blue,
);

const _PopupSpec _specMisi = _PopupSpec('popup_misi.png', 'Ayo', _BtnKind.blue);

const _PopupSpec _specBerhasil = _PopupSpec(
  'popup_berhasil.png',
  'OK',
  _BtnKind.blue,
);

const _PopupSpec _wrongBuku = _PopupSpec(
  'popup_buku_salah4.png',
  '<< Kembali',
  _BtnKind.red,
);

const _PopupSpec _wrongHp = _PopupSpec(
  'popup_hp_salah2.png',
  '<< Kembali',
  _BtnKind.red,
);

const _PopupSpec _wrongKamera = _PopupSpec(
  'popup_kamera_salah1.png',
  '<< Kembali',
  _BtnKind.red,
);

const _PopupSpec _wrongPensil = _PopupSpec(
  'popup_pensil_salah3.png',
  '<< Kembali',
  _BtnKind.red,
);

const _PopupSpec _rightPermen = _PopupSpec(
  'popup_permen_benar5.png',
  '<< Lanjut',
  _BtnKind.green,
);

const _PopupSpec _rightCake = _PopupSpec(
  'popup_cake_benar4.png',
  '<< Lanjut',
  _BtnKind.green,
);

const _PopupSpec _rightCokelat = _PopupSpec(
  'popup_cokelat_benar2.png',
  '<< Lanjut',
  _BtnKind.green,
);

const _PopupSpec _rightCola = _PopupSpec(
  'popup_cola_benar3.png',
  '<< Lanjut',
  _BtnKind.green,
);

const _PopupSpec _rightEskrim = _PopupSpec(
  'popup_eskrim_benar1.png',
  '<< Lanjut',
  _BtnKind.green,
);

const _PopupSpec _infoPermen = _PopupSpec(
  'papan_info_permen3.png',
  'Lanjut',
  _BtnKind.brown,
);

const _PopupSpec _infoCokelat = _PopupSpec(
  'papan_info_cokelat2.png',
  'Lanjut',
  _BtnKind.brown,
);

const _PopupSpec _infoCake = _PopupSpec(
  'papan_info_cake1.png',
  'Lanjut',
  _BtnKind.brown,
);

const _PopupSpec _infoEskrim = _PopupSpec(
  'papan_info_eskrim4.png',
  'Lanjut',
  _BtnKind.brown,
);

const _PopupSpec _infoCola = _PopupSpec(
  'papan_info_cola5.png',
  'Lanjut',
  _BtnKind.brown,
);

// =============================================================================

// BAGIAN 3 - MODEL DATA

// =============================================================================

enum Level4Stage { video, detective, matching, completed }

class _DetectiveItem {
  _DetectiveItem({
    required this.id,

    required this.file,

    required this.isCorrect,

    required this.popup,
  });

  final String id;

  final String file;

  final bool isCorrect;

  final _PopupSpec popup;

  int cell = 0;

  double jx = 0;

  double jy = 0;
}

class _Food {
  const _Food({
    required this.id,

    required this.file,

    required this.cx,

    required this.cy,

    required this.effect,

    required this.info,
  });

  final String id;

  final String file;

  final double cx;

  final double cy;

  final String effect;

  final _PopupSpec info;
}

class _Popup {
  const _Popup(this.spec, this.onClose);

  final _PopupSpec spec;

  final VoidCallback onClose;
}

class _LineSpec {
  const _LineSpec(this.from, this.to, this.color, {this.arrow = false});

  final Offset from;

  final Offset to;

  final Color color;

  final bool arrow;
}

// =============================================================================

// BAGIAN 4 - LAYAR UTAMA LEVEL 4

// =============================================================================

class Level4Screen extends StatefulWidget {
  const Level4Screen({super.key, this.onLevelCompleted});

  final VoidCallback? onLevelCompleted;

  @override
  State<Level4Screen> createState() => _Level4ScreenState();
}

class _Level4ScreenState extends State<Level4Screen> {
  final math.Random _rng = math.Random();

  Level4Stage _stage = Level4Stage.video;

  _Popup? _popup;

  // Video

  VideoPlayerController? _video;

  // Detektif

  static const double _safeL = 30;

  static const double _safeT = 205;

  static const double _safeR = 765;

  static const double _safeB = 705;

  static const int _cols = 4;

  static const int _rows = 3;

  late final List<_DetectiveItem> _items;

  final List<String> _foundItems = [];

  // Cocokkan

  static const double _foodD = 190;

  static const List<_Food> _foods = [
    _Food(
      id: 'cake',

      file: 'cake.png',

      cx: 165,

      cy: 132,

      effect: 'Meningkatkan risiko gigi berlubang.',

      info: _infoCake,
    ),

    _Food(
      id: 'eskrim',

      file: 'eskrim.png',

      cx: 400,

      cy: 134,

      effect: 'Bisa membuat gigi ngilu.',

      info: _infoEskrim,
    ),

    _Food(
      id: 'cola',

      file: 'cola.png',

      cx: 634,

      cy: 138,

      effect: 'Bisa mengikis lapisan luar gigi.',

      info: _infoCola,
    ),

    _Food(
      id: 'permen',

      file: 'permen.png',

      cx: 872,

      cy: 138,

      effect: 'Membuat gigi berlubang.',

      info: _infoPermen,
    ),

    _Food(
      id: 'cokelat',

      file: 'cokelat.png',

      cx: 1097,

      cy: 138,

      effect: 'Meningkatkan risiko gigi berlubang.',

      info: _infoCokelat,
    ),
  ];

  static final List<Rect> _pillRects = [
    Rect.fromLTWH(50, 564, 220, 68),

    Rect.fromLTWH(283, 564, 220, 68),

    Rect.fromLTWH(520, 564, 220, 68),

    Rect.fromLTWH(757, 564, 220, 68),

    Rect.fromLTWH(995, 564, 220, 68),
  ];

  late final List<_Food> _targetOrder;

  final Map<String, int> _matched = {};

  String? _draggingId;

  Offset? _dragPos;

  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (_forceLandscape) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,

        DeviceOrientation.landscapeRight,
      ]);

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _items = _buildDetectiveItems();

    _targetOrder = List<_Food>.of(_foods)..shuffle(_rng);

    _initVideo();
  }

  @override
  void dispose() {
    _video?.removeListener(_onVideoTick);

    _video?.dispose();

    super.dispose();
  }

  // ---- TAHAP 1 - VIDEO ----

  Future<void> _initVideo() async {
    try {
      await _loadVideo().timeout(_videoTimeout);
    } catch (_) {
      _finishVideo();
    }
  }

  Future<void> _loadVideo() async {
    for (final path in _videoCandidates) {
      if (!mounted || _stage != Level4Stage.video) return;

      final controller = VideoPlayerController.asset(path);

      try {
        await controller.initialize();

        if (!mounted || _stage != Level4Stage.video) {
          await controller.dispose();

          return;
        }

        await controller.setLooping(false);

        await controller.setVolume(1.0);

        controller.addListener(_onVideoTick);

        setState(() => _video = controller);

        await controller.play();

        return;
      } catch (_) {
        if (identical(_video, controller)) {
          controller.removeListener(_onVideoTick);

          if (mounted) setState(() => _video = null);
        }

        await controller.dispose();
      }
    }

    throw Exception('Gagal memuat video');
  }

  void _onVideoTick() {
    final c = _video;

    if (c == null) return;

    final v = c.value;

    if (v.hasError) {
      _finishVideo();

      return;
    }

    final reachedEnd =
        v.isInitialized &&
        v.duration > Duration.zero &&
        (v.isCompleted ||
            v.position >= v.duration - const Duration(milliseconds: 250));

    if (reachedEnd) _finishVideo();
  }

  void _finishVideo() {
    if (!mounted || _stage != Level4Stage.video) return;

    final old = _video;

    old?.removeListener(_onVideoTick);

    setState(() {
      _video = null;

      _stage = Level4Stage.detective;

      _popup = const _Popup(_specGuide, _noop);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
  }

  Widget _buildVideoStage() {
    final c = _video;

    return Stack(
      fit: StackFit.expand,

      children: [
        const ColoredBox(color: Colors.black),

        if (c != null && c.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: _videoFit,

              clipBehavior: Clip.hardEdge,

              child: SizedBox(
                width: c.value.size.width,

                height: c.value.size.height,

                child: VideoPlayer(c),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        Positioned(
          top: 8,

          right: 12,

          child: SafeArea(
            child: TextButton(
              onPressed: () => _finishVideo(),

              style: TextButton.styleFrom(
                foregroundColor: Colors.white,

                backgroundColor: Colors.black38,
              ),

              child: const Text('Lewati'),
            ),
          ),
        ),
      ],
    );
  }

  // ---- TAHAP 2 - GAME DETEKTIF ----

  List<_DetectiveItem> _buildDetectiveItems() {
    final items = <_DetectiveItem>[
      _DetectiveItem(
        id: 'permen',
        file: 'permen.png',
        isCorrect: true,
        popup: _rightPermen,
      ),

      _DetectiveItem(
        id: 'cake',
        file: 'cake.png',
        isCorrect: true,
        popup: _rightCake,
      ),

      _DetectiveItem(
        id: 'cokelat',

        file: 'cokelat.png',

        isCorrect: true,

        popup: _rightCokelat,
      ),

      _DetectiveItem(
        id: 'cola',
        file: 'cola.png',
        isCorrect: true,
        popup: _rightCola,
      ),

      _DetectiveItem(
        id: 'eskrim',
        file: 'eskrim.png',
        isCorrect: true,
        popup: _rightEskrim,
      ),

      _DetectiveItem(
        id: 'buku',
        file: 'buku.png',
        isCorrect: false,
        popup: _wrongBuku,
      ),

      _DetectiveItem(
        id: 'hp',
        file: 'hp.png',
        isCorrect: false,
        popup: _wrongHp,
      ),

      _DetectiveItem(
        id: 'kamera',

        file: 'kamera.png',

        isCorrect: false,

        popup: _wrongKamera,
      ),

      _DetectiveItem(
        id: 'pensil',

        file: 'pensil.png',

        isCorrect: false,

        popup: _wrongPensil,
      ),
    ];

    final cells = List<int>.generate(_cols * _rows, (i) => i)..shuffle(_rng);

    for (var i = 0; i < items.length; i++) {
      items[i].cell = cells[i];

      items[i].jx = _rng.nextDouble() - 0.5;

      items[i].jy = _rng.nextDouble() - 0.5;
    }

    return items;
  }

  void _onItemTap(_DetectiveItem item) {
    if (_popup != null) return;

    if (!item.isCorrect) {
      _showPopup(item.popup, onClose: _noop);

      return;
    }

    if (_foundItems.contains(item.id)) return;

    setState(() => _foundItems.add(item.id));

    _showPopup(
      item.popup,
      onClose: () {
        if (_foundItems.length >= _correctCount) _showDetectiveEnding();
      },
    );
  }

  void _showDetectiveEnding() {
    _showPopup(
      _specSelesaiDetektif,
      onClose: () {
        _showPopup(
          _specTahapBerikutnya,
          onClose: () {
            _showPopup(_specMisi, onClose: _startMatching);
          },
        );
      },
    );
  }

  void _startMatching() {
    if (!mounted) return;

    setState(() => _stage = Level4Stage.matching);
  }

  Widget _buildDetectiveStage() {
    return _CanvasStage(
      bgFile: 'bg_detektif.png',

      children: [
        for (final item in _items)
          if (!(item.isCorrect && _foundItems.contains(item.id)))
            _buildDetectiveItem(item),

        Positioned(
          left: 24,

          top: 18,

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

            decoration: BoxDecoration(
              color: Colors.black54,

              borderRadius: BorderRadius.circular(24),
            ),

            child: Text(
              'Ditemukan ${_foundItems.length}/$_correctCount',

              style: _fredoka(26, Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectiveItem(_DetectiveItem item) {
    final cellW = (_safeR - _safeL) / _cols;

    final cellH = (_safeB - _safeT) / _rows;

    final size = math.min(cellW, cellH) * 0.86;

    final col = item.cell % _cols;

    final row = item.cell ~/ _cols;

    final cx = _safeL + (col + 0.5) * cellW + item.jx * (cellW - size);

    final cy = _safeT + (row + 0.5) * cellH + item.jy * (cellH - size);

    return Positioned(
      left: cx - size / 2,

      top: cy - size / 2,

      width: size,

      height: size,

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: () => _onItemTap(item),

        child: _img(item.file),
      ),
    );
  }

  // ---- POPUP ----

  void _showPopup(_PopupSpec spec, {required VoidCallback onClose}) {
    if (!mounted) return;

    setState(() => _popup = _Popup(spec, onClose));
  }

  void _closePopup() {
    final p = _popup;

    if (p == null) return;

    setState(() => _popup = null);

    p.onClose();
  }

  Widget _buildPopupOverlay(_Popup popup) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: () {},

        child: Stack(
          fit: StackFit.expand,

          children: [
            const ColoredBox(color: Color(0xCC000000)),

            FittedBox(
              fit: BoxFit.contain, // khusus popup tetap pakai contain agar rasio popup aman

              child: SizedBox(
                width: _canvasW,

                height: _canvasH,

                child: Stack(
                  fit: StackFit.expand,

                  children: [
                    _img(popup.spec.file, fit: BoxFit.contain),

                    Positioned(
                      left: _btnRight - _btnW,

                      top: _btnBottom - _btnH,

                      width: _btnW,

                      height: _btnH,

                      child: _PopupButton(
                        spec: popup.spec,

                        onPressed: _closePopup,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- TAHAP 3 - GAME COCOKKAN ----

  void _onDrop(_Food food, int targetIdx) {
    final correct = _targetOrder[targetIdx].effect == food.effect;

    if (!correct) return;

    setState(() => _matched[food.id] = targetIdx);

    _showPopup(
      food.info,
      onClose: () {
        if (_matched.length == _foods.length) _onAllMatched();
      },
    );
  }

  void _onAllMatched() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (_showSuccessPopup) {
        _showPopup(_specBerhasil, onClose: _goCompleted);
      } else {
        _goCompleted();
      }
    });
  }

  void _goCompleted() {
    if (!mounted) return;

    setState(() => _stage = Level4Stage.completed);
  }

  Widget _buildMatchingStage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / _canvasW,

          constraints.maxHeight / _canvasH,
        );

        Offset sourceOf(_Food f) => Offset(f.cx, f.cy);

        Offset pillTop(int i) =>
            Offset(_pillRects[i].center.dx, _pillRects[i].top);

        final lines = <_LineSpec>[];

        _matched.forEach((foodId, idx) {
          final f = _foods.firstWhere((e) => e.id == foodId);

          lines.add(
            _LineSpec(sourceOf(f), pillTop(idx), _kLineGreen, arrow: true),
          );
        });

        final dragId = _draggingId;

        final dragPos = _dragPos;

        if (dragId != null && dragPos != null) {
          final f = _foods.firstWhere((e) => e.id == dragId);

          lines.add(_LineSpec(sourceOf(f), dragPos, _kLineOrange));
        }

        return _CanvasStage(
          bgFile: 'cocokkan.png',

          canvasKey: _canvasKey,

          children: [
            for (var i = 0; i < _pillRects.length; i++) _buildPill(i),

            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _LinePainter(lines)),
              ),
            ),

            for (final f in _foods) _buildFood(f, scale),
          ],
        );
      },
    );
  }

  Widget _buildPill(int i) {
    final rect = _pillRects[i].inflate(2);

    return Positioned.fromRect(
      rect: rect,

      child: DragTarget<_Food>(
        onWillAcceptWithDetails: (details) => !_matched.containsValue(i),

        onAcceptWithDetails: (details) => _onDrop(details.data, i),

        builder: (context, candidates, rejected) {
          final filled = _matched.containsValue(i);

          final hovering = candidates.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),

            alignment: Alignment.center,

            padding: const EdgeInsets.symmetric(horizontal: 10),

            decoration: BoxDecoration(
              color: filled ? _kPillDone : _kOrange,

              borderRadius: BorderRadius.circular(rect.height / 2),

              border: hovering
                  ? Border.all(color: Colors.white, width: 4)
                  : null,
            ),

            child: FittedBox(
              fit: BoxFit.scaleDown,

              child: SizedBox(
                width: rect.width - 20,

                child: Text(
                  _targetOrder[i].effect,

                  textAlign: TextAlign.center,

                  maxLines: 2,

                  style: _fredoka(20, _kBrownText, weight: FontWeight.w500),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFood(_Food f, double scale) {
    final matched = _matched.containsKey(f.id);

    final feedbackSize = _foodD * scale;

    return Positioned(
      left: f.cx - _foodD / 2,

      top: f.cy - _foodD / 2,

      width: _foodD,

      height: _foodD,

      child: matched
          ? _foodCircle(f, matched: true)
          : Draggable<_Food>(
              data: f,

              maxSimultaneousDrags: 1,

              dragAnchorStrategy: (draggable, context, position) =>
                  Offset(feedbackSize / 2, feedbackSize / 2),

              feedback: Material(
                type: MaterialType.transparency,

                child: SizedBox(
                  width: feedbackSize,

                  height: feedbackSize,

                  child: _foodCircle(f, scale: scale),
                ),
              ),

              childWhenDragging: _foodCircle(f, empty: true),

              onDragStarted: () => setState(() => _draggingId = f.id),

              onDragUpdate: (details) {
                final box =
                    _canvasKey.currentContext?.findRenderObject() as RenderBox?;

                if (box == null) return;

                setState(
                  () => _dragPos = box.globalToLocal(details.globalPosition),
                );
              },

              onDragEnd: (_) => setState(() {
                _draggingId = null;

                _dragPos = null;
              }),

              child: _foodCircle(f),
            ),
    );
  }

  Widget _foodCircle(
    _Food f, {
    double scale = 1,
    bool matched = false,
    bool empty = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,

      children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(22 * scale),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: _kOrange,

              border: matched
                  ? Border.all(color: _kGreen, width: 6 * scale)
                  : null,
            ),

            child: empty ? null : _img(f.file),
          ),
        ),

        if (matched)
          Positioned(
            right: 0,

            top: 0,

            child: Icon(Icons.check_circle, color: _kGreen, size: 44 * scale),
          ),
      ],
    );
  }

  // ---- TAHAP 4 - SELESAI LEVEL 4 ----

  void _finishLevel() {
    if (!mounted) return;

    // Buka Level 5 setelah pemain menyelesaikan Level 4.

    if (unlockedLevelNotifier.value < 5) {
      unlockedLevelNotifier.value = 5;
    }

    final cb = widget.onLevelCompleted;

    if (cb != null) {
      cb();
    } else {
      // Level 4 dibuka dari menu level dengan Navigator.push,

      // jadi pop akan mengembalikan pemain ke menu pemilihan level.

      Navigator.of(context).pop();
    }
  }

  Widget _buildCompletedStage() {
    return _CanvasStage(
      bgFile: 'selesai_level4.png',

      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,

            onTap: _finishLevel,
          ),
        ),

        // Tombol "Lanjut" diposisikan di tengah bawah kartu
        Positioned(
          left: (1280 - 210) / 2,

          top: 575,

          width: 210,

          height: 52,

          child: _PopupButton(
            spec: const _PopupSpec('', 'Lanjut', _BtnKind.cyan),

            onPressed: _finishLevel,
          ),
        ),
      ],
    );
  }

  // ---- BUILD ----

  Widget _buildStage() {
    switch (_stage) {
      case Level4Stage.video:
        return _buildVideoStage();

      case Level4Stage.detective:
        return _buildDetectiveStage();

      case Level4Stage.matching:
        return _buildMatchingStage();

      case Level4Stage.completed:
        return _buildCompletedStage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      resizeToAvoidBottomInset: false,

      body: Stack(
        fit: StackFit.expand,

        children: [
          _buildStage(),

          if (_popup != null) _buildPopupOverlay(_popup!),
        ],
      ),
    );
  }
}

void _noop() {}

// =============================================================================

// BAGIAN 5

// =============================================================================

Widget _img(String file, {BoxFit fit = BoxFit.cover}) {
  return Image.asset(_assetPath(file), fit: fit);
}

/// KANVAS LAYAR FULL (BoxFit.cover - tanpa gepeng/blur)

class _CanvasStage extends StatelessWidget {
  const _CanvasStage({
    required this.bgFile,

    required this.children,

    this.canvasKey,
  });

  final String bgFile;

  final List<Widget> children;

  final GlobalKey? canvasKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover, // biar rapih dan tidak gepeng

        clipBehavior: Clip.hardEdge,

        child: SizedBox(
          key: canvasKey,

          width: _canvasW,

          height: _canvasH,

          child: Stack(
            fit: StackFit.expand,

            children: [
              _img(bgFile, fit: BoxFit.cover),

              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupButton extends StatelessWidget {
  const _PopupButton({required this.spec, required this.onPressed});

  final _PopupSpec spec;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Color background = _kBlue;

    Color textColor = Colors.white;

    switch (spec.kind) {
      case _BtnKind.red:
        background = _kRed;

        break;

      case _BtnKind.green:
        background = _kGreen;

        break;

      case _BtnKind.blue:
        background = _kBlue;

        break;

      case _BtnKind.brown:
        background = _kBrown;

        textColor = _kBrownText;

        break;

      case _BtnKind.cyan:
        background = _kCyan;

        textColor = Colors.white;

        break;
    }

    return Material(
      color: background,

      elevation: 4,

      shadowColor: Colors.black26,

      borderRadius: BorderRadius.circular(26),

      child: InkWell(
        borderRadius: BorderRadius.circular(26),

        onTap: onPressed,

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),

            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
          ),

          child: Center(
            child: Text(
              spec.label,
              style: _fredoka(24, textColor, weight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================

// BAGIAN 6

// =============================================================================

class _LinePainter extends CustomPainter {
  _LinePainter(this.lines);

  final List<_LineSpec> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final l in lines) {
      final linePaint = Paint()
        ..color = l.color
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(l.from, l.to, linePaint);

      if (l.arrow) {
        final angle = math.atan2(l.to.dy - l.from.dy, l.to.dx - l.from.dx);

        const arrowSize = 28.0;

        final p1 =
            l.to -
            Offset(math.cos(angle - 0.45), math.sin(angle - 0.45)) * arrowSize;

        final p2 =
            l.to -
            Offset(math.cos(angle + 0.45), math.sin(angle + 0.45)) * arrowSize;

        final path = Path()
          ..moveTo(l.to.dx, l.to.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close();

        canvas.drawPath(
          path,

          Paint()
            ..color = l.color
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}
