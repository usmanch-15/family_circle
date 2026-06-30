import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/super_admin_service.dart';
import 'super_admin_dashboard_screen.dart';

class SuperAdminLoginScreen extends StatefulWidget {
  const SuperAdminLoginScreen({super.key});

  @override
  State<SuperAdminLoginScreen> createState() => _SuperAdminLoginScreenState();
}

class _SuperAdminLoginScreenState extends State<SuperAdminLoginScreen> {
  final _passCtrl = TextEditingController();
  final SuperAdminService _service = SuperAdminService();
  String? _error;

  void _verify() {
    if (_service.verifyPassword(_passCtrl.text.trim())) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuperAdminDashboardScreen()),
      );
    } else {
      setState(() => _error = 'Password sahi nahi hai');
    }
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings,
                  size: 56, color: Colors.white),
              const SizedBox(height: 16),
              const Text('Super Admin',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _verify(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verify,
                child: const Text('Enter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}