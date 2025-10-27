class TrainingJob {
  final String id;
  final String gpuSize;
  final String status;
  final DateTime createdAt;

  TrainingJob({
    required this.id,
    required this.gpuSize,
    required this.status,
    required this.createdAt,
  });

  factory TrainingJob.fromJson(Map<String, dynamic> json) {
    return TrainingJob(
      id: json['id'],
      gpuSize: json['gpu_size'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}