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

class MagazaDuzenleScreen extends StatefulWidget {
  final String id;
  const MagazaDuzenleScreen({super.key, required this.id});

  @override
  State<MagazaDuzenleScreen> createState() => _MagazaDuzenleScreenState();
}

class _MagazaDuzenleScreenState extends State<MagazaDuzenleScreen> {
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();

  List<Depot> depots = [];
  String depotId = "";
  bool isActive = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final depotsRes = await http.get(
      Uri.parse("http://localhost:5144/api/depots"),
      headers: {"Authorization": "Bearer $token"},
    );

    final storeRes = await http.get(
      Uri.parse("http://localhost:5144/api/stores/${widget.id}"),
      headers: {"Authorization": "Bearer $token"},
    );

    final depotsList = json.decode(depotsRes.body) as List;
    final store = json.decode(storeRes.body);

    setState(() {
      depots = depotsList.map((e) => Depot.fromJson(e)).toList();
      name.text = store["name"];
      address.text = store["address"];
      phone.text = store["phone"];
      depotId = store["depotId"];
      isActive = store["isActive"] ?? true;
      loading = false;
    });
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.put(
      Uri.parse("http://localhost:5144/api/stores/${widget.id}"),
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mağaza Düzenle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Mağaza Adı")),
            TextField(controller: address, decoration: const InputDecoration(labelText: "Adres")),
            TextField(controller: phone, decoration: const InputDecoration(labelText: "Telefon")),

            DropdownButtonFormField<String>(
              value: depotId,
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
