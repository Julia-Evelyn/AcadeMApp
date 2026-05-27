import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/services/database_service.dart';

class MockDatabaseService implements DatabaseService {
  final List<Map<String, dynamic>> _bancoDeMentira = [];

  @override
  Future<void> salvarDado(String colecao, Map<String, dynamic> dados) async {
    _bancoDeMentira.add(dados);
  }

  @override
  Future<List<Map<String, dynamic>>> buscarDados(String colecao) async {
    return _bancoDeMentira;
  }
}

void main() {
  test(
    'Deve salvar e buscar um dado no banco fake (Mock) com sucesso',
    () async {
      // PREPARAÇÃO
      final mockService = MockDatabaseService();
      final dadoExemplo = {'treino': 'Supino Reto', 'carga': 20};

      // AÇÃO
      await mockService.salvarDado('treinos', dadoExemplo);
      final resultado = await mockService.buscarDados('treinos');

      // VERIFICAÇÃO
      expect(resultado.length, 1);
      expect(resultado.first['treino'], 'Supino Reto');
      expect(resultado.first['carga'], 20);
    },
  );
}
