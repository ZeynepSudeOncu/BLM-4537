import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'magaza_ekle_screen.dart';
import 'magaza_duzenle_screen.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isActive;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json["id"],
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      phone: json["phone"] ?? "",
      isActive: json["isActive"] ?? false, // 🔥 null-safe
    );
  }
}

class MagazalarScreen extends StatefulWidget {
  const MagazalarScreen({super.key});

  @override
  State<MagazalarScreen> createState() => _MagazalarScreenState();
}

class _MagazalarScreenState extends State<MagazalarScreen> {
  List<Store> stores = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://localhost:5144/api/stores"),
      headers: {"Authorization": "Bearer $token"},
    );

    final List list = json.decode(res.body);
    setState(() {
      stores = list.map((e) => Store.fromJson(e)).toList();
      loading = false;
    });
  }

  Future<void> deleteStore(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Emin misiniz?"),
        content: const Text("Bu mağazayı kapatmak istiyor musunuz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Kapat")),
        ],
      ),
    );

    if (ok != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.delete(
      Uri.parse("http://localhost:5144/api/stores/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    setState(() => stores.removeWhere((s) => s.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tüm Mağazalar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MagazaEkleScreen()),
              ).then((_) => fetchStores());
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Ad")),
                  DataColumn(label: Text("Adres")),
                  DataColumn(label: Text("Telefon")),
                  DataColumn(label: Text("Durum")),
                  DataColumn(label: Text("İşlemler")),
                ],
                rows: stores.map((m) {
                  return DataRow(cells: [
                    DataCell(Text(m.name)),
                    DataCell(Text(m.address)),
                    DataCell(Text(m.phone)),
                    DataCell(Text(m.isActive ? "Aktif" : "Pasif")),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MagazaDuzenleScreen(id: m.id),
                              ),
                            ).then((_) => fetchStores());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteStore(m.id),
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
