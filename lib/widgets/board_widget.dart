import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_controller.dart';
import 'cell_widget.dart';

class BoardWidget extends ConsumerWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);

    return SizedBox(
      width: 300,
      height: 300,
      child: GridView.builder(
        itemCount: 9,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          return CellWidget(
            index: index,
            symbol: game.board[index],
          );
        },
      ),
    );
  }
}
