import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'kamyon_duzenle_screen.dart';

class Truck {
  final String id;
  final String plate;
  final String model;
  final int capacity;
  final bool isActive;

  Truck({
    required this.id,
    required this.plate,
    required this.model,
    required this.capacity,
    required this.isActive,
  });

  factory Truck.fromJson(Map<String, dynamic> json) {
  return Truck(
    id: json["id"]?.toString() ?? "",
    plate: json["plate"] ?? "",
    model: json["model"] ?? "",
    capacity: json["capacity"] ?? 0,
    isActive: json["isActive"] ?? false, 
  );
}

}

class KamyonlarScreen extends StatefulWidget {
  const KamyonlarScreen({super.key});

  @override
  State<KamyonlarScreen> createState() => _KamyonlarScreenState();
}

class _KamyonlarScreenState extends State<KamyonlarScreen> {
  List<Truck> trucks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://localhost:5144/api/Trucks"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final List list = json.decode(res.body);
    setState(() {
      trucks = list.map((e) => Truck.fromJson(e)).toList();
      loading = false;
    });
  }

  Future<void> deleteTruck(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Emin misiniz?"),
        content: const Text("Bu kamyonu silmek istiyor musunuz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sil")),
        ],
      ),
    );

    if (ok != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.delete(
      Uri.parse("http://localhost:5144/api/Trucks/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    setState(() => trucks.removeWhere((t) => t.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tüm Kamyonlar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/admin/kamyonlar/yeni");
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Plaka")),
                  DataColumn(label: Text("Model")),
                  DataColumn(label: Text("Kapasite")),
                  DataColumn(label: Text("Durum")),
                  DataColumn(label: Text("İşlemler")),
                ],
                rows: trucks.map((k) {
                  return DataRow(cells: [
                    DataCell(Text(k.plate)),
                    DataCell(Text(k.model)),
                    DataCell(Text(k.capacity.toString())),
                    DataCell(Text(k.isActive ? "Aktif" : "Pasif")),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KamyonDuzenleScreen(id: k.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTruck(k.id),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}
