import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'auth_service.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // Referencia raíz del usuario actual
  static DocumentReference get _userDoc =>
      _db.collection('usuarios').doc(AuthService.uid);

  // ══════════════════════════════════════════
  // PERFIL DE USUARIO
  // ══════════════════════════════════════════

  static Future<void> guardarPerfil(Usuario u) async {
    await _userDoc.set(u.toMap(), SetOptions(merge: true));
  }

  static Future<Usuario?> cargarPerfil() async {
    final doc = await _userDoc.get();
    if (!doc.exists) return null;
    return Usuario.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ══════════════════════════════════════════
  // PRESIÓN ARTERIAL
  // ══════════════════════════════════════════

  static CollectionReference get _presiones =>
      _userDoc.collection('presiones');

  static Future<void> agregarPresion(RegistroPresion r) async {
    await _presiones.add(r.toMap());
  }

  static Future<List<RegistroPresion>> cargarPresiones() async {
    final snap = await _presiones
        .orderBy('fechaHora', descending: true)
        .limit(50)
        .get();
    return snap.docs
        .map((d) => RegistroPresion.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  // ══════════════════════════════════════════
  // GLUCOSA
  // ══════════════════════════════════════════

  static CollectionReference get _glucosas =>
      _userDoc.collection('glucosas');

  static Future<void> agregarGlucosa(RegistroGlucosa r) async {
    await _glucosas.add(r.toMap());
  }

  static Future<List<RegistroGlucosa>> cargarGlucosas() async {
    final snap = await _glucosas
        .orderBy('fechaHora', descending: true)
        .limit(50)
        .get();
    return snap.docs
        .map((d) => RegistroGlucosa.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  // ══════════════════════════════════════════
  // PULSO
  // ══════════════════════════════════════════

  static CollectionReference get _pulsos => _userDoc.collection('pulsos');

  static Future<void> agregarPulso(RegistroPulso r) async {
    await _pulsos.add(r.toMap());
  }

  static Future<List<RegistroPulso>> cargarPulsos() async {
    final snap = await _pulsos
        .orderBy('fechaHora', descending: true)
        .limit(50)
        .get();
    return snap.docs
        .map((d) => RegistroPulso.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  // ══════════════════════════════════════════
  // HIDRATACIÓN
  // ══════════════════════════════════════════

  static CollectionReference get _hidratacion =>
      _userDoc.collection('hidratacion');

  static String _fechaStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<int> vasosHoy() async {
    final hoy = _fechaStr(DateTime.now());
    final snap =
        await _hidratacion.where('fecha', isEqualTo: hoy).limit(1).get();
    if (snap.docs.isEmpty) return 0;
    return (snap.docs.first.data() as Map<String, dynamic>)['vasos'] as int;
  }

  static Future<void> agregarVaso() async {
    final hoy = _fechaStr(DateTime.now());
    final snap =
        await _hidratacion.where('fecha', isEqualTo: hoy).limit(1).get();
    if (snap.docs.isEmpty) {
      await _hidratacion.add({'fecha': hoy, 'vasos': 1});
    } else {
      await snap.docs.first.reference
          .update({'vasos': FieldValue.increment(1)});
    }
  }

  // ══════════════════════════════════════════
  // CICLO MENSTRUAL
  // ══════════════════════════════════════════

  static CollectionReference get _ciclos => _userDoc.collection('ciclos');

  static Future<void> agregarCiclo(RegistroCiclo r) async {
    await _ciclos.add(r.toMap());
  }

  static Future<List<RegistroCiclo>> cargarCiclos() async {
    final snap = await _ciclos
        .orderBy('fechaInicio', descending: true)
        .limit(12)
        .get();
    return snap.docs
        .map((d) => RegistroCiclo.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  // ══════════════════════════════════════════
  // MEDICAMENTOS
  // ══════════════════════════════════════════

  static CollectionReference get _medicamentos =>
      _userDoc.collection('medicamentos');

  static Future<void> agregarMedicamento(Medicamento m) async {
    await _medicamentos.doc(m.id).set(m.toMap());
  }

  static Future<void> eliminarMedicamento(String id) async {
    await _medicamentos.doc(id).delete();
  }

  static Future<List<Medicamento>> cargarMedicamentos() async {
    final snap =
        await _medicamentos.orderBy('fechaInicio', descending: false).get();
    return snap.docs
        .map((d) => Medicamento.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  // ══════════════════════════════════════════
  // TOMAS (CALENDARIO DE SEGUIMIENTO)
  // ══════════════════════════════════════════

  // Subcolección dentro de cada medicamento
  static CollectionReference _tomasDe(String medId) =>
      _medicamentos.doc(medId).collection('tomas');

  /// Marca una toma como tomada (o la crea si no existe)
  static Future<void> marcarToma(
      String medId, String horaProgramada, String fecha) async {
    final col = _tomasDe(medId);
    // Busca si ya existe el documento para ese día+hora
    final snap = await col
        .where('fecha', isEqualTo: fecha)
        .where('horaProgramada', isEqualTo: horaProgramada)
        .limit(1)
        .get();

    final ahora = DateTime.now().toIso8601String();
    if (snap.docs.isEmpty) {
      await col.add({
        'medicamentoId': medId,
        'horaProgramada': horaProgramada,
        'fecha': fecha,
        'tomada': true,
        'horaReal': ahora,
      });
    } else {
      await snap.docs.first.reference.update({
        'tomada': true,
        'horaReal': ahora,
      });
    }
  }

  /// Desmarca una toma (el usuario se equivocó)
  static Future<void> desmarcarToma(
      String medId, String horaProgramada, String fecha) async {
    final col = _tomasDe(medId);
    final snap = await col
        .where('fecha', isEqualTo: fecha)
        .where('horaProgramada', isEqualTo: horaProgramada)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference
          .update({'tomada': false, 'horaReal': null});
    }
  }

  /// Tomas de un medicamento en un día específico
  static Future<List<RegistroToma>> tomasDelDia(
      String medId, String fecha) async {
    final snap = await _tomasDe(medId)
        .where('fecha', isEqualTo: fecha)
        .get();
    return snap.docs
        .map((d) => RegistroToma.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Tomas de un medicamento en un mes → para el calendario de seguimiento
  static Future<List<RegistroToma>> tomasDelMes(
      String medId, int anio, int mes) async {
    // Construye el rango de fechas del mes
    final inicio =
        '$anio-${mes.toString().padLeft(2, '0')}-01';
    final fin = mes < 12
        ? '${anio}-${(mes + 1).toString().padLeft(2, '0')}-01'
        : '${anio + 1}-01-01';

    final snap = await _tomasDe(medId)
        .where('fecha', isGreaterThanOrEqualTo: inicio)
        .where('fecha', isLessThan: fin)
        .get();
    return snap.docs
        .map((d) => RegistroToma.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Todas las tomas pendientes del día (todos los medicamentos)
  static Future<List<Map<String, dynamic>>> tomasPendientesHoy(
      List<Medicamento> medicamentos) async {
    final hoy = _fechaStr(DateTime.now());
    final horaActual =
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    final pendientes = <Map<String, dynamic>>[];

    for (final med in medicamentos) {
      for (final hora in med.horasToma) {
        if (hora.compareTo(horaActual) <= 0) {
          final tomas = await tomasDelDia(med.id, hoy);
          final tomada = tomas.any(
              (t) => t.horaProgramada == hora && t.tomada);
          if (!tomada) {
            pendientes.add({'med': med, 'hora': hora});
          }
        }
      }
    }
    return pendientes;
  }

  /// Estadísticas del mes para un medicamento
  static Future<Map<String, dynamic>> estadisticasMes(
      String medId, Medicamento med, int anio, int mes) async {
    final tomas = await tomasDelMes(medId, anio, mes);
    final diasEnMes = DateTime(anio, mes + 1, 0).day;
    int diasCompletos = 0;
    int diasParciales = 0;
    int diasOmitidos = 0;
    int rachaActual = 0;
    int mejorRacha = 0;
    int rachaTemp = 0;

    for (int d = 1; d <= diasEnMes; d++) {
      final fecha =
          '$anio-${mes.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final tomasDia = tomas.where((t) => t.fecha == fecha).toList();
      final total = med.horasToma.length;
      final tomadas = tomasDia.where((t) => t.tomada).length;

      if (tomadas == total) {
        diasCompletos++;
        rachaTemp++;
        if (rachaTemp > mejorRacha) mejorRacha = rachaTemp;
      } else if (tomadas > 0) {
        diasParciales++;
        rachaTemp = 0;
      } else if (DateTime.now()
          .isAfter(DateTime(anio, mes, d))) {
        diasOmitidos++;
        rachaTemp = 0;
      }
    }
    rachaActual = rachaTemp;

    final totalEsperadas =
        diasEnMes * med.horasToma.length;
    final totalTomadas =
        tomas.where((t) => t.tomada).length;
    final adherencia = totalEsperadas > 0
        ? (totalTomadas / totalEsperadas * 100).round()
        : 0;

    return {
      'diasCompletos': diasCompletos,
      'diasParciales': diasParciales,
      'diasOmitidos': diasOmitidos,
      'adherencia': adherencia,
      'rachaActual': rachaActual,
      'mejorRacha': mejorRacha,
    };
  }
}
