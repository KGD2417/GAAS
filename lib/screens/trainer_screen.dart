import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/styles.dart';
import '../widgets/glowing_button.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({super.key});

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen> {
  String _workerStatus = "unknown";
  String _workerLogs = "";
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _pollWorkerStatus();
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  void _pollWorkerStatus() {
    Future.doWhile(() async {
      if (!_isPolling) return false;

      await Future.delayed(const Duration(seconds: 3));

      final status = await ApiService.getLocalWorkerStatus();
      final logs = await ApiService.getWorkerLogs();

      if (!mounted) return false;

      setState(() {
        _workerStatus = status?['online'] == true ? "Online" : "Offline";
        _workerLogs = logs ?? "";
      });

      return _isPolling;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Become a GPU Trainer', style: AppStyles.heading1),
          const SizedBox(height: 8),
          Text('Rent out your GPU power and earn money', style: AppStyles.body),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlowingButton(
                      text: 'Start Worker',
                      onPressed:
                          _workerStatus == "Online"
                              ? null
                              : () async {
                                final success =
                                    await ApiService.startLocalWorker();

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? "🚀 Worker Started"
                                          : "❌ Failed to Start Worker",
                                    ),
                                  ),
                                );
                              },
                      width: 140,
                    ),
                    const SizedBox(width: 20),
                    GlowingButton(
                      text: 'Stop Worker',
                      onPressed:
                          _workerStatus == "Offline"
                              ? null
                              : () async {
                                final success =
                                    await ApiService.stopLocalWorker();

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? "🛑 Worker Stopped"
                                          : "❌ Failed to Stop Worker",
                                    ),
                                  ),
                                );
                              },
                      width: 140,
                      color: AppColors.error,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _workerStatus == "Online"
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color:
                          _workerStatus == "Online" ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Worker Status: $_workerStatus",
                      style: AppStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  color: Colors.black,
                  child: SingleChildScrollView(
                    child: Text(
                      _workerLogs,
                      style: const TextStyle(
                        fontFamily: "monospace",
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
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
