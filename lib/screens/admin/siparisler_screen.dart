import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminSiparislerScreen extends StatefulWidget {
  const AdminSiparislerScreen({super.key});

  @override
  State<AdminSiparislerScreen> createState() => _AdminSiparislerScreenState();
}

class _AdminSiparislerScreenState extends State<AdminSiparislerScreen> {
  List<dynamic> orders = [];
  List<dynamic> stores = [];
  List<dynamic> depots = [];
  List<dynamic> trucks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('http://localhost:5144/api/orders'), headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('http://localhost:5144/api/stores'), headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('http://localhost:5144/api/depots'), headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('http://localhost:5144/api/trucks'), headers: {'Authorization': 'Bearer $token'}),
      ]);

      setState(() {
        orders = jsonDecode(responses[0].body);
        stores = jsonDecode(responses[1].body);
        depots = jsonDecode(responses[2].body);
        trucks = jsonDecode(responses[3].body);
        loading = false;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
      setState(() => loading = false);
    }
  }

  String getStoreName(String id) => stores.firstWhere((s) => s['id'] == id, orElse: () => {'name': '-'})['name'];
  String getDepotName(String id) => depots.firstWhere((d) => d['id'] == id, orElse: () => {'name': '-'})['name'];
  String getTruckPlate(String id) => trucks.firstWhere((t) => t['id'] == id, orElse: () => {'plate': '-'})['plate'];

  Future<void> updateOrderStatus(String id, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$action onayı"),
        content: Text("Bu siparişi $action istiyor musunuz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child:  Text(action)),
        ],
      ),
    );

    if (confirmed != true) return;

    final url = 'http://localhost:5144/api/orders/$id/${action.toLowerCase()}';
    final response = await http.put(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      setState(() {
        final index = orders.indexWhere((o) => o['id'] == id);
        orders[index]['status'] = action == 'approve' ? 'Onaylandı' : 'Reddedildi';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action işlemi başarısız'))
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Onaylandı':
        return Colors.green[100]!;
      case 'Reddedildi':
        return Colors.red[100]!;
      case 'Beklemede':
        return Colors.yellow[100]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Siparişler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Yeni sipariş ekleme yakında')),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("Henüz sipariş bulunmuyor."))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final tarih = DateFormat('dd.MM.yyyy').format(DateTime.parse(order['date']));
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: getStatusColor(order['status']),
                      child: ListTile(
                        title: Text('Depo: ${getDepotName(order['depotId'])}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mağaza: ${getStoreName(order['storeId'])}'),
                            Text('Kamyon: ${getTruckPlate(order['truckId'])}'),
                            Text('Tarih: $tarih'),
                            Text('Durum: ${order['status']}'),
                          ],
                        ),
                        trailing: Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: order['status'] == 'Onaylandı'
                                  ? null
                                  : () => updateOrderStatus(order['id'], 'approve'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: order['status'] == 'Reddedildi'
                                  ? null
                                  : () => updateOrderStatus(order['id'], 'reject'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
