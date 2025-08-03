import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> results;

  const ResultPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final report = results['report'] as List<dynamic>? ?? [];

    final suspicious = report.where((e) => (e['similarity_score'] ?? 0) >= 0.8).toList();
    final safe = report.where((e) => (e['similarity_score'] ?? 0) < 0.8).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Kopya Risk Sonuçları")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (suspicious.isNotEmpty) ...[
            const Text("🚨 Şüpheli Benzerlikler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...suspicious.map((e) => _buildResultTile(e, true)),
            const SizedBox(height: 20),
          ],
          if (safe.isNotEmpty) ...[
            const Text("✅ Temiz Karşılaştırmalar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...safe.map((e) => _buildResultTile(e, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> entry, bool isSuspicious) {
    final students = (entry['students'] as List<dynamic>).join(' vs ');
    final score = ((entry['similarity_score'] ?? 0) * 100).toStringAsFixed(1);
    final reason = entry['analysis']['reason'] ?? "Gerekçe belirtilmedi";
    final parts = (entry['analysis']['suspicious_parts'] as List<dynamic>?)
        ?.join(', ') ?? "";

    return Card(
      color: isSuspicious ? Colors.red.shade100 : Colors.green.shade100,
      child: ListTile(
        title: Text(students),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Benzerlik: %$score"),
            Text("Gerekçe: $reason"),
            if (parts.isNotEmpty) Text("Şüpheli Bölümler: $parts"),
          ],
        ),
        trailing: Icon(
          isSuspicious ? Icons.warning : Icons.check_circle,
          color: isSuspicious ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
