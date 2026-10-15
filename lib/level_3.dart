import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_progress.dart';

enum CareStage { floss, brush, tongue, rinse }

extension CareStageInfo on CareStage {
  String get label {
    switch (this) {
      case CareStage.floss:
        return 'Benang gigi';
      case CareStage.brush:
        return 'Sikat gigi';
      case CareStage.tongue:
        return 'Pembersih lidah';
      case CareStage.rinse:
        return 'Kumur-kumur';
    }
  }

  String get instruction {
    switch (this) {
      case CareStage.floss:
        return 'Tahan benang gigi, lalu gerakkan naik-turun di tiap sela gigi yang ada garis putus-putusnya sampai muncul tanda centang. Gerakkan perlahan, jangan menyentak gusi.';
      case CareStage.brush:
        return 'Seret pasta gigi sebesar biji jagung ke kepala sikat. Sikat gigi depan dengan gerakan memutar, bagian dalam dari gusi ke arah gigi, dan geraham maju-mundur. Durasi menyikat yang dianjurkan adalah 2 menit.';
      case CareStage.tongue:
        return 'Tahan pembersih lidah dan tarik dari belakang lidah ke depan (ke bawah) mengikuti garis putus-putus.';
      case CareStage.rinse:
        return 'Tahan botol obat kumur sebentar untuk membuka tutupnya, lalu seret ke mulut dan gerakkan untuk berkumur. Jangan ditelan.';
    }
  }

  String get shortInstruction {
    switch (this) {
      case CareStage.floss:
        return 'Gerakkan floss naik-turun di tiap sela gigi sampai muncul centang.';
      case CareStage.brush:
        return 'Durasi menyikat gigi yang dianjurkan adalah 2 menit.';
      case CareStage.tongue:
        return 'Tarik scraper dari belakang lidah ke depan mengikuti garis.';
      case CareStage.rinse:
        return 'Tahan botol untuk membuka tutup, lalu gerakkan di area mulut. Jangan ditelan.';
    }
  }
}

// ---------------------------------------------------------------------------
// Layout mulut
// ---------------------------------------------------------------------------
enum StrokeKind { circle, vertical, horizontal }

class _BrushZone {
  final String label;
  final StrokeKind kind;
  final Rect area;
  final List<Offset> spots;
  final double need;
  const _BrushZone(this.label, this.kind, this.area, this.spots, this.need);
}

class MouthLayout {
  MouthLayout._();
  static const bool debug = false;
  static const List<Offset> upperTeeth = [
    Offset(.217, .368),
    Offset(.255, .311),
    Offset(.314, .270),
    Offset(.378, .254),
    Offset(.453, .254),
    Offset(.507, .270),
    Offset(.566, .302),
    Offset(.609, .335),
  ];
  static const List<Offset> lowerTeeth = [
    Offset(.211, .610),
    Offset(.249, .659),
    Offset(.298, .694),
    Offset(.352, .710),
    Offset(.405, .715),
    Offset(.459, .704),
    Offset(.513, .680),
    Offset(.561, .635),
  ];
  static const Rect mouthArea = Rect.fromLTRB(.15, .18, .65, .76);
  static const Rect tongueArea = Rect.fromLTRB(.26, .46, .58, .74);
  static const Offset tongueStart = Offset(.414, .49);
  static const Offset tongueEnd = Offset(.414, .68);
  static const List<Offset> tongueGerms = [
    Offset(.34, .56),
    Offset(.42, .52),
    Offset(.50, .57),
    Offset(.42, .63),
  ];
  static const List<Offset> throatGerms = [
    Offset(.33, .43),
    Offset(.40, .45),
    Offset(.47, .43),
    Offset(.54, .45),
    Offset(.60, .42),
  ];
  static const List<String> germAssets = [
    'assets/images/assetlevel3/kuman.png',
    'assets/images/assetlevel3/kuman_2.png',
  ];
  static const int flossGapsRequired = 14;
  static final List<Offset> innerSpots = [
    for (final i in [2, 3, 4, 5]) Offset(upperTeeth[i].dx, .375),
  ];
  static final List<_BrushZone> zones = [
    _BrushZone(
      'Gigi depan atas',
      StrokeKind.circle,
      const Rect.fromLTRB(.28, .16, .56, .31),
      [
        for (final i in [2, 3, 4, 5]) upperTeeth[i],
      ],
      1.4,
    ),
    _BrushZone(
      'Gigi depan bawah',
      StrokeKind.circle,
      const Rect.fromLTRB(.27, .63, .56, .78),
      [
        for (final i in [2, 3, 4, 5]) lowerTeeth[i],
      ],
      1.4,
    ),
    _BrushZone(
      'Bagian dalam',
      StrokeKind.vertical,
      const Rect.fromLTRB(.30, .32, .58, .47),
      innerSpots,
      1.0,
    ),
    _BrushZone(
      'Geraham kiri',
      StrokeKind.horizontal,
      const Rect.fromLTRB(.14, .28, .27, .74),
      [upperTeeth[0], lowerTeeth[0], upperTeeth[1], lowerTeeth[1]],
      1.2,
    ),
    _BrushZone(
      'Geraham kanan',
      StrokeKind.horizontal,
      const Rect.fromLTRB(.57, .26, .68, .72),
      [upperTeeth[6], lowerTeeth[6], upperTeeth[7], lowerTeeth[7]],
      1.2,
    ),
  ];
}

