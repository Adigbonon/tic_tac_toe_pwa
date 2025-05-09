enum GameMode {
  vsAI,
  vsFriend,
}

extension GameModeExtension on GameMode {
  String get label {
    switch (this) {
      case GameMode.vsAI:
        return 'Contre l\'IA';
      case GameMode.vsFriend:
        return 'Contre un ami';
    }
  }
}

enum AIDifficulty {
  easy,
  medium,
  hard
}

extension AIDifficultyExtension on AIDifficulty {
  String get label {
    switch (this) {
      case AIDifficulty.easy:
        return 'Facile';
      case AIDifficulty.medium:
        return 'Moyen';
      case AIDifficulty.hard:
        return 'Difficile';
    }
  }
}

