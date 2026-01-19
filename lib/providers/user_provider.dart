import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? get currentUser => _currentUser;

  UserProvider() {
    _initUser();
  }

  void _initUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(User user) async {
    final doc = await _db.collection('usuarios').doc(user.uid).get();
    
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.data()!);
    } else {
      // Cria perfil inicial com dados do Google/Auth
      _currentUser = UserModel(
        id: user.uid,
        nome: user.displayName ?? 'Estudante',
        email: user.email ?? '',
        fotoUrl: user.photoURL ?? '',
      );
      await _db.collection('usuarios').doc(user.uid).set(_currentUser!.toMap());
    }
    notifyListeners();
  }

  Future<void> updateProfile({
    String? nome,
    String? fotoUrl,
    String? telefone,
    String? dataNascimento,
    String? focoEstudo,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = UserModel(
      id: _currentUser!.id,
      nome: nome ?? _currentUser!.nome,
      email: _currentUser!.email,
      fotoUrl: fotoUrl ?? _currentUser!.fotoUrl,
      telefone: telefone ?? _currentUser!.telefone,
      dataNascimento: dataNascimento ?? _currentUser!.dataNascimento,
      focoEstudo: focoEstudo ?? _currentUser!.focoEstudo,
    );

    await _db.collection('usuarios').doc(_currentUser!.id).update(updatedUser.toMap());
    _currentUser = updatedUser;
    notifyListeners();
  }
}
