import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

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

    debugPrint("📸 Resim çekildi: ${picked.path}");

    final imageFile = File(picked.path);
    final name = await _askForName(context);

    if (name.trim().isEmpty) {
      debugPrint("⛔ İsim girilmedi, eklenmedi.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("İsim girilmedi! Görsel eklenmedi.")),
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
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: const Text("Öğrenci İsmi Gerekli"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Örn: Elif Kaya",
            ),
            autofocus: true,
            style: const TextStyle(color: Colors.white),
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
        const SnackBar(content: Text("Analiz için en az 2 öğrenci cevabı gerekir.")),
      );
      return;
    }

    final results = await model.analyzeAnswers();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: const Text("📊 Kopya Analiz Sonuçları"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: results.entries.map((e) {
              return ListTile(
                title: Text(e.key),
                trailing: Text("%${e.value}"),
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
                "Henüz görsel yüklenmedi",
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
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image),
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
