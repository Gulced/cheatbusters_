import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import '../models/cheating_report.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera ile Çek'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked == null) {
      debugPrint("📭 Görsel seçilmedi.");
      return;
    }

    final imageFile = File(picked.path);
    final name = await _askForName(context);

    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ İsim girilmedi! Görsel eklenmedi.")),
      );
      return;
    }

    if (context.mounted) {
      Provider.of<HomeViewModel>(context, listen: false)
          .addAnswer(name.trim(), imageFile);
    }
  }

  Future<String> _askForName(BuildContext context) async {
    final controller = TextEditingController();
    String? name;

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("🧑‍🎓 Öğrenci İsmi Gerekli"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Örn: Elif Kaya",
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final input = controller.text.trim();
                if (input.isNotEmpty) {
                  Navigator.of(ctx).pop(input);
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    ).then((value) => name = value);

    return name ?? "";
  }

  Future<void> _analyze(BuildContext context) async {
    final model = Provider.of<HomeViewModel>(context, listen: false);

    if (model.answers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ En az 2 öğrenci cevabı yüklemelisiniz.")),
      );
      return;
    }

    await model.analyzeAnswers();

    final result = model.result;

    if (result == null || result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Hata: ${result?.error ?? "Sonuç alınamadı."}")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📊 Kopya Analiz Raporu"),
        content: SizedBox(
          width: double.maxFinite,
          child: result.report.isEmpty
              ? const Text("✅ Hiç kopya tespiti yapılmadı.")
              : ListView(
            shrinkWrap: true,
            children: result.report.map((report) {
              final students = report.students.join(" ↔ ");
              final score = report.similarityScore != null
                  ? "${report.similarityScore!.toStringAsFixed(2)}%"
                  : "—";
              final reason = report.analysis.reason;
              final isCheating = report.analysis.isCheating;

              return ListTile(
                title: Text(
                  students,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCheating)
                      Text("Benzerlik: $score"),
                    Text("Gerekçe: $reason"),
                    Text(
                      isCheating ? "🚨 Kopya Tespit Edildi" : "✅ Kopya Tespit Edilmedi",
                      style: TextStyle(
                        color: isCheating ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("CheatBuster – Sınav Yükle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Tüm verileri temizle",
            onPressed: () => model.clearAnswers(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text("Öğrenci Cevabı Yükle"),
                onPressed: () => _showImageSourceDialog(context),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text("Analiz Et"),
                onPressed: () => _analyze(context),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: model.answers.isEmpty
                ? const Center(
              child: Text(
                "📭 Henüz görsel yüklenmedi",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: model.answers.length,
              itemBuilder: (context, index) {
                final item = model.answers[index];
                return ListTile(
                  leading: Image.file(
                    item.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                  title: Text(item.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
