import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/depolar_screen.dart';
import 'screens/admin/depo_ekle_screen.dart';
import 'screens/admin/depo_duzenle_screen.dart';
import 'screens/admin/kamyonlar_screen.dart';
import 'screens/admin/kamyon_ekle_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔹 İlk açılan ekran
      home: const LoginScreen(),

      // 🔹 STATIC ROUTE'LAR
      routes: {
        // ================= ADMIN =================

        // Dashboard
        "/admin/dashboard": (_) => AdminDashboardPage(),

        // Depolar
        "/admin/depolar": (_) => const DepolarScreen(),
        "/admin/depolar/yeni": (_) => const DepoEkleScreen(),

        // Kamyonlar
        "/admin/kamyonlar": (_) => const KamyonlarScreen(),
        "/admin/kamyonlar/yeni": (_) => const KamyonEkleScreen(),
      },

      // 🔹 DYNAMIC ROUTE (id alan sayfalar)
      onGenerateRoute: (settings) {
        // Depo düzenle
        if (settings.name == "/admin/depolar/duzenle") {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => DepoDuzenleScreen(id: id),
          );
        }

        // route bulunamazsa null
        return null;
      },
    );
  }
}
