import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../models/models.dart';

class CalendarioMedicamentoScreen extends StatefulWidget {
  final Medicamento medicamento;
  const CalendarioMedicamentoScreen({super.key, required this.medicamento});

  @override
  State<CalendarioMedicamentoScreen> createState() =>
      _CalendarioMedicamentoScreenState();
}

class _CalendarioMedicamentoScreenState
    extends State<CalendarioMedicamentoScreen> {
  DateTime _mesActual = DateTime(DateTime.now().year, DateTime.now().month);
  List<RegistroToma> _tomasMes = [];
  Map<String, dynamic> _stats = {};
  String? _diaSeleccionado;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final tomas = await FirebaseService.tomasDelMes(
        widget.medicamento.id, _mesActual.year, _mesActual.month);
    final stats = await FirebaseService.estadisticasMes(
        widget.medicamento.id,
        widget.medicamento,
        _mesActual.year,
        _mesActual.month);
    setState(() {
      _tomasMes = tomas;
      _stats = stats;
      _cargando = false;
    });
  }

  // Calcula el estado de un día: 'completo' | 'parcial' | 'omitido' | 'futuro'
  String _estadoDia(int dia) {
    final fecha =
        '${_mesActual.year}-${_mesActual.month.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';
    final fechaDt = DateTime(_mesActual.year, _mesActual.month, dia);
    final hoy = DateTime.now();
    if (fechaDt.isAfter(DateTime(hoy.year, hoy.month, hoy.day))) {
      return 'futuro';
    }
    final tomasDia = _tomasMes.where((t) => t.fecha == fecha).toList();
    final total = widget.medicamento.horasToma.length;
    final tomadas = tomasDia.where((t) => t.tomada).length;
    if (tomadas == total) return 'completo';
    if (tomadas > 0) return 'parcial';
    return 'omitido';
  }

  List<RegistroToma> _tomasDelDia(int dia) {
    final fecha =
        '${_mesActual.year}-${_mesActual.month.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';
    return _tomasMes.where((t) => t.fecha == fecha).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimiento · ${widget.medicamento.nombre}'),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoMed(),
                  const SizedBox(height: 16),
                  _buildNavMes(),
                  const SizedBox(height: 12),
                  _buildCalendario(),
                  const SizedBox(height: 12),
                  _buildLeyenda(),
                  const SizedBox(height: 16),
                  _buildEstadisticas(),
                  if (_diaSeleccionado != null) ...[
                    const SizedBox(height: 16),
                    _buildDetalleDia(),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoMed() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.medicamento.nombre,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            Text(
              '${widget.medicamento.dosis} · ${widget.medicamento.horasToma.join(', ')}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              widget.medicamento.esPermanente
                  ? 'Tratamiento permanente'
                  : 'Tratamiento temporal',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildNavMes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _mesActual = DateTime(_mesActual.year, _mesActual.month - 1);
              _diaSeleccionado = null;
            });
            _cargar();
          },
          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
        ),
        Text(
          DateFormat('MMMM yyyy', 'es').format(_mesActual),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        IconButton(
          onPressed: _mesActual.year == DateTime.now().year &&
                  _mesActual.month == DateTime.now().month
              ? null
              : () {
                  setState(() {
                    _mesActual =
                        DateTime(_mesActual.year, _mesActual.month + 1);
                    _diaSeleccionado = null;
                  });
                  _cargar();
                },
          icon: Icon(Icons.chevron_right,
              color: _mesActual.year == DateTime.now().year &&
                      _mesActual.month == DateTime.now().month
                  ? AppColors.surfaceAlt
                  : AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCalendario() {
    final diasEnMes =
        DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    // 0=lunes en nuestra convención; weekday: 1=lun ... 7=dom
    final offsetInicio = (primerDia.weekday - 1) % 7;
    final hoy = DateTime.now();
    final esHoy = (d) =>
        _mesActual.year == hoy.year &&
        _mesActual.month == hoy.month &&
        d == hoy.day;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        // Encabezados de días
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
        // Grid de días
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
            final estado = _estadoDia(dia);
            final fecha =
                '${_mesActual.year}-${_mesActual.month.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';
            final seleccionado = _diaSeleccionado == fecha;

            Color bg;
            Color textColor;
            switch (estado) {
              case 'completo':
                bg = AppColors.ok;
                textColor = Colors.white;
                break;
              case 'parcial':
                bg = AppColors.warn;
                textColor = Colors.white;
                break;
              case 'omitido':
                bg = AppColors.dangerBg;
                textColor = AppColors.danger;
                break;
              default:
                bg = AppColors.surfaceAlt;
                textColor = AppColors.textSecondary;
            }

            return GestureDetector(
              onTap: estado != 'futuro'
                  ? () => setState(() =>
                      _diaSeleccionado = seleccionado ? null : fecha)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: seleccionado
                        ? Colors.white
                        : esHoy(dia)
                            ? AppColors.primary
                            : Colors.transparent,
                    width: seleccionado || esHoy(dia) ? 2 : 0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$dia',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: esHoy(dia)
                            ? FontWeight.w700
                            : FontWeight.normal),
                  ),
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
        _leyItem(AppColors.ok, 'Completo'),
        const SizedBox(width: 14),
        _leyItem(AppColors.warn, 'Parcial'),
        const SizedBox(width: 14),
        _leyItem(AppColors.dangerBg, 'Omitido', border: AppColors.danger),
        const SizedBox(width: 14),
        _leyItem(AppColors.surfaceAlt, 'Futuro'),
      ],
    );
  }

  Widget _leyItem(Color color, String label, {Color? border}) {
    return Row(children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: border != null ? Border.all(color: border, width: 0.5) : null,
        ),
      ),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11)),
    ]);
  }

  Widget _buildEstadisticas() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas del mes',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6)),
          const SizedBox(height: 12),
          // Adherencia grande
          Center(
            child: Column(children: [
              Text(
                '${_stats['adherencia'] ?? 0}%',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 42,
                    fontWeight: FontWeight.w700),
              ),
              const Text('adherencia',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ((_stats['adherencia'] ?? 0) as int) / 100,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _statItem(Icons.check_circle_rounded, AppColors.ok,
                '${_stats['diasCompletos'] ?? 0}', 'días completos'),
            _statItem(Icons.remove_circle_rounded, AppColors.warn,
                '${_stats['diasParciales'] ?? 0}', 'días parciales'),
            _statItem(Icons.cancel_rounded, AppColors.danger,
                '${_stats['diasOmitidos'] ?? 0}', 'días omitidos'),
          ]),
          const Divider(color: AppColors.border, height: 24),
          Row(children: [
            _statItem(Icons.local_fire_department_rounded, AppColors.warn,
                '${_stats['rachaActual'] ?? 0}', 'racha actual'),
            _statItem(Icons.emoji_events_rounded, AppColors.primary,
                '${_stats['mejorRacha'] ?? 0}', 'mejor racha'),
          ]),
        ],
      ),
    );
  }

  Widget _statItem(IconData ico, Color color, String val, String label) {
    return Expanded(
      child: Column(children: [
        Icon(ico, color: color, size: 20),
        const SizedBox(height: 4),
        Text(val,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _buildDetalleDia() {
    if (_diaSeleccionado == null) return const SizedBox();
    final partes = _diaSeleccionado!.split('-');
    final dia = int.parse(partes[2]);
    final tomasDia = _tomasDelDia(dia);
    final fechaFmt = DateFormat("EEEE d 'de' MMMM", 'es')
        .format(DateTime.parse(_diaSeleccionado!));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              fechaFmt[0].toUpperCase() + fechaFmt.substring(1),
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ]),
          const SizedBox(height: 12),
          ...widget.medicamento.horasToma.map((hora) {
            final toma = tomasDia
                .where(
                    (t) => t.horaProgramada == hora)
                .firstOrNull;
            final tomada = toma?.tomada == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tomada ? AppColors.okBg : AppColors.dangerBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: tomada
                        ? AppColors.ok.withOpacity(0.3)
                        : AppColors.danger.withOpacity(0.3),
                    width: 0.5),
              ),
              child: Row(children: [
                Icon(
                  tomada
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: tomada ? AppColors.ok : AppColors.danger,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.medicamento.nombre} ${widget.medicamento.dosis}',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Programada: $hora',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11),
                        ),
                      ]),
                ),
                if (tomada && toma?.horaReal != null)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Tomada',
                            style: TextStyle(
                                color: AppColors.ok, fontSize: 11)),
                        Text(
                          DateFormat('HH:mm').format(toma!.horaReal!),
                          style: const TextStyle(
                              color: AppColors.ok,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ])
                else if (!tomada)
                  const Text('No registrada',
                      style: TextStyle(
                          color: AppColors.danger, fontSize: 11)),
              ]),
            );
          }),
        ],
      ),
    );
  }
}
