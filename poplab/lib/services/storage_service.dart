import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_data.dart';

class StorageService {
  static const String _playerDataKey = 'player_data';

  // Достижения по умолчанию
  static final List<Achievement> defaultAchievements = [
    const Achievement(
      id: 'pure_air',
      name: 'Pure Air',
      description: 'Достигните серии из 50 O₂ пузырей',
      requirement: 50,
      reward: 100,
    ),
    const Achievement(
      id: 'lab_hero',
      name: 'Lab Hero',
      description: 'Завершите 3 спринта подряд',
      requirement: 3,
      reward: 150,
    ),
    const Achievement(
      id: 'toxic_free',
      name: 'Toxic-Free',
      description: 'Не лопните ни одного токсичного пузыря за игру',
      requirement: 1,
      reward: 200,
    ),
    const Achievement(
      id: 'oxygen_master',
      name: 'Oxygen Master',
      description: 'Лопните 1000 O₂ пузырей всего',
      requirement: 1000,
      reward: 250,
    ),
    const Achievement(
      id: 'score_legend',
      name: 'Score Legend',
      description: 'Наберите 10000 очков в одной игре',
      requirement: 10000,
      reward: 300,
    ),
  ];

  // Предметы магазина по умолчанию
  static final List<ShopItem> defaultShopItems = [
    const ShopItem(
      id: 'clean_filter',
      name: 'Чистый Фильтр',
      description: 'Удаляет все токсичные пузыри на 5 секунд',
      price: 100,
      maxLevel: 3,
    ),
    const ShopItem(
      id: 'tap_radius',
      name: 'Расширение Зоны',
      description: 'Увеличивает радиус тапа',
      price: 150,
      maxLevel: 5,
    ),
    const ShopItem(
      id: 'slow_motion',
      name: 'Замедление',
      description: 'Замедляет время на 3 секунды',
      price: 120,
      maxLevel: 3,
    ),
    const ShopItem(
      id: 'skin_blue',
      name: 'Синяя Лаборатория',
      description: 'Скин лаборатории',
      price: 200,
      maxLevel: 1,
    ),
    const ShopItem(
      id: 'skin_green',
      name: 'Зеленая Лаборатория',
      description: 'Скин лаборатории',
      price: 250,
      maxLevel: 1,
    ),
  ];

  Future<PlayerData> loadPlayerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_playerDataKey);

      if (jsonString == null) {
        return PlayerData(
          achievements: defaultAchievements,
          shopItems: defaultShopItems,
        );
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerData.fromJson(
        json,
        defaultAchievements: defaultAchievements,
        defaultShopItems: defaultShopItems,
      );
    } catch (e) {
      // В случае ошибки возвращаем дефолтные данные
      return PlayerData(
        achievements: defaultAchievements,
        shopItems: defaultShopItems,
      );
    }
  }

  Future<void> savePlayerData(PlayerData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(_playerDataKey, jsonString);
    } catch (e) {
      // Логируем ошибку, но не бросаем исключение
      print('Error saving player data: $e');
    }
  }

  Future<void> clearPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerDataKey);
  }

  Future<PlayerData> updateHighScore(
    PlayerData data,
    int score,
    String mode,
  ) async {
    PlayerData updated = data;

    switch (mode) {
      case 'arcade':
        if (score > data.highScoreArcade) {
          updated = data.copyWith(highScoreArcade: score);
        }
        break;
      case 'timeAttack':
        if (score > data.highScoreTimeAttack) {
          updated = data.copyWith(highScoreTimeAttack: score);
        }
        break;
      case 'daily':
        if (score > data.highScoreDaily) {
          updated = data.copyWith(highScoreDaily: score);
        }
        break;
    }

    await savePlayerData(updated);
    return updated;
  }

  Future<PlayerData> unlockAchievement(
    PlayerData data,
    String achievementId,
  ) async {
    final achievements = data.achievements.map((a) {
      if (a.id == achievementId && !a.unlocked) {
        return a.copyWith(unlocked: true);
      }
      return a;
    }).toList();

    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    final newCapsules = achievement.unlocked ? data.totalCapsules + achievement.reward : data.totalCapsules;

    final updated = data.copyWith(
      achievements: achievements,
      totalCapsules: newCapsules,
    );

    await savePlayerData(updated);
    return updated;
  }

  Future<PlayerData> purchaseItem(
    PlayerData data,
    String itemId,
  ) async {
    final item = data.shopItems.firstWhere((s) => s.id == itemId);

    if (data.totalCapsules < item.getNextPrice()) {
      return data; // Недостаточно средств
    }

    final shopItems = data.shopItems.map((s) {
      if (s.id == itemId && s.level < s.maxLevel) {
        return s.copyWith(
          level: s.level + 1,
          purchased: true,
        );
      }
      return s;
    }).toList();

    final updated = data.copyWith(
      shopItems: shopItems,
      totalCapsules: data.totalCapsules - item.getNextPrice(),
    );

    await savePlayerData(updated);
    return updated;
  }
}
