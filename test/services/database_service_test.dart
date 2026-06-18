import 'package:academyapp/core/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDatabaseService implements DatabaseService {
  final List<Map<String, dynamic>> _fakeDatabase = [];

  @override
  Future<void> salvarDado(String colecao, Map<String, dynamic> dados) async {
    _fakeDatabase.add(dados);
  }

  @override
  Future<void> deletarDado(String path, String id) async {
  }

  @override
  Future<List<Map<String, dynamic>>> buscarDados(String colecao) async {
    return List<Map<String, dynamic>>.from(_fakeDatabase);
  }
}

void main() {
  test('deve salvar e buscar um dado no mock do banco com sucesso', () async {
    final mockService = MockDatabaseService();
    final dadoExemplo = {'treino': 'Supino Reto', 'carga': 20};

    await mockService.salvarDado('treinos', dadoExemplo);
    final resultado = await mockService.buscarDados('treinos');

    expect(resultado.length, 1);
    expect(resultado.first['treino'], 'Supino Reto');
    expect(resultado.first['carga'], 20);
  });
}
