import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_progress.dart';

class Level5Page extends StatefulWidget {
  const Level5Page({super.key});

  @override
  State<Level5Page> createState() => _Level5PageState();
}

class _Level5PageState extends State<Level5Page> {
  int currentQuestion = 0;
  int? selectedAnswer;
  int score = 0;

  final Color navy = const Color(0xFF304F9E);
  final Color borderBlue = const Color(0xFFC8E0F8);
  final Color correctGreen = const Color(0xFF32DF27);
  final Color wrongRed = const Color(0xFFF52228);

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Kapan waktu yang paling penting untuk menyikat gigi?',
      'answers': [
        'A. Setelah sarapan & sebelum tidur',
        'B. Sebelum sarapan & setelah makan',
        'C. Setelah makan & sebelum mandi',
        'D. Hanya saat gigi terasa kotor',
      ],
      'correct': 0,
    },
    {
      'question': 'Tuti suka makan permen, cokelat, dan es krim. Apa risiko jika ia sering mengonsumsi makanan manis?',
      'answers': [
        'A. Gigi menjadi lebih kuat',
        'B. Gigi menjadi lebih putih',
        'C. Risiko gigi berlubang meningkat',
        'D. Gigi tidak perlu disikat lagi',
      ],
      'correct': 2,
    },
    {
      'question': 'Berapa kali sebaiknya kita menyikat gigi setiap hari?',
      'answers': [
        'A. Satu kali sehari',
        'B. Hanya saat gigi terasa kotor',
        'C. Tiga kali sehari',
        'D. Dua kali sehari',
      ],
      'correct': 3,
    },
    {
      'question': 'Apa cara paling ampuh untuk membersihkan plak pada gigi?',
      'answers': [
        'A. Berkumur pakai air teh manis',
        'B. Menyikat gigi teratur & bersih',
        'C. Mengerok gigi pakai kuku',
        'D. Dibiarkan saja nanti hilang',
      ],
      'correct': 1,
    },
    {
      'question': 'Mengapa kita perlu membatasi konsumsi makanan manis dan lengket, seperti permen dan cokelat?',
      'answers': [
        'A. Menempel & picu gigi berlubang',
        'B. Buat gigi langsung rusak',
        'C. Buat gigi jadi lebih kuat',
        'D. Tidak boleh dimakan sama sekali',
      ],
      'correct': 0,
    },
  ];

  // Semua tulisan menggunakan Fredoka.
  TextStyle fredoka({
    Color color = const Color(0xFF304F9E),
    double size = 14,
    FontWeight weight = FontWeight.normal,
  }) {
    return GoogleFonts.fredoka(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showPanduanDialog();
      }
    });
  }

  // POPUP PANDUAN
  void _showPanduanDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.asset(
              'assets/images/assetlevel5/popup_panduan.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Siap bermain kuis kesehatan gigi?',
                  textAlign: TextAlign.center,
                  style: fredoka(size: 22, weight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2B48C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Mulai',
                  style: fredoka(
                    color: Colors.white,
                    size: 16,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POPUP KUIS SELESAI
  void _showSelesaiDialog() {
    final int totalQuestions = questions.length;
    final int wrongAnswers = totalQuestions - score;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/assetlevel5/popup_selesai.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 360,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'KUIS SELESAI!',
                  style: fredoka(size: 28, weight: FontWeight.bold),
                ),
              ),
            ),

            // SKOR BENAR DAN SALAH
            Positioned(
              bottom: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderBlue, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Benar: $score',
                      style: fredoka(
                        color: correctGreen,
                        size: 16,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Salah: $wrongAnswers',
                      style: fredoka(
                        color: wrongRed,
                        size: 16,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TOMBOL SELESAI DAN UPDATE PROGRES
            Positioned(
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: () {
                  // Tutup popup terlebih dahulu.
                  Navigator.pop(dialogContext);

                  // Tandai seluruh 5 level sudah selesai.
                  // Menu menghitung progres dari unlockedLevel - 1.
                  if (unlockedLevelNotifier.value < 6) {
                    unlockedLevelNotifier.value = 6;
                  }

                  // Kembali ke menu pemilihan level.
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2B48C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Selesai',
                  style: fredoka(
                    color: Colors.white,
                    size: 16,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MEMILIH JAWABAN
  void selectAnswer(int index) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = index;

      if (index == questions[currentQuestion]['correct']) {
        score++;
      }
    });
  }

  // PINDAH KE PERTANYAAN BERIKUTNYA
  void nextQuestion() {
    if (selectedAnswer == null) return;

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      _showSelesaiDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    final answers = question['answers'] as List<String>;
    final correctIndex = question['correct'] as int;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.fredokaTextTheme(Theme.of(context).textTheme),
        primaryTextTheme: GoogleFonts.fredokaTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/assetlevel5/bg kamar mandi.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // HEADER LEVEL 5
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE96B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFC94A),
                          width: 3,
                        ),
                      ),
                      child: Text(
                        'Level 5',
                        style: fredoka(
                          color: navy,
                          size: 22,
                          weight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                // CARD PERTANYAAN
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.58,
                    margin: const EdgeInsets.only(top: 40, bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFAED6FF),
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          question['question'] as String,
                          textAlign: TextAlign.center,
                          style: fredoka(
                            color: navy,
                            size: 13,
                            weight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // GRID JAWABAN 2 X 2
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: answers.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.8,
                              ),
                          itemBuilder: (context, index) {
                            Color background = Colors.white;
                            Color border = borderBlue;
                            Color textColor = navy;

                            if (selectedAnswer == index) {
                              if (index == correctIndex) {
                                background = correctGreen;
                                border = correctGreen;
                              } else {
                                background = wrongRed;
                                border = wrongRed;
                              }

                              textColor = Colors.white;
                            }

                            return GestureDetector(
                              onTap: () => selectAnswer(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: border, width: 2),
                                ),
                                child: Text(
                                  answers[index],
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: fredoka(
                                    color: textColor,
                                    size: 11,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // TOMBOL NEXT / SELESAI
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: selectedAnswer == null ? null : nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE52E),
                        foregroundColor: navy,
                        disabledBackgroundColor: const Color(0xFFCCCCCC),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentQuestion < questions.length - 1
                            ? 'Next >'
                            : 'Selesai >',
                        style: fredoka(
                          color: navy,
                          size: 14,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
