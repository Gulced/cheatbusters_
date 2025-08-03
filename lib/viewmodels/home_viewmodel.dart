import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/student_answer.dart';

class HomeViewModel extends ChangeNotifier {
  final List<StudentAnswer> _answers = [];

  List<StudentAnswer> get answers => List.unmodifiable(_answers);

  void addAnswer(String name, File image) {
    _answers.add(StudentAnswer(name: name, image: image));
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }

  /// Gerçek analiz: görselleri API'ye gönderir, skorları alır
  Future<Map<String, double>> analyzeAnswers() async {
    const String backendBaseUrl = 'http://10.0.2.2:8000'; // ANDROID EMÜLATÖR için
    final url = Uri.parse('$backendBaseUrl/api/analyze-batch');

    // Görselleri base64 + ad ile JSON'a hazırla
    final imagesJson = await Future.wait(_answers.map((answer) async {
      final bytes = await answer.image.readAsBytes();
      final base64Image = base64Encode(bytes);
      return {
        "name": answer.name,
        "base64": base64Image,
      };
    }));

    final body = jsonEncode({"images": imagesJson});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic> sim = decoded["similarities"];
        return sim.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } else {
        debugPrint("❌ Sunucu hatası: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      debugPrint("❌ API çağrısı başarısız: $e");
      return {};
    }
  }
}
