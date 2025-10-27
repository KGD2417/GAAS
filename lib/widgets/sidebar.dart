import 'package:flutter/material.dart';
import '../utils/styles.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.cardBackground,
      child: Column(
        children: [
          // Logo section
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: AppColors.cyan,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'GAAS',
                  style: AppStyles.heading2.copyWith(color: AppColors.cyan),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.textTertiary, height: 1),
          const SizedBox(height: 16),

          // Menu items
          _buildMenuItem(0, Icons.model_training, 'Train Model'),
          _buildMenuItem(1, Icons.person_add, 'Become a Trainer'),
          _buildMenuItem(2, Icons.settings, 'Settings'),
          _buildMenuItem(3, Icons.account_circle, 'Profile'),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'v1.0.0',
                  style: AppStyles.body.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 GAAS',
                  style: AppStyles.body.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = widget.selectedIndex == index;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => widget.onItemSelected(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyan.withOpacity(0.15)
                : isHovered
                ? AppColors.cardBackgroundLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.cyan.withOpacity(0.5), width: 1)
                : null,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.cyan.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.cyan : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.cyan : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}