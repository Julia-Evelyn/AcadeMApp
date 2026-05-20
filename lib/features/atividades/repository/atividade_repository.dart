import '../../../core/database_helper.dart';
import '../model/atividade_model.dart';

class AtividadeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> salvarAtividade(AtividadeModel atividade) async {
    final db = await _dbHelper.inicializarBanco();

    return await db.insert('RegistroAtividade', atividade.toMap());
  }

  Future<List<AtividadeModel>> buscarTodasAtividades() async {
    final db = await _dbHelper.inicializarBanco();

    final List<Map<String, dynamic>> listaDoBanco = await db.query(
      'RegistroAtividade',
    );

    return listaDoBanco.map((map) => AtividadeModel.fromMap(map)).toList();
  }
}
