// ─────────────────────────────────────────────
// MODELOS DE DATOS — VitalTrack
// ─────────────────────────────────────────────

// Condiciones de salud preexistentes
enum CondicionSalud {
  diabetes1,
  diabetes2,
  hipertension,
  sobrepeso,
  otra,
}

String condicionNombre(CondicionSalud c) {
  switch (c) {
    case CondicionSalud.diabetes1:
      return 'Diabetes tipo 1';
    case CondicionSalud.diabetes2:
      return 'Diabetes tipo 2';
    case CondicionSalud.hipertension:
      return 'Hipertensión';
    case CondicionSalud.sobrepeso:
      return 'Sobrepeso / Obesidad';
    case CondicionSalud.otra:
      return 'Otra condición';
  }
}

// ─── USUARIO ───
class Usuario {
  String nombre;
  String email;
  String password;
  DateTime fechaNacimiento;
  double peso; // kg
  double altura; // cm
  String genero; // 'mujer' | 'hombre'
  List<CondicionSalud> condiciones;
  String otraCondicion;

  Usuario({
    required this.nombre,
    required this.email,
    required this.password,
    required this.fechaNacimiento,
    required this.peso,
    required this.altura,
    required this.genero,
    this.condiciones = const [],
    this.otraCondicion = '',
  });

  int get edad {
    final hoy = DateTime.now();
    int anios = hoy.year - fechaNacimiento.year;
    if (hoy.month < fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      anios--;
    }
    return anios;
  }

  double get imc => peso / ((altura / 100) * (altura / 100));

  String get categoriaIMC {
    final v = imc;
    if (v < 18.5) return 'Bajo peso';
    if (v < 25) return 'Normal';
    if (v < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'email': email,
        'password': password,
        'fechaNacimiento': fechaNacimiento.toIso8601String(),
        'peso': peso,
        'altura': altura,
        'genero': genero,
        'condiciones': condiciones.map((c) => c.index).toList(),
        'otraCondicion': otraCondicion,
      };

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        nombre: m['nombre'],
        email: m['email'],
        password: m['password'],
        fechaNacimiento: DateTime.parse(m['fechaNacimiento']),
        peso: m['peso'],
        altura: m['altura'],
        genero: m['genero'],
        condiciones: (m['condiciones'] as List)
            .map((i) => CondicionSalud.values[i])
            .toList(),
        otraCondicion: m['otraCondicion'] ?? '',
      );
}

// ─── MEDICAMENTO ───
class Medicamento {
  String id;
  String nombre;
  String dosis; // ej. "500mg"
  List<String> horasToma; // ej. ["08:00", "14:00", "21:00"]
  bool esPermanente;
  DateTime fechaInicio;
  DateTime? fechaFin;
  String notas;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.horasToma,
    this.esPermanente = true,
    required this.fechaInicio,
    this.fechaFin,
    this.notas = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'horasToma': horasToma,
        'esPermanente': esPermanente,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin?.toIso8601String(),
        'notas': notas,
      };

  factory Medicamento.fromMap(Map<String, dynamic> m) => Medicamento(
        id: m['id'],
        nombre: m['nombre'],
        dosis: m['dosis'],
        horasToma: List<String>.from(m['horasToma']),
        esPermanente: m['esPermanente'],
        fechaInicio: DateTime.parse(m['fechaInicio']),
        fechaFin: m['fechaFin'] != null ? DateTime.parse(m['fechaFin']) : null,
        notas: m['notas'] ?? '',
      );
}

// ─── REGISTRO DE TOMA ───
class RegistroToma {
  String medicamentoId;
  String horaProgramada; // "08:00"
  DateTime? horaReal; // hora en que realmente se tomó
  String fecha; // "2026-05-22"
  bool tomada;

  RegistroToma({
    required this.medicamentoId,
    required this.horaProgramada,
    this.horaReal,
    required this.fecha,
    this.tomada = false,
  });

  Map<String, dynamic> toMap() => {
        'medicamentoId': medicamentoId,
        'horaProgramada': horaProgramada,
        'horaReal': horaReal?.toIso8601String(),
        'fecha': fecha,
        'tomada': tomada,
      };

