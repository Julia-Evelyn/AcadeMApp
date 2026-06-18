import 'package:flutter/material.dart';
import '../../../core/services/database_service.dart';

class TreinoProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  List<Map<String, dynamic>> _meusTreinos = [];
  bool _carregando = false;

  TreinoProvider(this._dbService) {
    buscarMeusTreinos();
  }

  List<Map<String, dynamic>> get meusTreinos => _meusTreinos;
  bool get carregando => _carregando;

  Future<void> buscarMeusTreinos() async {
    _carregando = true;
    notifyListeners();

    try {
      _meusTreinos = await _dbService.buscarDados('meus_treinos');
    } catch (e) {
      debugPrint("Erro ao buscar treinos: $e");
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionarTreino(Map<String, dynamic> treino) async {
    try {
      await _dbService.salvarDado('meus_treinos', treino);
      await buscarMeusTreinos();
    } catch (e) {
      debugPrint("Erro ao salvar treino: $e");
    }
  }

  Future<void> adicionarTreinoPersonalizado(
    Map<String, dynamic> novoTreino,
  ) async {
    try {
      await _dbService.salvarDado('meus_treinos', novoTreino);
      await buscarMeusTreinos();
    } catch (e) {
      debugPrint("Erro ao salvar treino personalizado: $e");
    }
  }

  Future<void> atualizarTreinoPersonalizado(
    String idAntigo,
    Map<String, dynamic> treinoAtualizado,
  ) async {
    try {
      await _dbService.deletarDado('meus_treinos', idAntigo);
      await _dbService.salvarDado('meus_treinos', treinoAtualizado);
      await buscarMeusTreinos();
    } catch (e) {
      debugPrint("Erro ao atualizar treino: $e");
    }
  }

  Future<void> removerTreino(String idTreino) async {
    try {
      await _dbService.deletarDado('meus_treinos', idTreino);
      await buscarMeusTreinos();
    } catch (e) {
      debugPrint("Erro ao remover treino: $e");
    }
  }
}
