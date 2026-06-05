import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class PresionScreen extends StatefulWidget {
  const PresionScreen({super.key});

  @override
  State<PresionScreen> createState() => _PresionScreenState();
}

class _PresionScreenState extends State<PresionScreen> {
  List<RegistroPresion> _registros = [];
  final _sisCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final r = await FirebaseService.cargarPresiones();
    setState(() => _registros = r.reversed.toList());
  }

  Future<void> _guardar() async {
    final sis = int.tryParse(_sisCtrl.text);
    final dia = int.tryParse(_diaCtrl.text);
    if (sis == null || dia == null) return;
    await FirebaseService.agregarPresion(RegistroPresion(
      sistolica: sis,
      diastolica: dia,
      fechaHora: DateTime.now(),
    ));
    _sisCtrl.clear();
    _diaCtrl.clear();
    await _cargar();
    if (mounted) Navigator.pop(context);
  }

  void _mostrarFormulario() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva lectura de presión',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _sisCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration:
                      const InputDecoration(labelText: 'Sistólica (mmHg)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _diaCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration:
                      const InputDecoration(labelText: 'Diastólica (mmHg)'),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Normal: menos de 120/80\nElevada: 120–129/menos de 80\nAlta I: 130–139 / 80–89\nAlta II: 140+ / 90+',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
    final ultimo = _registros.isNotEmpty ? _registros.first : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presión arterial'),
        actions: [
          IconButton(
              onPressed: _mostrarFormulario,
              icon: const Icon(Icons.add_rounded, color: AppColors.primary)),
        ],
      ),
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
                  RichText(
                    text: TextSpan(
                      text: '${ultimo.sistolica}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: '/${ultimo.diastolica}',
                          style: const TextStyle(
                              fontSize: 32, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Text('mmHg',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 10),
                  EstadoBadge(ultimo.estado),
                ]),
              ),
              const SizedBox(height: 20),
            ],
            const SeccionTitulo('historial'),
            const SizedBox(height: 10),
            if (_registros.isEmpty)
              _sinRegistros()
            else
              ..._registros.map((r) => _buildFila(r)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFila(RegistroPresion r) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              DateFormat("d MMM yyyy 'a las' HH:mm", 'es').format(r.fechaHora),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text('${r.sistolica}/${r.diastolica} mmHg',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ]),
          EstadoBadge(r.estado),
        ],
      ),
    );
  }

  Widget _sinRegistros() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(children: [
          Icon(Icons.favorite_border_rounded,
              color: AppColors.textSecondary, size: 36),
          SizedBox(height: 10),
          Text('Sin registros aún',
              style: TextStyle(color: AppColors.textSecondary)),
          Text('Toca + para agregar tu primera lectura',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
      ),
    );
  }
}
