import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_progress.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const ToothHeroApp());
}

class ToothHeroApp extends StatelessWidget {
  const ToothHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tooth Hero',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF55C7E8)),
        useMaterial3: true,
      ),
      home: const ToothHeroGame(),
    );
  }
}

class ToothItem {
  final String id;
  final String name;
  final String image;
  final String function;
  final String usage;

  const ToothItem({
    required this.id,
    required this.name,
    required this.image,
    required this.function,
    required this.usage,
  });
}

class ToothHeroGame extends StatefulWidget {
  const ToothHeroGame({super.key});

  @override
  State<ToothHeroGame> createState() => _ToothHeroGameState();
}

class _ToothHeroGameState extends State<ToothHeroGame> {
  final String _introText =
      'Hai, Hero! Yuk kenali alat-alat untuk menjaga kesehatan gigi!';

  String _typedText = '';
  bool _showBubble = false;

  final Set<String> _foundItems = {};

  bool _finishDialogShown = false;

  Timer? _typingTimer;
  Timer? _bubbleTimer;

  final List<ToothItem> _items = const [
    ToothItem(
      id: 'toothpaste',
      name: 'Pasta Gigi',
      image: 'assets/images/assetlevel1/toothpaste.png',
      function: 'Membantu membersihkan gigi. Pasta gigi berfluorida juga membantu melindungi gigi dari gigi berlubang.',
      usage: 'Gunakan pasta gigi secukupnya pada sikat gigi, lalu sikat seluruh permukaan gigi dengan lembut.',
    ),
    ToothItem(
      id: 'toothbrush',
      name: 'Sikat Gigi',
      image: 'assets/images/assetlevel1/toothbrush.png',
      function:
          'Membantu membersihkan plak dan sisa makanan dari permukaan gigi.',
      usage:
          'Sikat gigi dengan lembut selama sekitar dua menit, dua kali sehari.',
    ),
    ToothItem(
      id: 'mouthwash',
      name: 'Obat Kumur',
      image: 'assets/images/assetlevel1/mouthwash.png',
      function: 'Membantu menjaga kebersihan mulut. Jenis tertentu dapat membantu mengurangi plak atau melindungi gigi.',
      usage: 'Gunakan sesuai petunjuk pada kemasan. Obat kumur bukan pengganti sikat gigi dan floss.',
    ),
    ToothItem(
      id: 'floss',
      name: 'Benang Gigi (Dental Floss)',
      image: 'assets/images/assetlevel1/dental_floss.png',
      function: 'Membersihkan sisa makanan dan plak di sela-sela gigi yang sulit dijangkau sikat gigi.',
      usage: 'Masukkan benang secara perlahan di sela gigi, lalu gerakkan lembut mengikuti sisi gigi. Jangan menghentak gusi.',
    ),
    ToothItem(
      id: 'tongue_scraper',
      name: 'Pembersih Lidah (Tongue Scraper)',
      image: 'assets/images/assetlevel1/tongue_scraper.png',
      function: 'Membantu mengangkat lapisan kotoran pada permukaan lidah.',
      usage: 'Gerakkan alat secara perlahan dari bagian belakang lidah ke arah depan, tanpa menekan terlalu kuat. Bersihkan alat setelah digunakan.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startIntro();
    });
  }

  void _startIntro() {
    if (!mounted) return;

    _typingTimer?.cancel();
    _bubbleTimer?.cancel();

    setState(() {
      _showBubble = true;
      _typedText = '';
    });

    int index = 0;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 38), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (index >= _introText.length) {
        timer.cancel();

        _bubbleTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;

          setState(() {
            _showBubble = false;
          });
        });

        return;
      }

      setState(() {
        index++;
        _typedText = _introText.substring(0, index);
      });
    });
  }

  void _showTemporaryBubble(String message, {int seconds = 4}) {
    _typingTimer?.cancel();
    _bubbleTimer?.cancel();

    setState(() {
      _showBubble = true;
      _typedText = message;
    });

    _bubbleTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted) return;

      setState(() {
        _showBubble = false;
      });
    });
  }

  void _onItemTapped(ToothItem item) {
    _typingTimer?.cancel();
    _bubbleTimer?.cancel();

    setState(() {
      _showBubble = false;
      _foundItems.add(item.id);
    });

    SystemSound.play(SystemSoundType.click);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final screenHeight = MediaQuery.of(dialogContext).size.height;

        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: 460,
            height: screenHeight * 0.88,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDEBF8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF168DB7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    flex: 4,
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.cleaning_services,
                          size: 54,
                          color: Color(0xFF55C7E8),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    flex: 5,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 12, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoSection(
                              title: 'Fungsinya',
                              description: item.function,
                            ),
                            const SizedBox(height: 12),
                            _infoSection(
                              title: 'Cara Menggunakan',
                              description: item.usage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF42BDE3),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'Mengerti!',
                        style: GoogleFonts.fredoka(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (!mounted) return;

      if (_foundItems.length == _items.length) {
        _showFinishDialog();
      } else {
        _showEncouragement();
      }
    });
  }

  Widget _infoSection({required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF168DB7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          softWrap: true,
          style: GoogleFonts.fredoka(
            fontSize: 12,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  void _showEncouragement() {
    final message =
        'Hebat! Kamu sudah menemukan ${_foundItems.length} dari 5 barang. Ayo cari yang lain!';

    _showTemporaryBubble(message, seconds: 4);
    SystemSound.play(SystemSoundType.click);
  }

  // Layar kemenangan: menutupi seluruh layar aplikasi.
  void _showFinishDialog() {
    if (!mounted || _finishDialogShown) return;

    _finishDialogShown = true;
    _typingTimer?.cancel();
    _bubbleTimer?.cancel();

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Level selesai',
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final screenSize = MediaQuery.of(dialogContext).size;

        return Material(
          color: Colors.transparent,
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background kemenangan full screen.
                Positioned.fill(
                  child: ClipRect(
                    child: Transform.scale(
                      scale: 1.04,
                      child: Image.asset(
                        'assets/images/assetlevel1/winlevel1.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        width: screenSize.width,
                        height: screenSize.height,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: const Color(0xFFDDF7FF),
                            alignment: Alignment.center,
                            child: Text(
                              'Gambar winlevel1.png tidak ditemukan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                color: const Color(0xFF168DB7),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Tombol Lanjut.
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
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () {
                          // Tutup layar kemenangan terlebih dahulu.
                          Navigator.of(dialogContext).pop();

                          // Buka Level 2 dan kembali ke menu level.
                          _onContinue();
                        },
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
            ),
          ),
        );
      },
    );
  }

  // Membuka Level 2 dan kembali ke pemilihan level.
  void _onContinue() {
    if (!mounted) return;

    unlockedLevelNotifier.value = 2;

    Navigator.of(context).pop();
  }

  void _restartGame() {
    _typingTimer?.cancel();
    _bubbleTimer?.cancel();

    setState(() {
      _foundItems.clear();
      _finishDialogShown = false;
      _showBubble = false;
      _typedText = '';
    });

    _startIntro();
  }

  Widget _tapTarget({
    required double x,
    required double y,
    required double w,
    required double h,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      width: MediaQuery.of(context).size.width * w,
      height: MediaQuery.of(context).size.height * h,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/assetlevel1/bathroom_bg.png',
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: const Color(0xFFDDF7FF),
                    alignment: Alignment.center,
                    child: Text(
                      'Background tidak ditemukan.\n'
                      'Periksa assets/images/assetlevel1/bathroom_bg.png',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(fontSize: 20),
                    ),
                  );
                },
              ),

              // Area klik pasta gigi.
              _tapTarget(
                x: 0.335,
                y: 0.355,
                w: 0.075,
                h: 0.17,
                onTap: () => _onItemTapped(_items[0]),
              ),

              // Area klik sikat gigi.
              _tapTarget(
                x: 0.515,
                y: 0.345,
                w: 0.075,
                h: 0.18,
                onTap: () => _onItemTapped(_items[1]),
              ),

              // Area klik obat kumur.
              _tapTarget(
                x: 0.625,
                y: 0.145,
                w: 0.075,
                h: 0.15,
                onTap: () => _onItemTapped(_items[2]),
              ),

              // Area klik dental floss.
              _tapTarget(
                x: 0.685,
                y: 0.605,
                w: 0.095,
                h: 0.12,
                onTap: () => _onItemTapped(_items[3]),
              ),

              // Area klik pembersih lidah.
              _tapTarget(
                x: 0.385,
                y: 0.825,
                w: 0.105,
                h: 0.12,
                onTap: () => _onItemTapped(_items[4]),
              ),

              // Area klik barang palsu: vas bunga.
              _tapTarget(
                x: 0.695,
                y: 0.12,
                w: 0.085,
                h: 0.14,
                onTap: _showWrongItemMessage,
              ),

              // Penghitung barang.
              Positioned(
                top: screenHeight * 0.025,
                right: screenWidth * 0.025,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF55C7E8),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Tooth Hero  ${_foundItems.length}/5',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF168DB7),
                    ),
                  ),
                ),
              ),

              // Balon percakapan.
              if (_showBubble)
                Positioned(
                  left: screenWidth * 0.265,
                  top: screenHeight * 0.215,
                  width: screenWidth * 0.40,
                  child: IgnorePointer(child: _SpeechBubble(text: _typedText)),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showWrongItemMessage() {
    const message =
        'Ups, itu vas bunga! Cari alat yang membantu merawat gigi, ya!';

    _showTemporaryBubble(message, seconds: 4);
    SystemSound.play(SystemSoundType.click);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _bubbleTimer?.cancel();
    super.dispose();
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;

  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF55C7E8), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 7,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 17,
              color: const Color(0xFF34495E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: CustomPaint(
            size: const Size(25, 13),
            painter: _BubbleTailPainter(),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF55C7E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(2, 0)
      ..lineTo(size.width * 0.35, size.height)
      ..lineTo(size.width - 2, 0);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
