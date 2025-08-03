import 'dart:io';
import 'package:flutter/material.dart';
import '../models/student_answer.dart';
import '../services/api_service.dart';

class AnalyzeViewModel extends ChangeNotifier {
  List<File> imageFiles = [];
  List<StudentAnswer> answers = [];
  Map<String, dynamic>? results;
  bool isLoading = false;

  void addImage(File file, String name) {
    imageFiles.add(file);
    answers.add(StudentAnswer(name: name, image: file));
    notifyListeners();
  }

  void clearAll() {
    imageFiles.clear();
    answers.clear();
    results = null;
    notifyListeners();
  }

  Future<void> sendImagesForAnalysis() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.analyzeBatch(answers);
      results = response;
    } catch (e) {
      print("❌ API çağrısı başarısız: $e");
      results = {};
    }

    isLoading = false;
    notifyListeners();
  }
}
