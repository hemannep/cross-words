import 'package:flutter/material.dart';

import '../../Ads/banner_ads.dart';
import '../../utils/game_progress.dart';
import '../Difficulty Screen/difficulty_screen.dart';
import 'continue_control.dart';
import 'daily_challenge_widget.dart';
import 'streak_counter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameProgress? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await GameProgress.load();
    if (mounted) {
      setState(() {
        _progress = progress;
        _loading = false;
      });
    }
  }

  void _refreshProgress() {
    _loadProgress();
  }

  int get _totalGames {
    if (_progress == null) return 0;
    return _progress!.newbieGames +
        _progress!.easyGames +
        _progress!.regularGames +
        _progress!.hardGames +
        _progress!.expertGames +
        _progress!.professionalGames +
        _progress!.extremeGames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green))
            : Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.shade800,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            "Crossword",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        StreakCounter(streak: _progress?.streak ?? 0),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Stats card
                          _buildStatsCard(),

                          const SizedBox(height: 18),

                          // Daily challenge
                          const DailyChallengeWidget(),

                          const SizedBox(height: 18),

                          // Continue game
                          ContinueControl(onResumed: _refreshProgress),

                          const SizedBox(height: 18),

                          // Play button
                          _buildPlayButton(),

                          const SizedBox(height: 16),

                          // Tagline
                          Text(
                            "Words, Wit & Wisdom",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Banner ad
                  const BannerAdWidget(),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            icon: Icons.emoji_events_rounded,
            color: Colors.amber.shade600,
            value: "$_totalGames",
            label: "Solved",
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          _statItem(
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange.shade600,
            value: "${_progress?.streak ?? 0}",
            label: "Streak",
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          _statItem(
            icon: Icons.star_rounded,
            color: Colors.green.shade600,
            value: "${_progress?.expertGames ?? 0}",
            label: "Expert+",
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => const DifficultyScreen(),
              ),
            )
            .then((_) => _refreshProgress());
      },
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade500, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(width: 8),
            Text(
              "PLAY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
