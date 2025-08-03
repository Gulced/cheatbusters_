import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/student_answer.dart';
import '../models/cheating_report.dart';

class HomeViewModel extends ChangeNotifier {
  final List<StudentAnswer> _answers = [];

  List<StudentAnswer> get answers => List.unmodifiable(_answers);
  AnalysisResponse? result;
  bool isLoading = false;

  void addAnswer(String name, File image) {
    _answers.add(StudentAnswer(name: name, image: image));
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    result = null;
    notifyListeners();
  }

  /// Görselleri multipart olarak gönderir, AnalysisResponse alır
  Future<void> analyzeAnswers() async {
    const String backendBaseUrl = 'http://10.0.2.2:8000'; // 🛜 Android emulator için localhost
    final url = Uri.parse('$backendBaseUrl/api/v1/analyze');
    final request = http.MultipartRequest('POST', url);

    isLoading = true;
    notifyListeners();

    try {
      for (var answer in _answers) {
        final file = answer.image;
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          // ✅ ÖNEMLİ: Öğrenci ismini dosya adı olarak gönder
          filename: '${answer.name}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final parsed = json.decode(utf8.decode(response.bodyBytes));
        result = AnalysisResponse.fromJson(parsed);
      } else {
        result = AnalysisResponse(
          totalDocumentsProcessed: 0,
          cheatingPairsFound: 0,
          report: [],
          error: 'Sunucu hatası: ${response.statusCode}',
        );
      }
    } catch (e) {
      result = AnalysisResponse(
        totalDocumentsProcessed: 0,
        cheatingPairsFound: 0,
        report: [],
        error: 'Bağlantı hatası: $e',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
