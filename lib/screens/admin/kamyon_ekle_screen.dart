import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KamyonEkleScreen extends StatefulWidget {
  const KamyonEkleScreen({super.key});

  @override
  State<KamyonEkleScreen> createState() => _KamyonEkleScreenState();
}

class _KamyonEkleScreenState extends State<KamyonEkleScreen> {
  final plate = TextEditingController();
  final model = TextEditingController();
  final capacity = TextEditingController();
  String status = "Active";

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.post(
      Uri.parse("http://localhost:5144/api/Trucks"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "plate": plate.text,
        "model": model.text,
        "capacity": int.parse(capacity.text),
        "status": status,
      }),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Kamyon Ekle")),
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
            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: "Active", child: Text("Aktif")),
                DropdownMenuItem(value: "Passive", child: Text("Pasif")),
              ],
              onChanged: (v) => setState(() => status = v!),
              decoration: const InputDecoration(labelText: "Durum"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: save, child: const Text("Kaydet")),
          ],
        ),
      ),
    );
  }
}
