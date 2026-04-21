import 'package:flutter/material.dart';
import '../services/auth_api.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({Key? key}) : super(key: key);

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    setState(() => _loading = true);
    try {
      final resp = await AuthApi.checkEmail(email);
      final exists = resp['exists'] as bool;
      final hasUser = resp['has_user'] as bool;
      if (!exists) {
        await AuthApi.register(email);
        Navigator.pushNamed(context, '/verify', arguments: {'email': email});
      } else if (!hasUser) {
        await AuthApi.requestOtp(email);
        Navigator.pushNamed(context, '/verify', arguments: {'email': email});
      } else {
        Navigator.pushNamed(context, '/password', arguments: {'email': email});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) return 'Ingrese un email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(val)) return 'Email inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
