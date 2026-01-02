import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'product_detail_screen.dart';

class ProductSummary {
  final String productId;
  final String productName;
  final String productCode;
  final int totalQuantity;

  ProductSummary({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.totalQuantity,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      productId: json["productId"],
      productName: json["productName"],
      productCode: json["productCode"],
      totalQuantity: json["totalQuantity"] ?? 0,
    );
  }
}

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<ProductSummary> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://localhost:5144/api/admin/products/summary"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final List list = json.decode(res.body);

    setState(() {
      items = list.map((e) => ProductSummary.fromJson(e)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürün Stok Özeti")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Kod")),
                  DataColumn(label: Text("Ürün")),
                  DataColumn(label: Text("Toplam Adet")),
                ],
                rows: items.map((x) {
                  return DataRow(cells: [
                    DataCell(Text(x.productCode)),
                    DataCell(
                      Text(
                        x.productName,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(productId: x.productId),
                          ),
                        );
                      },
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          x.totalQuantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}
