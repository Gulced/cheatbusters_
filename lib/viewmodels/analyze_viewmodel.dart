import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/cheating_report.dart';
import '../models/student_answer.dart';

class AnalyzeViewModel extends ChangeNotifier {
  final List<StudentAnswer> imageFiles = [];

  AnalysisResponse? results;
  bool isLoading = false;

  /// Öğrenci adı ve XFile ile yeni görsel ekler
  void addImage(XFile file, String studentName) {
    final fileAsFile = File(file.path);
    imageFiles.add(StudentAnswer(name: studentName, image: fileAsFile));
    notifyListeners();
  }

  void clearAll() {
    imageFiles.clear();
    results = null;
    notifyListeners();
  }

  Future<void> sendImagesForAnalysis() async {
    if (imageFiles.length < 2) {
      results = AnalysisResponse(
        totalDocumentsProcessed: 0,
        cheatingPairsFound: 0,
        report: [],
        error: "Lütfen en az 2 görsel seçin.",
      );
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.analyzeExams(imageFiles);
      results = response;
    } catch (e) {
      results = AnalysisResponse(
        totalDocumentsProcessed: 0,
        cheatingPairsFound: 0,
        report: [],
        error: e.toString(),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
