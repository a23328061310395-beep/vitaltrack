import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../utils/auth_service.dart';
import '../../models/models.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final u = await FirebaseService.cargarPerfil();
    setState(() => _usuario = u);
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cerrar sesión',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('¿Estás seguro que quieres cerrar sesión?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await AuthService.cerrarSesion();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.blue]),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  _usuario!.nombre[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(_usuario!.nombre,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            Text(_usuario!.email,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),

            // Datos de salud
            _seccion('Datos de salud', [
              _fila('Edad', '${_usuario!.edad} años'),
              _fila('Peso', '${_usuario!.peso} kg'),
              _fila('Altura', '${_usuario!.altura} cm'),
              _fila('IMC',
                  '${_usuario!.imc.toStringAsFixed(1)} · ${_usuario!.categoriaIMC}'),
              _fila('Género',
                  _usuario!.genero == 'mujer' ? 'Mujer' : 'Hombre'),
            ]),
            const SizedBox(height: 14),

            // Condiciones
            if (_usuario!.condiciones.isNotEmpty)
              _seccion(
                  'Condiciones de salud',
                  _usuario!.condiciones
                      .map((c) => _fila('·', condicionNombre(c)))
                      .toList()),
            if (_usuario!.condiciones.isNotEmpty) const SizedBox(height: 14),

            // Opciones
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(children: [
                _opcion(Icons.edit_outlined, AppColors.primary,
                    'Editar perfil', () {}),
                const Divider(color: AppColors.border, height: 0.5),
                _opcion(Icons.logout_rounded, AppColors.danger,
                    'Cerrar sesión', _cerrarSesion),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, List<Widget> filas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6)),
          const SizedBox(height: 10),
          ...filas,
        ],
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Text(valor,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _opcion(
      IconData ico, Color color, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(ico, color: color, size: 20),
      title: Text(label,
          style: TextStyle(
              color: color == AppColors.danger
                  ? AppColors.danger
                  : AppColors.textPrimary,
              fontSize: 14)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textSecondary, size: 18),
      onTap: onTap,
    );
  }
}
