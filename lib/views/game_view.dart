import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../logic/game_controller.dart';
import '../models/game_mode.dart';
import '../widgets/AudioService.dart';
import '../widgets/board_widget.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key});

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  bool _playedEndSound = false;

  @override
  void initState() {
    super.initState();
    AudioService.loop("sounds/start_game.mp3");
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (game.isGameOver && !_playedEndSound) {
        _playedEndSound = true;
        AudioService.stop();

        if (game.winner == 'X') {
          AudioService.play('sounds/winneris.mp3');
        } else if (game.winner == 'O') {
          AudioService.play('sounds/lost.mp3');
        } else if (game.winner == null || game.winner!.isEmpty) {
          AudioService.play('sounds/credits.mp3');
        }
      }

      // Remet le flag à false quand une nouvelle partie commence
      if (!game.isGameOver && _playedEndSound) {
        _playedEndSound = false;
      }
    });

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Tic Tac Toe",
            style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
              color: Colors.white
            )
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Rejouer",
              color: Colors.blueGrey,
              onPressed: () {
                AudioService.stop();
                AudioService.play('sounds/click.wav');
                controller.resetGame();
              },
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              color: Colors.blueGrey,
              tooltip: "Retour à l’accueil",
              onPressed: () async {
                AudioService.play('sounds/click.wav');
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      'Retour à l’accueil ?',
                      style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          color: Colors.white
                      )
                    ),
                    content: Text(
                      'La partie en cours sera perdue.',
                      style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          color: Colors.redAccent
                      )
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14,
                              color: Colors.green
                          )
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Confirmer',
                          style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14,
                              color: Colors.red
                          )
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  context.go('/');
                }
              },
            ),
          ],
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (game.isGameOver && game.winner != null && game.mode == GameMode.vsAI) ...[
              const SizedBox(height: 12),
              Image.asset(
                game.winner == 'X'
                    ? 'assets/trophy.gif'
                    : 'assets/lost.gif',
                height: 100,
                width: 100,
              ),
            ],
            Text("Parties gagnées contre l'IA : ${game.playerScore}",
                style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    color: Colors.white
                )),
            const SizedBox(height: 3),
            game.mode == GameMode.vsAI ? ElevatedButton.icon(
              onPressed: () => controller.resetScore(),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: Text(
                "RESET SCORE",
                style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 9,
                    color: Colors.white
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: const BorderSide(color: Colors.redAccent, width: 2),
                ),
                elevation: 4,
                shadowColor: Colors.redAccent,
              ),) : SizedBox(),
            const SizedBox(height: 40),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Text(
                game.isGameOver
                    ? game.winner != null
                        ? game.mode == GameMode.vsAI
                            ? (game.winner == 'X'
                                ? "🎉 Vous avez gagné !"
                                : "😞 Dommage, réessayez la prochaine fois !")
                            : (game.winner == 'X'
                                ? "❌ a gagné !"
                                : "⭕ a gagné !")
                        : "🤝 Match nul"
                    : game.mode == GameMode.vsAI
                        ? (game.xTurn
                            ? "🕹️ Votre tour (❌)"
                            : "🤖 Tour de l'IA (⭕)")
                        : "Tour de : ${game.xTurn ? '❌' : '⭕'}",
                key: ValueKey(game.winner ?? game.xTurn),
                style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 15,
                    color: Colors.red
                ),
              ),
            ),
            const SizedBox(height: 7),
            if (game.blitzMode) ...[
              Consumer(
                builder: (context, ref, _) {
                  final progress = ref.watch(blitzTimerProvider);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: progress > 0.4
                          ? Colors.green
                          : (progress > 0.2 ? Colors.orange : Colors.red),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            if (!game.isGameOver) ...[
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: game.powers.undoAvailable
                        ? () {
                      AudioService.play('sounds/click.wav');
                      controller.useUndo();
                    }
                        : null,
                    icon: const Icon(Icons.undo),
                    label: Text("Annuler",
                        style:TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 9,
                            color: Colors.blueGrey
                        )),
                  ),
                  ElevatedButton.icon(
                    onPressed: game.powers.doublePlayAvailable
                        ? () {
                      AudioService.play('sounds/click.wav');
                      controller.useDoublePlay();
                    }
                        : null,
                    icon: const Icon(Icons.looks_two),
                    label: Text("Double coup",
                        style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 9,
                            color: Colors.blueGrey
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            BoardWidget(),
          ],
        )));
  }
}
