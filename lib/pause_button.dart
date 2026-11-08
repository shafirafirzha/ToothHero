import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PauseButton extends StatelessWidget {
  const PauseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const Color _blue = Color.fromARGB(255, 112, 166, 247);
  static const double _size = 54;

  @override
  Widget build(BuildContext context) {
    Widget bar() => Container(
      width: 7,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: _blue,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withOpacity(0.8), width: 2),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [bar(), const SizedBox(width: 7), bar()],
            ),
          ),
        ),
      ),
    );
  }
}

class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  static const double _boardWidth = 230;
  static const double _buttonWidth = 170;
  static const double _buttonHeight = 52;

  Widget _menuImageButton({
    required String image,
    required VoidCallback onPressed,
    required double u,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: _buttonWidth * u,
        height: _buttonHeight * u,
        child: Image.asset(image, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildBoard(double u) {
    return Container(
      width: _boardWidth * u,
      padding: EdgeInsets.symmetric(horizontal: 24 * u, vertical: 18 * u),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(24 * u),
        border: Border.all(color: const Color(0xFF8AB8F5), width: 4 * u),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12 * u,
            offset: Offset(0, 5 * u),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PAUSE',
            style: GoogleFonts.fredoka(
              fontSize: 26 * u,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF304F9E),
            ),
          ),
          SizedBox(height: 12 * u),
          _menuImageButton(
            image: 'assets/images/lanjutkan.png',
            onPressed: onResume,
            u: u,
          ),
          SizedBox(height: 8 * u),
          _menuImageButton(
            image: 'assets/images/ulang.png',
            onPressed: onRestart,
            u: u,
          ),
          SizedBox(height: 8 * u),
          _menuImageButton(
            image: 'assets/images/kluar.png',
            onPressed: onExit,
            u: u,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : 360.0;
          final double u = (h / 360).clamp(0.6, 1.5).toDouble();

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FittedBox(fit: BoxFit.scaleDown, child: _buildBoard(u)),
            ),
          );
        },
      ),
    );
  }
}
