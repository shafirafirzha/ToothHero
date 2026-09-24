import 'dart:math' as math;

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double soundVolume = 0.8;
  double musicVolume = 0.4;

  static const Color panelColor = Color(0xFFFFE96B);
  static const Color blueColor = Color(0xFF78B5E8);
  static const Color darkBlueColor = Color(0xFF287BA8);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Ukuran panel menyesuaikan layar.
    final double panelWidth = math.min(size.width * 0.38, 620.0);

    final double safePanelWidth = math.max(
      math.min(panelWidth, size.width * 0.86),
      280.0,
    );

    final double panelHeight = math.min(size.height * 0.70, 620.0);

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================
          // 1. BACKGROUND
          // ==================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==================================================
          // 2. PANEL DAN JUDUL SETTINGS
          // ==================================================
          Center(
            child: SizedBox(
              width: safePanelWidth,
              height: panelHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ==================================================
                  // PANEL KUNING
                  // ==================================================

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: safePanelWidth * 0.09,
                          right: safePanelWidth * 0.09,
                          top: 58,
                          bottom: 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ==================================================
                            // 3. SLIDER SOUND
                            // ==================================================

                            _buildVolumeRow(
                              icon: Icons.volume_up,
                              value: soundVolume,
                              onChanged: (value) {
                                setState(() {
                                  soundVolume = value;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            // ==================================================
                            // 4. SLIDER MUSIC
                            // ==================================================
                            _buildVolumeRow(
                              icon: Icons.music_note,
                              value: musicVolume,
                              onChanged: (value) {
                                setState(() {
                                  musicVolume = value;
                                });
                              },
                            ),

                            const SizedBox(height: 26),

                            // ==================================================
                            // 5. TOMBOL ABOUT
                            // ==================================================
                            _buildActionButton(
                              text: 'about',
                              onPressed: _showAboutDialog,
                            ),

                            const SizedBox(height: 18),

                            // ==================================================
                            // 6. TOMBOL BACK
                            // ==================================================
                            _buildActionButton(
                              text: 'back',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // 7. JUDUL SETTINGS
                  // ==================================================
                  Positioned(
                    top: -26,
                    left: safePanelWidth * 0.20,
                    right: safePanelWidth * 0.20,
                    child: Container(
                      height: 66,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'SETTINGS',
                          style: TextStyle(
                            fontSize: math.max(
                              16,
                              math.min(size.width * 0.022, 30),
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  // ==========================================================
  // WIDGET SLIDER SUARA DAN MUSIK
  // ==========================================================

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

  // ==========================================================
  // WIDGET TOMBOL ABOUT DAN BACK
  // ==========================================================

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 190,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: blueColor,
          elevation: 4,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ABOUT DIALOG
  // ==========================================================

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('About Tooth Hero'),
          content: const Text(
            'Tooth Hero adalah game edukasi '
            'tentang kesehatan gigi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
