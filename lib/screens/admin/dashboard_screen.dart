import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/dashboard_card.dart';
import '../../widgets/daily_request_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic>? data;
  Map<String, dynamic>? critical;
  Map<String, dynamic>? productDemand;
  Map<String, dynamic>? delivery;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    const baseUrl = "http://localhost:5144/api";

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    try {
      final dashboardRes =
          await http.get(Uri.parse("$baseUrl/admin/dashboard"), headers: headers);
      final criticalRes = await http.get(
          Uri.parse("$baseUrl/admin/dashboard/critical-stocks?threshold=5"),
          headers: headers);
      final demandRes = await http.get(
          Uri.parse("$baseUrl/admin/dashboard/product-demand?days=7"),
          headers: headers);
      final deliveryRes = await http.get(
          Uri.parse(
              "$baseUrl/admin/dashboard/delivery-metrics?delayHours=24"),
          headers: headers);

      setState(() {
        data = json.decode(dashboardRes.body);
        critical = json.decode(criticalRes.body);
        productDemand = json.decode(demandRes.body);
        delivery = json.decode(deliveryRes.body);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cards = data!["cards"];
    final charts = data!["charts"];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= KARTLAR =================
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                DashboardCard(title: "Toplam Ürün", value: cards["totalProducts"]),
                DashboardCard(title: "Toplam Stok", value: cards["totalStock"]),
                DashboardCard(title: "Bekleyen", value: cards["pendingRequests"]),
                DashboardCard(title: "Yolda", value: cards["onTheWayRequests"]),
                DashboardCard(title: "Teslim", value: cards["deliveredRequests"]),
                DashboardCard(
                  title: "Kritik Stok",
                  value: critical?["count"] ?? 0,
                  danger: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ================= KRİTİK STOK LİSTESİ =================
            if (critical != null && critical!["count"] > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🚨 Kritik Stoktaki Ürünler",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...critical!["items"].map<Widget>((x) {
                        return ListTile(
                          title: Text(x["productName"]),
                          subtitle: Text(x["productCode"]),
                          trailing: Text(
                            x["totalQuantity"].toString(),
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            /// ================= GÜNLÜK TALEPLER =================
            const Text(
              "Son 7 Günlük Talepler",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 200, child: DailyRequestChart()),

            const SizedBox(height: 24),

            /// ================= DURUM DAĞILIMI =================
            const Text(
              "Talep Durum Dağılımı",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(sections: [
                  PieChartSectionData(
                      value: charts["statusDistribution"]["pending"].toDouble(),
                      title: "Beklemede",
                      color: Colors.amber),
                  PieChartSectionData(
                      value: charts["statusDistribution"]["onTheWay"].toDouble(),
                      title: "Yolda",
                      color: Colors.blue),
                  PieChartSectionData(
                      value: charts["statusDistribution"]["delivered"].toDouble(),
                      title: "Teslim",
                      color: Colors.green),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= EN ÇOK TALEP EDİLEN ÜRÜNLER =================
            if (productDemand != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📊 En Çok Talep Edilen Ürünler (Son 7 Gün)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...productDemand!["topProducts"].map<Widget>((x) {
                    return ListTile(
                      title: Text(x["productName"]),
                      subtitle: Text(x["productCode"]),
                      trailing: Text(x["requestCount"].toString()),
                    );
                  }).toList(),
                ],
              ),

            const SizedBox(height: 24),

            /// ================= TESLİMAT PERFORMANSI =================
            if (delivery != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🚚 Teslimat Performansı",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: "En Hızlı Depo",
                          value: delivery!["fastestDepot"]?["avgHours"]?.round() ?? 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DashboardCard(
                          title: "En Yavaş Depo",
                          value: delivery!["slowestDepot"]?["avgHours"]?.round() ?? 0,
                          danger: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 24),

            /// ================= GECİKEN TESLİMATLAR =================
            if (delivery != null && delivery!["delayedCount"] > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "⏱ Geciken Teslimatlar (24+ saat)",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ...delivery!["delayed"].map<Widget>((x) {
                    return ListTile(
                      leading:
                          const Icon(Icons.warning, color: Colors.red),
                      title: Text(x["productName"]),
                      subtitle: Text(
                          "Mağaza: ${x["storeName"]} • Depo: ${x["depotName"]}"),
                      trailing: Text(
                        "${x["delayHours"]}s",
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ],
              )
            else
              const Text(
                "Geciken teslimat yok 👍",
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
