import '../../../core/database_helper.dart';
import '../model/atividade_model.dart';

abstract class AtividadeStorageService {
  Future<int> salvarAtividade(AtividadeModel atividade);
  Future<List<AtividadeModel>> buscarTodasAtividades();
}

class SqfliteAtividadeStorageService implements AtividadeStorageService {
  SqfliteAtividadeStorageService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  @override
  Future<int> salvarAtividade(AtividadeModel atividade) async {
    final db = await _databaseHelper.inicializarBanco();
    return db.insert('RegistroAtividade', atividade.toMap());
  }

  @override
  Future<List<AtividadeModel>> buscarTodasAtividades() async {
    final db = await _databaseHelper.inicializarBanco();
    final registros = await db.query('RegistroAtividade');

    return registros.map(AtividadeModel.fromMap).toList();
  }
}
