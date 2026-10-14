import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tentang_screen.dart';
import 'level_select_dialog.dart';
import 'settings_screen.dart';
import 'loading_screen.dart';
import 'level_4.dart';

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
      home: const LoadingScreen(nextScreen: MainMenuScreen()),
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

  void _openLevel4() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => Level4Screen()));
  }

  // ==========================================================
  // EXIT APP
  // ==========================================================

  void _exitApp() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tombol Keluar tersedia saat aplikasi '
            'dijalankan di perangkat.',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      return;
    }

    SystemNavigator.pop();
  }

  // ==========================================================
  // OPEN LEVEL SELECT
  // ==========================================================

  void _openLevelSelect() {
    setState(() {
      showSelectLevel = true;
    });
  }

  // ==========================================================
  // OPEN TENTANG
  // ==========================================================

  void _openTentang() {
    setState(() {
      showGuidance = true;
    });
  }

  // ==========================================================
  // BUILD MAIN MENU
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;

          final double screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // ==================================================
              // 1. BACKGROUND
              // ==================================================

              Positioned.fill(
                child: Image.asset(
                  'assets/images/bg with tuti.png',
                  fit: BoxFit.cover,
                ),
              ),

              // ==================================================
              // 2. SETTINGS
              // ==================================================
              Positioned(
                left: screenWidth * 0.028,
                top: screenHeight * 0.055,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: _buildTopButton(icon: Icons.settings),
                ),
              ),

              // ==================================================
              // 3. LOGO TOOTH HERO
              // ==================================================
              Positioned(
                right: screenWidth * 0.100,
                top: screenHeight * 0.018,
                width: screenWidth * 0.29,
                child: Center(
                  child: Image.asset(
                    'assets/images/judul.png',
                    width: screenWidth * 0.25,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ==================================================
              // 4. MENU BUTTON
              // ==================================================
              Positioned(
                right: screenWidth * 0.100,
                top: screenHeight * 0.340,
                width: screenWidth * 0.29,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // MULAI

                    _buildMenuButton(
                      imagePath: 'assets/images/mulai.png',
                      width: screenWidth * 0.18,
                      onTap: _openLevelSelect,
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    // TENTANG
                    _buildMenuButton(
                      imagePath: 'assets/images/tentang.png',
                      width: screenWidth * 0.18,
                      onTap: _openTentang,
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    // KELUAR
                    _buildMenuButton(
                      imagePath: 'assets/images/keluar.png',
                      width: screenWidth * 0.18,
                      onTap: _exitApp,
                    ),
                  ],
                ),
              ),

              // ==================================================
              // 5. POPUP LEVEL SELECT
              // ==================================================
              if (showSelectLevel)
                LevelSelectDialog(
                  onClose: () {
                    setState(() {
                      showSelectLevel = false;
                    });
                  },
                  onLevelSelected: (level) {
                    if (level == 4) {
                      _openLevel4();
                    } else if (level == 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Level 5 belum tersedia.'),
                        ),
                      );
                    }
                  },
                ),

              // ==================================================
              // 6. POPUP TENTANG
              // ==================================================
              if (showGuidance)
                TentangScreen(
                  onClose: () {
                    setState(() {
                      showGuidance = false;
                    });
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // MENU BUTTON
  // ==========================================================

  Widget _buildMenuButton({
    required String imagePath,
    required double width,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(imagePath, width: width, fit: BoxFit.contain),
      ),
    );
  }

  // ==========================================================
  // SETTINGS BUTTON
  // ==========================================================

  Widget _buildTopButton({required IconData icon}) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF1976D2), size: 30),
    );
  }
}
