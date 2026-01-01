import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/admin/admin_home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'admin@example.com');
  final passwordController = TextEditingController(text: 'Pass123!');
  bool isLoading = false;
  String? errorMessage;

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await AuthService.login(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        final profile = await AuthService.getProfile();
        final role = (profile['roles']?[0] ?? '').toString().toLowerCase();

        Widget nextPage;

        switch (role) {
          case 'admin':
            nextPage = const  AdminHomeScreen();
            break;
          // case 'driver':
          //   nextPage = const DriverScreen();
          //   break;
          // case 'store':
          //   nextPage = const StoreScreen();
          //   break;
          // case 'depot':
          //   nextPage = const DepotScreen();
          //   break;
          default:
            throw Exception('Geçersiz rol: $role');
        }

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Şifre'),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
