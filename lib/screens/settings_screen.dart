import 'package:flutter/material.dart';
import '../utils/styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoSave = true;
  String _theme = 'Dark';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppStyles.heading1),
          const SizedBox(height: 32),

          _buildSettingCard(
            'Notifications',
            'Receive updates about your training jobs',
            Switch(
              value: _notifications,
              onChanged: (val) => setState(() => _notifications = val),
              activeColor: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingCard(
            'Auto-save Progress',
            'Automatically save your work',
            Switch(
              value: _autoSave,
              onChanged: (val) => setState(() => _autoSave = val),
              activeColor: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingCard(
            'Theme',
            'Choose your preferred theme',
            DropdownButton<String>(
              value: _theme,
              dropdownColor: AppColors.cardBackground,
              style: const TextStyle(color: AppColors.textPrimary),
              items: ['Dark', 'Light', 'Auto'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => setState(() => _theme = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, Widget trailing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.glowingCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.heading3),
                const SizedBox(height: 4),
                Text(subtitle, style: AppStyles.body),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
