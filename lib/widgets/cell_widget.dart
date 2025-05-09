import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_controller.dart';

class CellWidget extends ConsumerWidget {
  final int index;
  final String symbol;

  const CellWidget({super.key, required this.index, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);

    return GestureDetector(
      onTap: () => controller.playMove(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: symbol == 'X' ? Colors.indigo : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
