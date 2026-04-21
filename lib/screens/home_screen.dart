import 'package:flutter/material.dart';
import '../services/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await Session.getToken();
    setState(() => _token = t);
  }

  Future<void> _logout() async {
    await Session.clearToken();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Sesión activa'),
          const SizedBox(height: 8),
          Text(_token ?? 'Sin token', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _logout, child: const Text('Cerrar sesión')),
        ]),
      ),
    );
  }
}
