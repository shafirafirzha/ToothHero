import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_progress.dart';

class FoodCard {
  final String id;
  final String name;
  final String image;
  final bool healthy;

  const FoodCard({
    required this.id,
    required this.name,
    required this.image,
    required this.healthy,
  });
}

class Level2Screen extends StatefulWidget {
  const Level2Screen({super.key});

  @override
  State<Level2Screen> createState() => _Level2ScreenState();
}

class _Level2ScreenState extends State<Level2Screen> {
  static const String _assetFolder = 'assets/images/assetlevel2/';

  final List<FoodCard> _foods = const [
    FoodCard(
      id: 'wortel',
      name: 'Wortel',
      image: '${_assetFolder}kartu wortel.png',
      healthy: true,
    ),
    FoodCard(
      id: 'permen',
      name: 'Permen',
      image: '${_assetFolder}kartu permen.png',
      healthy: false,
    ),
    FoodCard(
      id: 'snack',
      name: 'Snack',
      image: '${_assetFolder}kartu snack.png',
      healthy: false,
    ),
    FoodCard(
      id: 'air',
      name: 'Air Putih',
      image: '${_assetFolder}kartu air.png',
      healthy: true,
    ),
    FoodCard(
      id: 'jelly',
      name: 'Jelly',
      image: '${_assetFolder}kartu jelly.png',
      healthy: false,
    ),
    FoodCard(
      id: 'apel',
      name: 'Apel',
      image: '${_assetFolder}kartu apel.png',
      healthy: true,
    ),
    FoodCard(
      id: 'brokoli',
      name: 'Brokoli',
      image: '${_assetFolder}kartu brokoli.png',
      healthy: true,
    ),
    FoodCard(
      id: 'eskrim',
      name: 'Es Krim',
      image: '${_assetFolder}kartu eskrim.png',
      healthy: false,
    ),
    FoodCard(
      id: 'kue',
      name: 'Kue',
      image: '${_assetFolder}kartu kue.png',
      healthy: false,
    ),
    FoodCard(
      id: 'pisang',
      name: 'Pisang',
      image: '${_assetFolder}kartu pisang.png',
      healthy: true,
    ),
  ];

  final Set<String> _answered = <String>{};
  final List<FoodCard> _healthyFoods = [];
  final List<FoodCard> _limitedFoods = [];

  String _message = 'Yuk, pilih makanan dan minuman yang baik untuk gigi!';

  bool _finished = false;
  bool _lastAnswerCorrect = true;

  int get _progress => _answered.length;

