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

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
