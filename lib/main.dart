import 'package:flutter/material.dart';
import 'features/configuracoes/controller/configuracoes_controller.dart';
import 'core/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Anti-Sedentarismo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaDeTestesSprint2(),
    );
  }
}

class TelaDeTestesSprint2 extends StatefulWidget {
  const TelaDeTestesSprint2({super.key});

  @override
  State<TelaDeTestesSprint2> createState() => _TelaDeTestesSprint2State();
}

class _TelaDeTestesSprint2State extends State<TelaDeTestesSprint2> {
  // Instanciando ajudantes
  final ConfiguracoesController _configController = ConfiguracoesController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Variável para guardar o tempo que vamos ler do SharedPreferences
  int _tempoAtualNaTela = 0;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes(); // Carrega os dados assim que a tela abre
  }

  // Função para ler o SharedPreferences e atualizar a tela
  Future<void> _carregarConfiguracoes() async {
    int tempoSalvo = await _configController.lerTempoAlerta();
    setState(() {
      _tempoAtualNaTela = tempoSalvo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testes da Sprint 2'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TESTE DO SHAREDPREFERENCES
            const Text(
              'Teste SharedPreferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Tempo de Alerta atual: $_tempoAtualNaTela minutos'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Salva o valor 30 no celular e depois atualiza a tela
                await _configController.salvarTempoAlerta(30);
                await _carregarConfiguracoes();
                
                // Mostra um aviso na tela
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alerta alterado para 30 min!')),
                );
              },
              child: const Text('Mudar Alerta para 30 min'),
            ),
            
            const Divider(height: 50, thickness: 2),

            // TESTE DO SQLITE 
            const Text(
              'Teste SQLite',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Aperte para salvar uma corrida falsa no banco'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Insere uma corrida de 5.2km com a data e hora atual
                await _dbHelper.inserirAtividade(
                  5.2, 
                  DateTime.now().toString()
                );
                
                // Mostra um aviso na tela
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Corrida salva no SQLite com sucesso!')),
                );
              },
              child: const Text('Salvar Corrida (5.2 km)'),
            ),
          ],
        ),
      ),
    );
  }
}