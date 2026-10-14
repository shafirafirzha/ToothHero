import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatefulWidget {
  final Widget nextScreen;

  const LoadingScreen({super.key, required this.nextScreen});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  Timer? navigationTimer;

  @override
  void initState() {
    super.initState();

    // Loading dimulai dari 0% selama 12 detik
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
      value: 0.0,
    );

    animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        navigationTimer = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => widget.nextScreen),
          );
        });
      }
    });

    // Pastikan setiap halaman loading mulai dari nol
    controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    navigationTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Ukuran loading bar
    final barWidth = screenWidth * 0.60;
    const barHeight = 64.0;

    // Ukuran gambar Tuti
    const tutiWidth = 145.0;
    const tutiHeight = 100.0;

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // BACKGROUND
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg load.png',
                fit: BoxFit.cover,
              ),
            ),

            // LOADING BAR
            Center(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final progress = animation.value.clamp(0.0, 1.0);

                  // SATU SUMBER PROGRESS UNTUK SEMUANYA
                  // Ujung kanan kuning bergerak dari 0 sampai barWidth.
                  final yellowWidth = barWidth * progress;

                  // Titik tengah Tuti tepat mengikuti ujung kuning.
                  // Tuti berada di depan bar dan menutupi ujungnya.
                  final tutiLeft = yellowWidth - (tutiWidth / 2);

                  return Transform.translate(
                    offset: const Offset(0, 20),
                    child: SizedBox(
                      width: barWidth,
                      height: 150,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. BAR PUTIH
                          Positioned(
                            top: 18,
                            left: 0,
                            child: Container(
                              width: barWidth,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),

                          // 2. BAR KUNING
                          // Lebarnya memakai progress yang sama
                          // dengan posisi Tuti.
                          Positioned(
                            top: 18,
                            left: 0,
                            child: Container(
                              width: yellowWidth,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE99A),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),

                          // 3. PERSENTASE
                          Positioned(
                            top: 18,
                            left: 0,
                            right: 0,
                            height: barHeight,
                            child: Center(
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: GoogleFonts.fredoka(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5896C8),
                                ),
                              ),
                            ),
                          ),

                          // 4. TUTI
                          // Diletakkan setelah bar agar selalu
                          // tampil di depan ujung warna kuning.
                          Positioned(
                            top: 0,
                            left: tutiLeft,
                            width: tutiWidth,
                            height: tutiHeight,
                            child: Image.asset(
                              'assets/images/tuti.png',
                              width: tutiWidth,
                              height: tutiHeight,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),

                          // 5. TEKS MEMUAT
                          Positioned(
                            top: 98,
                            left: 0,
                            right: 0,
                            child: Text(
                              'Memuat...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
