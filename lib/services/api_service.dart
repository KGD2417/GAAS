import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://100.119.34.103:8000";
  static const String workerBaseUrl = "http://localhost:9000";

  static Future<bool> startLocalWorker() async {
    try {
      final response = await http.post(Uri.parse('$workerBaseUrl/start'));

      return response.statusCode == 200;
    } catch (e) {
      // print("Worker start error: $e");
      return false;
    }
  }

  static Future<bool> stopLocalWorker() async {
    try {
      final response = await http.post(Uri.parse('$workerBaseUrl/stop'));

      return response.statusCode == 200;
    } catch (e) {
      // print("Worker stop error: $e");
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
      print("Hello");
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
      final url = '$baseUrl/job/$jobId';
      print("Polling URL: $url");

      final response = await http.get(Uri.parse(url));

      print("Status code: ${response.statusCode}");
      print("Raw response: ${response.body}");

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
    required Uint8List? datasetBytes,
    required String? datasetFileName,
    required Uint8List? modelBytes,
    required String? modelFileName,
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

      // DATASET FILE
      if (datasetBytes != null && datasetFileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'dataset',
            datasetBytes,
            filename: datasetFileName,
          ),
        );
      }

      // MODEL FILE
      if (modelBytes != null && modelFileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'model_file',
            modelBytes,
            filename: modelFileName,
          ),
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
