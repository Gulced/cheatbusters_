import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  String _status = 'Henüz analiz yapılmadı.';
  Map<String, dynamic>? _result;

  Future<void> _pickAndAnalyze() async {
    final images = await _picker.pickMultiImage();
    if (images.isEmpty || images.length < 2) {
      setState(() => _status = '⚠️ En az 2 görsel seçmelisiniz.');
      return;
    }

    setState(() {
      _status = '🔍 Analiz ediliyor...';
      _result = null;
    });

    try {
      final result = await _apiService.analyzeExams(images);
      setState(() {
        _result = result;
        _status = '✅ Analiz tamamlandı!';
      });
    } catch (e) {
      setState(() => _status = '❌ Hata oluştu: $e');
    }
  }

  Widget _buildResultReport() {
    if (_result == null) return const SizedBox.shrink();

    final report = _result!['report'] as List<dynamic>;
    final total = _result!['total_documents_processed'];
    final cheatingCount = _result!['cheating_pairs_found'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("🗂 Toplam Belgeler: $total"),
        Text("🚨 Tespit Edilen Kopya Çifti: $cheatingCount"),
        const Divider(),
        ...report.map((e) {
          final students = (e['students'] as List).join(' vs ');
          final similarity = (e['similarity_score'] * 100).toStringAsFixed(1);
          final reason = e['analysis']['reason'];
          final parts = (e['analysis']['suspicious_parts'] as List).join(', ');

          return Card(
            color: Colors.red.shade50,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text("$students"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Benzerlik: %$similarity"),
                  Text("Gerekçe: $reason"),
                  if (parts.isNotEmpty) Text("Şüpheli Bölümler: $parts"),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CheatBuster – Hızlı Analiz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: _pickAndAnalyze,
              icon: const Icon(Icons.image_search),
              label: const Text('Görselleri Seç ve Analiz Et'),
            ),
            const SizedBox(height: 16),
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            if (_result != null) _buildResultReport(),
          ],
        ),
      ),
    );
  }
}
