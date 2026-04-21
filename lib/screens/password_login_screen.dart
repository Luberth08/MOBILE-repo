import 'package:flutter/material.dart';
import '../services/auth_api.dart';
import '../services/session.dart';

class PasswordLoginScreen extends StatefulWidget {
  const PasswordLoginScreen({Key? key}) : super(key: key);

  @override
  State<PasswordLoginScreen> createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final _passwordController = TextEditingController();
  String _email = '';
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] ?? '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese la contraseña')));
      return;
    }
    setState(() => _loading = true);
    try {
      final token = await AuthApi.login(_email, password);
      await Session.saveToken(token);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar con contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Usuario: $_email'),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Iniciar sesión')),
          ],
        ),
      ),
    );
  }
}
