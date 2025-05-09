enum PowerType { undo, doublePlay, blockCell }

class PlayerPowers {
  final bool undoAvailable;
  final bool doublePlayAvailable;
  final bool blockAvailable;

  const PlayerPowers({
    this.undoAvailable = true,
    this.doublePlayAvailable = true,
    this.blockAvailable = true,
  });

  PlayerPowers copyWith({
    bool? undoAvailable,
    bool? doublePlayAvailable,
    bool? blockAvailable,
  }) {
    return PlayerPowers(
      undoAvailable: undoAvailable ?? this.undoAvailable,
      doublePlayAvailable: doublePlayAvailable ?? this.doublePlayAvailable,
      blockAvailable: blockAvailable ?? this.blockAvailable,
    );
  }
}

