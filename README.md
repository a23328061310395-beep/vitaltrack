# 💚 VitalTrack — Aplicación Móvil de Gestión Médica Personal

Aplicación móvil desarrollada en **Flutter** con base de datos en la nube mediante **Firebase**, que permite registrar y monitorear datos de salud diarios de forma personalizada.

> **Proyecto Final — Submódulo 2: Implementa aplicaciones móviles multiplataforma**
> CETis 131 | 6A Programación | Turno Vespertino
> Alumna: Allisson Guadalupe Garcia Mendo
> Maestra: Lorena Armandina Sanchez Turrubiartes

---

## 📱 Funciones principales

| Módulo | Descripción |
|---|---|
| 🩺 Presión arterial | Registro diario con clasificación automática (Normal / Elevada / Alta) |
| 🩸 Glucosa en sangre | Registro en ayunas o postprandial con historial |
| ❤️ Frecuencia cardíaca | Registro de pulso en bpm |
| ⚖️ IMC | Cálculo automático de Índice de Masa Corporal |
| 💧 Hidratación | Control de vasos de agua diarios |
| 💊 Medicamentos | Gestión de tomas con horarios y marcado diario |
| 📅 Calendario de seguimiento | Historial mensual de adherencia a medicamentos |
| 🌸 Ciclo menstrual | Calendario, predicción de período y días fértiles (mujeres) |
| 💡 Consejos de salud | Recomendaciones automáticas según los registros del día |

---

## 🛠️ Tecnologías utilizadas

- **Flutter** — Framework de desarrollo multiplataforma
- **Dart** — Lenguaje de programación
- **Firebase Authentication** — Registro e inicio de sesión seguro
- **Firebase Firestore** — Base de datos en la nube en tiempo real
- **Material Design** — Sistema de diseño de interfaz

---

## 📂 Estructura del proyecto

```
lib/
├── main.dart
├── models/
│   └── models.dart
├── utils/
│   ├── theme.dart
│   ├── auth_service.dart
│   └── firebase_service.dart
├── widgets/
│   └── widgets.dart
└── screens/
    ├── auth/
    │   ├── splash_screen.dart
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── dashboard/
    │   ├── dashboard_screen.dart
    │   └── perfil_screen.dart
    ├── health/
    │   ├── presion_screen.dart
    │   └── health_screens.dart
    ├── medications/
    │   ├── medicamentos_screen.dart
    │   └── calendario_medicamento_screen.dart
    ├── calendar/
    │   └── ciclo_screen.dart
    └── tips/
        └── consejos_screen.dart
```

---

## 🚀 Instalación y configuración

### Requisitos previos
- Flutter SDK 3.0 o superior
- Android Studio o VS Code
- Cuenta de Firebase

### Pasos

1. **Clona el repositorio**
```bash
git clone https://github.com/a23328061310395-beep/vitaltrack.git
cd vitaltrack
```

2. **Instala las dependencias**
```bash
flutter pub get
```

3. **Configura Firebase**
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com)
   - Activa Authentication (Email/Password) y Firestore
   - Descarga `google-services.json` y colócalo en `android/app/`
   - Ejecuta `flutterfire configure` para generar `firebase_options.dart`

4. **Corre la app**
```bash
flutter run
```

5. **Genera el APK**
```bash
flutter build apk --release
```

---

## 🔒 Seguridad

Cada usuario solo puede acceder a sus propios datos gracias a las reglas de seguridad de Firestore:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## 📋 Dependencias principales

```yaml
dependencies:
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  intl: ^0.18.1
  uuid: ^4.3.3
```

---

Desarrollado con 💚 por **Allisson Guadalupe Garcia Mendo** | CETis 131 | 2026
