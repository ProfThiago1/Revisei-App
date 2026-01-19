import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> salvarEstudo(Map<String, dynamic> estudo) async {
    if (userId == null) return;
    await _db.collection('usuarios').doc(userId).collection('estudos').add({
      ...estudo,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getEstudos() {
    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('estudos')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> atualizarPerfil(Map<String, dynamic> perfil) async {
    if (userId == null) return;
    await _db.collection('usuarios').doc(userId).set(perfil, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getPerfil() async {
    return await _db.collection('usuarios').doc(userId).get();
  }
}
