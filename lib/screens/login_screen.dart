import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_provider.dart';
import '../utils/styles.dart';
import '../widgets/glowing_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late List<AnimationController> _gpuAnimations;

  @override
  void initState() {
    super.initState();
    // Create animated floating GPUs with varied durations
    _gpuAnimations = List.generate(
      8,
          (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 400)),
        vsync: this,
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    for (var controller in _gpuAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.cardBackground,
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Animated floating GPU background
          ...List.generate(8, (index) {
            final positions = [
              {'left': 0.05, 'startTop': 0.1},
              {'left': 0.15, 'startTop': 0.6},
              {'left': 0.25, 'startTop': 0.2},
              {'left': 0.40, 'startTop': 0.7},
              {'left': 0.55, 'startTop': 0.15},
              {'left': 0.70, 'startTop': 0.5},
              {'left': 0.82, 'startTop': 0.25},
              {'left': 0.92, 'startTop': 0.65},
            ];

            final pos = positions[index];
            final sizes = [60.0, 80.0, 70.0, 90.0, 65.0, 75.0, 85.0, 95.0];
            final opacities = [0.08, 0.12, 0.1, 0.15, 0.09, 0.13, 0.11, 0.14];

            return AnimatedBuilder(
              animation: _gpuAnimations[index],
              builder: (context, child) {
                // Calculate smooth up-down movement
                final movement = _gpuAnimations[index].value;
                final yOffset = (movement - 0.5) * 200; // Movement range

                return Positioned(
                  left: size.width * pos['left']! - sizes[index] / 2,
                  top: size.height * pos['startTop']! + yOffset,
                  child: Opacity(
                    opacity: opacities[index],
                    child: Transform.rotate(
                      angle: movement * 0.3 - 0.15, // Subtle rotation
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withOpacity(0.2),
                              blurRadius: 50,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: Image.asset("assets/gpu1.png", height: 250,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Add some particles for extra effect
          ...List.generate(15, (index) {
            return AnimatedBuilder(
              animation: _gpuAnimations[index % 8],
              builder: (context, child) {
                final movement = _gpuAnimations[index % 8].value;
                final xPos = (index * 0.07 * size.width) % size.width;
                final yPos = movement * size.height;

                return Positioned(
                  left: xPos,
                  top: yPos,
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cyan.withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // Login form with glassmorphism
          Center(
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppColors.cardBackground.withOpacity(0.7),
                border: Border.all(
                  color: AppColors.cyan.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo and title with glow effect
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.memory,
                      size: 80,
                      color: AppColors.cyan,
                    ),
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: 20),
                  Text(
                    'GAAS',
                    style: AppStyles.heading1.copyWith(
                      fontSize: 48,
                      color: AppColors.cyan,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: AppColors.cyan.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).shimmer(
                    duration: 2000.ms,
                    color: AppColors.cyan.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPU as a Service',
                    style: AppStyles.body.copyWith(
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 40),

                  // Email field
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.email, color: AppColors.cyan),
                      filled: true,
                      fillColor: AppColors.cardBackgroundLight.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.cyan, width: 2),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideX(),
                  const SizedBox(height: 20),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.lock, color: AppColors.cyan),
                      filled: true,
                      fillColor: AppColors.cardBackgroundLight.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.cyan, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _handleLogin(),
                  ).animate().fadeIn(delay: 800.ms).slideX(),
                  const SizedBox(height: 30),

                  // Login button
                  GlowingButton(
                    text: _isLoading ? 'Logging in...' : 'Login',
                    onPressed: _isLoading ? null : _handleLogin,
                    width: double.infinity,
                  ).animate().fadeIn(delay: 1000.ms).scale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}