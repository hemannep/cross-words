import 'package:flutter/material.dart';

import '../../utils/crossword_generator.dart';
import '../../utils/daily_challenge_service.dart';
import '../Game Screen/game_screen.dart';

class DailyChallengeWidget extends StatefulWidget {
  const DailyChallengeWidget({super.key});

  @override
  State<DailyChallengeWidget> createState() => _DailyChallengeWidgetState();
}

class _DailyChallengeWidgetState extends State<DailyChallengeWidget> {
  bool _loading = false;
  bool _completedToday = false;

  @override
  void initState() {
    super.initState();
    _checkCompletion();
  }

  Future<void> _checkCompletion() async {
    final done = await DailyChallengeService.hasCompletedToday();
    if (mounted) setState(() => _completedToday = done);
  }

  Future<void> _startChallenge() async {
    if (_completedToday) {
      _showCompletedDialog();
      return;
    }

    setState(() => _loading = true);

    try {
      final today = DateTime.now();
      final dateStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final challenge = await DailyChallengeService.getTodayChallenge();

      if (challenge == null) {
        throw Exception('Could not load daily challenge');
      }

      final game = CrosswordGame.fromJson(challenge['game']);
      final difficulty = challenge['difficulty'] as String;

      if (!mounted) return;
      setState(() => _loading = false);

      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (_) => GameScreen(
      //       difficulty: difficulty,
      //       isDailyChallenge: true,
      //       challengeDate:  dateStr,
      //       customGame: game,
      //     ),
      //   ),
      // ).then((_) => _checkCompletion());
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load challenge: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
            const SizedBox(width: 10),
            const Text("Already Done!"),
          ],
        ),
        content: const Text(
          "You've already completed today's challenge. Come back tomorrow for a new puzzle!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("OK", style: TextStyle(color: Colors.green.shade700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dateLabel = "${months[today.month - 1]} ${today.day}";

    return GestureDetector(
      onTap: _loading ? null : _startChallenge,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _completedToday
                ? [Colors.green.shade400, Colors.green.shade700]
                : [Colors.purple.shade400, Colors.deepPurple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_completedToday ? Colors.green : Colors.deepPurple)
                  .withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _completedToday
                    ? Icons.check_circle_rounded
                    : Icons.calendar_today_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Challenge",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _completedToday ? "Completed today" : "Today, $dateLabel",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
