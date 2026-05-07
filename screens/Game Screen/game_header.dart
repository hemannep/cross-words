import 'package:flutter/material.dart';
import '../../utils/game_state.dart';

class GameHeader extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onBack;
  final VoidCallback onPauseToggle;

  const GameHeader({
    required this.gameState,
    required this.onBack,
    required this.onPauseToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                  ),
                ),
                Text(
                  "${gameState.score}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: onPauseToggle,
                  child: Container(
                    decoration: BoxDecoration(
                      color: gameState.isPaused
                          ? Colors.green.shade600
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      gameState.isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: gameState.isPaused
                          ? Colors.white
                          : Colors.grey.shade700,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeaderStat(
                  icon: Icons.speed_rounded,
                  label: 'Difficulty',
                  value: gameState.difficulty,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _HeaderStat(
                  icon: Icons.error_outline_rounded,
                  label: 'Mistakes',
                  value: "${gameState.mistakes}/${gameState.maxMistakes}",
                  showError: gameState.mistakes > 1,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                GestureDetector(
                  onTap: onPauseToggle,
                  child: _HeaderStat(
                    icon: Icons.schedule_rounded,
                    label: 'Time',
                    value: gameState.formattedTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showError;

  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: showError ? Colors.red : Colors.green.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: showError ? Colors.red : Colors.black87,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
