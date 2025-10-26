import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../services/storage_service.dart';
import '../services/achievement_service.dart';
import '../models/player_data.dart';
import '../widgets/bubble_widget.dart';
import '../widgets/hazard_widget.dart';
import '../widgets/game_hud.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final int? dailySeed;

  const GameScreen({
    super.key,
    required this.mode,
    this.dailySeed,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine _gameEngine;
  late Ticker _ticker;
  late StorageService _storageService;
  late AchievementService _achievementService;

  Duration _lastElapsed = Duration.zero;
  PlayerData? _playerData;

  @override
  void initState() {
    super.initState();

    _storageService = StorageService();
    _achievementService = AchievementService(_storageService);
    _gameEngine = GameEngine();

    _loadPlayerData();

    // Создаем Ticker для игрового цикла
    _ticker = createTicker(_onTick);

    // Запускаем игру после первого фрейма
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _gameEngine.setScreenSize(size);
      _gameEngine.startGame(widget.mode, seed: widget.dailySeed);
      _ticker.start();
    });

    _gameEngine.addListener(_onGameStateChanged);
  }

  Future<void> _loadPlayerData() async {
    final data = await _storageService.loadPlayerData();
    setState(() {
      _playerData = data;
    });
  }

  void _onTick(Duration elapsed) {
    if (_gameEngine.state.status != GameStatus.playing) return;

    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;

    if (dt > 0 && dt < 0.1) {
      // Ограничиваем dt для стабильности
      _gameEngine.update(dt);
    }
  }

  void _onGameStateChanged() {
    if (_gameEngine.state.status == GameStatus.gameOver) {
      _handleGameOver();
    }
    setState(() {});
  }

  Future<void> _handleGameOver() async {
    if (_playerData == null) return;

    // Обновляем рекорды
    String modeStr = 'arcade';
    if (widget.mode == GameMode.timeAttack) modeStr = 'timeAttack';
    if (widget.mode == GameMode.daily) modeStr = 'daily';

    var updatedData = await _storageService.updateHighScore(
      _playerData!,
      _gameEngine.state.score,
      modeStr,
    );

    // Проверяем достижения
    updatedData = await _achievementService.checkAchievements(
      updatedData,
      _gameEngine.state,
    );

    // Обновляем статистику
    updatedData = updatedData.copyWith(
      totalOxygenPopped:
          updatedData.totalOxygenPopped + _gameEngine.state.oxygenPopped,
      totalGamesPlayed: updatedData.totalGamesPlayed + 1,
      longestStreak: updatedData.longestStreak > _gameEngine.state.longestStreak
          ? updatedData.longestStreak
          : _gameEngine.state.longestStreak,
      totalCapsules: updatedData.totalCapsules + _gameEngine.state.capsules,
    );

    await _storageService.savePlayerData(updatedData);

    setState(() {
      _playerData = updatedData;
    });

    // Показываем диалог Game Over
    if (mounted) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Игра Окончена!',
          style: TextStyle(color: Colors.white, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Счет: ${_gameEngine.state.score}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Лучшая серия: ${_gameEngine.state.longestStreak}',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'O₂ собрано: ${_gameEngine.state.oxygenPopped}',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Капсулы: +${_gameEngine.state.capsules}',
              style: const TextStyle(color: Colors.amber, fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Главное меню',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Играть снова'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    _lastElapsed = Duration.zero;
    _gameEngine.startGame(widget.mode, seed: widget.dailySeed);
    _ticker.start();
  }

  void _pauseGame() {
    _gameEngine.pauseGame();
    _showPauseDialog();
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Пауза',
          style: TextStyle(color: Colors.white, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Счет: ${_gameEngine.state.score}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              _gameEngine.returnToMenu();
            },
            child: const Text(
              'Выход',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _gameEngine.resumeGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _gameEngine.removeListener(_onGameStateChanged);
    _gameEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          _gameEngine.onTap(details.localPosition);
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Частицы фона (необязательно)
              ..._buildBackgroundParticles(),

              // Пузыри
              ..._gameEngine.bubbles.map((bubble) {
                return BubbleWidget(bubble: bubble);
              }),

              // Опасности
              ..._gameEngine.hazards.map((hazard) {
                return HazardWidget(hazard: hazard);
              }),

              // HUD
              GameHUD(
                state: _gameEngine.state,
                onPause: _pauseGame,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundParticles() {
    // Простые декоративные элементы
    return List.generate(10, (index) {
      return Positioned(
        left: (index * 50.0) % MediaQuery.of(context).size.width,
        top: (index * 80.0) % MediaQuery.of(context).size.height,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      );
    });
  }
}
