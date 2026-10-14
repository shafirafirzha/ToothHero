import 'package:flutter/material.dart';

class TentangScreen extends StatelessWidget {
  final VoidCallback onClose;

  const TentangScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // UKURAN GAMBAR TENTANG
    final double imageWidth = size.width * 0.94;
    final double imageHeight = imageWidth * 9 / 16;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.black.withValues(alpha: 0.40),
        alignment: Alignment.center,
        child: SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: Stack(
            children: [
              // ==========================================
              // GAMBAR ISI TENTANG
              // ==========================================

              Positioned.fill(
                child: Image.asset(
                  'assets/images/isi tentang.png',
                  fit: BoxFit.contain,
                ),
              ),

              // ==========================================
              // TOMBOL KEMBALI DI POJOK KANAN ATAS
              // ==========================================
              Positioned(
                right: imageWidth * 0.035,
                top: imageHeight * 0.085,
                width: imageWidth * 0.045,
                height: imageHeight * 0.09,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClose,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Image.asset(
                      'assets/images/back rev.png',
                      fit: BoxFit.contain,
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
