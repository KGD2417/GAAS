import 'package:flutter/material.dart';
import '../utils/styles.dart';

class GpuCard extends StatefulWidget {
  final String title;
  final String specs;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const GpuCard({
    super.key,
    required this.title,
    required this.specs,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<GpuCard> createState() => _GpuCardState();
}

class _GpuCardState extends State<GpuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: widget.isSelected
              ? AppStyles.selectedCardDecoration()
              : AppStyles.glowingCardDecoration(),
          child: Column(
            children: [
              Icon(
                Icons.memory,
                size: 48,
                color: widget.isSelected || _isHovered
                    ? AppColors.cyan
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: AppStyles.heading3.copyWith(
                  color: widget.isSelected ? AppColors.cyan : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.specs,
                style: AppStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.cyan.withOpacity(0.2)
                      : AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.price,
                  style: TextStyle(
                    color: widget.isSelected ? AppColors.cyan : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}