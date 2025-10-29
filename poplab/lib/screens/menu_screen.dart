import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/player_data.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  PlayerData? _playerData;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _loadPlayerData();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadPlayerData() async {
    final data = await _storageService.loadPlayerData();
    setState(() {
      _playerData = data;
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  int _getDailySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  bool _canPlayDaily() {
    if (_playerData == null) return true;

    final lastPlayed = _playerData!.lastDailyPlayed;
    if (lastPlayed == null) return true;

    final now = DateTime.now();
    return lastPlayed.year != now.year ||
        lastPlayed.month != now.month ||
        lastPlayed.day != now.day;
  }

  Future<void> _updateDailyPlayed() async {
    if (_playerData == null) return;

    final updated = _playerData!.copyWith(
      lastDailyPlayed: DateTime.now(),
      dailySeed: _getDailySeed(),
    );

    await _storageService.savePlayerData(updated);
    setState(() {
      _playerData = updated;
    });
  }

  void _startGame(GameMode mode) async {
    int? seed;
    if (mode == GameMode.daily) {
      if (!_canPlayDaily()) {
        _showDailyAlreadyPlayedDialog();
        return;
      }
      seed = _getDailySeed();
      await _updateDailyPlayed();
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          mode: mode,
          dailySeed: seed,
        ),
      ),
    ).then((_) {
      _loadPlayerData();
    });
  }

  void _showDailyAlreadyPlayedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Daily Test',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You have already completed today\'s test! Come back tomorrow.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),

                  // Title
              AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingController.value * 10 - 5),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      'Bubble Pop Lab',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'O₂ Bubbles',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Player statistics
              if (_playerData != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Capsules',
                        '${_playerData!.totalCapsules}',
                        Icons.bubble_chart,
                      ),
                      _buildStatCard(
                        'Record',
                        '${_playerData!.highScoreArcade}',
                        Icons.emoji_events,
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Mode buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildModeButton(
                      title: 'ARCADE',
                      subtitle: 'Endless mode',
                      icon: Icons.all_inclusive,
                      color: Colors.blue,
                      onTap: () => _startGame(GameMode.arcade),
                    ),
                    const SizedBox(height: 16),
                    _buildModeButton(
                      title: 'TIME ATTACK',
                      subtitle: '90 seconds',
                      icon: Icons.timer,
                      color: Colors.orange,
                      onTap: () => _startGame(GameMode.timeAttack),
                    ),
                    const SizedBox(height: 16),
                    _buildModeButton(
                      title: 'DAILY LAB TEST',
                      subtitle: _canPlayDaily()
                          ? 'Daily test'
                          : 'Completed today',
                      icon: Icons.calendar_today,
                      color: _canPlayDaily() ? Colors.purple : Colors.grey,
                      onTap: () => _startGame(GameMode.daily),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomButton(
                      icon: Icons.shopping_bag,
                      label: 'Shop',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ShopScreen(),
                          ),
                        ).then((_) => _loadPlayerData());
                      },
                    ),
                    _buildBottomButton(
                      icon: Icons.emoji_events,
                      label: 'Achievements',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AchievementsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
                ],
              ),

              // Settings icon in top right corner
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ).then((_) => _loadPlayerData());
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
