import 'package:flutter/material.dart';
import '../models/player_data.dart';
import '../services/storage_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final StorageService _storageService = StorageService();
  PlayerData? _playerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    final data = await _storageService.loadPlayerData();
    setState(() {
      _playerData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics
              if (_playerData != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Unlocked',
                          '${_playerData!.achievements.where((a) => a.unlocked).length}/${_playerData!.achievements.length}',
                          Icons.emoji_events,
                        ),
                        _buildStatItem(
                          'Games',
                          '${_playerData!.totalGamesPlayed}',
                          Icons.gamepad,
                        ),
                        _buildStatItem(
                          'Total O₂',
                          '${_playerData!.totalOxygenPopped}',
                          Icons.bubble_chart,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Achievements list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _playerData?.achievements.length ?? 0,
                        itemBuilder: (context, index) {
                          final achievement = _playerData!.achievements[index];
                          return _buildAchievementCard(achievement);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? Colors.amber.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked
              ? Colors.amber.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.unlocked
                  ? Icons.emoji_events
                  : Icons.lock,
              color: achievement.unlocked
                  ? Colors.amber
                  : Colors.white70,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          // Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color: achievement.unlocked
                        ? Colors.white
                        : Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: achievement.unlocked
                        ? Colors.white70
                        : Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.bubble_chart,
                      size: 16,
                      color: achievement.unlocked
                          ? Colors.amber
                          : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reward: ${achievement.reward} capsules',
                      style: TextStyle(
                        color: achievement.unlocked
                            ? Colors.amber
                            : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status
          if (achievement.unlocked)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            )
          else
            Icon(
              Icons.radio_button_unchecked,
              color: Colors.white.withOpacity(0.3),
              size: 32,
            ),
        ],
      ),
    );
  }
}
