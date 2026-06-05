import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../health/presion_screen.dart';
import '../health/health_screens.dart';



import '../medications/medicamentos_screen.dart';
import '../calendar/ciclo_screen.dart';
import '../tips/consejos_screen.dart';

import 'perfil_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  Usuario? _usuario;
  RegistroPresion? _ultimaPresion;
  RegistroGlucosa? _ultimaGlucosa;
  RegistroPulso? _ultimoPulso;
  int _vasosHoy = 0;
  List<Medicamento> _medicamentos = [];
  List<Map<String, dynamic>> _tomasPendientes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final u = await FirebaseService.cargarPerfil();
    final presiones = await FirebaseService.cargarPresiones();
    final glucosas = await FirebaseService.cargarGlucosas();
    final pulsos = await FirebaseService.cargarPulsos();
    final hid = await FirebaseService.vasosHoy();
    final meds = await FirebaseService.cargarMedicamentos();
    final pendientes = await FirebaseService.tomasPendientesHoy(meds);
    setState(() {
      _usuario = u;
      _ultimaPresion = presiones.isNotEmpty ? presiones.first : null;
      _ultimaGlucosa = glucosas.isNotEmpty ? glucosas.first : null;
      _ultimoPulso = pulsos.isNotEmpty ? pulsos.first : null;
      _vasosHoy = hid;
      _medicamentos = meds;
      _tomasPendientes = pendientes;
    });
  }

  List<Widget> get _pages => [
        _buildHome(),
        const HistorialScreen(),
        const MedicamentosScreen(),
        const ConsejosScreen(),
        const PerfilScreen(),
      ];

  List<Widget> get _pagesConCiclo => [
        _buildHome(),
        const CicloScreen(),
        const HistorialScreen(),
        const MedicamentosScreen(),
        const ConsejosScreen(),
        const PerfilScreen(),
      ];

  bool get _esMujer => _usuario?.genero == 'mujer';

  @override
  Widget build(BuildContext context) {
    final pages = _esMujer ? _pagesConCiclo : _pages;
    return Scaffold(
      body: pages[_navIndex],
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    final items = _esMujer
        ? [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Inicio'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), label: 'Ciclo'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'Historial'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.medication_outlined), label: 'Medicamentos'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline), label: 'Consejos'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Perfil'),
          ]
        : [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Inicio'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'Historial'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.medication_outlined), label: 'Medicamentos'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline), label: 'Consejos'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Perfil'),
          ];

    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      items: items,
    );
  }

  Widget _buildHome() {
    if (_usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildAlertas(),
                  const SizedBox(height: 20),
                  _buildAccesosRapidos(),
                  const SizedBox(height: 20),
                  _buildMetricas(),
                  const SizedBox(height: 20),
                  _buildHidratacion(),
                  const SizedBox(height: 20),
                  _buildTomasPendientes(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hora = DateTime.now().hour;
    String saludo = hora < 12
        ? 'Buenos días'
        : hora < 19
            ? 'Buenas tardes'
            : 'Buenas noches';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$saludo,',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Text(_usuario!.nombre.split(' ').first,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600)),
          Text(
            DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now()),
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
        ]),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.blue]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(
              _usuario!.nombre[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertas() {
    final alertas = <Widget>[];

    // Alertas por condición — módulos prioritarios no registrados hoy
    final tieneGlucosa = _usuario!.condiciones.any((c) =>
        c == CondicionSalud.diabetes1 || c == CondicionSalud.diabetes2);
    final tieneHipertension =
        _usuario!.condiciones.contains(CondicionSalud.hipertension);

    if (tieneGlucosa && _ultimaGlucosa == null) {
      alertas.add(AlertaPrioritaria(
        mensaje: '¡Importante! Registra tu glucosa de hoy',
        icono: Icons.warning_amber_rounded,
        color: AppColors.warn,
        colorBg: AppColors.warnBg,
      ));
    }
    if (tieneHipertension && _ultimaPresion == null) {
      alertas.add(AlertaPrioritaria(
        mensaje: '¡Importante! Registra tu presión arterial de hoy',
        icono: Icons.warning_amber_rounded,
        color: AppColors.warn,
        colorBg: AppColors.warnBg,
      ));
    }

    // Alerta por valor fuera de rango
    if (_ultimaPresion != null && _ultimaPresion!.estado != 'Normal') {
      alertas.add(AlertaPrioritaria(
        mensaje:
            'Tu presión está ${_ultimaPresion!.estado.toLowerCase()}. Descansa y evita el estrés.',
        icono: Icons.favorite_border_rounded,
        color: AppColors.danger,
        colorBg: AppColors.dangerBg,
      ));
    }
    if (_ultimaGlucosa != null && _ultimaGlucosa!.estado != 'Normal') {
      alertas.add(AlertaPrioritaria(
        mensaje:
            'Tu glucosa está ${_ultimaGlucosa!.estado.toLowerCase()}. Consulta a tu médico si persiste.',
        icono: Icons.water_drop_outlined,
        color: AppColors.danger,
        colorBg: AppColors.dangerBg,
      ));
    }

    // Tomas pendientes
    final numPendientes = _tomasPendientes.length;
    if (numPendientes > 0) {
      alertas.add(AlertaPrioritaria(
        mensaje:
            'Tienes $numPendientes toma${numPendientes > 1 ? 's' : ''} de medicamento pendiente${numPendientes > 1 ? 's' : ''}',
        icono: Icons.medication_outlined,
        color: AppColors.warn,
        colorBg: AppColors.warnBg,
      ));
    }

    if (alertas.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alertas
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: a,
              ))
          .toList(),
    );
  }

  Widget _buildAccesosRapidos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeccionTitulo('registrar hoy'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _accesoBtn(Icons.favorite_rounded, 'Presión', AppColors.danger,
                  () => _irA(const PresionScreen())),
              _accesoBtn(Icons.water_drop_rounded, 'Glucosa', AppColors.blue,
                  () => _irA(const GlucosaScreen())),
              _accesoBtn(Icons.monitor_heart_outlined, 'Pulso', AppColors.pink,
                  () => _irA(const PulsoScreen())),
              _accesoBtn(Icons.scale_outlined, 'IMC', AppColors.warn,
                  () => _irA(const ImcScreen())),
              _accesoBtn(Icons.local_drink_outlined, 'Agua', AppColors.blue,
                  () => _irA(const HidratacionScreen())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accesoBtn(
      IconData icono, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _buildMetricas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeccionTitulo('resumen del día'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            MetricaCard(
              titulo: 'Presión',
              valor: _ultimaPresion != null
                  ? '${_ultimaPresion!.sistolica}/${_ultimaPresion!.diastolica}'
                  : '--',
              unidad: 'mmHg',
              estado: _ultimaPresion?.estado ?? 'Sin registro',
              icono: Icons.favorite_outline_rounded,
              onTap: () => _irA(const PresionScreen()),
            ),
            MetricaCard(
              titulo: 'Glucosa',
              valor: _ultimaGlucosa != null
                  ? _ultimaGlucosa!.valor.toStringAsFixed(0)
                  : '--',
              unidad: 'mg/dL',
              estado: _ultimaGlucosa?.estado ?? 'Sin registro',
              icono: Icons.water_drop_outlined,
              onTap: () => _irA(const GlucosaScreen()),
            ),
            MetricaCard(
              titulo: 'Pulso',
              valor: _ultimoPulso != null
                  ? '${_ultimoPulso!.bpm}'
                  : '--',
              unidad: 'bpm',
              estado: _ultimoPulso?.estado ?? 'Sin registro',
              icono: Icons.monitor_heart_outlined,
              onTap: () => _irA(const PulsoScreen()),
            ),
            MetricaCard(
              titulo: 'IMC',
              valor: _usuario!.imc.toStringAsFixed(1),
              unidad: '',
              estado: _usuario!.categoriaIMC,
              icono: Icons.scale_outlined,
              onTap: () => _irA(const ImcScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHidratacion() {
    final vasos = _vasosHoy;
    final pct = (vasos / 8).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () => _irA(const HidratacionScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.local_drink_outlined,
                    color: AppColors.blue, size: 16),
                SizedBox(width: 6),
                Text('Hidratación',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ]),
              Text('$vasos / 8 vasos',
                  style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.surfaceAlt,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.blue),
              minHeight: 6,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTomasPendientes() {
    final pendientes = _tomasPendientes;
    if (pendientes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeccionTitulo('tomas pendientes'),
        const SizedBox(height: 10),
        ...pendientes.map((p) {
          final med = p['med'] as Medicamento;
          final hora = p['hora'] as String;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warnBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.warn.withOpacity(0.3), width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.medication_outlined,
                    color: AppColors.warn, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${med.nombre} ${med.dosis}',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text('Programada a las $hora',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
                    await FirebaseService.marcarToma(med.id, hora, hoy);
                    await _cargarDatos();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Tomé', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _irA(Widget pantalla) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    ).then((_) => _cargarDatos());
  }
}
