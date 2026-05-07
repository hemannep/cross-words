import 'package:flutter/material.dart';
import '../utils/crossword_generator.dart';

class CrosswordBoard extends StatelessWidget {
  final CrosswordGame game;
  final int selectedRow;
  final int selectedCol;
  final bool isAcrossDirection;
  final int? activeClueNumber;
  final void Function(int, int) onTap;

  const CrosswordBoard({
    super.key,
    required this.game,
    required this.selectedRow,
    required this.selectedCol,
    required this.isAcrossDirection,
    required this.activeClueNumber,
    required this.onTap,
  });

  // Returns the set of cells that are part of the active word
  Set<String> _getActiveWordCells() {
    final cells = <String>{};
    if (selectedRow < 0 || selectedCol < 0) return cells;
    if (game.isBlack[selectedRow][selectedCol]) return cells;

    if (isAcrossDirection) {
      int startC = selectedCol;
      while (startC > 0 && !game.isBlack[selectedRow][startC - 1]) {
        startC--;
      }
      int c = startC;
      while (c < game.size && !game.isBlack[selectedRow][c]) {
        cells.add('$selectedRow,$c');
        c++;
      }
    } else {
      int startR = selectedRow;
      while (startR > 0 && !game.isBlack[startR - 1][selectedCol]) {
        startR--;
      }
      int r = startR;
      while (r < game.size && !game.isBlack[r][selectedCol]) {
        cells.add('$r,$selectedCol');
        r++;
      }
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final activeWordCells = _getActiveWordCells();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800, width: 3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(game.size, (r) {
          return Expanded(
            child: Row(
              children: List.generate(game.size, (c) {
                return Expanded(
                  child: _CrosswordCell(
                    row: r,
                    col: c,
                    isBlack: game.isBlack[r][c],
                    letter: game.board[r][c],
                    solutionLetter: game.solution[r][c],
                    number: game.numbers[r][c],
                    isSelected: r == selectedRow && c == selectedCol,
                    isInActiveWord: activeWordCells.contains('$r,$c'),
                    onTap: () => onTap(r, c),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _CrosswordCell extends StatelessWidget {
  final int row;
  final int col;
  final bool isBlack;
  final String letter;
  final String solutionLetter;
  final int number;
  final bool isSelected;
  final bool isInActiveWord;
  final VoidCallback onTap;

  const _CrosswordCell({
    required this.row,
    required this.col,
    required this.isBlack,
    required this.letter,
    required this.solutionLetter,
    required this.number,
    required this.isSelected,
    required this.isInActiveWord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlack) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border.all(color: Colors.grey.shade800, width: 0.5),
        ),
      );
    }

    final wrong = letter.isNotEmpty && letter != solutionLetter;

    Color bgColor = Colors.white;
    if (isSelected && wrong) {
      bgColor = Colors.red.shade100;
    } else if (isSelected) {
      bgColor = Colors.green.shade500;
    } else if (isInActiveWord) {
      bgColor = const Color.fromARGB(255, 226, 246, 229);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            // Cell number (top-left)
            if (number > 0)
              Positioned(
                top: 1,
                left: 2,
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ),
            // Letter
            Center(
              child: letter.isNotEmpty
                  ? Text(
                      letter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? Colors.white
                            : wrong
                                ? Colors.red.shade600
                                : Colors.green.shade800,
                        letterSpacing: -0.5,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