  factory RegistroToma.fromMap(Map<String, dynamic> m) => RegistroToma(
        medicamentoId: m['medicamentoId'],
        horaProgramada: m['horaProgramada'],
        horaReal:
            m['horaReal'] != null ? DateTime.parse(m['horaReal']) : null,
        fecha: m['fecha'],
        tomada: m['tomada'],
      );
}

// ─── REGISTRO DE PRESIÓN ───
class RegistroPresion {
  int sistolica;
  int diastolica;
  DateTime fechaHora;

  RegistroPresion({
    required this.sistolica,
    required this.diastolica,
    required this.fechaHora,
  });

  String get estado {
    if (sistolica < 120 && diastolica < 80) return 'Normal';
    if (sistolica < 130 && diastolica < 80) return 'Elevada';
    if (sistolica < 140 || diastolica < 90) return 'Alta I';
    return 'Alta II';
  }

  Map<String, dynamic> toMap() => {
        'sistolica': sistolica,
        'diastolica': diastolica,
        'fechaHora': fechaHora.toIso8601String(),
      };

  factory RegistroPresion.fromMap(Map<String, dynamic> m) => RegistroPresion(
        sistolica: m['sistolica'],
        diastolica: m['diastolica'],
        fechaHora: DateTime.parse(m['fechaHora']),
      );
}

// ─── REGISTRO DE GLUCOSA ───
class RegistroGlucosa {
  double valor; // mg/dL
  String momento; // 'ayunas' | 'postprandial' | 'aleatorio'
  DateTime fechaHora;

  RegistroGlucosa({
    required this.valor,
    required this.momento,
    required this.fechaHora,
  });

  String get estado {
    if (momento == 'ayunas') {
      if (valor < 100) return 'Normal';
      if (valor < 126) return 'Prediabetes';
      return 'Alta';
    } else {
      if (valor < 140) return 'Normal';
      if (valor < 200) return 'Alta';
      return 'Muy alta';
    }
  }

  Map<String, dynamic> toMap() => {
        'valor': valor,
        'momento': momento,
        'fechaHora': fechaHora.toIso8601String(),
      };

  factory RegistroGlucosa.fromMap(Map<String, dynamic> m) => RegistroGlucosa(
        valor: m['valor'],
        momento: m['momento'],
        fechaHora: DateTime.parse(m['fechaHora']),
      );
}

// ─── REGISTRO DE PULSO ───
class RegistroPulso {
  int bpm;
  DateTime fechaHora;

  RegistroPulso({required this.bpm, required this.fechaHora});

  String get estado {
    if (bpm < 60) return 'Bajo';
    if (bpm <= 100) return 'Normal';
    return 'Alto';
  }

  Map<String, dynamic> toMap() => {
        'bpm': bpm,
        'fechaHora': fechaHora.toIso8601String(),
      };

  factory RegistroPulso.fromMap(Map<String, dynamic> m) => RegistroPulso(
        bpm: m['bpm'],
        fechaHora: DateTime.parse(m['fechaHora']),
      );
}

// ─── REGISTRO MENSTRUAL ───
class RegistroCiclo {
  DateTime fechaInicio;
  int duracionDias;

  RegistroCiclo({required this.fechaInicio, this.duracionDias = 5});

  DateTime get fechaFin =>
      fechaInicio.add(Duration(days: duracionDias - 1));

  Map<String, dynamic> toMap() => {
        'fechaInicio': fechaInicio.toIso8601String(),
        'duracionDias': duracionDias,
      };

  factory RegistroCiclo.fromMap(Map<String, dynamic> m) => RegistroCiclo(
        fechaInicio: DateTime.parse(m['fechaInicio']),
        duracionDias: m['duracionDias'],
      );
}

// ─── REGISTRO DE HIDRATACIÓN ───
class RegistroHidratacion {
  int vasos;
  String fecha; // "2026-05-22"

  RegistroHidratacion({required this.vasos, required this.fecha});

  Map<String, dynamic> toMap() => {'vasos': vasos, 'fecha': fecha};

  factory RegistroHidratacion.fromMap(Map<String, dynamic> m) =>
      RegistroHidratacion(vasos: m['vasos'], fecha: m['fecha']);
}
