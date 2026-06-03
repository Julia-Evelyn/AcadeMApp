import 'package:academyapp/features/atividades/model/atividade_model.dart';
import 'package:academyapp/features/atividades/repository/atividade_repository.dart';
import 'package:academyapp/features/atividades/service/atividade_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAtividadeStorageService implements AtividadeStorageService {
  final List<AtividadeModel> _atividades = [];

  @override
  Future<List<AtividadeModel>> buscarTodasAtividades() async {
    return List<AtividadeModel>.from(_atividades);
  }

  @override
  Future<int> salvarAtividade(AtividadeModel atividade) async {
    _atividades.add(atividade);
    return _atividades.length;
  }
}

void main() {
  group('AtividadeRepository', () {
    test('delegates save and load to the storage service', () async {
      final storage = MockAtividadeStorageService();
      final repository = AtividadeRepository(storageService: storage);
      final atividade = AtividadeModel(
        id: 1,
        distanciaKm: 3.5,
        dataHora: DateTime(2026, 5, 27),
      );

      final savedId = await repository.salvarAtividade(atividade);
      final atividades = await repository.buscarTodasAtividades();

      expect(savedId, 1);
      expect(atividades, hasLength(1));
      expect(atividades.first.distanciaKm, 3.5);
    });
  });
}
