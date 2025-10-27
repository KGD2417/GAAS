import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/styles.dart';
import '../widgets/sidebar.dart';
import '../widgets/glowing_button.dart';
import '../services/api_service.dart';
import 'trainer_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedGpu = 'Medium';
  String? _datasetPath;
  String? _modelPath;
  final _pythonCodeController = TextEditingController();
  final _requirementsController = TextEditingController();
  bool _useCodeUpload = true;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pythonCodeController.dispose();
    _requirementsController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isDataset) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          isDataset ? ['csv', 'zip', 'json', 'txt'] : ['py', 'ipynb'],
    );

    if (result != null) {
      setState(() {
        if (isDataset) {
          _datasetPath = result.files.single.path;
        } else {
          _modelPath = result.files.single.path;
        }
      });
    }
  }

  Future<void> _startTraining() async {
    if (_datasetPath == null && _pythonCodeController.text.isEmpty) {
      _showErrorDialog('Please upload dataset and code');
      return;
    }

    final confirmed = await _showTrainingConfirmationDialog();
    if (!confirmed) return;

    final success = await ApiService.startTraining(
      gpuSize: _selectedGpu,
      datasetPath: _datasetPath,
      modelPath: _modelPath,
      pythonCode: _useCodeUpload ? null : _pythonCodeController.text,
      requirements: _requirementsController.text,
    );

    if (mounted) {
      if (success != null) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Failed to start training');
      }
    }
  }

  Future<bool> _showTrainingConfirmationDialog() async {
    final gpuPrices = {'Small': 0.50, 'Medium': 1.20, 'Large': 2.50};
    final price = gpuPrices[_selectedGpu]!;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => _ModernDialog(
                title: 'Start Training?',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.cyan.withOpacity(0.1),
                            AppColors.cyanDark.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.cyan.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.memory, size: 60, color: AppColors.cyan)
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shimmer(
                                duration: 2000.ms,
                                color: AppColors.cyan.withOpacity(0.3),
                              ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedGpu,
                            style: AppStyles.heading2.copyWith(
                              color: AppColors.cyan,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$$price/hour',
                            style: AppStyles.body.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoRow(
                      icon: Icons.dataset,
                      label: 'Dataset',
                      value: _datasetPath?.split('/').last ?? 'Code only',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.code,
                      label: 'Model',
                      value: _modelPath?.split('/').last ?? 'Inline code',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You will be charged based on actual usage time',
                              style: AppStyles.body.copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppColors.textSecondary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Cancel', style: AppStyles.body),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlowingButton(
                            text: 'Start Training',
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ) ??
        false;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _ModernDialog(
            title: 'Training Started!',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.success.withOpacity(0.3),
                        AppColors.success.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success,
                  ),
                ).animate().scale(duration: 500.ms).then().shimmer(),
                const SizedBox(height: 24),
                Text(
                  'Your model is now training on the cloud',
                  style: AppStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check the Trainer tab for progress',
                  style: AppStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GlowingButton(
                  text: 'View Progress',
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 1);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => _ModernDialog(
            title: 'Error',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GlowingButton(
                  text: 'OK',
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTrainModelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: 48),
          _buildGpuSelectionSection(),
          const SizedBox(height: 48),
          _buildFileUploadSection(),
          const SizedBox(height: 32),
          _buildCodeToggleSection(),
          if (!_useCodeUpload) ...[
            const SizedBox(height: 24),
            _buildPythonCodeSection(),
            const SizedBox(height: 32),
          ],
          _buildDependenciesSection(),
          const SizedBox(height: 48),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Train Your Model',
                style: AppStyles.heading1.copyWith(fontSize: 36),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 12),
              Text(
                'Select a GPU, upload your data, and deploy your training pipeline in seconds',
                style: AppStyles.body.copyWith(fontSize: 16),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _buildRotatingIcon(),
      ],
    );
  }

  Widget _buildRotatingIcon() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 6.28,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.cyan.withOpacity(0.2),
                  AppColors.cyanDark.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(Icons.memory, size: 80, color: AppColors.cyan),
          ),
        );
      },
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildGpuSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select GPU Configuration',
          style: AppStyles.heading2,
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        Text(
          'Choose the perfect GPU for your workload',
          style: AppStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _GPU3DCard(
                title: 'Small',
                subtitle: 'Light Tasks',
                vram: '8GB',
                cores: '4',
                price: '0.50',
                isSelected: _selectedGpu == 'Small',
                onTap: () => setState(() => _selectedGpu = 'Small'),
                color: Colors.blue,
                size: GPUSize.small,
                rotationController: _rotationController,
                pulseController: _pulseController,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _GPU3DCard(
                title: 'Medium',
                subtitle: 'Recommended',
                vram: '16GB',
                cores: '8',
                price: '1.20',
                isSelected: _selectedGpu == 'Medium',
                onTap: () => setState(() => _selectedGpu = 'Medium'),
                color: AppColors.cyan,
                size: GPUSize.medium,
                rotationController: _rotationController,
                pulseController: _pulseController,
                isRecommended: true,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _GPU3DCard(
                title: 'Large',
                subtitle: 'Heavy Workloads',
                vram: '24GB',
                cores: '12',
                price: '2.50',
                isSelected: _selectedGpu == 'Large',
                onTap: () => setState(() => _selectedGpu = 'Large'),
                color: AppColors.cyanDark,
                size: GPUSize.large,
                rotationController: _rotationController,
                pulseController: _pulseController,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Your Files', style: AppStyles.heading2).animate().fadeIn(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child:
                  _ModernFileUploadBox(
                    label: 'Training Dataset',
                    subtitle: 'CSV, ZIP, JSON, TXT',
                    icon: Icons.dataset,
                    fileName: _datasetPath?.split('/').last,
                    onTap: () => _pickFile(true),
                  ).animate().fadeIn(delay: 400.ms).slideX(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child:
                  _ModernFileUploadBox(
                    label: 'Model Code',
                    subtitle: 'Python (.py, .ipynb)',
                    icon: Icons.code,
                    fileName: _modelPath?.split('/').last,
                    onTap: () => _pickFile(false),
                  ).animate().fadeIn(delay: 500.ms).slideX(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCodeToggleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.code, color: AppColors.cyan, size: 24),
          const SizedBox(width: 16),
          Text('Upload Code File', style: AppStyles.body),
          const Spacer(),
          Switch(
            value: !_useCodeUpload,
            onChanged: (val) => setState(() => _useCodeUpload = !val),
            activeColor: AppColors.cyan,
          ),
          const SizedBox(width: 8),
          Text('Paste Code', style: AppStyles.body),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildPythonCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Python Code', style: AppStyles.heading3),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyan.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextField(
            controller: _pythonCodeController,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText:
                  '# Paste your Python code here...\nimport torch\nimport torch.nn as nn\n\nclass MyModel(nn.Module):\n    def __init__(self):\n        super().__init__()\n        # Your model architecture',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
            ),
          ),
        ).animate().fadeIn().slideY(),
      ],
    );
  }

  Widget _buildDependenciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dependencies & Setup',
          style: AppStyles.heading3,
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyan.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _requirementsController,
            maxLines: 4,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText:
                  'pip install torch torchvision\npip install pandas numpy scikit-learn\npip install transformers',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
            ),
          ),
        ).animate().fadeIn(delay: 700.ms),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() => _selectedGpu = 'Medium');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '✨ Auto-selected Medium GPU based on your requirements',
                  ),
                  backgroundColor: AppColors.cyan,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              side: BorderSide(
                color: AppColors.cyan.withOpacity(0.5),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: AppColors.cyan),
                const SizedBox(width: 12),
                Text(
                  'Auto-Select GPU',
                  style: AppStyles.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child:
              GlowingButton(
                text: 'Start Training',
                onPressed: _startTraining,
              ).animate().fadeIn(delay: 800.ms).scale(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTrainModelPage(),
      const TrainerScreen(),
      const SettingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
    );
  }
}

