import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DepoEkleScreen extends StatefulWidget {
  const DepoEkleScreen({super.key});

  @override
  State<DepoEkleScreen> createState() => _DepoEkleScreenState();
}

class _DepoEkleScreenState extends State<DepoEkleScreen> {
  final name = TextEditingController();
  final address = TextEditingController();
  final capacity = TextEditingController();
  bool isActive = true;

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.post(
      Uri.parse("http://localhost:5144/api/depots"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: json.encode({
        "name": name.text,
        "address": address.text,
        "capacity": int.parse(capacity.text),
        "isActive": isActive,
      }),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Depo Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Depo Adı")),
            TextField(controller: address, decoration: const InputDecoration(labelText: "Adres")),
            TextField(
              controller: capacity,
              decoration: const InputDecoration(labelText: "Kapasite"),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text("Aktif mi?"),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
            ElevatedButton(onPressed: save, child: const Text("Kaydet")),
          ],
        ),
      ),
    );
  }
}
