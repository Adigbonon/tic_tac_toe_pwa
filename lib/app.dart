import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe/widgets/AnimatedBackground.dart';
import 'router.dart';

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class ScaffoldWrapper extends StatelessWidget {
  final Widget child;

  const ScaffoldWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AnimatedBackground(),
        Container(
          color: Colors.black.withOpacity(0.05),
          foregroundDecoration: const BoxDecoration(
            backgroundBlendMode: BlendMode.overlay,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.02, 0.02],
              colors: [Colors.black, Colors.transparent],
              tileMode: TileMode.repeated,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
