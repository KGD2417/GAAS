import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://localhost:8000";
  static const String workerBaseUrl = "http://localhost:9000";

  static Future<bool> startLocalWorker() async {
    try {
      final response = await http.post(Uri.parse('$workerBaseUrl/start'));

      return response.statusCode == 200;
    } catch (e) {
      print("Worker start error: $e");
      return false;
    }
  }

  static Future<bool> stopLocalWorker() async {
    try {
      final response = await http.post(Uri.parse('$workerBaseUrl/stop'));

      return response.statusCode == 200;
    } catch (e) {
      print("Worker stop error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getLocalWorkerStatus() async {
    try {
      final response = await http.get(Uri.parse('$workerBaseUrl/status'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Worker status error: $e");
    }
    return null;
  }

  static Future<String?> getWorkerLogs() async {
    try {
      final response = await http.get(Uri.parse('$workerBaseUrl/logs'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['logs'];
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getJobStatus(String jobId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/job/$jobId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Polling error: $e");
    }
    return null;
  }

  static Future<String?> startTraining({
    required String gpuSize,
    required String? datasetPath,
    required String? modelPath,
    required String? pythonCode,
    required String requirements,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/job/submit'),
      );

      request.fields['gpu_size'] = gpuSize;
      request.fields['requirements'] = requirements;

      if (pythonCode != null) {
        request.fields['python_code'] = pythonCode;
      }

      if (datasetPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('dataset', datasetPath),
        );
      }

      if (modelPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('model_file', modelPath),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var data = jsonDecode(respStr);
        return data['job_id'];
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }
}