// GPU Size Enum
enum GPUSize { small, medium, large }

// 3D GPU Card with Custom 3D Models
class _GPU3DCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String vram;
  final String cores;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final GPUSize size;
  final AnimationController rotationController;
  final AnimationController pulseController;
  final bool isRecommended;

  const _GPU3DCard({
    required this.title,
    required this.subtitle,
    required this.vram,
    required this.cores,
    required this.price,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.size,
    required this.rotationController,
    required this.pulseController,
    this.isRecommended = false,
  });

  @override
  State<_GPU3DCard> createState() => _GPU3DCardState();
}

class _GPU3DCardState extends State<_GPU3DCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_isHovered ? -0.05 : 0)
                ..scale(_isHovered ? 1.02 : 1.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    widget.isSelected
                        ? [
                          widget.color.withOpacity(0.2),
                          AppColors.cardBackground,
                        ]
                        : [AppColors.cardBackground, AppColors.cardBackground],
              ),
              border: Border.all(
                color:
                    widget.isSelected
                        ? widget.color
                        : AppColors.textTertiary.withOpacity(0.2),
                width: widget.isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                if (widget.isRecommended)
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'RECOMMENDED',
                          style: AppStyles.body.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2000.ms),
                if (widget.isRecommended) const SizedBox(height: 16),

                // 3D GPU Model
                _GPU3DModel(
                  size: widget.size,
                  color: widget.color,
                  rotationController: widget.rotationController,
                  pulseController: widget.pulseController,
                  isSelected: widget.isSelected,
                ),
                const SizedBox(height: 20),

                Text(
                  widget.title,
                  style: AppStyles.heading2.copyWith(
                    fontSize: 24,
                    color:
                        widget.isSelected
                            ? widget.color
                            : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: AppStyles.body.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                _SpecRow(
                  icon: Icons.sd_card,
                  label: 'VRAM',
                  value: widget.vram,
                ),
                const SizedBox(height: 8),
                _SpecRow(
                  icon: Icons.settings,
                  label: 'Cores',
                  value: widget.cores,
                ),
                const SizedBox(height: 20),

                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        widget.color.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${widget.price}',
                      style: AppStyles.heading2.copyWith(
                        fontSize: 28,
                        color:
                            widget.isSelected
                                ? widget.color
                                : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '/hr',
                      style: AppStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom 3D GPU Model Widget
class _GPU3DModel extends StatelessWidget {
  final GPUSize size;
  final Color color;
  final AnimationController rotationController;
  final AnimationController pulseController;
  final bool isSelected;

  const _GPU3DModel({
    required this.size,
    required this.color,
    required this.rotationController,
    required this.pulseController,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([rotationController, pulseController]),
      builder: (context, child) {
        return Transform(
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(rotationController.value * 6.28)
                ..scale(1.0 + pulseController.value * 0.1),
          alignment: Alignment.center,
          child: SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _GPU3DPainter(
                size: size,
                color: color,
                animationValue: rotationController.value,
                isSelected: isSelected,
              ),
              size: const Size(120, 120),
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter for 3D GPU Models
class _GPU3DPainter extends CustomPainter {
  final GPUSize size;
  final Color color;
  final double animationValue;
  final bool isSelected;

  _GPU3DPainter({
    required this.size,
    required this.color,
    required this.animationValue,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final angle = animationValue * 2 * math.pi;

    // Base card dimensions based on GPU size
    final cardWidth =
        size == GPUSize.small
            ? 60.0
            : size == GPUSize.medium
            ? 70.0
            : 80.0;
    final cardHeight =
        size == GPUSize.small
            ? 40.0
            : size == GPUSize.medium
            ? 50.0
            : 60.0;
    final depth =
        size == GPUSize.small
            ? 8.0
            : size == GPUSize.medium
            ? 12.0
            : 16.0;

    // Paint setup
    final basePaint =
        Paint()
          ..color = color.withOpacity(0.8)
          ..style = PaintingStyle.fill;

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final highlightPaint =
        Paint()
          ..color = color.withOpacity(0.4)
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = isSelected ? color : color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // Calculate 3D rotation
    final cos = math.cos(angle);
    final sin = math.sin(angle);

    // Shadow
    final shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + cardHeight / 2 + 20),
        width: cardWidth * 1.2,
        height: depth * 2,
      ),
    );
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw GPU card body with 3D effect
    _drawGPUBody(
      canvas,
      center,
      cardWidth,
      cardHeight,
      depth,
      cos,
      sin,
      basePaint,
      highlightPaint,
      borderPaint,
    );

    // Draw cooling fans based on GPU size
    final fanCount =
        size == GPUSize.small
            ? 1
            : size == GPUSize.medium
            ? 2
            : 3;
    _drawCoolingFans(
      canvas,
      center,
      cardWidth,
      cardHeight,
      fanCount,
      angle,
      color,
    );

    // Draw PCB components
    _drawPCBComponents(canvas, center, cardWidth, cardHeight, size, color);

    // Draw glow effect if selected
    if (isSelected) {
      final glowPaint =
          Paint()
            ..color = color.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: cardWidth + 20,
            height: cardHeight + 20,
          ),
          const Radius.circular(12),
        ),
        glowPaint,
      );
    }
  }

  void _drawGPUBody(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double depth,
    double cos,
    double sin,
    Paint basePaint,
    Paint highlightPaint,
    Paint borderPaint,
  ) {
    // Main card body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, basePaint);

    // 3D depth effect (side panels)
    final sidePath = Path();
    sidePath.moveTo(center.dx + width / 2, center.dy - height / 2);
    sidePath.lineTo(
      center.dx + width / 2 + depth * cos,
      center.dy - height / 2 - depth * sin,
    );
    sidePath.lineTo(
      center.dx + width / 2 + depth * cos,
      center.dy + height / 2 - depth * sin,
    );
    sidePath.lineTo(center.dx + width / 2, center.dy + height / 2);
    sidePath.close();

    final sidePaint =
        Paint()
          ..color = basePaint.color.withOpacity(0.6)
          ..style = PaintingStyle.fill;
    canvas.drawPath(sidePath, sidePaint);

    // Top panel
    final topPath = Path();
    topPath.moveTo(center.dx - width / 2, center.dy - height / 2);
    topPath.lineTo(center.dx + width / 2, center.dy - height / 2);
    topPath.lineTo(
      center.dx + width / 2 + depth * cos,
      center.dy - height / 2 - depth * sin,
    );
    topPath.lineTo(
      center.dx - width / 2 + depth * cos,
      center.dy - height / 2 - depth * sin,
    );
    topPath.close();

    canvas.drawPath(topPath, highlightPaint);

    // Border
    canvas.drawRRect(bodyRect, borderPaint);
  }

  void _drawCoolingFans(
    Canvas canvas,
    Offset center,
    double cardWidth,
    double cardHeight,
    int fanCount,
    double angle,
    Color color,
  ) {
    final fanRadius = cardHeight / (fanCount * 2.5);
    final spacing = cardWidth / (fanCount + 1);

    for (int i = 0; i < fanCount; i++) {
      final fanCenter = Offset(
        center.dx - cardWidth / 2 + spacing * (i + 1),
        center.dy,
      );

      // Fan housing
      final fanPaint =
          Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(fanCenter, fanRadius, fanPaint);

      // Fan blades
      final bladePaint =
          Paint()
            ..color = color.withOpacity(0.6)
            ..style = PaintingStyle.fill;

      for (int j = 0; j < 6; j++) {
        final bladeAngle = angle * 4 + (j * math.pi / 3);
        final bladePath = Path();
        bladePath.moveTo(fanCenter.dx, fanCenter.dy);
        bladePath.lineTo(
          fanCenter.dx + fanRadius * 0.7 * math.cos(bladeAngle),
          fanCenter.dy + fanRadius * 0.7 * math.sin(bladeAngle),
        );
        bladePath.lineTo(
          fanCenter.dx + fanRadius * 0.5 * math.cos(bladeAngle + 0.3),
          fanCenter.dy + fanRadius * 0.5 * math.sin(bladeAngle + 0.3),
        );
        bladePath.close();
        canvas.drawPath(bladePath, bladePaint);
      }

      // Fan center
      final centerPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;
      canvas.drawCircle(fanCenter, fanRadius * 0.2, centerPaint);
    }
  }

  void _drawPCBComponents(
    Canvas canvas,
    Offset center,
    double cardWidth,
    double cardHeight,
    GPUSize size,
    Color color,
  ) {
    final componentPaint =
        Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    // Draw capacitors/chips based on size
    final componentCount =
        size == GPUSize.small
            ? 4
            : size == GPUSize.medium
            ? 6
            : 8;
    final componentSize = 3.0;

    for (int i = 0; i < componentCount; i++) {
      final x = center.dx - cardWidth / 3 + (i % 2) * (cardWidth / 1.5);
      final y = center.dy + cardHeight / 4 + (i ~/ 2) * 6;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: componentSize,
          height: componentSize * 1.5,
        ),
        componentPaint,
      );
    }

    // Power connector
    final connectorPaint =
        Paint()
          ..color = Colors.yellow.withOpacity(0.8)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          center.dx + cardWidth / 2 - 8,
          center.dy - cardHeight / 3,
        ),
        width: 4,
        height: 12,
      ),
      connectorPaint,
    );
  }

  @override
  bool shouldRepaint(_GPU3DPainter oldDelegate) => true;
}

