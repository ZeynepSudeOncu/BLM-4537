import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/depolar_screen.dart';
import 'screens/admin/depo_ekle_screen.dart';
import 'screens/admin/depo_duzenle_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔹 ilk açılan ekran
      home: const LoginScreen(),

      // 🔹 TÜM ROUTE'LAR BURADA
      routes: {
        // ✅ DASHBOARD
        "/admin/dashboard": (_) =>  AdminDashboardPage(),

        // ✅ DEPOLAR
        "/admin/depolar": (_) => const DepolarScreen(),
        "/admin/depolar/yeni": (_) => const DepoEkleScreen(),
        "/admin/depolar/duzenle": (ctx) {
          final id = ModalRoute.of(ctx)!.settings.arguments as String;
          return DepoDuzenleScreen(id: id);
        },
      },
    );
  }
}
