import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class KamyonlarScreen extends StatefulWidget {
  const KamyonlarScreen({super.key});

  @override
  State<KamyonlarScreen> createState() => _KamyonlarScreenState();
}

class _KamyonlarScreenState extends State<KamyonlarScreen> {
  List<Map<String, dynamic>> trucks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://localhost:5144/api/trucks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        trucks = List<Map<String, dynamic>>.from(jsonList);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamyonlar alınamadı (${response.statusCode})')),
      );
    }
  }

  Future<void> deleteTruck(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Silme Onayı"),
        content: const Text("Bu kamyonu silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sil")),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('http://localhost:5144/api/trucks/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        trucks.removeWhere((t) => t['id'] == id);
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
        title: const Text('Tüm Kamyonlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yeni Kamyon Ekle (yakında)')),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : trucks.isEmpty
              ? const Center(child: Text("Kamyon bulunamadı."))
              : ListView.builder(
                  itemCount: trucks.length,
                  itemBuilder: (context, index) {
                    final truck = trucks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text('${truck['plate']} - ${truck['model']}'),
                        subtitle: Text('Kapasite: ${truck['capacity']} ton\nDurum: ${truck['status']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTruck(truck['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