  void _dropFood(FoodCard food, bool targetHealthy) {
    if (_answered.contains(food.id) || _finished) return;

    if (food.healthy != targetHealthy) {
      SystemSound.play(SystemSoundType.alert);

      setState(() {
        _lastAnswerCorrect = false;
        _message = 'Belum tepat! Coba lagi, ya.';
      });

      return;
    }

    SystemSound.play(SystemSoundType.click);

    setState(() {
      _answered.add(food.id);

      if (targetHealthy) {
        _healthyFoods.add(food);
      } else {
        _limitedFoods.add(food);
      }

      _lastAnswerCorrect = true;
      _message = 'Hebat! Jawaban kamu benar!';
    });

    if (_answered.length == _foods.length) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        setState(() {
          _finished = true;
        });
      });
    }
  }

  void _continueAfterWin() {
    // Buka Level 3. Level 3 tetap perlu dibuat di project.
    if (unlockedLevelNotifier.value < 3) {
      unlockedLevelNotifier.value = 3;
    }

    // Kembali ke dialog pemilihan level.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          // Kartu awal sedikit lebih besar dari versi sebelumnya.
          final double cardWidth = math.min(w * 0.075, h * 0.16);
          final double cardHeight = h * 0.16;

          return Stack(
            fit: StackFit.expand,
            children: [
              // BACKGROUND LEVEL 2
              Image.asset(
                '${_assetFolder}bglevel2.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: Color(0xFFFFEEDB),
                    child: Center(
                      child: Text('Background Level 2 tidak ditemukan.'),
                    ),
                  );
                },
              ),

              // KOTAK MAKANAN RAMAH GIGI
              Positioned(
                left: w * 0.305,
                top: h * 0.425,
                width: w * 0.225,
                height: h * 0.245,
                child: _buildDropPanel(
                  foods: _healthyFoods,
                  targetHealthy: true,
                ),
              ),

              // KOTAK MAKANAN YANG PERLU DIBATASI
              Positioned(
                left: w * 0.575,
                top: h * 0.425,
                width: w * 0.225,
                height: h * 0.245,
                child: _buildDropPanel(
                  foods: _limitedFoods,
                  targetHealthy: false,
                ),
              ),

              // POP-UP BUBBLE
              // Dibuat langsung di Flutter agar teks selalu sinkron.
              if (!_finished)
                Positioned(
                  left: w * 0.115,
                  top: h * 0.115,
                  width: w * 0.205,
                  height: h * 0.155,
                  child: _buildSpeechBubble(w, h),
                ),

              // SKOR
              Positioned(
                top: h * 0.025,
                right: w * 0.025,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.012,
                    vertical: h * 0.009,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.97),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFFC343),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: const Color(0xFFFFBF32),
                        size: h * 0.05,
                      ),
                      SizedBox(width: w * 0.004),
                      Text(
                        '$_progress/10',
                        style: GoogleFonts.fredoka(
                          fontSize: (w * 0.015).clamp(14.0, 24.0),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF315B91),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // KARTU YANG BELUM DI-DRAG
              if (!_finished)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: h * 0.055,
                  height: cardHeight,
                  child: _buildRemainingCards(
                    screenWidth: w,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                ),

              // LAYAR MENANG
              if (_finished)
                Positioned.fill(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        '${_assetFolder}winlevel2.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(
                            color: Color(0xFFFFEEDB),
                            child: Center(
                              child: Text(
                                'Level 2 Selesai!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF315B91),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: h * 0.075,
                        child: Center(
                          child: SizedBox(
                            width: math.min(w * 0.23, 260.0),
                            height: math.min(h * 0.09, 65.0),
                            child: FilledButton(
                              onPressed: _continueAfterWin,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF42BDE3),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Lanjut',
                                style: GoogleFonts.fredoka(
                                  fontSize: (w * 0.02).clamp(16.0, 27.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // BUBBLE POP-UP DENGAN TEKS DI TENGAH
  Widget _buildSpeechBubble(double w, double h) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Ekor bubble
        Positioned(
          bottom: h * 0.002,
          right: w * 0.045,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: w * 0.027,
              height: w * 0.027,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF315B91).withOpacity(0.10),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Badan bubble
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: h * 0.018,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.012,
              vertical: h * 0.012,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _lastAnswerCorrect
                    ? const Color(0xFFF7F0E8)
                    : const Color(0xFFFFD8C8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF315B91).withOpacity(0.12),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  _message,
                  key: ValueKey<String>(_message),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    color: const Color(0xFF438CC8),
                    fontSize: (w * 0.011).clamp(12.0, 18.0),
                    height: 1.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // KARTU YANG BELUM DIPILIH
  Widget _buildRemainingCards({
    required double screenWidth,
    required double cardWidth,
    required double cardHeight,
  }) {
    final List<FoodCard> remaining = _foods
        .where((food) => !_answered.contains(food.id))
        .toList();

    if (remaining.isEmpty) {
      return const SizedBox.shrink();
    }

    final double spacing = math.min(screenWidth * 0.006, 9.0);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: spacing,
          runSpacing: 4,
          children: remaining.map((food) {
            return Draggable<String>(
              data: food.id,
              maxSimultaneousDrags: 1,
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Image.asset(food.image, fit: BoxFit.contain),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.18,
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Image.asset(food.image, fit: BoxFit.contain),
                ),
              ),
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Image.asset(
                  food.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        food.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: const Color(0xFF438CC8),
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // TARGET DROP: KARTU KECIL, TENGAH, DAN TIDAK KELUAR KOTAK
  Widget _buildDropPanel({
    required List<FoodCard> foods,
    required bool targetHealthy,
  }) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        return !_answered.contains(details.data) && !_finished;
      },
      onAcceptWithDetails: (details) {
        final FoodCard food = _foods.firstWhere(
          (item) => item.id == details.data,
        );

        _dropFood(food, targetHealthy);
      },
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const int columns = 5;
            const int rows = 2;

            final double slotWidth = constraints.maxWidth / columns;
            final double slotHeight = constraints.maxHeight / rows;

            final double imageWidth = slotWidth * 0.78;
            final double imageHeight = slotHeight * 0.76;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (int i = 0; i < foods.length; i++)
                  Positioned(
                    left: (i % columns) * slotWidth,
                    top: (i ~/ columns) * slotHeight,
                    width: slotWidth,
                    height: slotHeight,
                    child: Center(
                      child: SizedBox(
                        width: imageWidth,
                        height: imageHeight,
                        child: Image.asset(foods[i].image, fit: BoxFit.contain),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
