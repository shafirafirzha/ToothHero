import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'guidance_dialog.dart';
import 'level_select_dialog.dart';
import 'settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const ToothHeroApp());
}

// ============================================================
// TOOTH HERO APP
// ============================================================

class ToothHeroApp extends StatelessWidget {
  const ToothHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToothHero',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Arial'),
      home: const MainMenuScreen(),
    );
  }
}

// ============================================================
// MAIN MENU SCREEN
// ============================================================

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool showSelectLevel = false;
  bool showGuidance = false;

  // ==========================================================
  // EXIT APP
  // ==========================================================

  void _exitApp() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tombol Exit tersedia saat aplikasi dijalankan di perangkat.',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      return;
    }

    SystemNavigator.pop();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================
          // 1. BACKGROUND PENUH
          // ==================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==================================================
          // 2. TOMBOL SETTINGS DAN SHOP
          // ==================================================
          Positioned(
            left: 16,
            top: 16,
            child: Row(
              children: [
                // ==================================================
                // TOMBOL SETTINGS
                // ==================================================

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const SettingsScreen();
                        },
                      ),
                    );
                  },
                  child: _buildTopButton(icon: Icons.settings),
                ),

                const SizedBox(width: 10),

                // ==================================================
                // TOMBOL SHOP
                // ==================================================
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tombol Shop Dipencet!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: _buildTopButton(icon: Icons.store),
                ),
              ],
            ),
          ),

          // ==================================================
          // 3. KARAKTER TUTI
          // ==================================================
          Positioned(
            left: size.width * 0.04,
            bottom: 5,
            child: Image.asset(
              'assets/images/tuti.png',
              height: size.height * 0.75,
            ),
          ),

          // ==================================================
          // 4. LOGO TOOTH HERO
          // ==================================================
          Positioned(
            right: size.width * 0.10,
            top: size.height * 0.03,
            child: Image.asset(
              'assets/images/judul.png',
              width: size.width * 0.36,
            ),
          ),

          // ==================================================
          // 5. TOMBOL PLAY, GUIDANCE, EXIT
          // ==================================================
          Positioned(
            right: size.width * 0.10,
            top: size.height * 0.30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // PLAY
                // ==================================================

                GestureDetector(
                  onTap: () {
                    setState(() {
                      showSelectLevel = true;
                    });
                  },
                  child: Image.asset(
                    'assets/images/play.png',
                    width: size.width * 0.22,
                  ),
                ),

                SizedBox(height: size.height * 0.018),

                // ==================================================
                // GUIDANCE
                // ==================================================
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showGuidance = true;
                    });
                  },
                  child: Image.asset(
                    'assets/images/guidance.png',
                    width: size.width * 0.22,
                  ),
                ),

                SizedBox(height: size.height * 0.018),

                // ==================================================
                // EXIT
                // ==================================================
                GestureDetector(
                  onTap: _exitApp,
                  child: Image.asset(
                    'assets/images/exit.png',
                    width: size.width * 0.22,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // 6. POPUP SELECT LEVEL
          // ==================================================
          if (showSelectLevel)
            LevelSelectDialog(
              onClose: () {
                setState(() {
                  showSelectLevel = false;
                });
              },
            ),

          // ==================================================
          // 7. POPUP GUIDANCE
          // ==================================================
          if (showGuidance)
            GuidanceDialog(
              onClose: () {
                setState(() {
                  showGuidance = false;
                });
              },
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET TOMBOL ATAS
  // ==========================================================

  Widget _buildTopButton({required IconData icon}) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF1976D2), size: 48),
    );
  }
}
