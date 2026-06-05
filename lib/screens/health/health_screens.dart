// ─── GLUCOSA ───
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class GlucosaScreen extends StatefulWidget {
  const GlucosaScreen({super.key});
  @override
  State<GlucosaScreen> createState() => _GlucosaScreenState();
}

class _GlucosaScreenState extends State<GlucosaScreen> {
  List<RegistroGlucosa> _registros = [];
  final _valorCtrl = TextEditingController();
  String _momento = 'ayunas';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final r = await FirebaseService.cargarGlucosas();
    setState(() => _registros = r.reversed.toList());
  }

  Future<void> _guardar() async {
    final v = double.tryParse(_valorCtrl.text);
    if (v == null) return;
    await FirebaseService.agregarGlucosa(RegistroGlucosa(
      valor: v,
      momento: _momento,
      fechaHora: DateTime.now(),
    ));
    _valorCtrl.clear();
    await _cargar();
    if (mounted) Navigator.pop(context);
  }

  void _mostrarForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nueva lectura de glucosa',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              TextField(
                controller: _valorCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Glucosa (mg/dL)'),
              ),
              const SizedBox(height: 14),
              const Text('Momento de la medición',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(children: [
                _chipMomento('ayunas', 'En ayunas', setS),
                const SizedBox(width: 8),
                _chipMomento('postprandial', 'Post comida', setS),
                const SizedBox(width: 8),
                _chipMomento('aleatorio', 'Aleatorio', setS),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar registro')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipMomento(String valor, String label, StateSetter setS) {
    final sel = _momento == valor;
    return GestureDetector(
      onTap: () => setS(() => _momento = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.okBg : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel ? AppColors.primary : AppColors.border, width: 0.5),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _registros.isNotEmpty ? _registros.first : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Glucosa en sangre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ultimo != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(children: [
                  const Text('Último registro',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('${ultimo.valor.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.w600)),
                  const Text('mg/dL',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(ultimo.momento == 'ayunas'
                      ? 'Medición en ayunas'
                      : ultimo.momento == 'postprandial'
                          ? 'Después de comer'
                          : 'Medición aleatoria',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 10),
                  EstadoBadge(ultimo.estado),
                ]),
              ),
              const SizedBox(height: 20),
            ],
            const SeccionTitulo('historial'),
            const SizedBox(height: 10),
            if (_registros.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Column(children: [
                    Icon(Icons.water_drop_outlined,
                        color: AppColors.textSecondary, size: 36),
                    SizedBox(height: 10),
                    Text('Sin registros aún',
                        style:
                            TextStyle(color: AppColors.textSecondary)),
                  ]),
                ),
              )
            else
              ..._registros.map((r) => Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat("d MMM 'a las' HH:mm", 'es')
                                    .format(r.fechaHora),
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${r.valor.toStringAsFixed(0)} mg/dL · ${r.momento}',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                            ]),
                        EstadoBadge(r.estado),
                      ],
                    ),
                  )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarForm,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─── PULSO ───
class PulsoScreen extends StatefulWidget {
  const PulsoScreen({super.key});
  @override
  State<PulsoScreen> createState() => _PulsoScreenState();
}

class _PulsoScreenState extends State<PulsoScreen> {
  List<RegistroPulso> _registros = [];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final r = await FirebaseService.cargarPulsos();
    setState(() => _registros = r.reversed.toList());
  }

  Future<void> _guardar() async {
    final v = int.tryParse(_ctrl.text);
    if (v == null) return;
    await FirebaseService.agregarPulso(
        RegistroPulso(bpm: v, fechaHora: DateTime.now()));
    _ctrl.clear();
    await _cargar();
    if (mounted) Navigator.pop(context);
  }

  void _mostrarForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Registrar pulso',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Frecuencia cardíaca (bpm)'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Normal en reposo: 60–100 bpm\nBradycardia: menos de 60 bpm\nTachycardia: más de 100 bpm',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar registro')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frecuencia cardíaca')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_registros.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.border, width: 0.5)),
                child: Column(children: [
                  const Text('Último registro',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('${_registros.first.bpm}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.w600)),
                  const Text('bpm',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 10),
                  EstadoBadge(_registros.first.estado),
                ]),
              ),
              const SizedBox(height: 20),
            ],
            const SeccionTitulo('historial'),
            const SizedBox(height: 10),
            ..._registros.map((r) => Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 14),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.border, width: 0.5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("d MMM 'a las' HH:mm", 'es')
                                  .format(r.fechaHora),
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11),
                            ),
                            Text('${r.bpm} bpm',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ]),
                      EstadoBadge(r.estado),
                    ],
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarForm,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─── IMC ───
class ImcScreen extends StatefulWidget {
  const ImcScreen({super.key});
  @override
  State<ImcScreen> createState() => _ImcScreenState();
}

