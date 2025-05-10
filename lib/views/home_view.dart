import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../logic/game_controller.dart';
import '../models/game_mode.dart';
import '../widgets/AudioService.dart';
import '../widgets/FireText.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  GameMode? _selectedMode;
  AIDifficulty _selectedDifficulty = AIDifficulty.easy;
  bool _blitzMode = false;

  @override
  void initState() {
    super.initState();

    // Jouer un son d'ambiance dès l'ouverture de la page
    AudioService.loop('sounds/home.mp3');
  }

  @override
  void dispose() {
    //AudioService.stop();
    super.dispose();
  }

  void _startGame() {
    if (_selectedMode != null) {
      ref.read(gameControllerProvider.notifier).setMode(
            _selectedMode!,
            _selectedDifficulty,
            blitz: _blitzMode,
          );
      context.go('/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/tictactoe.gif',
                height: 100,
              ),
              const SizedBox(height: 24),
              const FireText(),
              const SizedBox(height: 32),
              SizedBox(
                width: 400,
                child: SegmentedButton<GameMode>(
                  segments: [
                    ButtonSegment(
                      value: GameMode.vsAI,
                      label: Text(
                        "Contre l'IA",
                        style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 10
                        )
                      ),
                    ),
                    ButtonSegment(
                      value: GameMode.vsFriend,
                      label: Text(
                        "Contre un ami",
                        style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 10
                        )
                      ),
                    ),
                  ],
                  selected: _selectedMode != null ? {_selectedMode!} : {},
                  emptySelectionAllowed: true,
                  onSelectionChanged: (s) =>
                      setState(() => _selectedMode = s.first),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // ✅ carré
                      side: const BorderSide(color: Colors.white, width: 2),
                    )),
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors
                            .orange.shade800; // ✅ fond actif pixel-style
                      }
                      return Colors.black;
                    }),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    overlayColor: MaterialStateProperty.all(
                        Colors.deepOrange.shade200.withOpacity(0.2)),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12)),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 8
                        )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedMode == GameMode.vsAI)
                Column(
                  children: [
                    Text(
                      "Niveau de difficulté",
                      style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 15,
                        color: Colors.white
                      )
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 400,
                      child: SegmentedButton<AIDifficulty>(
                        segments: [
                          ButtonSegment(
                            value: AIDifficulty.easy,
                            label: Text("Facile",
                                style:TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 10
                                )),
                          ),
                          ButtonSegment(
                            value: AIDifficulty.medium,
                            label: Text("Moyen",
                                style: TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 10
                                )),
                          ),
                          ButtonSegment(
                            value: AIDifficulty.hard,
                            label: Text("Difficile",
                                style: TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 8
                                )),
                          ),
                        ],
                        selected: {_selectedDifficulty},
                        onSelectionChanged: (s) =>
                            setState(() => _selectedDifficulty = s.first),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // 👾 carré
                              side: const BorderSide(
                                  color: Colors.white, width: 2),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.blue; // ✅ fond pixelisé actif
                            }
                            return Colors.black;
                          }),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          overlayColor: MaterialStateProperty.all(
                              Colors.orangeAccent.withOpacity(0.2)),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10)),
                          textStyle: MaterialStateProperty.all(
                               TextStyle(
                                fontFamily: 'PressStart2P',
                                fontSize: 8
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Mode Blitz 5s ⏱️",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 14,
                        color: Colors.white,
                      )),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _blitzMode = !_blitzMode;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _blitzMode ? Colors.purple : Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: Text(_blitzMode ? "ON" : "OFF",
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 10,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: Text("▶ COMMENCER",
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
