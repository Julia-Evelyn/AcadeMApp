import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Future<Database> inicializarBanco() async {
    String caminho = join(await getDatabasesPath(), 'app_treino.db');

    return await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        // Cria a tabela de histórico de atividades
        await db.execute('''
              CREATE TABLE RegistroAtividade (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                distancia_km REAL,
                data_hora TEXT
              )
            ''');
      },
    );
  }

  // Função básica para inserir uma corrida (CRUD - Create)
  Future<void> inserirAtividade(double distancia, String data) async {
    final db = await inicializarBanco();
    await db.insert('RegistroAtividade', {
      'distancia_km': distancia,
      'data_hora': data,
    });
  }
}