enum GermGroup { zone, tongue, throat }

class _Germ {
  final Offset pos;
  final int type;
  final GermGroup group;
  final int zone;
  final int order;
  const _Germ(this.pos, this.type, this.group, this.zone, this.order);
}

class _Gap {
  final Offset a0;
  final Offset a1;
  double travel = 0;
  bool done = false;
  _Gap(this.a0, this.a1);
}

class _GapGeom {
  final Offset center;
  final Offset across;
  final Offset along;
  final double spacing;
  final double half;
  const _GapGeom(this.center, this.across, this.along, this.spacing, this.half);
}

_GapGeom _gapGeom(_Gap g, Size s) {
  final p0 = Offset(g.a0.dx * s.width, g.a0.dy * s.height);
  final p1 = Offset(g.a1.dx * s.width, g.a1.dy * s.height);
  final t = p1 - p0;
  final spacing = math.max(t.distance, 1.0);
  final across = t / spacing;
  final along = Offset(-across.dy, across.dx);
  return _GapGeom((p0 + p1) / 2, across, along, spacing, s.height * .07);
}

double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;
double _clampD(double v, double lo, double hi) => math.max(lo, math.min(hi, v));

// ---------------------------------------------------------------------------
// Layar
// ---------------------------------------------------------------------------
enum Tool { floss, brush, tube, scraper, bottle }

