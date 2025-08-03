import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../models/cheating_report.dart';
import '../models/student_answer.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.110.93:8000';

  static Future<AnalysisResponse> analyzeExams(List<StudentAnswer> answers) async {
    final uri = Uri.parse('$_baseUrl/api/v1/analyze');
    final headers = {'Content-Type': 'application/json'};

    try {
      final List<Map<String, dynamic>> imagePayload = [];

      for (var answer in answers) {
        final bytes = await answer.image.readAsBytes();
        final base64Str = base64Encode(bytes);
        final mimeType = lookupMimeType(answer.image.path) ?? 'image/jpeg';
        final base64Full = 'data:$mimeType;base64,$base64Str';

        imagePayload.add({
          'student_name': answer.name,
          'content': base64Full,
        });
      }

      final body = jsonEncode({'images': imagePayload});

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return AnalysisResponse.fromJson(decoded);
      } else {
        throw Exception('❌ Sunucu hatası: ${response.statusCode}\nYanıt: ${response.body}');
      }
    } catch (e) {
      throw Exception('❌ Bağlantı hatası: $e');
    }
  }
}
