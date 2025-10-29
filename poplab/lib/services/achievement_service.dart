import '../models/game_state.dart';
import '../models/player_data.dart';
import 'storage_service.dart';

class AchievementService {
  final StorageService _storageService;

  AchievementService(this._storageService);

  Future<PlayerData> checkAchievements(
    PlayerData playerData,
    GameState gameState,
  ) async {
    PlayerData updated = playerData;

    // Pure Air - streak of 50
    if (gameState.longestStreak >= 50) {
      updated = await _storageService.unlockAchievement(updated, 'pure_air');
    }

    // Toxic-Free - no toxins
    if (gameState.toxicHit == 0 && gameState.oxygenPopped > 10) {
      updated = await _storageService.unlockAchievement(updated, 'toxic_free');
    }

    // Oxygen Master - 1000 O₂ in total
    final totalOxygen = updated.totalOxygenPopped + gameState.oxygenPopped;
    if (totalOxygen >= 1000) {
      updated = await _storageService.unlockAchievement(updated, 'oxygen_master');
    }

    // Score Legend - 10000 points
    if (gameState.score >= 10000) {
      updated = await _storageService.unlockAchievement(updated, 'score_legend');
    }

    return updated;
  }

  List<Achievement> getUnlockedAchievements(PlayerData data) {
    return data.achievements.where((a) => a.unlocked).toList();
  }

  int getTotalRewardsEarned(PlayerData data) {
    return data.achievements
        .where((a) => a.unlocked)
        .fold(0, (sum, a) => sum + a.reward);
  }
}
