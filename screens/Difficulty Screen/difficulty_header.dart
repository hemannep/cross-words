import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'difficulty_dialog.dart';
import '../../utils/game_state.dart';

class DifficultyHeader extends StatelessWidget {
  const DifficultyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        final allUnlocked = !gameState.isDifficultyLocked('Easy') &&
            !gameState.isDifficultyLocked('Regular') &&
            !gameState.isDifficultyLocked('Hard') &&
            !gameState.isDifficultyLocked('Expert') &&
            !gameState.isDifficultyLocked('Professional') &&
            !gameState.isDifficultyLocked('Extreme');

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.green.shade500, Colors.green.shade700],
                    ).createShader(bounds),
                    child: const Text(
                      "Crossword",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (!allUnlocked)
                GestureDetector(
                  onTap: () => DifficultyDialogs.showUnlockAllDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_open_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Unlock All",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