// Spec Row Widget
class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.cyan),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppStyles.body.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppStyles.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Modern File Upload Box
class _ModernFileUploadBox extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final VoidCallback onTap;

  const _ModernFileUploadBox({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.fileName,
    required this.onTap,
  });

  @override
  State<_ModernFileUploadBox> createState() => _ModernFileUploadBoxState();
}

class _ModernFileUploadBoxState extends State<_ModernFileUploadBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.fileName != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _isHovered
                      ? AppColors.cyan
                      : (hasFile
                          ? AppColors.success
                          : AppColors.cyan.withOpacity(0.2)),
              width: _isHovered ? 2 : 1.5,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: AppColors.cyan.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          hasFile
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hasFile ? Icons.check_circle : widget.icon,
                      color: hasFile ? AppColors.success : AppColors.cyan,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: AppStyles.body.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: AppStyles.body.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      hasFile
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.cardBackgroundLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        hasFile
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.textTertiary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasFile ? Icons.insert_drive_file : Icons.upload_file,
                      size: 16,
                      color:
                          hasFile ? AppColors.success : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.fileName ?? 'No file selected',
                        style: AppStyles.body.copyWith(
                          fontSize: 13,
                          color:
                              hasFile
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern Dialog
class _ModernDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const _ModernDialog({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child:
          Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.cyan.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppStyles.heading1.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              )
              .animate()
              .scale(duration: 300.ms, curve: Curves.easeOutBack)
              .fadeIn(),
    );
  }
}

// Info Row for dialog
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyan.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.cyan, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
