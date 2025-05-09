import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class FireText extends StatelessWidget {
  const FireText({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ShimmerEffect(
          duration: const Duration(seconds: 2),
          color: Colors.orange.shade600,
          angle: 0,
        ),
        FadeEffect(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          begin: 0.8,
          end: 1.0,
        ),
        ScaleEffect(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
        ),
      ],
      onPlay: (controller) => controller.repeat(),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Colors.indigo,
              Colors.purple,
              Colors.red,
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: Text(
          'Tic Tac Toe',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 26,
            color: Colors.white, // remplacé par le shader
          ),
        ),
      ),
    );
  }
}
