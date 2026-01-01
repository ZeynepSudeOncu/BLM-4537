import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DepoDuzenleScreen extends StatefulWidget {
  final String id;
  const DepoDuzenleScreen({super.key, required this.id});

  @override
  State<DepoDuzenleScreen> createState() => _DepoDuzenleScreenState();
}

class _DepoDuzenleScreenState extends State<DepoDuzenleScreen> {
  final name = TextEditingController();
  final address = TextEditingController();
  final capacity = TextEditingController();
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    loadDepot();
  }

  Future<void> loadDepot() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://localhost:5144/api/depots"),
      headers: {"Authorization": "Bearer $token"},
    );

    final list = json.decode(res.body) as List;
    final d = list.firstWhere((e) => e["id"] == widget.id);

    setState(() {
      name.text = d["name"];
      address.text = d["address"];
      capacity.text = d["capacity"].toString();
      isActive = d["isActive"];
    });
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.put(
      Uri.parse("http://localhost:5144/api/depots/${widget.id}"),
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
      appBar: AppBar(title: const Text("Depo Düzenle")),
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
