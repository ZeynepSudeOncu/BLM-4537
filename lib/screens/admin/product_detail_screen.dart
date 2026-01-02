import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool loading = true;
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse(
        "http://localhost:5144/api/admin/products/${widget.productId}/details",
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    setState(() {
      data = json.decode(res.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final depots = data["depots"] as List;
    final stores = data["stores"] as List;

    return Scaffold(
      appBar: AppBar(title: const Text("Ürün Detayı")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 DEPOLAR
              const Text(
                "Depolar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...depots.map((d) => ListTile(
                    leading: const Icon(Icons.warehouse),
                    title: Text(d["depotName"]),
                    trailing: Text(d["quantity"].toString()),
                  )),

              const SizedBox(height: 24),

              // 🔹 MAĞAZALAR
              const Text(
                "Mağazalar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...stores.map((s) => ListTile(
                    leading: const Icon(Icons.store),
                    title: Text(s["storeName"]),
                    trailing: Text(s["quantity"].toString()),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
