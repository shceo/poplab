import 'package:flutter/material.dart';
import '../models/player_data.dart';
import '../services/storage_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
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

  Future<void> _purchaseItem(ShopItem item) async {
    if (_playerData == null) return;

    final price = item.getNextPrice();

    if (_playerData!.totalCapsules < price) {
      _showInsufficientFundsDialog();
      return;
    }

    final updated = await _storageService.purchaseItem(_playerData!, item.id);

    setState(() {
      _playerData = updated;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Куплено: ${item.name}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Недостаточно капсул',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Играйте больше, чтобы заработать капсулы!',
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
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Магазин',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bubble_chart,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_playerData?.totalCapsules ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Список предметов
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _playerData?.shopItems.length ?? 0,
                        itemBuilder: (context, index) {
                          final item = _playerData!.shopItems[index];
                          return _buildShopItem(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopItem(ShopItem item) {
    final canPurchase = _playerData != null &&
        _playerData!.totalCapsules >= item.getNextPrice() &&
        item.level < item.maxLevel;

    final isMaxLevel = item.level >= item.maxLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Иконка
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getItemColor(item.id).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getItemIcon(item.id),
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                if (item.maxLevel > 1) ...[
                  Row(
                    children: [
                      Text(
                        'Уровень: ${item.level}/${item.maxLevel}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: item.level / item.maxLevel,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getItemColor(item.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Кнопка покупки
          ElevatedButton(
            onPressed: canPurchase ? () => _purchaseItem(item) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canPurchase
                  ? Colors.amber
                  : Colors.grey,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Column(
              children: [
                if (isMaxLevel)
                  const Text(
                    'МАКС',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      const Icon(Icons.bubble_chart, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${item.getNextPrice()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Купить',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(String itemId) {
    switch (itemId) {
      case 'clean_filter':
        return Icons.filter_alt;
      case 'tap_radius':
        return Icons.touch_app;
      case 'slow_motion':
        return Icons.slow_motion_video;
      case 'skin_blue':
        return Icons.palette;
      case 'skin_green':
        return Icons.color_lens;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getItemColor(String itemId) {
    switch (itemId) {
      case 'clean_filter':
        return Colors.blue;
      case 'tap_radius':
        return Colors.green;
      case 'slow_motion':
        return Colors.purple;
      case 'skin_blue':
        return Colors.lightBlue;
      case 'skin_green':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }
}
