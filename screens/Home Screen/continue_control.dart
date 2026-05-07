import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/game_state.dart';
import '../../Ads/rewared_ads.dart';
import '../Game Screen/game_screen.dart';

class ContinueControl extends StatelessWidget {
  const ContinueControl({super.key, required void Function() onResumed});

  @override
  Widget build(BuildContext context) {
    return Selector<GameState, bool>(
      selector: (_, gameState) => gameState.hasGameInProgress,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, hasGameInProgress, _) {
        if (!hasGameInProgress) return const SizedBox.shrink();
        return const _ContinueGameCard();
      },
    );
  }
}

class _ContinueGameCard extends StatelessWidget {
  const _ContinueGameCard();

  Future<void> _handleContinueGame(BuildContext context) async {
    final gameState = context.read<GameState>();

    if (RewardedAdHelper.isRewardedAdReady()) {
      await RewardedAdHelper.showRewardedAd(
        onRewardEarned: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(
                difficulty: gameState.difficulty,
                isContinue: true,
              ),
            ),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            difficulty: gameState.difficulty,
            isContinue: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _handleContinueGame(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.indigo.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Continue Game",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Selector<GameState, String>(
                        selector: (_, state) => state.difficulty,
                        shouldRebuild: (previous, next) => previous != next,
                        builder: (context, difficulty, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              difficulty,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.blue.shade600,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_ScoreStat(), _TimeStat(), _MistakesStat()],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat();

  @override
  Widget build(BuildContext context) {
    return Selector<GameState, int>(
      selector: (_, gameState) => gameState.score,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, score, _) {
        return _ProgressStat(
          icon: Icons.star,
          label: 'Score',
          value: '$score',
          color: Colors.amber,
        );
      },
    );
  }
}

class _TimeStat extends StatelessWidget {
  const _TimeStat();

  @override
  Widget build(BuildContext context) {
    return Selector<GameState, String>(
      selector: (_, gameState) => gameState.formattedTime,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, formattedTime, _) {
        return _ProgressStat(
          icon: Icons.schedule,
          label: 'Time',
          value: formattedTime,
          color: Colors.blue,
        );
      },
    );
  }
}

class _MistakesStat extends StatelessWidget {
  const _MistakesStat();

  @override
  Widget build(BuildContext context) {
    return Selector<GameState, String>(
      selector: (_, gameState) =>
          '${gameState.mistakes}/${gameState.maxMistakes}',
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, mistakesText, _) {
        return _ProgressStat(
          icon: Icons.error_outline,
          label: 'Mistakes',
          value: mistakesText,
          color: Colors.red,
        );
      },
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProgressStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
