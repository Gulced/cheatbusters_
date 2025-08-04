import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/student_answer.dart';
import '../models/cheating_report.dart';

class HomeViewModel extends ChangeNotifier {
  final List<StudentAnswer> _answers = [];

  List<StudentAnswer> get answers => List.unmodifiable(_answers);

  AnalysisResponse? result;
  bool isLoading = false;

  /// Yeni öğrenci cevabı ekler
  void addAnswer(String name, File image) {
    _answers.add(StudentAnswer(name: name, image: image));
    notifyListeners();
  }

  /// Belirli index'teki öğrenci cevabını siler
  void removeAnswerAt(int index) {
    _answers.removeAt(index);
    notifyListeners();
  }

  /// Tüm cevapları ve sonucu temizler
  void clearAnswers() {
    _answers.clear();
    result = null;
    notifyListeners();
  }

  /// Görselleri multipart olarak backend'e gönderir ve analiz sonucunu alır
  Future<void> analyzeAnswers() async {
    const String backendBaseUrl = 'http://192.168.1.111:8000';
    final url = Uri.parse('$backendBaseUrl/api/v1/analyze');
    final request = http.MultipartRequest('POST', url);

    isLoading = true;
    notifyListeners();

    try {
      for (var answer in _answers) {
        final file = answer.image;
        if (!file.existsSync()) continue;

        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');

        final multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: '${answer.name}.jpg',
          contentType: MediaType(mimeParts[0], mimeParts[1]),
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
          error: '❌ Sunucu hatası: ${response.statusCode}',
        );
      }
    } catch (e) {
      result = AnalysisResponse(
        totalDocumentsProcessed: 0,
        cheatingPairsFound: 0,
        report: [],
        error: '❌ Bağlantı hatası: $e',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
