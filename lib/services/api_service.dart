import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // mime türleri için
import 'package:mime/mime.dart';

import '../models/cheating_report.dart';
import '../models/student_answer.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.1.111:8000';

  static Future<AnalysisResponse> analyzeExams(List<StudentAnswer> answers) async {
    final uri = Uri.parse('$_baseUrl/api/v1/analyze');
    final request = http.MultipartRequest('POST', uri);

    for (var answer in answers) {
      final mimeType = lookupMimeType(answer.image.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');
      final bytes = await answer.image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'files', // ❗ FastAPI'deki parametre ismi
          bytes,
          filename: answer.name, // 🎯 Öğrenci ismini filename olarak kullanıyoruz
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AnalysisResponse.fromJson(decoded);
    } else {
      throw Exception('❌ Sunucu hatası: ${response.statusCode}\nYanıt: ${response.body}');
    }
  }
}
