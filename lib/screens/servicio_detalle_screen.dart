import 'package:flutter/material.dart';
import '../models/servicio.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicioDetalleScreen extends StatelessWidget {
  final ServicioCliente servicio;

  const ServicioDetalleScreen({
    Key? key,
    required this.servicio,
  }) : super(key: key);

  Color _getEstadoColor() {
    return Color(int.parse(servicio.estadoColor.replaceFirst('#', '0xFF')));
  }

  IconData _getEstadoIcon() {
    switch (servicio.estado) {
      case 'creado':
        return Icons.build;
      case 'en_proceso':
        return Icons.engineering;
      case 'completado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> _llamarTaller(BuildContext context) async {
    if (servicio.taller.telefono == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El taller no tiene teléfono registrado')),
      );
      return;
    }

    final uri = Uri.parse('tel:${servicio.taller.telefono}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede realizar la llamada')),
        );
      }
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
        title: const Text(
          'Detalle del Servicio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            _buildHeader(),
            
            // Información del taller
            _buildTallerSection(context),
            
            // Técnicos asignados
            if (servicio.tecnicosAsignados.isNotEmpty)
              _buildTecnicosSection(),
            
            // Vehículos asignados
            if (servicio.vehiculosAsignados.isNotEmpty)
              _buildVehiculosSection(),
            
            // Diagnóstico
            if (servicio.diagnostico != null)
              _buildDiagnosticoSection(),
            
            // Mapa (ubicación del cliente)
            if (servicio.ubicacionCliente != null)
              _buildMapaSection(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getEstadoColor(),
            _getEstadoColor().withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getEstadoIcon(),
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            servicio.estadoTexto.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Servicio #${servicio.id}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatFecha(servicio.fecha),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTallerSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF932D30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFF932D30),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'TALLER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF52341A),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Rating
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    servicio.taller.puntos.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            servicio.taller.nombre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          if (servicio.taller.direccion != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: Color(0xFF52341A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    servicio.taller.direccion!,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF52341A).withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (servicio.taller.telefono != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _llamarTaller(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 18,
                    color: Color(0xFF932D30),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    servicio.taller.telefono!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF932D30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (servicio.taller.email != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.email,
                  size: 18,
                  color: Color(0xFF52341A),
                ),
                const SizedBox(width: 8),
                Text(
                  servicio.taller.email!,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF52341A).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTecnicosSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF932D30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.engineering,
                  color: Color(0xFF932D30),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'TÉCNICOS ASIGNADOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52341A),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...servicio.tecnicosAsignados.map((tecnico) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF932D30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF932D30),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tecnico.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVehiculosSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF932D30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Color(0xFF932D30),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'VEHÍCULOS DEL TALLER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52341A),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...servicio.vehiculosAsignados.map((vehiculo) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF932D30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vehiculo.matricula,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${vehiculo.marca} ${vehiculo.modelo}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoSection() {
    final diagnostico = servicio.diagnostico!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF932D30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFF932D30),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'DIAGNÓSTICO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52341A),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (diagnostico.descripcion != null) ...[
            Text(
              diagnostico.descripcion!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C2C2C),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              const Text(
                'Nivel de confianza:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF52341A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(diagnostico.nivelConfianza * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF932D30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapaSection() {
    final coords = servicio.coordenadasCliente;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF932D30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF932D30),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'TU UBICACIÓN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF52341A),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Placeholder para el mapa
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map,
                    size: 48,
                    color: Color(0xFF932D30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mapa de ubicación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  if (coords != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${coords.keys.first.toStringAsFixed(6)}, Lng: ${coords.values.first.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF52341A).withOpacity(0.8),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '(Implementar con google_maps_flutter)',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF52341A).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${fecha.day} ${months[fecha.month - 1]} ${fecha.year}, ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
