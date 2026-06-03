abstract class DatabaseService {
  Future<void> salvarDado(String colecao, Map<String, dynamic> dados);
  Future<List<Map<String, dynamic>>> buscarDados(String colecao);
}
