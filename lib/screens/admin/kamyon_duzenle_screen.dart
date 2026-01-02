import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class KamyonDuzenleScreen extends StatefulWidget {
  final String id;
  const KamyonDuzenleScreen({super.key, required this.id});

  @override
  State<KamyonDuzenleScreen> createState() => _KamyonDuzenleScreenState();
}

class _KamyonDuzenleScreenState extends State<KamyonDuzenleScreen> {
  final plate = TextEditingController();
  final model = TextEditingController();
  final capacity = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTruck();
  }

  Future<void> loadTruck() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) return;

  final res = await http.get(
    Uri.parse("http://localhost:5144/api/Trucks"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  final list = json.decode(res.body) as List;

  final truck = list.firstWhere(
    (e) => e["id"] == widget.id,
    orElse: () => null,
  );

  if (truck == null) {
    // 🔥 KRİTİK: crash yerine kontrollü davran
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kamyon bulunamadı")),
    );
    Navigator.pop(context);
    return;
  }

  setState(() {
    plate.text = truck["plate"];
    model.text = truck["model"];
    capacity.text = truck["capacity"].toString();
  });
}

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.put(
      Uri.parse("http://localhost:5144/api/Trucks/${widget.id}"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "plate": plate.text,
        "model": model.text,
        "capacity": int.parse(capacity.text),
      }),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kamyon Düzenle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: plate, decoration: const InputDecoration(labelText: "Plaka")),
            TextField(controller: model, decoration: const InputDecoration(labelText: "Model")),
            TextField(
              controller: capacity,
              decoration: const InputDecoration(labelText: "Kapasite"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: save, child: const Text("Kaydet")),
          ],
        ),
      ),
    );
  }
}
