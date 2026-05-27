import 'package:flutter/material.dart';

import '../model/atividade_model.dart';
import '../repository/atividade_repository.dart';

class AtividadeController extends ChangeNotifier {
  AtividadeController({AtividadeRepository? repository})
    : _repository = repository ?? AtividadeRepository();

  final AtividadeRepository _repository;

  List<AtividadeModel> atividades = [];

  Future<void> carregarAtividades() async {
    atividades = await _repository.buscarTodasAtividades();
    notifyListeners();
  }

  Future<void> adicionarAtividade(double distanciaKm) async {
    final novaAtividade = AtividadeModel(
      distanciaKm: distanciaKm,
      dataHora: DateTime.now(),
    );

    await _repository.salvarAtividade(novaAtividade);
    await carregarAtividades();
  }
}
