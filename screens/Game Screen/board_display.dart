import 'package:flutter/material.dart';
import '../../widgets/crossword_board.dart';
import '../../utils/game_state.dart';

class BoardDisplay extends StatelessWidget {
  final GameState gameState;

  const BoardDisplay({required this.gameState, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            CrosswordBoard(
              game: gameState.game,
              selectedRow: gameState.selectedRow,
              selectedCol: gameState.selectedCol,
              isAcrossDirection: gameState.isAcrossDirection,
              activeClueNumber: gameState.activeClueNumber,
              onTap: gameState.selectCell,
            ),
            if (gameState.isPaused)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.pause_circle_filled,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
