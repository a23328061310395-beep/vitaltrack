import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'calendario_medicamento_screen.dart';

class MedicamentosScreen extends StatefulWidget {
  const MedicamentosScreen({super.key});

  @override
  State<MedicamentosScreen> createState() => _MedicamentosScreenState();
}

class _MedicamentosScreenState extends State<MedicamentosScreen> {
  List<Medicamento> _medicamentos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final meds = await FirebaseService.cargarMedicamentos();
    setState(() {
      _medicamentos = meds;
      _cargando = false;
    });
  }

  void _abrirFormulario([Medicamento? existente]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormMedicamento(
        existente: existente,
        onGuardado: _cargar,
      ),
    );
  }

  Future<void> _eliminar(Medicamento m) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar medicamento',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('¿Eliminar ${m.nombre}? Se borrará también su historial de tomas.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await FirebaseService.eliminarMedicamento(m.id);
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis medicamentos'),
        actions: [
          IconButton(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _medicamentos.isEmpty
              ? _sinMedicamentos()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _medicamentos.length,
                  itemBuilder: (_, i) =>
                      _tarjetaMedicamento(_medicamentos[i]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _tarjetaMedicamento(Medicamento m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.okBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.nombre,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      Text('${m.dosis} · ${m.horasToma.length} toma${m.horasToma.length > 1 ? 's' : ''} al día',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      if (m.notas.isNotEmpty)
                        Text(m.notas,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.surfaceAlt,
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary),
                  onSelected: (v) {
                    if (v == 'editar') _abrirFormulario(m);
                    if (v == 'eliminar') _eliminar(m);
                    if (v == 'calendario') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                CalendarioMedicamentoScreen(medicamento: m)),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'calendario',
                        child: Row(children: [
                          Icon(Icons.calendar_month_outlined,
                              color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Ver calendario',
                              style:
                                  TextStyle(color: AppColors.textPrimary)),
                        ])),
                    const PopupMenuItem(
                        value: 'editar',
                        child: Row(children: [
                          Icon(Icons.edit_outlined,
                              color: AppColors.textSecondary, size: 18),
                          SizedBox(width: 8),
                          Text('Editar',
                              style:
                                  TextStyle(color: AppColors.textPrimary)),
                        ])),
                    const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              color: AppColors.danger, size: 18),
                          SizedBox(width: 8),
                          Text('Eliminar',
                              style: TextStyle(color: AppColors.danger)),
                        ])),
                  ],
                ),
              ],
            ),
          ),
          // Horarios del día
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _HorariosToma(medicamento: m),
          ),
        ],
      ),
    );
  }

  Widget _sinMedicamentos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.medication_outlined,
                color: AppColors.textSecondary, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Sin medicamentos registrados',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Toca + para agregar tu primer medicamento',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── HORARIOS DEL DÍA CON BOTÓN DE MARCAR ───
class _HorariosToma extends StatefulWidget {
  final Medicamento medicamento;
  const _HorariosToma({required this.medicamento});

  @override
  State<_HorariosToma> createState() => _HorariosTomaState();
}

