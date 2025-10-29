import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameHUD extends StatelessWidget {
  final GameState state;
  final VoidCallback onPause;

  const GameHUD({
    super.key,
    required this.state,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top panel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score and combo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: ${state.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    if (state.combo > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Combo: x${state.combo}',
                        style: TextStyle(
                          color: _getComboColor(state.combo),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (state.multiplier > 1.0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Multiplier: x${state.multiplier.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                // Pause button and timer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white, size: 32),
                      onPressed: onPause,
                    ),
                    if (state.mode == GameMode.timeAttack) ...[
                      Text(
                        '${state.timeRemaining.toInt()}s',
                        style: TextStyle(
                          color: state.timeRemaining < 10
                              ? Colors.red
                              : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Streak indicator
            if (state.currentStreak >= 10) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'Streak: ${state.currentStreak} 🔥',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Sprint challenge
            if (state.isSprintActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'SPRINT CHALLENGE!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Collect ${state.sprintTarget} O₂ in ${state.sprintTimeRemaining.toInt()}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: state.sprintProgress / state.sprintTarget,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.sprintProgress} / ${state.sprintTarget}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Reward: ${state.sprintReward} capsules',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Color _getComboColor(int combo) {
    if (combo >= 50) return Colors.purple;
    if (combo >= 30) return Colors.red;
    if (combo >= 20) return Colors.orange;
    if (combo >= 10) return Colors.yellow;
    return Colors.green;
  }
}
