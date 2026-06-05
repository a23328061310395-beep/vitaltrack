import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  // Usuario actual
  static User? get usuarioActual => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;

  // Stream para escuchar cambios de sesión
  static Stream<User?> get estadoAuth => _auth.authStateChanges();

  // Registro con email y contraseña
  static Future<String?> registrar(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // null = sin error
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este correo ya tiene una cuenta registrada';
        case 'weak-password':
          return 'La contraseña es muy débil (mínimo 6 caracteres)';
        case 'invalid-email':
          return 'El correo no tiene un formato válido';
        default:
          return 'Error al registrar: ${e.message}';
      }
    }
  }

  // Login con email y contraseña
  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde';
        default:
          return 'Error al iniciar sesión: ${e.message}';
      }
    }
  }

  // Cerrar sesión
  static Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