class _HorariosTomaState extends State<_HorariosToma> {
  List<RegistroToma> _tomasHoy = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final tomas =
        await FirebaseService.tomasDelDia(widget.medicamento.id, hoy);
    setState(() {
      _tomasHoy = tomas;
      _cargando = false;
    });
  }

  Future<void> _toggle(String hora) async {
    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final tomada =
        _tomasHoy.any((t) => t.horaProgramada == hora && t.tomada);
    if (tomada) {
      await FirebaseService.desmarcarToma(widget.medicamento.id, hora, hoy);
    } else {
      await FirebaseService.marcarToma(widget.medicamento.id, hora, hoy);
    }
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
          height: 20,
          child: Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: widget.medicamento.horasToma.map((hora) {
        final tomada =
            _tomasHoy.any((t) => t.horaProgramada == hora && t.tomada);
        final horaReal = _tomasHoy
            .where((t) => t.horaProgramada == hora && t.tomada)
            .map((t) => t.horaReal)
            .firstOrNull;
        return GestureDetector(
          onTap: () => _toggle(hora),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tomada ? AppColors.okBg : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color:
                      tomada ? AppColors.primary : AppColors.border,
                  width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tomada
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: tomada ? AppColors.primary : AppColors.textSecondary,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hora,
                        style: TextStyle(
                            color: tomada
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    if (tomada && horaReal != null)
                      Text(
                        'Tomada ${DateFormat('HH:mm').format(horaReal)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 9),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── FORMULARIO PARA AGREGAR / EDITAR MEDICAMENTO ───
class _FormMedicamento extends StatefulWidget {
  final Medicamento? existente;
  final VoidCallback onGuardado;
  const _FormMedicamento({this.existente, required this.onGuardado});

  @override
  State<_FormMedicamento> createState() => _FormMedicamentoState();
}

class _FormMedicamentoState extends State<_FormMedicamento> {
  final _nombreCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  List<String> _horas = ['08:00'];
  bool _esPermanente = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existente != null) {
      final m = widget.existente!;
      _nombreCtrl.text = m.nombre;
      _dosisCtrl.text = m.dosis;
      _notasCtrl.text = m.notas;
      _horas = List.from(m.horasToma);
      _esPermanente = m.esPermanente;
    }
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.isEmpty || _dosisCtrl.text.isEmpty) {
      setState(() => _error = 'Nombre y dosis son obligatorios');
      return;
    }
    final med = Medicamento(
      id: widget.existente?.id ?? const Uuid().v4(),
      nombre: _nombreCtrl.text.trim(),
      dosis: _dosisCtrl.text.trim(),
      horasToma: _horas,
      esPermanente: _esPermanente,
      fechaInicio: widget.existente?.fechaInicio ?? DateTime.now(),
      notas: _notasCtrl.text.trim(),
    );
    await FirebaseService.agregarMedicamento(med);
    widget.onGuardado();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _agregarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (hora != null) {
      final str =
          '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (!_horas.contains(str)) {
          _horas.add(str);
          _horas.sort();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existente == null
                  ? 'Nuevo medicamento'
                  : 'Editar medicamento',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nombre del medicamento',
                hintText: 'Ej: Metformina, Losartán...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosisCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Dosis',
                hintText: 'Ej: 500mg, 50mg...',
              ),
            ),
            const SizedBox(height: 16),
            // Horarios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Horarios de toma',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                TextButton.icon(
                  onPressed: _agregarHora,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: const Text('Agregar hora',
                      style: TextStyle(
                          color: AppColors.primary, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _horas.map((h) => GestureDetector(
                    onLongPress: () =>
                        setState(() => _horas.remove(h)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.okBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary, width: 0.5),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.access_time,
                            color: AppColors.primary, size: 13),
                        const SizedBox(width: 5),
                        Text(h,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 5),
                        const Icon(Icons.close,
                            color: AppColors.primary, size: 11),
                      ]),
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 4),
            const Text('Mantén presionada una hora para eliminarla',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            const SizedBox(height: 14),
            // Tipo de tratamiento
            GestureDetector(
              onTap: () =>
                  setState(() => _esPermanente = !_esPermanente),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(children: [
                  Icon(
                    _esPermanente
                        ? Icons.repeat_rounded
                        : Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _esPermanente
                                ? 'Tratamiento permanente'
                                : 'Tratamiento temporal',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14),
                          ),
                          Text(
                            _esPermanente
                                ? 'Para condiciones crónicas (diabetes, hipertensión...)'
                                : 'Para una molestia o enfermedad temporal',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11),
                          ),
                        ]),
                  ),
                  Icon(
                    _esPermanente
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    color: _esPermanente
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 30,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notasCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Ej: tomar con comida, no con leche...',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
                onPressed: _guardar,
                child: Text(
                  widget.existente == null
                      ? 'Guardar medicamento'
                      : 'Guardar cambios',
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}
