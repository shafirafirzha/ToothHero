import 'package:flutter/material.dart';

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
        'A. Setelah sarapan dan sebelum tidur malam',
        'B. Sebelum sarapan dan setelah makan siang',
        'C. Setelah makan siang dan sebelum mandi',
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
        'B. Hanya ketika gigi terasa kotor',
        'C. Tiga kali sehari',
        'D. Dua kali sehari',
      ],
      'correct': 3,
    },
    {
      'question': 'Apa cara paling ampuh untuk membersihkan plak pada gigi?',
      'answers': [
        'A. Berkumur pakai air teh manis',
        'B. Menyikat gigi sampai bersih dan teratur',
        'C. Mengerok gigi pakai kuku',
        'D. Dibiarkan saja nanti hilang sendiri',
      ],
      'correct': 1,
    },
    {
      'question': 'Mengapa kita perlu membatasi konsumsi makanan manis dan lengket, seperti permen dan cokelat?',
      'answers': [
        'A. Karena makanan tersebut bisa menempel pada gigi dan meningkatkan risiko gigi berlubang.',
        'B. Karena semua makanan manis membuat gigi langsung rusak.',
        'C. Karena makanan lengket membuat gigi menjadi lebih kuat.',
        'D. Karena makanan manis tidak boleh dimakan sama sekali.',
      ],
      'correct': 0,
    },
  ];

  void selectAnswer(int index) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = index;

      if (index == questions[currentQuestion]['correct']) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (selectedAnswer == null) return;

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Level 5 Selesai!'),
          content: Text('Skor kamu: $score dari ${questions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  currentQuestion = 0;
                  selectedAnswer = null;
                  score = 0;
                });
              },
              child: const Text('Ulangi'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    final answers = question['answers'] as List<String>;
    final correctIndex = question['correct'] as int;

    return Scaffold(
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
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Judul level
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE96B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFC94A), width: 4),
                ),
                child: Text(
                  'Level 5',
                  style: TextStyle(
                    color: navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Soal ${currentQuestion + 1} dari ${questions.length}',
                style: TextStyle(
                  color: navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFAED6FF),
                        width: 4,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          question['question'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: navy,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: answers.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 115,
                              ),
                          itemBuilder: (context, index) {
                            Color background = Colors.white;
                            Color border = borderBlue;
                            Color text = navy;

                            if (selectedAnswer == index) {
                              if (index == correctIndex) {
                                background = correctGreen;
                                border = correctGreen;
                              } else {
                                background = wrongRed;
                                border = wrongRed;
                              }
                              text = Colors.white;
                            }

                            return GestureDetector(
                              onTap: () => selectAnswer(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: border, width: 3),
                                ),
                                child: Text(
                                  answers[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: selectedAnswer == null
                                ? null
                                : nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE52E),
                              foregroundColor: navy,
                              disabledBackgroundColor: const Color(0xFFFFE52E),
                              disabledForegroundColor: navy,
                            ),
                            child: Text(
                              currentQuestion < questions.length - 1
                                  ? 'Next >'
                                  : 'Selesai >',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
