import 'package:flutter/material.dart';

class GuidanceDialog extends StatelessWidget {
  final VoidCallback onClose;

  const GuidanceDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final List<Map<String, dynamic>> items = [
      {
        'type': 'single_image',
        'image': 'assets/images/sikatgigi.png',
        'text': 'Temukan sikat gigi untuk menjawab kuis',
      },
      {
        'type': 'single_image',
        'image': 'assets/images/kotak.png',
        'text': 'Temukan hint yang dapat membantu kamu menjawab kuis',
      },
      {
        'type': 'double_image',
        'image1': 'assets/images/enemy1.png',
        'image2': 'assets/images/enemy2.png',
        'text': 'Hindari kuman! Mereka akan mengurangi nyawa kamu.',
      },
      {
        'type': 'icon',
        'text': 'Kumpulkan koin untuk membeli karakter yang menarik',
      },
    ];

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          width: size.width * 0.88,
          height: size.height * 0.82,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE66D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Header "HOW TO PLAY"
              Positioned(
                top: -22,
                left: size.width * 0.28,
                right: size.width * 0.28,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FA8DA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Text(
                    'HOW TO PLAY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Tombol Close "X"
              Positioned(
                top: 8,
                right: 12,
                child: GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF5B69E8),
                    size: 32,
                  ),
                ),
              ),

              // Content: 4 Card Putih
              Padding(
                padding: const EdgeInsets.only(
                  top: 38,
                  left: 14,
                  right: 14,
                  bottom: 14,
                ),
                child: Row(
                  children: items.map((item) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            // Area Gambar Dibuat Lebih Besar & Mengisi Ruang
                            Expanded(
                              child: Center(child: _buildMedia(item, size)),
                            ),

                            const SizedBox(height: 8),

                            // Deskripsi Teks
                            Text(
                              item['text'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(Map<String, dynamic> item, Size size) {
    if (item['type'] == 'single_image') {
      return Image.asset(
        item['image'],
        width: size.width * 0.13,
        height: size.height * 0.32,
        fit: BoxFit.contain,
      );
    } else if (item['type'] == 'double_image') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              item['image1'],
              height: size.height * 0.28,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Image.asset(
              item['image2'],
              height: size.height * 0.28,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    } else {
      // Ikon Koin
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFFFC107),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.monetization_on_rounded,
          color: const Color(0xFFFFE082),
          size: size.height * 0.22,
        ),
      );
    }
  }
}
