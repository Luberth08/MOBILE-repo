import 'package:flutter/material.dart';
import '../services/auth_api.dart';
import '../services/session.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] ?? '';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese un código de 6 dígitos')));
      return;
    }
    setState(() => _loading = true);
    try {
      final token = await AuthApi.verifyOtp(_email, code);
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
      appBar: AppBar(title: const Text('Verificar código')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Se envió un código a $_email'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Código (6 dígitos)'),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _confirm,
              child: _loading ? const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
