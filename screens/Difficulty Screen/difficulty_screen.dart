import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/game_state.dart';
import 'difficulty_dialog.dart';
import 'difficulty_header.dart';
import 'difficulty_card.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final difficulties = [
      {
        'name': 'Newbie',
        'desc': 'Perfect for beginners',
        'color': Colors.blue,
        'emoji': '🎮',
      },
      {
        'name': 'Easy',
        'desc': 'Relaxed & casual',
        'color': Colors.green,
        'emoji': '😊',
      },
      {
        'name': 'Regular',
        'desc': 'Balanced challenge',
        'color': Colors.orange,
        'emoji': '🎯',
      },
      {
        'name': 'Hard',
        'desc': 'For sharp minds',
        'color': Colors.red,
        'emoji': '💪',
      },
      {
        'name': 'Expert',
        'desc': 'Extreme difficulty',
        'color': Colors.purple,
        'emoji': '🧠',
      },
      {
        'name': 'Professional',
        'desc': 'Master level',
        'color': Colors.amber,
        'emoji': '👑',
      },
      {
        'name': 'Extreme',
        'desc': 'Ultimate challenge',
        'color': Colors.deepOrange,
        'emoji': '⚡',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DifficultyHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Your Challenge",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Pick a difficulty level and start solving",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Consumer<GameState>(
                builder: (context, gameState, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: difficulties.length,
                      itemBuilder: (context, index) {
                        final diff = difficulties[index];
                        final diffName = diff['name'] as String;
                        final requirement = gameState.getDifficultyRequirement(
                          diffName,
                        );

                        return DifficultyCard(
                          difficulty: diff,
                          onLockedTap: () {
                            DifficultyDialogs.showLockedDialog(
                              context,
                              requirement,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
