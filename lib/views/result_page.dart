import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> results;

  const ResultPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final suspicious = results.entries.where((e) => (e.value ?? 0) >= 80).toList();
    final safe = results.entries.where((e) => (e.value ?? 0) < 80).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Kopya Risk Sonuçları")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (suspicious.isNotEmpty)
            const Text("🚨 Şüpheli Benzerlikler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...suspicious.map((e) => _buildResultTile(e.key, e.value as int, true)),
          const SizedBox(height: 20),
          if (safe.isNotEmpty)
            const Text("✅ Temiz Karşılaştırmalar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...safe.map((e) => _buildResultTile(e.key, e.value as int, false)),
        ],
      ),
    );
  }

  Widget _buildResultTile(String title, int similarity, bool isSuspicious) {
    return Card(
      color: isSuspicious ? Colors.red.shade100 : Colors.green.shade100,
      child: ListTile(
        title: Text(title),
        subtitle: Text("Benzerlik: $similarity%"),
        trailing: Icon(
          isSuspicious ? Icons.warning : Icons.check_circle,
          color: isSuspicious ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
