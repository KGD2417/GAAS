import 'package:flutter/material.dart';
import '../utils/styles.dart';

class FileUploadBox extends StatefulWidget {
  final String label;
  final IconData icon;
  final String fileName;
  final VoidCallback onTap;

  const FileUploadBox({
    super.key,
    required this.label,
    required this.icon,
    required this.fileName,
    required this.onTap,
  });

  @override
  State<FileUploadBox> createState() => _FileUploadBoxState();
}

class _FileUploadBoxState extends State<FileUploadBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.fileName != 'No file selected';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: hasFile
              ? AppStyles.selectedCardDecoration()
              : AppStyles.glowingCardDecoration(
            glowColor: _isHovered ? AppColors.cyan : AppColors.textTertiary,
          ),
          child: Column(
            children: [
              Icon(
                widget.icon,
                size: 48,
                color: hasFile || _isHovered
                    ? AppColors.cyan
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: AppStyles.heading3.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.fileName,
                style: AppStyles.body.copyWith(
                  color: hasFile ? AppColors.cyan : AppColors.textTertiary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: hasFile
                      ? AppColors.cyan.withOpacity(0.2)
                      : AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasFile
                        ? AppColors.cyan
                        : AppColors.textTertiary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  hasFile ? 'Change File' : 'Choose File',
                  style: TextStyle(
                    color: hasFile ? AppColors.cyan : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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