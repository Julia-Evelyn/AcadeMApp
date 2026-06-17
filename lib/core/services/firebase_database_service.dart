import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> salvarDado(String colecao, Map<String, dynamic> dados) async {
    await _firestore.collection(colecao).add(dados);
  }

  @override
  Future<List<Map<String, dynamic>>> buscarDados(String colecao) async {
    final snapshot = await _firestore.collection(colecao).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Future<void> deletarDado(String colecao, String id) async {
    await _firestore.collection(colecao).doc(id).delete();
  }
}
