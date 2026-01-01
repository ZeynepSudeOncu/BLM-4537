import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Depot {
  final String id;
  final String name;
  final String address;
  final int capacity;
  final bool isActive;

  Depot({
    required this.id,
    required this.name,
    required this.address,
    required this.capacity,
    required this.isActive,
  });

  factory Depot.fromJson(Map<String, dynamic> json) {
    return Depot(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      capacity: json["capacity"],
      isActive: json["isActive"],
    );
  }
}

class DepolarScreen extends StatefulWidget {
  const DepolarScreen({super.key});

  @override
  State<DepolarScreen> createState() => _DepolarScreenState();
}

class _DepolarScreenState extends State<DepolarScreen> {
  List<Depot> depots = [];
  String? sortField;
  bool asc = true;
  bool loading = true;

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
      loading = false;
    });
  }

  void sortBy(String field) {
    setState(() {
      if (sortField == field) {
        asc = !asc;
      } else {
        sortField = field;
        asc = true;
      }

      depots.sort((a, b) {
        dynamic aVal = (field == "name")
            ? a.name
            : field == "address"
                ? a.address
                : field == "capacity"
                    ? a.capacity
                    : a.isActive;

        dynamic bVal = (field == "name")
            ? b.name
            : field == "address"
                ? b.address
                : field == "capacity"
                    ? b.capacity
                    : b.isActive;

        return asc
            ? aVal.toString().compareTo(bVal.toString())
            : bVal.toString().compareTo(aVal.toString());
      });
    });
  }

  Future<void> deleteDepot(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Emin misiniz?"),
        content: const Text("Bu depoyu silmek istiyor musunuz?"),
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
      Uri.parse("http://localhost:5144/api/depots/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    setState(() => depots.removeWhere((d) => d.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tüm Depolar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/admin/depolar/yeni");
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: InkWell(onTap: () => sortBy("name"), child: const Text("Depo Adı"))),
                  DataColumn(label: InkWell(onTap: () => sortBy("address"), child: const Text("Adres"))),
                  DataColumn(label: InkWell(onTap: () => sortBy("capacity"), child: const Text("Kapasite"))),
                  DataColumn(label: InkWell(onTap: () => sortBy("isActive"), child: const Text("Durum"))),
                  const DataColumn(label: Text("İşlemler")),
                ],
                rows: depots.map((d) {
                  return DataRow(cells: [
                    DataCell(Text(d.name)),
                    DataCell(Text(d.address)),
                    DataCell(Text(d.capacity.toString())),
                    DataCell(Text(d.isActive ? "Aktif" : "Pasif")),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(context, "/admin/depolar/duzenle", arguments: d.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteDepot(d.id),
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
