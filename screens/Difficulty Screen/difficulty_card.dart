import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Ads/interstitial_ads.dart';
import '../Game Screen/game_screen.dart';
import '../../utils/game_state.dart';

class DifficultyCard extends StatelessWidget {
  final Map<String, dynamic> difficulty;
  final VoidCallback onLockedTap;

  const DifficultyCard({
    required this.difficulty,
    required this.onLockedTap,
    super.key,
  });

  Future<void> _handleDifficultyTap(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int playCount = prefs.getInt('global_play_count') ?? 0;
    playCount++;
    await prefs.setInt('global_play_count', playCount);

    if (playCount % 2 == 0) {
      await InterstitialAdHelper.showInterstitialAd();
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            difficulty: difficulty['name'] as String,
            isContinue: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        final color = difficulty['color'] as Color;
        final emoji = difficulty['emoji'] as String;
        final diffName = difficulty['name'] as String;
        final isLocked = gameState.isDifficultyLocked(diffName);
        final requirement = gameState.getDifficultyRequirement(diffName);

        return GestureDetector(
          onTap: isLocked ? onLockedTap : () => _handleDifficultyTap(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border(
                left: BorderSide(
                  color: isLocked ? Colors.grey.shade300 : color,
                  width: 5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isLocked ? 0.03 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            difficulty['name'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isLocked
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (isLocked)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.lock_rounded,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (diffName == 'Newbie')
                        Text(
                          difficulty['desc'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.1,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete ${requirement.requiredGames} ${requirement.previousDifficulty} games',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isLocked ? Colors.grey.shade400 : color,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (requirement.currentGames /
                                    requirement.requiredGames),
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${requirement.currentGames}/${requirement.requiredGames}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 34,
                        color: isLocked ? Colors.grey.shade300 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!isLocked)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: color,
                        size: 18,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.grey.shade400,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