class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});
  @override
  State<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen> {
  static const Color blue = Color(0xFF3198F5);
  static const Color darkBlue = Color(0xFF24538F);
  static const Color paleBlue = Color(0xFFE7F4FF);
  static const int tonguePullsNeeded = 3;

  static const Map<Tool, Offset> _home = {
    Tool.floss: Offset(.72, .30),
    Tool.brush: Offset(.72, .20),
    Tool.tube: Offset(.72, .48),
    Tool.scraper: Offset(.72, .45),
    Tool.bottle: Offset(.73, .40),
  };

  static const Map<Tool, Alignment> _hotspot = {
    Tool.floss: Alignment(0, 0),
    Tool.brush: Alignment(-.75, -.45),
    Tool.tube: Alignment(0, 0),
    Tool.scraper: Alignment(.6, -.5),
    Tool.bottle: Alignment(0, 0),
  };

  static const Alignment _pasteOnBrush = Alignment(-.7, -.65);
  CareStage _stage = CareStage.floss;
  final Set<CareStage> _completed = {};
  bool _showFinished = false;

  List<_Gap> _gaps = _buildGaps();
  bool _pasteAdded = false;
  final List<double> _zoneProgress = List<double>.filled(
    MouthLayout.zones.length,
    0.0,
  );
  int _tonguePulls = 0;
  double _tonguePull = 0;
  bool _bottleOpen = false;
  double _rinseProgress = 0;
  Timer? _openTimer;
  final Map<Tool, Offset> _pos = {};
  Tool? _held;
  int? _heldPointer;
  late final List<_Germ> _germs = _buildGerms();

  static List<_Gap> _buildGaps() => [
    for (int i = 0; i < MouthLayout.upperTeeth.length - 1; i++)
      _Gap(MouthLayout.upperTeeth[i], MouthLayout.upperTeeth[i + 1]),
    for (int i = 0; i < MouthLayout.lowerTeeth.length - 1; i++)
      _Gap(MouthLayout.lowerTeeth[i], MouthLayout.lowerTeeth[i + 1]),
  ];

  static List<_Germ> _buildGerms() {
    final out = <_Germ>[];
    var n = 0;
    for (int z = 0; z < MouthLayout.zones.length; z++) {
      final spots = MouthLayout.zones[z].spots;
      for (int i = 0; i < spots.length; i++) {
        out.add(_Germ(spots[i], n++ % 2, GermGroup.zone, z, i));
      }
    }
    for (int i = 0; i < MouthLayout.tongueGerms.length; i++) {
      out.add(
        _Germ(MouthLayout.tongueGerms[i], n++ % 2, GermGroup.tongue, -1, i),
      );
    }
    for (int i = 0; i < MouthLayout.throatGerms.length; i++) {
      out.add(
        _Germ(MouthLayout.throatGerms[i], n++ % 2, GermGroup.throat, -1, i),
      );
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    super.dispose();
  }

  void _finishLevel() {
    // Buka Level 4 setelah Level 3 selesai.
    if (unlockedLevelNotifier.value < 4) {
      unlockedLevelNotifier.value = 4;
    }

    // Kembali ke halaman pemilihan level.
    Navigator.of(context).pop();
  }

  int get _stageIndex => CareStage.values.indexOf(_stage);
  int get _flossDone => _gaps.where((g) => g.done).length;
  int get _flossTarget => math.min(MouthLayout.flossGapsRequired, _gaps.length);
  int get _zonesDone => _zoneProgress.where((p) => p >= 1).length;

  _BrushZone? _activeZone() {
    for (int i = 0; i < _zoneProgress.length; i++) {
      if (_zoneProgress[i] < 1) return MouthLayout.zones[i];
    }
    return null;
  }

  int _foamShown(int z) =>
      (_zoneProgress[z] * MouthLayout.zones[z].spots.length).ceil();

  bool _germAlive(_Germ g) {
    switch (g.group) {
      case GermGroup.zone:
        return g.order >= _foamShown(g.zone);
      case GermGroup.tongue:
        final total = MouthLayout.tongueGerms.length;
        final cleared = (total * _tonguePulls / tonguePullsNeeded).ceil();
        return g.order >= cleared;
      case GermGroup.throat:
        final total = MouthLayout.throatGerms.length;
        final cleared = (total * _rinseProgress).ceil();
        return g.order >= cleared;
    }
  }

  void _completeStage() {
    if (_stage == CareStage.floss && _flossDone < _flossTarget) {
      _showMessage(
        'Masih ada sela gigi yang belum di-floss ($_flossDone/$_flossTarget).',
      );
      return;
    }
    if (_stage == CareStage.brush) {
      if (!_pasteAdded) {
        _showMessage('Seret pasta gigi ke kepala sikat terlebih dahulu.');
        return;
      }
      final zone = _activeZone();
      if (zone != null) {
        _showMessage('Masih ada area yang belum disikat: ${zone.label}.');
        return;
      }
    }
    if (_stage == CareStage.tongue && _tonguePulls < tonguePullsNeeded) {
      _showMessage(
        'Tarik scraper dari belakang lidah ke depan ($_tonguePulls/$tonguePullsNeeded).',
      );
      return;
    }
    if (_stage == CareStage.rinse && _rinseProgress < 1) {
      _showMessage('Tahan botol, lalu gerakkan di area mulut untuk berkumur.');
      return;
    }
    setState(() {
      _completed.add(_stage);
      if (_completed.length == CareStage.values.length) {
        _showFinished = true;
      } else {
        _stage = CareStage.values[_completed.length];
        _resetTransient();
      }
    });
  }

  void _resetTransient() {
    _openTimer?.cancel();
    _pos.clear();
    _held = null;
    _heldPointer = null;
    _bottleOpen = false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkBlue,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _restart() {
    setState(() {
      _stage = CareStage.floss;
      _completed.clear();
      _showFinished = false;
      _gaps = _buildGaps();
      _pasteAdded = false;
      _zoneProgress.fillRange(0, _zoneProgress.length, 0.0);
      _tonguePulls = 0;
      _tonguePull = 0;
      _rinseProgress = 0;
      _resetTransient();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme
            .apply(fontFamily: GoogleFonts.fredoka().fontFamily),
        primaryTextTheme: Theme.of(context).primaryTextTheme
            .apply(fontFamily: GoogleFonts.fredoka().fontFamily),
      ),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, outer) {
            final landscape = outer.maxWidth > outer.maxHeight;
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/assetlevel3/kucing.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _BathroomBackground(),
                  ),
                ),
                if (_showFinished)
                  FinishedView(onRestart: _restart, onContinue: _finishLevel)
                else
                  SafeArea(
                    child: landscape
                        ? Row(
                            children: [
                              SizedBox(
                                width: outer.maxWidth * .29,
                                child: _instructionPanel(),
                              ),
                              Expanded(child: _simulationArea()),
                            ],
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: outer.maxHeight * .31,
                                child: _instructionPanel(),
                              ),
                              Expanded(child: _simulationArea()),
                            ],
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _instructionPanel() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8ED0FF), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22305C8D),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: paleBlue,
                        child: Icon(Icons.health_and_safety, color: blue),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'SIMULASI\nPERAWATAN MULUT',
                          style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Langkah ${_stageIndex + 1} dari 4',
                    style: const TextStyle(
                      color: darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: List.generate(4, (i) {
                      final done = _completed.contains(CareStage.values[i]);
                      final active = i == _stageIndex;
                      return Expanded(
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: done || active
                                ? blue
                                : const Color(0xFFD5E0EA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _stage.label,
                    style: const TextStyle(
                      fontSize: 21,
                      color: darkBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _stage.instruction,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF315779),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: paleBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _stage == CareStage.brush
                          ? 'Durasi menyikat gigi yang dianjurkan: 2 menit. Gerakkan sikat mengikuti pola pada area gigi.'
                          : _stage.shortInstruction,
                      style: const TextStyle(
                        fontSize: 12,
                        color: darkBlue,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Progres: ${_currentProgressText()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF55738E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _completeStage,
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                _stageIndex == 3 ? 'SELESAI' : 'LANJUT',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _currentProgressText() {
    switch (_stage) {
      case CareStage.floss:
        return 'sela gigi $_flossDone/$_flossTarget';
      case CareStage.brush:
        if (!_pasteAdded) return 'tambahkan pasta ke sikat dulu';
        final zone = _activeZone();
        return 'pola $_zonesDone/${MouthLayout.zones.length}'
            '${zone == null ? ' • selesai' : ' • ${zone.label}'}';
      case CareStage.tongue:
        return '$_tonguePulls/$tonguePullsNeeded tarikan scraper';
      case CareStage.rinse:
        return 'berkumur ${(_rinseProgress * 100).round()}%';
    }
  }

  Size _toolBox(Size sim) => Size(sim.width * .17, sim.height * .19);
  List<Tool> get _stageTools {
    switch (_stage) {
      case CareStage.floss:
        return [Tool.floss];
      case CareStage.brush:
        return [if (!_pasteAdded) Tool.tube, Tool.brush];
      case CareStage.tongue:
        return [Tool.scraper];
      case CareStage.rinse:
        return [Tool.bottle];
    }
  }

  Offset _topLeft(Tool t, Size sim) {
    final saved = _pos[t];
    if (saved != null) return saved;
    final h = _home[t]!;
    return Offset(h.dx * sim.width, h.dy * sim.height);
  }

  Offset _hot(Tool t, Size sim) {
    final box = _toolBox(sim);
    final tl = _topLeft(t, sim);
    final a = _hotspot[t]!;
    return Offset(
      tl.dx + box.width * (1 + a.x) / 2,
      tl.dy + box.height * (1 + a.y) / 2,
    );
  }

  int _zoneAt(Offset px, Size sim) {
    final p = Offset(px.dx / sim.width, px.dy / sim.height);
    return MouthLayout.zones.indexWhere((z) => z.area.contains(p));
  }

  double _dropRadius(Size sim) => sim.width * .10;
  bool _tubeNearBrush(Size sim) =>
      (_hot(Tool.tube, sim) - _hot(Tool.brush, sim)).distance <
      _dropRadius(sim);

  Widget _simulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sim = Size(constraints.maxWidth, constraints.maxHeight);
        final held = _held;
        final stageTools = _stageTools;
        final tools = [
          for (final t in stageTools)
            if (t != held) t,
          if (held != null && stageTools.contains(held)) held,
        ];
        final showRing = _stage == CareStage.brush && !_pasteAdded;
        final ringNear = showRing && held == Tool.tube && _tubeNearBrush(sim);
        final ringCenter = _hot(Tool.brush, sim);
        final ringR = _dropRadius(sim) * .85;
        return Stack(
          fit: StackFit.expand,
          children: [
            for (final g in _germs) _germWidget(g, sim),
            for (int z = 0; z < MouthLayout.zones.length; z++)
              for (int i = 0; i < MouthLayout.zones[z].spots.length; i++)
                _foamWidget(z, i, sim),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GuidePainter(
                    stage: _stage,
                    gaps: _gaps,
                    zone: (_stage == CareStage.brush && _pasteAdded)
                        ? _activeZone()
                        : null,
                    debugHotspots: MouthLayout.debug
                        ? [for (final t in stageTools) _hot(t, sim)]
                        : const [],
                  ),
                ),
              ),
            ),
            if (showRing)
              Positioned(
                left: ringCenter.dx - ringR,
                top: ringCenter.dy - ringR,
                width: ringR * 2,
                height: ringR * 2,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _RingPainter(
                      ringNear
                          ? const Color(0xFF43A047)
                          : const Color(0xFFFFC107),
                    ),
                  ),
                ),
              ),
            Positioned(left: 12, right: 12, bottom: 8, child: _toolBar()),
            for (final t in tools) _toolWidget(t, sim),
            Positioned(
              right: 16,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .93),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8ED0FF), width: 2),
                ),
                child: Text(
                  'Level 3 • ${_completed.length}/4 tahap',
                  style: const TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _germWidget(_Germ g, Size sim) {
    final alive = _germAlive(g);
    final s = sim.width * .045;
    return Positioned(
      left: g.pos.dx * sim.width - s / 2,
      top: g.pos.dy * sim.height - s / 2,
      width: s,
      height: s,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: alive ? 1 : 0,
          duration: const Duration(milliseconds: 350),
          child: AnimatedScale(
            scale: alive ? 1 : .2,
            duration: const Duration(milliseconds: 350),
            child: Image.asset(
              MouthLayout.germAssets[g.type],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: g.type == 0
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF8BC34A),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _foamWidget(int z, int i, Size sim) {
    final shown = i < _foamShown(z);
    final spot = MouthLayout.zones[z].spots[i];
    final jx = ((z * 7 + i * 5) % 5 - 2) * .004;
    final jy = ((z * 3 + i * 7) % 5 - 2) * .006;
    final s = sim.width * .06;
    return Positioned(
      left: (spot.dx + jx) * sim.width - s / 2,
      top: (spot.dy + jy) * sim.height - s / 2,
      width: s,
      height: s,
      child: IgnorePointer(
        child: AnimatedScale(
          scale: shown ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Opacity(
            opacity: (1 - _rinseProgress).clamp(0.0, 1.0).toDouble(),
            child: Image.asset(
              'assets/images/assetlevel3/busa.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .9),
                  border: Border.all(color: const Color(0xFF9AD3FF), width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolImage(String asset) {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.touch_app, color: blue, size: 44),
      ),
    );
  }

  Widget _toolContent(Tool t, Size sim, Size box) {
    switch (t) {
      case Tool.floss:
        return _toolImage('assets/images/assetlevel3/floss.png');
      case Tool.tube:
        return _toolImage('assets/images/assetlevel3/pasta_gigi.png');
      case Tool.scraper:
        return _toolImage('assets/images/assetlevel3/scraper.png');
      case Tool.bottle:
        return _toolImage(
          _bottleOpen
              ? 'assets/images/assetlevel3/obat_kumur_buka.png'
              : 'assets/images/assetlevel3/obat_kumur.png',
        );
      case Tool.brush:
        final z = _zoneAt(_hot(Tool.brush, sim), sim);
        final inner =
            z >= 0 && MouthLayout.zones[z].kind == StrokeKind.vertical;
        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            _toolImage(
              inner
                  ? 'assets/images/assetlevel3/sikat_bawah.png'
                  : 'assets/images/assetlevel3/sikat_depan.png',
            ),
            if (_pasteAdded)
              Align(
                alignment: _pasteOnBrush,
                child: SizedBox(
                  width: box.width * .34,
                  child: Image.asset(
                    'assets/images/assetlevel3/pasta_biji_jagung.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      height: box.height * .18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3198F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
    }
  }

  Widget _toolWidget(Tool t, Size sim) {
    final box = _toolBox(sim);
    final tl = _topLeft(t, sim);
    return Positioned(
      key: ValueKey(t),
      left: tl.dx,
      top: tl.dy,
      width: box.width,
      height: box.height,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => _toolDown(t, e.pointer, sim),
        onPointerMove: (e) => _toolMove(t, e.pointer, e.delta, sim),
        onPointerUp: (e) => _toolUp(t, e.pointer, sim),
        onPointerCancel: (e) => _toolUp(t, e.pointer, sim),
        child: AnimatedScale(
          scale: _held == t ? 1.08 : 1,
          duration: const Duration(milliseconds: 120),
          child: _toolContent(t, sim, box),
        ),
      ),
    );
  }

  void _toolDown(Tool t, int pointer, Size sim) {
    if (_held != null) return;
    setState(() {
      _held = t;
      _heldPointer = pointer;
      _pos[t] = _topLeft(t, sim);
    });
    if (t == Tool.bottle) {
      _openTimer?.cancel();
      _openTimer = Timer(const Duration(milliseconds: 450), () {
        if (!mounted || _held != Tool.bottle) return;
        HapticFeedback.mediumImpact();
        setState(() => _bottleOpen = true);
      });
    }
  }

  void _toolMove(Tool t, int pointer, Offset delta, Size sim) {
    if (_held != t || _heldPointer != pointer) return;
    final box = _toolBox(sim);
    setState(() {
      final prev = _hot(t, sim);
      final old = _topLeft(t, sim);
      _pos[t] = Offset(
        _clampD(old.dx + delta.dx, 0, sim.width - box.width),
        _clampD(old.dy + delta.dy, 0, sim.height - box.height),
      );
      final cur = _hot(t, sim);
      switch (t) {
        case Tool.floss:
          _flossMotion(prev, cur, sim);
          break;
        case Tool.brush:
          _brushMotion(prev, cur, sim);
          break;
        case Tool.scraper:
          _tongueMotion(prev, cur, sim);
          break;
        case Tool.bottle:
          _rinseMotion(prev, cur, sim);
          break;
        case Tool.tube:
          break;
      }
    });
  }

  void _toolUp(Tool t, int pointer, Size sim) {
    if (_held != t || _heldPointer != pointer) return;
    _openTimer?.cancel();
    String? message;
    setState(() {
      if (t == Tool.tube) {
        if (_tubeNearBrush(sim)) {
          _pasteAdded = true;
          message = 'Pas! Pasta gigi sebesar biji jagung sudah ada di sikat.';
          HapticFeedback.lightImpact();
        } else {
          message = 'Dekatkan pasta gigi ke bulu sikat (lingkaran kuning).';
        }
        _pos.remove(Tool.tube);
      }
      if (t == Tool.bottle) _bottleOpen = false;
      _held = null;
      _heldPointer = null;
    });
    final m = message;
    if (m != null) _showMessage(m);
  }

  void _flossMotion(Offset prev, Offset cur, Size s) {
    _Gap? best;
    _GapGeom? bestGeom;
    var bestU = double.infinity;
    for (final g in _gaps) {
      final gg = _gapGeom(g, s);
      final rel = cur - gg.center;
      final u = _dot(rel, gg.across).abs();
      final v = _dot(rel, gg.along).abs();
      if (v > gg.half * 1.4 || u > gg.spacing * .55) continue;
      if (u < bestU) {
        bestU = u;
        best = g;
        bestGeom = gg;
      }
    }
    final gap = best;
    final geom = bestGeom;
    if (gap == null || geom == null || gap.done) return;
    final d = cur - prev;
    final dv = _dot(d, geom.along).abs();
    final du = _dot(d, geom.across).abs();
    if (dv < du * .65) return;
    gap.travel += dv;
    if (gap.travel >= geom.half * 2.6) {
      gap.done = true;
      HapticFeedback.lightImpact();
    }
  }

  void _brushMotion(Offset prev, Offset cur, Size s) {
    if (!_pasteAdded) return;
    final z = _zoneAt(cur, s);
    if (z < 0) return;
    final zone = MouthLayout.zones[z];
    final d = cur - prev;
    final amount = switch (zone.kind) {
      StrokeKind.circle => d.distance,
      StrokeKind.vertical => d.dy.abs(),
      StrokeKind.horizontal => d.dx.abs(),
    };
    final before = _zoneProgress[z];
    if (before >= 1) return;
    final after = math.min(1.0, before + amount / (zone.need * s.height));
    _zoneProgress[z] = after;
    if (after >= 1) HapticFeedback.lightImpact();
  }

  void _tongueMotion(Offset prev, Offset cur, Size s) {
    final p = Offset(cur.dx / s.width, cur.dy / s.height);
    if (!MouthLayout.tongueArea.contains(p)) return;
    final d = cur - prev;
    if (d.dy <= 0 || d.dy < d.dx.abs() * .5) return;
    _tonguePull += d.dy;
    if (_tonguePull >= s.height * .15 && _tonguePulls < tonguePullsNeeded) {
      _tonguePull = 0;
      _tonguePulls++;
      HapticFeedback.lightImpact();
    }
  }

  void _rinseMotion(Offset prev, Offset cur, Size s) {
    if (!_bottleOpen) return;
    final p = Offset(cur.dx / s.width, cur.dy / s.height);
    if (!MouthLayout.mouthArea.contains(p)) return;
    _rinseProgress = math.min(
      1.0,
      _rinseProgress + (cur - prev).distance / (2.2 * s.height),
    );
  }

  Widget _toolBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8ED0FF), width: 3),
      ),
      child: Row(
        children: CareStage.values.map((s) {
          final enabled = s == _stage || _completed.contains(s);
          final done = _completed.contains(s);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: enabled ? 1 : .38,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 3,
                  ),
                  decoration: BoxDecoration(
                    color: s == _stage
                        ? const Color(0xFFDDF0FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: s == _stage
                        ? Border.all(color: blue, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        done ? Icons.check_circle : _iconFor(s),
                        color: done
                            ? Colors.green
                            : (enabled ? blue : Colors.grey),
                        size: 25,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: enabled ? darkBlue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(CareStage s) {
    switch (s) {
      case CareStage.floss:
        return Icons.linear_scale;
      case CareStage.brush:
        return Icons.cleaning_services;
      case CareStage.tongue:
        return Icons.sanitizer_outlined;
      case CareStage.rinse:
        return Icons.local_drink_outlined;
    }
  }
}

void _dashPath(
  Canvas canvas,
  Path path,
  Paint paint, {
  double dash = 9,
  double gap = 7,
}) {
  for (final m in path.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      final end = math.min(d + dash, m.length);
      canvas.drawPath(m.extractPath(d, end), paint);
      d += dash + gap;
    }
  }
}

void _arrowHead(Canvas canvas, Offset tip, Offset dir, Paint paint) {
  const l = 9.0;
  final n = Offset(-dir.dy, dir.dx);
  canvas.drawLine(tip, tip - dir * l + n * l * .55, paint);
  canvas.drawLine(tip, tip - dir * l - n * l * .55, paint);
}

class _GuidePainter extends CustomPainter {
  final CareStage stage;
  final List<_Gap> gaps;
  final _BrushZone? zone;
  final List<Offset> debugHotspots;
  const _GuidePainter({
    required this.stage,
    required this.gaps,
    required this.zone,
    required this.debugHotspots,
  });

  Offset _px(Offset f, Size s) => Offset(f.dx * s.width, f.dy * s.height);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    switch (stage) {
      case CareStage.floss:
        _paintFloss(canvas, size, p);
        break;
      case CareStage.brush:
        final z = zone;
        if (z != null) _paintZone(canvas, size, p, z);
        break;
      case CareStage.tongue:
        final a = _px(MouthLayout.tongueStart, size);
        final b = _px(MouthLayout.tongueEnd, size);
        _dashPath(
          canvas,
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy),
          p,
        );
        _arrowHead(canvas, b, const Offset(0, 1), p);
        break;
      case CareStage.rinse:
        final r = MouthLayout.mouthArea;
        final rect = Rect.fromLTRB(
          r.left * size.width,
          r.top * size.height,
          r.right * size.width,
          r.bottom * size.height,
        );
        _dashPath(canvas, Path()..addOval(rect), p, dash: 10, gap: 9);
        break;
    }
    if (MouthLayout.debug) _paintDebug(canvas, size);
  }

  void _paintFloss(Canvas canvas, Size size, Paint p) {
    for (final g in gaps) {
      final gg = _gapGeom(g, size);
      if (g.done) {
        canvas.drawCircle(
          gg.center,
          6,
          Paint()..color = const Color(0xFF43A047),
        );
        final chk = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          gg.center + const Offset(-2.6, .2),
          gg.center + const Offset(-.8, 2.2),
          chk,
        );
        canvas.drawLine(
          gg.center + const Offset(-.8, 2.2),
          gg.center + const Offset(3, -2.2),
          chk,
        );
        continue;
      }
      final a = gg.center - gg.along * gg.half;
      final b = gg.center + gg.along * gg.half;
      _dashPath(
        canvas,
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy),
        p,
        dash: 5,
        gap: 4,
      );
    }
  }

  void _paintZone(Canvas canvas, Size size, Paint p, _BrushZone z) {
    final r = Rect.fromLTRB(
      z.area.left * size.width,
      z.area.top * size.height,
      z.area.right * size.width,
      z.area.bottom * size.height,
    );
    switch (z.kind) {
      case StrokeKind.circle:
        var cx = 0.0, cy = 0.0;
        for (final s in z.spots) {
          cx += s.dx;
          cy += s.dy;
        }
        final c = Offset(
          cx / z.spots.length * size.width,
          cy / z.spots.length * size.height,
        );
        final oval = Rect.fromCenter(
          center: c,
          width: r.width * .85,
          height: r.height * .75,
        );
        _dashPath(canvas, Path()..addOval(oval), p);
        break;
      case StrokeKind.vertical:
        final x = r.center.dx;
        final a = Offset(x, r.top + r.height * .1);
        final b = Offset(x, r.bottom - r.height * .1);
        _dashPath(
          canvas,
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy),
          p,
        );
        _arrowHead(canvas, b, const Offset(0, 1), p);
        break;
      case StrokeKind.horizontal:
        final yUp = (z.spots[0].dy + z.spots[2].dy) / 2 * size.height;
        final yDn = (z.spots[1].dy + z.spots[3].dy) / 2 * size.height;
        for (final y in [yUp, yDn]) {
          final a = Offset(r.left, y);
          final b = Offset(r.right, y);
          _dashPath(
            canvas,
            Path()
              ..moveTo(a.dx, a.dy)
              ..lineTo(b.dx, b.dy),
            p,
            dash: 7,
            gap: 5,
          );
          _arrowHead(canvas, a, const Offset(-1, 0), p);
          _arrowHead(canvas, b, const Offset(1, 0), p);
        }
        break;
    }
  }

  void _paintDebug(Canvas canvas, Size size) {
    final red = Paint()..color = const Color(0xFFE53935);
    final green = Paint()
      ..color = const Color(0xFF43A047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final purple = Paint()
      ..color = const Color(0xFF8E24AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final blueP = Paint()
      ..color = const Color(0xFF1E88E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final t in [...MouthLayout.upperTeeth, ...MouthLayout.lowerTeeth]) {
      canvas.drawCircle(_px(t, size), 2.5, red);
    }
    for (final z in MouthLayout.zones) {
      canvas.drawRect(
        Rect.fromLTRB(
          z.area.left * size.width,
          z.area.top * size.height,
          z.area.right * size.width,
          z.area.bottom * size.height,
        ),
        green,
      );
    }
    for (final r in [MouthLayout.mouthArea, MouthLayout.tongueArea]) {
      canvas.drawRect(
        Rect.fromLTRB(
          r.left * size.width,
          r.top * size.height,
          r.right * size.width,
          r.bottom * size.height,
        ),
        purple,
      );
    }
    for (final g in gaps) {
      final gg = _gapGeom(g, size);
      canvas.drawLine(
        gg.center - gg.along * gg.half,
        gg.center + gg.along * gg.half,
        blueP,
      );
    }
    for (final h in debugHotspots) {
      canvas.drawCircle(h, 5, Paint()..color = const Color(0xFFFF6F00));
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter oldDelegate) => true;
}

class _RingPainter extends CustomPainter {
  final Color color;
  const _RingPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    _dashPath(canvas, Path()..addOval(Offset.zero & size), p, dash: 8, gap: 6);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BathroomBackground extends StatelessWidget {
  const _BathroomBackground();
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDFF4FF), Color(0xFF9DD9F5), Color(0xFFF5EBDD)],
            ),
          ),
        ),
        CustomPaint(painter: _TilePainter()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 90,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEDE5D9), Color(0xFFD9D1C4)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB6E1F5)
      ..strokeWidth = 1;
    const tileW = 90.0;
    const tileH = 65.0;
    for (double x = 0; x < size.width; x += tileW) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += tileH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Tampilan Selesai (Menggunakan winlevel3.png & Gaya Level 1)
// ---------------------------------------------------------------------------

class FinishedView extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onContinue;

  const FinishedView({
    super.key,
    required this.onRestart,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background kemenangan Level 3
        Positioned.fill(
          child: Image.asset(
            'assets/images/assetlevel3/winlevel3.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: const Color(0xFFE7F4FF),
                alignment: Alignment.center,
                child: const Text(
                  'LEVEL 3 SELESAI!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF24538F),
                  ),
                ),
              );
            },
          ),
        ),

        // Tombol Lanjut mengikuti desain Level 1
        Positioned(
          left: 0,
          right: 0,
          bottom: screenSize.height * 0.035,
          child: Center(
            child: SizedBox(
              width: screenSize.width * 0.18,
              height: screenSize.height * 0.09,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF42BDE3),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onPressed: onContinue,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Lanjut',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
