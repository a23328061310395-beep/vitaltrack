import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../utils/auth_service.dart';
import '../../utils/auth_service.dart';
import '../../models/models.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _paso = 0;

  // Paso 1
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  DateTime? _fechaNac;
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  String _genero = 'mujer';

  // Paso 2
  final Set<CondicionSalud> _condiciones = {};
  final _otraCtrl = TextEditingController();

  // Paso 3
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _verPass = false;
  String? _error;

  void _siguiente() {
    if (_paso == 0) {
      if (_nombreCtrl.text.isEmpty ||
          _emailCtrl.text.isEmpty ||
          _fechaNac == null ||
          _pesoCtrl.text.isEmpty ||
          _alturaCtrl.text.isEmpty) {
        setState(() => _error = 'Completa todos los campos');
        return;
      }
    }
    if (_paso == 2) {
      _registrar();
      return;
    }
    setState(() {
      _error = null;
      _paso++;
    });
  }

  Future<void> _registrar() async {
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (_passCtrl.text != _pass2Ctrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    // 1. Crear cuenta en Firebase Auth
    final authError = await AuthService.registrar(
        _emailCtrl.text.trim(), _passCtrl.text);
    if (authError != null) {
      setState(() => _error = authError);
      return;
    }
    // 2. Guardar perfil en Firestore
    final usuario = Usuario(
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: '', // No guardamos la contraseña — Firebase Auth la maneja
      fechaNacimiento: _fechaNac!,
      peso: double.parse(_pesoCtrl.text),
      altura: double.parse(_alturaCtrl.text),
      genero: _genero,
      condiciones: _condiciones.toList(),
      otraCondicion: _otraCtrl.text,
    );
    await FirebaseService.guardarPerfil(usuario);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> _seleccionarFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _fechaNac = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgreso(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: [
                  _buildPaso1(),
                  _buildPaso2(),
                  _buildPaso3(),
                ][_paso],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgreso() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i <= _paso ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 10),
          Text('Paso ${_paso + 1} de 3',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPaso1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Tus datos personales',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Necesitamos conocerte para personalizar tu experiencia',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 28),
        TextField(
          controller: _nombreCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const Icon(Icons.cake_outlined,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Text(
                _fechaNac == null
                    ? 'Fecha de nacimiento'
                    : '${_fechaNac!.day}/${_fechaNac!.month}/${_fechaNac!.year}',
                style: TextStyle(
                    color: _fechaNac == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 15),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _pesoCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _alturaCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        const Text('Género',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Row(children: [
          _generoBtn('mujer', Icons.female_rounded, 'Mujer'),
          const SizedBox(width: 10),
          _generoBtn('hombre', Icons.male_rounded, 'Hombre'),
        ]),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style:
                  const TextStyle(color: AppColors.danger, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _siguiente,
          child: const Text('Siguiente', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('¿Ya tienes cuenta? Inicia sesión',
                style: TextStyle(
                    color: AppColors.primary, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _generoBtn(String valor, IconData icono, String etiqueta) {
    final sel = _genero == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _genero = valor),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? AppColors.okBg : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: sel ? AppColors.primary : AppColors.border,
                width: sel ? 1.5 : 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono,
                  color:
                      sel ? AppColors.primary : AppColors.textSecondary,
                  size: 20),
              const SizedBox(width: 6),
              Text(etiqueta,
                  style: TextStyle(
                      color: sel
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: sel
                          ? FontWeight.w500
                          : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaso2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Tu historial de salud',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text(
            'Selecciona si tienes alguna condición. Esto personalizará tus alertas y recordatorios.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        ...CondicionSalud.values.map((c) => _condicionTile(c)),
        if (_condiciones.contains(CondicionSalud.otra)) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _otraCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: '¿Cuál es tu condición?',
              prefixIcon: Icon(Icons.edit_outlined,
                  color: AppColors.textSecondary),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline, color: AppColors.blue, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Si no tienes ninguna condición, puedes continuar sin seleccionar nada.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _siguiente,
          child: const Text('Siguiente', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _paso--),
          child: const Text('← Atrás',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _condicionTile(CondicionSalud c) {
    final sel = _condiciones.contains(c);
    return GestureDetector(
      onTap: () => setState(() {
        sel ? _condiciones.remove(c) : _condiciones.add(c);
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: sel ? AppColors.okBg : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: sel ? AppColors.primary : AppColors.border,
              width: sel ? 1.5 : 0.5),
        ),
        child: Row(children: [
          Icon(
            sel ? Icons.check_box : Icons.check_box_outline_blank,
            color: sel ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(condicionNombre(c),
              style: TextStyle(
                  color: sel
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 15)),
        ]),
      ),
    );
  }

  Widget _buildPaso3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Crea tu contraseña',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Ya casi terminamos. Define una contraseña segura.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 28),
        TextField(
          controller: _passCtrl,
          obscureText: !_verPass,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline,
                color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                  _verPass ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary),
              onPressed: () => setState(() => _verPass = !_verPass),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _pass2Ctrl,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: Icon(Icons.lock_outline,
                color: AppColors.textSecondary),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style:
                  const TextStyle(color: AppColors.danger, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _siguiente,
          child: const Text('Crear cuenta', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _paso--),
          child: const Text('← Atrás',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
