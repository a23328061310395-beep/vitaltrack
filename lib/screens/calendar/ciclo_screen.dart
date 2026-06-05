import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class CicloScreen extends StatefulWidget {
  const CicloScreen({super.key});

  @override
  State<CicloScreen> createState() => _CicloScreenState();
}

class _CicloScreenState extends State<CicloScreen> {
  List<RegistroCiclo> _ciclos = [];
  DateTime _mesActual = DateTime(DateTime.now().year, DateTime.now().month);
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final c = await FirebaseService.cargarCiclos();
    setState(() {
      _ciclos = c;
      _cargando = false;
    });
  }

  // Calcula el promedio del ciclo
  int get _promedioCiclo {
    if (_ciclos.length < 2) return 28;
    int total = 0;
    for (int i = 0; i < _ciclos.length - 1; i++) {
      total += _ciclos[i]
          .fechaInicio
          .difference(_ciclos[i + 1].fechaInicio)
          .inDays
          .abs();
    }
    return (total / (_ciclos.length - 1)).round();
  }

  DateTime? get _proximoPeriodo {
    if (_ciclos.isEmpty) return null;
    return _ciclos.first.fechaInicio.add(Duration(days: _promedioCiclo));
  }

  // Días fértiles: 10-16 días después del inicio (aproximado)
  List<DateTime> get _diasFertiles {
    if (_ciclos.isEmpty) return [];
    final inicio = _ciclos.first.fechaInicio;
    return List.generate(
        6, (i) => inicio.add(Duration(days: 10 + i)));
  }

  String _tipoDia(DateTime fecha) {
    for (final c in _ciclos) {
      for (int d = 0; d < c.duracionDias; d++) {
        final dia = c.fechaInicio.add(Duration(days: d));
        if (dia.year == fecha.year &&
            dia.month == fecha.month &&
            dia.day == fecha.day) {
          return 'periodo';
        }
      }
    }
    for (final f in _diasFertiles) {
      if (f.year == fecha.year &&
          f.month == fecha.month &&
          f.day == fecha.day) {
        return 'fertil';
      }
    }
    return 'normal';
  }

  void _mostrarFormulario() {
    int _duracion = 5;
    DateTime? _fechaSeleccionada;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registrar inicio de período',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 60)),
                    lastDate: DateTime.now(),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.dark(
                            primary: AppColors.pink,
                            surface: AppColors.surface),
                      ),
                      child: child!,
                    ),
                  );
                  if (d != null) setS(() => _fechaSeleccionada = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.pink, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _fechaSeleccionada == null
                          ? 'Selecciona la fecha de inicio'
                          : DateFormat('d MMMM yyyy', 'es')
                              .format(_fechaSeleccionada!),
                      style: TextStyle(
                          color: _fechaSeleccionada == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 14),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Text('Duración estimada: $_duracion días',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              Slider(
                value: _duracion.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                activeColor: AppColors.pink,
                inactiveColor: AppColors.surfaceAlt,
                onChanged: (v) => setS(() => _duracion = v.round()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink),
                onPressed: _fechaSeleccionada == null
                    ? null
                    : () async {
                        await FirebaseService.agregarCiclo(RegistroCiclo(
                          fechaInicio: _fechaSeleccionada!,
                          duracionDias: _duracion,
                        ));
                        await _cargar();
                        if (mounted) Navigator.pop(ctx);
                      },
                child: const Text('Guardar período'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ciclo menstrual')),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumen(),
                  const SizedBox(height: 16),
                  _buildNavMes(),
                  const SizedBox(height: 10),
                  _buildCalendario(),
                  const SizedBox(height: 10),
                  _buildLeyenda(),
                  const SizedBox(height: 16),
                  _buildHistorial(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormulario,
        backgroundColor: AppColors.pink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Registrar período',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: _resumenItem(
              'Ciclo promedio',
              '$_promedioCiclo días',
              Icons.loop_rounded,
              AppColors.pink,
            ),
          ),
          Container(
              width: 0.5, height: 50, color: AppColors.border),
          Expanded(
            child: _resumenItem(
              'Próximo período',
              _proximoPeriodo != null
                  ? DateFormat('d MMM', 'es').format(_proximoPeriodo!)
                  : 'Sin datos',
              Icons.event_rounded,
              AppColors.pink,
            ),
          ),
        ]),
        if (_diasFertiles.isNotEmpty) ...[
          const Divider(color: AppColors.border, height: 20),
          _resumenItem(
            'Días fértiles estimados',
            '${DateFormat('d MMM', 'es').format(_diasFertiles.first)} – ${DateFormat('d MMM', 'es').format(_diasFertiles.last)}',
            Icons.favorite_rounded,
            AppColors.blue,
          ),
        ],
      ]),
    );
  }

  Widget _resumenItem(
      String label, String valor, IconData ico, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(children: [
        Icon(ico, color: color, size: 20),
        const SizedBox(height: 4),
        Text(valor,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _buildNavMes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => setState(() =>
              _mesActual = DateTime(_mesActual.year, _mesActual.month - 1)),
          icon: const Icon(Icons.chevron_left,
              color: AppColors.textSecondary),
        ),
        Text(
          DateFormat('MMMM yyyy', 'es').format(_mesActual),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        IconButton(
          onPressed: () => setState(() =>
              _mesActual = DateTime(_mesActual.year, _mesActual.month + 1)),
          icon: const Icon(Icons.chevron_right,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCalendario() {
    final diasEnMes =
        DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final offsetInicio = (primerDia.weekday - 1) % 7;
    final hoy = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        Row(
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: offsetInicio + diasEnMes,
          itemBuilder: (_, i) {
            if (i < offsetInicio) return const SizedBox();
            final dia = i - offsetInicio + 1;
            final fecha =
                DateTime(_mesActual.year, _mesActual.month, dia);
            final tipo = _tipoDia(fecha);
            final esHoy = fecha.year == hoy.year &&
                fecha.month == hoy.month &&
                fecha.day == hoy.day;

            Color bg;
            Color textColor;
            switch (tipo) {
              case 'periodo':
                bg = const Color(0xFF3D1A2E);
                textColor = AppColors.pink;
                break;
              case 'fertil':
                bg = const Color(0xFF0E2235);
                textColor = AppColors.blue;
                break;
              default:
                bg = esHoy ? AppColors.pink : Colors.transparent;
                textColor = esHoy
                    ? Colors.white
                    : AppColors.textSecondary;
            }

            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(7),
                border: esHoy && tipo != 'periodo'
                    ? Border.all(color: AppColors.pink, width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$dia',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: esHoy
                          ? FontWeight.w700
                          : FontWeight.normal),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildLeyenda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _leyItem(const Color(0xFF3D1A2E), AppColors.pink, 'Período'),
        const SizedBox(width: 16),
        _leyItem(const Color(0xFF0E2235), AppColors.blue, 'Días fértiles'),
        const SizedBox(width: 16),
        _leyItem(AppColors.pink, Colors.white, 'Hoy'),
      ],
    );
  }

  Widget _leyItem(Color bg, Color text, String label) {
    return Row(children: [
      Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11)),
    ]);
  }

  Widget _buildHistorial() {
    if (_ciclos.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeccionTitulo('historial de ciclos'),
        const SizedBox(height: 10),
        ..._ciclos.take(6).map((c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.circle,
                        color: AppColors.pink, size: 10),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat("d 'de' MMMM yyyy", 'es')
                          .format(c.fechaInicio),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                    ),
                  ]),
                  Text('${c.duracionDias} días',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13)),
                ],
              ),
            )),
      ],
    );
  }
}
