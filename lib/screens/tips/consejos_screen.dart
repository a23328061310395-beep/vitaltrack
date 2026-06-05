import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/firebase_service.dart';
import '../../models/models.dart';

class ConsejosScreen extends StatefulWidget {
  const ConsejosScreen({super.key});

  @override
  State<ConsejosScreen> createState() => _ConsejosScreenState();
}

class _ConsejosScreenState extends State<ConsejosScreen> {
  List<_Consejo> _consejos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _generar();
  }

  Future<void> _generar() async {
    final presiones = await FirebaseService.cargarPresiones();
    final glucosas = await FirebaseService.cargarGlucosas();
    final pulsos = await FirebaseService.cargarPulsos();
    final perfil = await FirebaseService.cargarPerfil();
    final vasos = await FirebaseService.vasosHoy();

    final lista = <_Consejo>[];

    // ── Consejos por presión ──
    if (presiones.isNotEmpty) {
      final ultima = presiones.first;
      if (ultima.estado == 'Normal') {
        lista.add(_Consejo(
          icono: Icons.favorite_rounded,
          color: AppColors.ok,
          titulo: '¡Tu presión está perfecta!',
          descripcion:
              'Tu presión arterial de ${ultima.sistolica}/${ultima.diastolica} mmHg está en rango normal. Mantén hábitos saludables como una dieta baja en sal y ejercicio regular.',
          categoria: 'Presión arterial',
          urgencia: 0,
        ));
      } else if (ultima.estado == 'Elevada' || ultima.estado == 'Alta I') {
        lista.add(_Consejo(
          icono: Icons.warning_amber_rounded,
          color: AppColors.warn,
          titulo: 'Tu presión está elevada',
          descripcion:
              'Tu última lectura fue ${ultima.sistolica}/${ultima.diastolica} mmHg. Intenta descansar, evita la cafeína y el estrés. Si persiste más de 2 días, consulta a tu médico.',
          categoria: 'Presión arterial',
          urgencia: 1,
        ));
      } else {
        lista.add(_Consejo(
          icono: Icons.emergency_rounded,
          color: AppColors.danger,
          titulo: '⚠️ Presión arterial muy alta',
          descripcion:
              'Tu presión de ${ultima.sistolica}/${ultima.diastolica} mmHg es preocupante. Siéntate, respira lento y busca atención médica hoy mismo. Si tienes dolor de cabeza intenso o visión borrosa, ve a urgencias.',
          categoria: 'Presión arterial',
          urgencia: 2,
        ));
      }
    } else {
      lista.add(_Consejo(
        icono: Icons.favorite_border_rounded,
        color: AppColors.blue,
        titulo: 'Registra tu presión hoy',
        descripcion:
            'Llevar un control diario de tu presión arterial te ayuda a detectar problemas a tiempo. El mejor momento es por la mañana, antes de comer.',
        categoria: 'Presión arterial',
        urgencia: 1,
      ));
    }

    // ── Consejos por glucosa ──
    if (glucosas.isNotEmpty) {
      final ultima = glucosas.first;
      if (ultima.estado == 'Normal') {
        lista.add(_Consejo(
          icono: Icons.water_drop_rounded,
          color: AppColors.ok,
          titulo: '¡Tu glucosa está bien!',
          descripcion:
              'Tu nivel de glucosa de ${ultima.valor.toStringAsFixed(0)} mg/dL es normal. Recuerda mantener una dieta equilibrada y evitar el exceso de azúcar.',
          categoria: 'Glucosa',
          urgencia: 0,
        ));
      } else if (ultima.estado == 'Prediabetes') {
        lista.add(_Consejo(
          icono: Icons.warning_amber_rounded,
          color: AppColors.warn,
          titulo: 'Glucosa en zona de prediabetes',
          descripcion:
              'Tu glucosa de ${ultima.valor.toStringAsFixed(0)} mg/dL indica prediabetes. Reduce el consumo de azúcar y harinas blancas, aumenta el ejercicio. Consulta a tu médico para un plan personalizado.',
          categoria: 'Glucosa',
          urgencia: 1,
        ));
      } else {
        lista.add(_Consejo(
          icono: Icons.emergency_rounded,
          color: AppColors.danger,
          titulo: '⚠️ Glucosa muy alta — consulta a tu médico',
          descripcion:
              'Tu glucosa de ${ultima.valor.toStringAsFixed(0)} mg/dL está fuera de rango. Evita carbohidratos y azúcares, toma agua abundante y busca atención médica hoy. Si tienes mareo, confusión o mucha sed, ve a urgencias.',
          categoria: 'Glucosa',
          urgencia: 2,
        ));
      }
    }

    // ── Consejos por pulso ──
    if (pulsos.isNotEmpty) {
      final ultimo = pulsos.first;
      if (ultimo.estado == 'Alto') {
        lista.add(_Consejo(
          icono: Icons.monitor_heart_outlined,
          color: AppColors.warn,
          titulo: 'Frecuencia cardíaca elevada',
          descripcion:
              'Tu pulso de ${ultimo.bpm} bpm está por encima de lo normal. Puede ser por estrés, cafeína o ejercicio reciente. Descansa y vuelve a medir en 30 minutos. Si persiste, consulta a tu médico.',
          categoria: 'Frecuencia cardíaca',
          urgencia: 1,
        ));
      }
    }

    // ── Consejo por hidratación ──
    if (vasos < 4) {
      lista.add(_Consejo(
        icono: Icons.local_drink_outlined,
        color: AppColors.blue,
        titulo: 'Necesitas tomar más agua',
        descripcion:
            'Solo llevas $vasos vasos hoy. El agua ayuda a controlar la presión y la glucosa. Trata de tomar un vaso cada hora. La meta son 8 vasos al día.',
        categoria: 'Hidratación',
        urgencia: 1,
      ));
    }

    // ── Consejo por IMC ──
    if (perfil != null) {
      if (perfil.categoriaIMC == 'Sobrepeso' ||
          perfil.categoriaIMC == 'Obesidad') {
        lista.add(_Consejo(
          icono: Icons.scale_outlined,
          color: AppColors.warn,
          titulo: 'Cuida tu peso para mejorar tu salud',
          descripcion:
              'Tu IMC de ${perfil.imc.toStringAsFixed(1)} indica ${perfil.categoriaIMC.toLowerCase()}. Reducir peso mejora la presión arterial, la glucosa y la salud del corazón. Una caminata de 30 minutos al día es un buen comienzo.',
          categoria: 'Peso',
          urgencia: 1,
        ));
      }

      // ── Consejos por condición ──
      if (perfil.condiciones
          .any((c) => c == CondicionSalud.diabetes1 || c == CondicionSalud.diabetes2)) {
        lista.add(_Consejo(
          icono: Icons.tips_and_updates_outlined,
          color: AppColors.primary,
          titulo: 'Consejo para personas con diabetes',
          descripcion:
              'Mide tu glucosa en ayunas cada mañana. Evita saltarte comidas. Come porciones pequeñas varias veces al día. El ejercicio moderado después de comer ayuda a bajar el azúcar.',
          categoria: 'Diabetes',
          urgencia: 0,
        ));
      }
      if (perfil.condiciones.contains(CondicionSalud.hipertension)) {
        lista.add(_Consejo(
          icono: Icons.tips_and_updates_outlined,
          color: AppColors.primary,
          titulo: 'Consejo para personas con hipertensión',
          descripcion:
              'Reduce el consumo de sal a menos de 5g al día. Evita el alcohol y el tabaco. El estrés sube la presión — practica respiración profunda o meditación.',
          categoria: 'Hipertensión',
          urgencia: 0,
        ));
      }
    }

    // ── Consejos generales ──
    lista.add(const _Consejo(
      icono: Icons.nightlight_round,
      color: AppColors.blue,
      titulo: 'El sueño también importa',
      descripcion:
          'Dormir 7-8 horas por noche ayuda a regular la presión, el azúcar y el peso. Intenta acostarte a la misma hora todos los días y evita pantallas antes de dormir.',
      categoria: 'Bienestar general',
      urgencia: 0,
    ));

    lista.add(const _Consejo(
      icono: Icons.directions_walk_rounded,
      color: AppColors.primary,
      titulo: 'Muévete aunque sea 30 minutos',
      descripcion:
          'Caminar, nadar o hacer bicicleta 30 minutos al día reduce el riesgo de diabetes, hipertensión y enfermedades del corazón. No necesitas un gimnasio.',
      categoria: 'Actividad física',
      urgencia: 0,
    ));

    // Ordenar por urgencia (urgentes primero)
    lista.sort((a, b) => b.urgencia.compareTo(a.urgencia));

    setState(() {
      _consejos = lista;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consejos de salud'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _cargando = true);
              _generar();
            },
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _consejos.length,
              itemBuilder: (_, i) => _tarjetaConsejo(_consejos[i]),
            ),
    );
  }

  Widget _tarjetaConsejo(_Consejo c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: c.urgencia == 2
              ? AppColors.danger.withOpacity(0.4)
              : c.urgencia == 1
                  ? AppColors.warn.withOpacity(0.3)
                  : AppColors.border,
          width: c.urgencia > 0 ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(c.icono, color: c.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.titulo,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(c.categoria,
                          style: TextStyle(
                              color: c.color, fontSize: 10)),
                    ),
                  ]),
            ),
          ]),
          const SizedBox(height: 10),
          Text(c.descripcion,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5)),
        ],
      ),
    );
  }
}

class _Consejo {
  final IconData icono;
  final Color color;
  final String titulo;
  final String descripcion;
  final String categoria;
  final int urgencia; // 0=info, 1=advertencia, 2=urgente

  const _Consejo({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.urgencia,
  });
}
