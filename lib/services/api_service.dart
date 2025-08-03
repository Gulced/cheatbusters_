import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_answer.dart';

class ApiService {
  static Future<Map<String, dynamic>> analyzeBatch(List<StudentAnswer> answers) async {
    final url = Uri.parse("http://192.168.110.93:8000/api/analyze-batch"); // IP’ni buraya yaz

    final imageList = await Future.wait(answers.map((e) async {
      final bytes = await e.image.readAsBytes();
      final base64Image = base64Encode(bytes);
      return {
        "name": e.name,
        "base64": base64Image,
      };
    }));

    final body = jsonEncode({"images": imageList});

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Sunucu hatası: ${response.statusCode}");
    }
  }
}
