import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> results;

  const ResultPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final report = results['report'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Kopya Risk Sonuçları")),
      body: report.isEmpty
          ? const Center(
        child: Text(
          "📭 Hiçbir eşleştirme sonucu bulunamadı.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: report.length,
        itemBuilder: (context, index) {
          final entry = report[index];
          final students = (entry['students'] as List<dynamic>).join(' vs ');
          final analysis = entry['analysis'] as Map<String, dynamic>? ?? {};
          final reason = analysis['reason'] ?? "Gerekçe belirtilmedi";
          final parts = (analysis['suspicious_parts'] as List<dynamic>?)?.join(', ') ?? "";
          final isCheating = analysis['is_cheating'] == true;
          final similarity = entry['similarity_score'];

          return Card(
            color: isCheating ? Colors.red.shade100 : Colors.green.shade100,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(
                students,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCheating && similarity != null)
                    Text("Benzerlik Oranı: %${(similarity as num).toStringAsFixed(1)}"),
                  Text("Gerekçe: $reason"),
                  if (parts.isNotEmpty) Text("Şüpheli Bölümler: $parts"),
                  const SizedBox(height: 4),
                  Text(
                    isCheating ? "🚨 Kopya Tespit Edildi" : "✅ Kopya Tespit Edilmedi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCheating ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                isCheating ? Icons.warning : Icons.check_circle,
                color: isCheating ? Colors.red : Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
