import 'package:flutter/material.dart';
import '../services/session.dart';
import '../services/auth_api.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;
  
  final List<String> _tabTitles = [
    'Mi Perfil',
    'Solicitar Diagnóstico',
    'Solicitudes'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    setState(() => _loading = true);
    try {
      final token = await Session.getToken();
      if (token != null) {
        await AuthApi.logout(token);
      }
      await Session.clearToken();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      // Incluso si falla el logout en el servidor, limpiamos la sesión local
      await Session.clearToken();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF932D30),
        foregroundColor: Colors.white,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return Text(
              _tabTitles[_tabController.index],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _logout,
            icon: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ProfileTab(),
          _buildComingSoonTab('Solicitar Diagnóstico'),
          _buildComingSoonTab('Solicitudes'),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF932D30),
          unselectedLabelColor: const Color(0xFF52341A).withOpacity(0.6),
          indicatorColor: const Color(0xFF932D30),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Mi Perfil',
            ),
            Tab(
              icon: Icon(Icons.car_repair),
              text: 'Diagnóstico',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Solicitudes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonTab(String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F2EB), Color(0xFFE8E3DA)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.construction,
                size: 64,
                color: Color(0xFF932D30),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$title estará disponible pronto',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF52341A).withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
