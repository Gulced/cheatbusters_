import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../models/cheating_report.dart'; // 🔹 Response modelini import et

class ApiService {
  static const String _baseUrl = 'http://192.168.110.93:8000'; // 🔁 Gerekirse değiştir

  static Future<AnalysisResponse> analyzeExams(List<XFile> imageFiles) async {
    final uri = Uri.parse('$_baseUrl/api/v1/analyze');
    final request = http.MultipartRequest('POST', uri);

    try {
      for (var imageFile in imageFiles) {
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();

        final multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return AnalysisResponse.fromJson(decoded); // 🔹 Yeni modelden dönüş
      } else {
        throw Exception('❌ Sunucu hatası: ${response.statusCode}\nYanıt: ${response.body}');
      }
    } catch (e) {
      throw Exception('❌ Bağlantı hatası: $e');
    }
  }
}
