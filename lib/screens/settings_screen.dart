import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingCard(
            'App Settings',
            [
              _buildSettingTile(
                'Notifications',
                'Manage notification preferences',
                Icons.notifications_outlined,
                onTap: () {
                  // Add notification settings logic
                },
              ),
              _buildSettingTile(
                'Theme',
                'Change app appearance',
                Icons.palette_outlined,
                onTap: () {
                  // Add theme settings logic
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            'Data Settings',
            [
              _buildSettingTile(
                'Data Refresh',
                'Configure auto-refresh interval',
                Icons.refresh,
                onTap: () {
                  // Add refresh settings logic
                },
              ),
              _buildSettingTile(
                'Storage',
                'Manage local data storage',
                Icons.storage_outlined,
                onTap: () {
                  // Add storage settings logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
