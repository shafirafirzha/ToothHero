import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double soundVolume = 0.8;
  double musicVolume = 0.4;

  static const Color blueColor = Color(0xFF78B5E8);

  // FONT FREDOKA
  TextStyle fredoka({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.white,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double panelWidth = math.min(size.width * 0.38, 620.0);

    final double safePanelWidth = math.max(
      math.min(panelWidth, size.width * 0.86),
      280.0,
    );

    final double panelHeight = math.min(size.height * 0.70, 620.0);

    return Scaffold(
      body: Stack(
        children: [
          // ================================================
          // BACKGROUND
          // ================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ================================================
          // TOMBOL KEMBALI DI POJOK KANAN ATAS
          // ================================================
          Positioned(
            top: size.height * 0.035,
            right: size.width * 0.025,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Image.asset(
                  'assets/images/back rev.png',
                  width: size.width * 0.055,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ================================================
          // PANEL SETTINGS
          // ================================================
          Center(
            child: SizedBox(
              width: safePanelWidth,
              height: panelHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ==========================================
                  // PANEL UTAMA
                  // ==========================================

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE96B),
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      // HANYA SLIDER SOUND DAN MUSIC
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: safePanelWidth * 0.09,
                          right: safePanelWidth * 0.09,
                          top: 58,
                          bottom: 28,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // SLIDER SOUND

                            _buildVolumeRow(
                              icon: Icons.volume_up,
                              value: soundVolume,
                              onChanged: (value) {
                                setState(() {
                                  soundVolume = value;
                                });
                              },
                            ),

                            const SizedBox(height: 25),

                            // SLIDER MUSIC
                            _buildVolumeRow(
                              icon: Icons.music_note,
                              value: musicVolume,
                              onChanged: (value) {
                                setState(() {
                                  musicVolume = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==========================================
                  // JUDUL PENGATURAN DARI ASSET
                  // ==========================================
                  Positioned(
                    top: -26,
                    left: safePanelWidth * 0.20,
                    right: safePanelWidth * 0.20,
                    child: Image.asset(
                      'assets/images/pengaturan.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // SLIDER SOUND DAN MUSIC
  // ========================================================

  Widget _buildVolumeRow({
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: blueColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 35),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white,
              thumbColor: blueColor,
              overlayColor: Colors.transparent,
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 19),
            ),
            child: Slider(value: value, min: 0, max: 1, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}
