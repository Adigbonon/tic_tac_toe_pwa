import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_mode.dart';
import '../models/powers.dart';

final gameControllerProvider = StateNotifierProvider<GameController, GameState>(
  (ref) => GameController(ref),
);

final blitzTimerProvider = StateProvider<double>((ref) => 1.0); // de 1.0 à 0.0

class GameState {
  final List<String> board;
  final bool xTurn;
  final String? winner;
  final GameMode? mode;
  final AIDifficulty difficulty;
  final int playerScore;
  final bool blitzMode;
  final PlayerPowers powers;

  GameState({
    required this.board,
    required this.xTurn,
    required this.winner,
    this.mode,
    this.difficulty = AIDifficulty.easy,
    this.playerScore = 0,
    this.blitzMode = false,
    this.powers = const PlayerPowers(),
  });

  GameState copyWith({
    List<String>? board,
    bool? xTurn,
    String? winner,
    GameMode? mode,
    AIDifficulty? difficulty,
    int? playerScore,
    bool? blitzMode,
    PlayerPowers? powers,
  }) {
    return GameState(
      board: board ?? this.board,
      xTurn: xTurn ?? this.xTurn,
      winner: winner ?? this.winner,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      playerScore: playerScore ?? this.playerScore,
      blitzMode: blitzMode ?? this.blitzMode,
      powers: powers ?? this.powers,
    );
  }

  bool get isGameOver => winner != null || !board.contains('');
}

class GameController extends StateNotifier<GameState> {
  final Ref _ref;
  Timer? _blitzTimer;
  List<String>? _lastBoard;
  bool _extraTurn = false;

  GameController(this._ref)
      : super(GameState(board: List.filled(9, ''), xTurn: true, winner: null)) {
    _loadScore();
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    final storedScore = prefs.getInt('player_score') ?? 0;
    state = state.copyWith(playerScore: storedScore);
  }

  void setMode(GameMode mode, AIDifficulty difficulty, {bool blitz = false}) {
    _blitzTimer?.cancel();

    state = GameState(
        board: List.filled(9, ''),
        xTurn: true,
        winner: null,
        mode: mode,
        difficulty: difficulty,
        playerScore: state.playerScore,
        blitzMode: blitz);

    if (blitz && state.xTurn) {
      _startBlitzTimer();
    }
  }

  void resetGame() {
    state = GameState(
      board: List.filled(9, ''),
      xTurn: true,
      winner: null,
      mode: state.mode,
      difficulty: state.difficulty,
      blitzMode: state.blitzMode,
      playerScore: state.playerScore,
    );

    _blitzTimer?.cancel();
  }

  void playMove(int index) {
    // Ne rien faire si la case est déjà remplie ou si la partie est terminée
    if (state.board[index] != '' || state.isGameOver) return;

    _lastBoard = [...state.board];

    // Annule le timer actuel (évite que le tour soit passé après un coup valide)
    _blitzTimer?.cancel();

    // Marque le symbole (X ou O)
    final symbol = state.xTurn ? 'X' : 'O';
    final updatedBoard = [...state.board];
    updatedBoard[index] = symbol;

    // Vérifie s'il y a un gagnant
    final winner = _checkWinner(updatedBoard);

    // Incrémente le score si le joueur gagne contre l’IA
    int newScore = state.playerScore;
    if (winner == 'X' && state.mode == GameMode.vsAI) {
      newScore += 1;
      _saveScore(newScore);
    }

    bool nextTurn = _extraTurn ? state.xTurn : !state.xTurn;
    _extraTurn = false;

    state = state.copyWith(
      board: updatedBoard,
      xTurn: nextTurn,
      winner: winner,
      playerScore: newScore,
    );

    // Si la partie est finie, ne rien faire d'autre
    if (state.isGameOver) return;

    // Mode IA : joue automatiquement au prochain tour
    if (!state.xTurn && state.mode == GameMode.vsAI) {
      Future.delayed(const Duration(milliseconds: 500), _playAIMove);
    }

    // Redémarre le timer si Blitz est activé
    if (state.blitzMode) {
      _startBlitzTimer();
    }
  }

  void useUndo() {
    if (_lastBoard == null || !state.powers.undoAvailable) return;

    state = state.copyWith(
      board: _lastBoard,
      powers: state.powers.copyWith(undoAvailable: false),
    );

    _lastBoard = null;
  }

  void useDoublePlay() {
    if (!state.powers.doublePlayAvailable) return;

    _extraTurn = true;

    state = state.copyWith(
      powers: state.powers.copyWith(doublePlayAvailable: false),
    );
  }

  Future<void> _saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_score', score);
  }

  void _startBlitzTimer() {
    final ref = _ref;
    _blitzTimer?.cancel();
    const duration = Duration(seconds: 5);
    const tickInterval = Duration(milliseconds: 100);
    int ticks = 0;
    int maxTicks = duration.inMilliseconds ~/ tickInterval.inMilliseconds;

    _blitzTimer = Timer.periodic(tickInterval, (timer) {
      ticks++;
      final progress = 1.0 - ticks / maxTicks;
      ref.read(blitzTimerProvider.notifier).state = progress;

      if (ticks >= maxTicks) {
        timer.cancel();
        if (!state.isGameOver) {
          state = state.copyWith(xTurn: !state.xTurn);
          if (!state.xTurn && state.mode == GameMode.vsAI) {
            _playAIMove();
          } else {
            _startBlitzTimer(); // prochain joueur
          }
        }
      }
    });
  }

  void _playAIMove() {
    int move = _chooseAIMove(state.board, state.difficulty);
    playMove(move);
  }

  int _chooseAIMove(List<String> board, AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return _randomMove(board);
      case AIDifficulty.medium:
        return _findWinningMove(board, 'O') ??
            _findWinningMove(board, 'X') ??
            _randomMove(board);
      case AIDifficulty.hard:
        return _minimaxMove(board);
    }
  }

  int _minimaxMove(List<String> board) {
    int bestScore = -999;
    int bestMove = -1;

    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = 'O';
        int score = _minimax(board, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    return bestMove;
  }

  int _minimax(List<String> board, bool isMaximizing) {
    final winner = _checkWinner(board);
    if (winner == 'O') return 10;
    if (winner == 'X') return -10;
    if (!board.contains('')) return 0; // Match nul

    int bestScore = isMaximizing ? -999 : 999;

    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = isMaximizing ? 'O' : 'X';
        int score = _minimax(board, !isMaximizing);
        board[i] = '';
        if (isMaximizing) {
          bestScore = max(score, bestScore);
        } else {
          bestScore = min(score, bestScore);
        }
      }
    }

    return bestScore;
  }

  int? _findWinningMove(List<String> board, String symbol) {
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = symbol;
        if (_checkWinner(board) == symbol) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }
    return null;
  }

  int _randomMove(List<String> board) {
    final available = <int>[];
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') available.add(i);
    }
    return available[Random().nextInt(available.length)];
  }

  String? _checkWinner(List<String> board) {
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var combo in wins) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        return board[combo[0]];
      }
    }
    return null;
  }

  Future<void> resetScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_score', 0);
    state = state.copyWith(playerScore: 0);
  }
}
