import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles.dart';
import '../services/auth_provider.dart';
import '../widgets/glowing_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppStyles.heading1),
          const SizedBox(height: 32),

          Center(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              decoration: AppStyles.glowingCardDecoration(),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.cyan.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(authProvider.userEmail, style: AppStyles.heading2),
                  const SizedBox(height: 8),
                  Text('Active User', style: AppStyles.body),
                  const SizedBox(height: 32),

                  _buildStatRow('Total Jobs', '12'),
                  const Divider(height: 32, color: AppColors.textTertiary),
                  _buildStatRow('GPU Hours', '48.5'),
                  const Divider(height: 32, color: AppColors.textTertiary),
                  _buildStatRow('Total Spent', '\$87.20'),
                  const SizedBox(height: 32),

                  GlowingButton(
                    text: 'Logout',
                    onPressed: () {
                      authProvider.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    color: AppColors.error,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.body),
        Text(
          value,
          style: AppStyles.heading3.copyWith(color: AppColors.cyan),
        ),
      ],
    );
  }
}