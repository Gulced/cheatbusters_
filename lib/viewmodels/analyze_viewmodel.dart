import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/cheating_report.dart'; // ✅ Yeni model

class AnalyzeViewModel extends ChangeNotifier {
  final List<XFile> imageFiles = [];

  AnalysisResponse? results; // ✅ Değiştirildi
  bool isLoading = false;

  void addImage(XFile file) {
    imageFiles.add(file);
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
