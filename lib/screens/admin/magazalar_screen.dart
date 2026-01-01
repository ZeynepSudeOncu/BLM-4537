import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MagazalarScreen extends StatefulWidget {
  const MagazalarScreen({super.key});

  @override
  State<MagazalarScreen> createState() => _MagazalarScreenState();
}

class _MagazalarScreenState extends State<MagazalarScreen> {
  List<Map<String, dynamic>> stores = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://localhost:5144/api/stores'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        stores = List<Map<String, dynamic>>.from(jsonList);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mağazalar alınamadı (${response.statusCode})')),
      );
    }
  }

  Future<void> deleteStore(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Silme Onayı"),
        content: const Text("Bu mağazayı kapatmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Kapat")),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('http://localhost:5144/api/stores/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        stores.removeWhere((m) => m['id'] == id);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme başarısız: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Mağazalar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yeni Mağaza Ekle (yakında)')),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : stores.isEmpty
              ? const Center(child: Text("Mağaza bulunamadı."))
              : ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final magaza = stores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(magaza['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Adres: ${magaza['address']}"),
                            Text("Telefon: ${magaza['phone']}"),
                            Text("Durum: ${magaza['isActive'] ? 'Aktif' : 'Pasif'}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => deleteStore(magaza['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
