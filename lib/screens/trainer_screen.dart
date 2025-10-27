import 'package:flutter/material.dart';
import '../utils/styles.dart';
import '../widgets/glowing_button.dart';

class TrainerScreen extends StatelessWidget {
  const TrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Become a GPU Trainer', style: AppStyles.heading1),
          const SizedBox(height: 8),
          Text(
            'Rent out your GPU power and earn money',
            style: AppStyles.body,
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(32),
            decoration: AppStyles.glowingCardDecoration(),
            child: Column(
              children: [
                Icon(Icons.computer, size: 80, color: AppColors.cyan),
                const SizedBox(height: 24),
                Text(
                  'Share Your GPU Power',
                  style: AppStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Connect your GPU and start earning passive income by helping others train their AI models.',
                  style: AppStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildInfoRow(
                  Icons.speed,
                  'Fast Setup',
                  'Connect in under 5 minutes',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.attach_money,
                  'Earn Money',
                  'Get paid per hour of usage',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.security,
                  'Secure & Safe',
                  'Enterprise-grade security',
                ),
                const SizedBox(height: 32),

                GlowingButton(
                  text: 'Register as Trainer',
                  onPressed: () {
                    print('🎯 Trainer registration clicked');
                  },
                  width: 300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.cyan, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppStyles.heading3),
            Text(subtitle, style: AppStyles.body),
          ],
        ),
      ],
    );
  }
}