class _ImcScreenState extends State<ImcScreen> {
  double? _imc;
  String _categoria = '';
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final u = await FirebaseService.cargarPerfil();
    if (u != null) {
      setState(() {
        _imc = u.imc;
        _categoria = u.categoriaIMC;
        _pesoCtrl.text = u.peso.toString();
        _alturaCtrl.text = u.altura.toString();
      });
    }
  }

  Future<void> _actualizar() async {
    final p = double.tryParse(_pesoCtrl.text);
    final a = double.tryParse(_alturaCtrl.text);
    if (p == null || a == null) return;
    final u = await FirebaseService.cargarPerfil();
    if (u == null) return;
    u.peso = p;
    u.altura = a;
    await FirebaseService.guardarPerfil(u);
    await _cargar();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Índice de masa corporal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imc != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.border, width: 0.5)),
                child: Column(children: [
                  Text(_imc!.toStringAsFixed(1),
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 56,
                          fontWeight: FontWeight.w600)),
                  const Text('IMC',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 10),
                  EstadoBadge(_categoria),
                ]),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(children: [
                _imcRango('Bajo peso', 'Menos de 18.5', AppColors.blue),
                _imcRango('Normal', '18.5 – 24.9', AppColors.ok),
                _imcRango('Sobrepeso', '25 – 29.9', AppColors.warn),
                _imcRango('Obesidad', '30 o más', AppColors.danger),
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20,
                      MediaQuery.of(context).viewInsets.bottom + 20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Actualizar medidas',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _pesoCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Peso (kg)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _alturaCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Altura (cm)'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _actualizar,
                        child: const Text('Actualizar')),
                  ]),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Actualizar peso y altura'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imcRango(String cat, String rango, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 10),
          Text(cat,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13)),
          const Spacer(),
          Text(rango,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── HIDRATACIÓN ───
class HidratacionScreen extends StatefulWidget {
  const HidratacionScreen({super.key});
  @override
  State<HidratacionScreen> createState() => _HidratacionScreenState();
}

class _HidratacionScreenState extends State<HidratacionScreen> {
  int _vasos = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final h = await FirebaseService.vasosHoy();
    setState(() => _vasos = h);
  }

  Future<void> _agregar() async {
    await FirebaseService.agregarVaso();
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_vasos / 8).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('Hidratación diaria')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(children: [
                Text('$_vasos',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 64,
                        fontWeight: FontWeight.w600)),
                const Text('vasos de agua hoy',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.blue),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$_vasos de 8 vasos recomendados',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                  8,
                  (i) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 48,
                          decoration: BoxDecoration(
                            color: i < _vasos
                                ? AppColors.blue
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_drink_rounded,
                              color: Colors.white, size: 18),
                        ),
                      )),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _vasos < 8 ? _agregar : null,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Agregar un vaso',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _vasos >= 8 ? AppColors.surface : AppColors.blue,
              ),
            ),
            if (_vasos >= 8) ...[
              const SizedBox(height: 12),
              const AlertaPrioritaria(
                mensaje: '¡Excelente! Has alcanzado tu meta de hidratación de hoy.',
                icono: Icons.celebration_outlined,
                color: AppColors.ok,
                colorBg: AppColors.okBg,
              ),
            ],
          ],
        ),
      ),
    );
  }
} // ←←← CIERRE DE LA CLASE _HidratacionScreenState

// ─── HISTORIAL GENERAL ───
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});
  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Map<String, dynamic>> _todos = [];
  String _filtro = 'Todo';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final presiones = await FirebaseService.cargarPresiones();
    final glucosas = await FirebaseService.cargarGlucosas();
    final pulsos = await FirebaseService.cargarPulsos();
    final todos = <Map<String, dynamic>>[];

    for (final r in presiones) {
      todos.add({
        'tipo': 'Presión',
        'valor': '${r.sistolica}/${r.diastolica} mmHg',
        'estado': r.estado,
        'fecha': r.fechaHora,
      });
    }
    for (final r in glucosas) {
      todos.add({
        'tipo': 'Glucosa',
        'valor': '${r.valor.toStringAsFixed(0)} mg/dL',
        'estado': r.estado,
        'fecha': r.fechaHora,
      });
    }
    for (final r in pulsos) {
      todos.add({
        'tipo': 'Pulso',
        'valor': '${r.bpm} bpm',
        'estado': r.estado,
        'fecha': r.fechaHora,
      });
    }

    todos.sort((a, b) =>
        (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
    setState(() => _todos = todos);
  }

  List<Map<String, dynamic>> get _filtrados =>
      _filtro == 'Todo' ? _todos : _todos.where((e) => e['tipo'] == _filtro).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todo', 'Presión', 'Glucosa', 'Pulso']
                    .map((f) => GestureDetector(
                          onTap: () => setState(() => _filtro = f),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _filtro == f
                                  ? AppColors.okBg
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _filtro == f
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 0.5),
                            ),
                            child: Text(f,
                                style: TextStyle(
                                    color: _filtro == f
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontSize: 13)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: _filtrados.isEmpty
                ? const Center(
                    child: Text('Sin registros',
                        style:
                            TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtrados.length,
                    itemBuilder: (_, i) {
                      final r = _filtrados[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.border, width: 0.5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(r['tipo'],
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat("d MMM 'a las' HH:mm", 'es')
                                        .format(r['fecha']),
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(r['valor'],
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ]),
                            EstadoBadge(r['estado']),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
