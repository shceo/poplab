import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to reset all progress? This action cannot be undone.\n\nThis will clear:\n• All scores and statistics\n• Achievements\n• Purchased items\n• Capsules',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final storageService = StorageService();
      await storageService.clearPlayerData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Return to menu and reload data
        Navigator.of(context).pop();
      }
    }
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Game Card
                      _buildInfoCard(
                        title: 'About Bubble Pop Lab',
                        children: [
                          const Text(
                            'Welcome to Bubble Pop Lab - an exciting bubble-popping game where you test your reflexes and chemistry knowledge!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.bubble_chart, 'Pop O₂ bubbles to earn points'),
                          _buildInfoRow(Icons.warning_amber, 'Avoid toxic bubbles or lose lives'),
                          _buildInfoRow(Icons.timer, 'Different game modes for different challenges'),
                          _buildInfoRow(Icons.emoji_events, 'Unlock achievements and earn rewards'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Game Modes Card
                      _buildInfoCard(
                        title: 'Game Modes',
                        children: [
                          _buildModeInfo(
                            'Arcade Mode',
                            'Endless gameplay - pop bubbles and set high scores with no time limit. Challenge yourself to survive as long as possible!',
                            Icons.all_inclusive,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildModeInfo(
                            'Time Attack',
                            '90 seconds of intense action - pop as many bubbles as you can before time runs out. Speed and accuracy are key!',
                            Icons.timer,
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildModeInfo(
                            'Daily Lab Test',
                            'Special daily challenge with unique bubble patterns. Complete it once per day for exclusive rewards!',
                            Icons.calendar_today,
                            Colors.purple,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Version Info
                      _buildInfoCard(
                        title: 'App Information',
                        children: [
                          _buildInfoRow(Icons.info_outline, 'Version: 1.0.0'),
                          _buildInfoRow(Icons.code, 'Built with Flutter'),
                          _buildInfoRow(Icons.color_lens, 'Theme: Dark Blue Laboratory'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Clear Data Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _clearData(context),
                    icon: const Icon(Icons.delete_forever, size: 28),
                    label: const Text(
                      'Clear All Data',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
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

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeInfo(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
