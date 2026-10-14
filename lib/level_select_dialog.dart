import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_1.dart';
import 'level_2.dart';
import 'level_3.dart';
import 'level_4.dart';
import 'level_5.dart';
import 'level_progress.dart';

class LevelSelectDialog extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<int>? onLevelSelected;

  const LevelSelectDialog({
    super.key,
    required this.onClose,
    this.onLevelSelected,
  });

  static const String bgAsset = 'assets/images/Level/bg level.png';

  static const List<String> levelAssets = [
    'assets/images/Level/level1.png',
    'assets/images/Level/level2.png',
    'assets/images/Level/level3.png',
    'assets/images/Level/level4.png',
    'assets/images/Level/level 5.png',
  ];

  static const List<double> grayscaleMatrix = [
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(35),
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;

            final cardWidth = math.min(sw * 0.155, sh * 0.90);
            final cardHeight = cardWidth / 0.635;
            final gap = sw * 0.025;
            final totalWidth = cardWidth * 5 + gap * 4;
            final startX = (sw - totalWidth) / 2;
            final top = sh * 0.345;

            return Stack(
              fit: StackFit.expand,
              children: [
                // BACKGROUND PEMILIHAN LEVEL
                Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const ColoredBox(color: Color(0xFFFFF3C5));
                  },
                ),

                // KARTU LEVEL 1–5
                ValueListenableBuilder<int>(
                  valueListenable: unlockedLevelNotifier,
                  builder: (context, unlockedLevel, child) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        for (int i = 0; i < levelAssets.length; i++)
                          _buildLevelCard(
                            context: context,
                            screenWidth: sw,
                            screenHeight: sh,
                            left: startX + i * (cardWidth + gap),
                            top: top,
                            width: cardWidth,
                            height: math.min(cardHeight, sh * 0.58),
                            level: i + 1,
                            asset: levelAssets[i],
                            locked: i + 1 > unlockedLevel,
                          ),
                      ],
                    );
                  },
                ),

                // TOMBOL KEMBALI
                Positioned(
                  left: sw * 0.025,
                  top: sh * 0.045,
                  width: sh * 0.105,
                  height: sh * 0.105,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Image.asset(
                        'assets/images/back rev.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.arrow_back_rounded,
                            size: 40,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // INDIKATOR PROGRES LEVEL
                Positioned(
                  top: sh * 0.055,
                  right: sw * 0.035,
                  child: ValueListenableBuilder<int>(
                    valueListenable: unlockedLevelNotifier,
                    builder: (context, unlockedLevel, child) {
                      final completed = (unlockedLevel - 1).clamp(0, 5);

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.014,
                          vertical: sh * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: const Color(0xFF83BCEB),
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFFFB52E),
                              size: sh * 0.055,
                            ),
                            SizedBox(width: sw * 0.004),
                            Text(
                              '$completed/5',
                              style: GoogleFonts.fredoka(
                                fontSize: sh * 0.033,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3686CC),
                              ),
                            ),
                            SizedBox(width: sw * 0.012),
                            Text(
                              'Level Selesai',
                              style: GoogleFonts.fredoka(
                                fontSize: sh * 0.032,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3686CC),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
    required double left,
    required double top,
    required double width,
    required double height,
    required int level,
    required String asset,
    required bool locked,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // GAMBAR KARTU LEVEL
          ColorFiltered(
            colorFilter: locked
                ? const ColorFilter.matrix(grayscaleMatrix)
                : const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
            child: Image.asset(
              asset,
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Text(
                    'Gambar level tidak ditemukan',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),

          // TOMBOL MULAI
          Positioned(
            left: width * 0.19,
            right: width * 0.19,
            bottom: height * 0.035,
            height: height * 0.105,
            child: ElevatedButton(
              onPressed: locked
                  ? null
                  : () {
                      if (level == 1) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ToothHeroGame(),
                          ),
                        );
                      } else if (level == 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Level2Screen(),
                          ),
                        );
                      } else if (level == 3) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Level3Screen(),
                          ),
                        );
                      } else if (level == 4) {
                        // BUKA GAMEPLAY LEVEL 4
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Level4Screen(),
                          ),
                        );
                      } else if (level == 5) {
                        // BUKA GAMEPLAY LEVEL 5
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Level5Page(),
                          ),
                        );
                      } else {
                        onLevelSelected?.call(level);
                      }
                    },
              style: ElevatedButton.styleFrom(
                elevation: locked ? 0 : 2,
                padding: EdgeInsets.zero,
                backgroundColor: locked
                    ? const Color(0xFFD7D7D7)
                    : const Color(0xFFFFDD7D),
                disabledBackgroundColor: const Color(0xFFD7D7D7),
                foregroundColor: locked
                    ? const Color(0xFF777777)
                    : const Color(0xFF3686CC),
                disabledForegroundColor: const Color(0xFF777777),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Mulai',
                  style: GoogleFonts.fredoka(
                    fontSize: screenHeight * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
