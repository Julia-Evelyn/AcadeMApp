import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> salvarDado(String caminho, Map<String, dynamic> dados) async {
    final partes = caminho.split('/');

    if (partes.length == 2) {
      await _firestore.collection(partes[0]).doc(partes[1]).set(dados);
    } else {
      await _firestore.collection(caminho).add(dados);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> buscarDados(String caminho) async {
    final partes = caminho.split('/');

    if (partes.length == 2) {
      final doc = await _firestore.collection(partes[0]).doc(partes[1]).get();
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        return [data];
      }
      return [];
    } else {
      final snapshot = await _firestore.collection(caminho).get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    }
  }

  @override
  Future<void> deletarDado(String caminho, String id) async {
    await _firestore.collection(caminho).doc(id).delete();
  }
}
