import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Depot {
  final String id;
  final String name;

  Depot({required this.id, required this.name});

  factory Depot.fromJson(Map<String, dynamic> json) {
    return Depot(
      id: json["id"],
      name: json["name"],
    );
  }
}

class MagazaEkleScreen extends StatefulWidget {
  const MagazaEkleScreen({super.key});

  @override
  State<MagazaEkleScreen> createState() => _MagazaEkleScreenState();
}

class _MagazaEkleScreenState extends State<MagazaEkleScreen> {
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();

  List<Depot> depots = [];
  String depotId = "";
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    fetchDepots();
  }

  Future<void> fetchDepots() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://localhost:5144/api/depots"),
      headers: {"Authorization": "Bearer $token"},
    );

    final List list = json.decode(res.body);
    setState(() {
      depots = list.map((e) => Depot.fromJson(e)).toList();
    });
  }

  Future<void> save() async {
    if (depotId.isEmpty) {
      alert("Lütfen depo seçin");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.post(
      Uri.parse("http://localhost:5144/api/stores"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "name": name.text,
        "address": address.text,
        "phone": phone.text,
        "isActive": isActive,
        "depotId": depotId,
      }),
    );

    Navigator.pop(context);
  }

  void alert(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Mağaza Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Mağaza Adı")),
            TextField(controller: address, decoration: const InputDecoration(labelText: "Adres")),
            TextField(controller: phone, decoration: const InputDecoration(labelText: "Telefon")),

            DropdownButtonFormField<String>(
              value: depotId.isEmpty ? null : depotId,
              hint: const Text("Bağlı Depo"),
              items: depots
                  .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                  .toList(),
              onChanged: (v) => setState(() => depotId = v!),
            ),

            SwitchListTile(
              title: const Text("Aktif"),
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
