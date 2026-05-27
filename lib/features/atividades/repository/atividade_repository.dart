import '../model/atividade_model.dart';
import '../service/atividade_storage_service.dart';

class AtividadeRepository {
  AtividadeRepository({AtividadeStorageService? storageService})
    : _storageService = storageService ?? SqfliteAtividadeStorageService();

  final AtividadeStorageService _storageService;

  Future<int> salvarAtividade(AtividadeModel atividade) async {
    return _storageService.salvarAtividade(atividade);
  }

  Future<List<AtividadeModel>> buscarTodasAtividades() async {
    return _storageService.buscarTodasAtividades();
  }
}
