import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan pengguna saat ini
  User? get currentUser => _auth.currentUser;

  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Akun dengan email ini tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        throw 'Kata sandi yang dimasukkan salah.';
      } else if (e.code == 'invalid-email') {
        throw 'Format email tidak valid.';
      } else if (e.code == 'too-many-requests') {
        throw 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
      } else {
        throw 'Terjadi kesalahan saat login. Silakan coba lagi.';
      }
    } catch (e) {
      throw 'Terjadi kesalahan tak terduga: $e';
    }
  }
}
