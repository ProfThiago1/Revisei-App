import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Adicione esta dependência no pubspec

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Login com Google para sincronização real entre Mobile e Web
  Future<void> signInWithGoogle() async {
    try {
      // Nota: Para Web e Mobile, a configuração do GoogleSignIn varia.
      // No Mobile exige o arquivo google-services.json.
      // Na Web funciona via Popup.
      
      /* 
      // Exemplo de implementação (requer pacote google_sign_in):
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _auth.signInWithCredential(credential);
      */
      
      // Por enquanto, manteremos o Anonymous para teste, 
      // mas recomendo vincular ao Google no Firebase Console.
      await _auth.signInAnonymously();
    } catch (e) {
      print("Erro no login: \$e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
