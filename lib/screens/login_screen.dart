import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admin_product_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _login() async {
    final url = Uri.parse('http://192.168.1.14:5274/api/auth/login');

    try {
      setState(() => isLoading = true);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        print("✅ Données reçues : $data");

        if (data['id'] == null) {
          _showErrorDialog("Erreur : identifiant utilisateur manquant.");
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('userId', data['id']);
        prefs.setString('fullName', '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}');
        prefs.setString('codeSage', data['codeSage'] ?? 'XXX');
        prefs.setString('role', data['role'] ?? '');

        if (!mounted) return;
        if (data['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminProductScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavScreen()),
          );
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      _showErrorDialog('Erreur de connexion : $e');
    }
  }

  void _handleError(http.Response response) {
    String errorMessage = "Erreur inconnue";
    if (response.body.isNotEmpty) {
      try {
        final error = jsonDecode(response.body);
        errorMessage = error['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = "Erreur de format JSON.";
      }
    }
    _showErrorDialog(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
