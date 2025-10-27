import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  static final String baseUrl = "https://5765e1a915fa.ngrok-free.app";

  // returns jobId on success
  static Future<String?> startTraining({
    required String gpuSize,
    String? datasetPath,
    String? modelPath,
    String? dockerfilePath,
    String? runShPath,
    String? requirements,
    String? pythonCode, // ✅ NEW
  }) async {
    var uri = Uri.parse('$baseUrl/api/v1/jobs');
    var request = http.MultipartRequest('POST', uri);

    request.fields['gpu_size'] = gpuSize;

    if (requirements != null) request.fields['requirements_txt'] = requirements;
    if (pythonCode != null && pythonCode.isNotEmpty) {
      request.fields['python_code'] = pythonCode; // ✅ add main.py code
    }

    if (dockerfilePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'dockerfile',
          dockerfilePath,
          filename: 'Dockerfile',
        ),
      );
    }
    if (runShPath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'run_sh',
          runShPath,
          filename: 'run.sh',
        ),
      );
    }
    if (datasetPath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('dataset', datasetPath),
      );
    }
    if (modelPath != null) {
      request.files.add(await http.MultipartFile.fromPath('model', modelPath));
    }

    try {
      var streamedResp = await request.send();
      var resp = await http.Response.fromStream(streamedResp);
      if (resp.statusCode == 202) {
        var data = json.decode(resp.body);
        return data['job_id'] as String?;
      } else {
        print('startTraining failed: ${resp.statusCode} ${resp.body}');
        return null;
      }
    } catch (e) {
      print('startTraining error: $e');
      return null;
    }
  }

  // Connect to logs via WebSocket
  static WebSocketChannel connectLogs(String jobId) {
    final wsUrl =
        baseUrl.replaceFirst('http', 'ws') + '/api/v1/jobs/$jobId/logs/ws';
    return WebSocketChannel.connect(Uri.parse(wsUrl));
  }
}
