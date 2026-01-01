import 'package:flutter/material.dart';
import 'package:flutter_mobil/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'depolar_screen.dart';
import 'kamyonlar_screen.dart';
import 'magazalar_screen.dart';
import 'siparisler_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
           _buildButton(
            context,
            title: "🏠 Ana Sayfa ",
            destination:  AdminDashboardPage(),
          ),
          _buildButton(
            context,
            title: "📦 Tüm Depolar",
            destination: const DepolarScreen(),
          ),
          _buildButton(
            context,
            title: "🚚 Tüm Kamyonlar",
            destination: const KamyonlarScreen(),
          ),
          _buildButton(
            context,
            title: "🏬 Tüm Mağazalar",
            destination: const MagazalarScreen(),
          ),
          _buildButton(
            context,
            title: "📄 Tüm Siparişler",
            destination: const AdminSiparislerScreen(),
          ),
          _buildButton(
            context, 
            title: "🚪 Çıkış Yap", 
            destination:   LoginScreen(),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String title, required Widget destination}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Text(title),
      ),
    );
  }
}
