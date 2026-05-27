import 'dart:convert';
import 'package:academyapp/features/treinos/controller/treino_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


class BuscaTreinosView extends StatefulWidget {
  const BuscaTreinosView({super.key});

  @override
  State<BuscaTreinosView> createState() => _BuscaTreinosViewState();
}

class _BuscaTreinosViewState extends State<BuscaTreinosView> {
  List<Map<String, dynamic>> _todosOsTreinos = [];
  bool _carregandoApi = true; 
  String _filtroAtual = 'Todos';
  String _textoBusca = '';

  @override
  void initState() {
    super.initState();
    _buscarTreinosReaisDaApi();
  }

  Future<void> _buscarTreinosReaisDaApi() async {
    try {
      final url = Uri.parse('https://exercisedb.p.rapidapi.com/exercises?limit=30');
      
      final resposta = await http.get(url, headers: {
        'X-RapidAPI-Key': 'e6174e33d9msh3136e0f08d03576p10121bjsn05177eff2666', 
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com'
      });

      if (resposta.statusCode == 200) {
        final List resultadosDaInternet = jsonDecode(resposta.body);

        setState(() {
          _todosOsTreinos = resultadosDaInternet.map((exercicio) {
            String instrucoesJuntas = 'Instruções não disponíveis.';
            if (exercicio['instructions'] != null) {
              instrucoesJuntas = (exercicio['instructions'] as List).join(' ');
            }

            return {
              'nome': (exercicio['name'] ?? 'Exercício').toString().toUpperCase(),
              'objetivo': exercicio['target'] ?? 'Geral', 
              'dificuldade': exercicio['equipment'] ?? 'Variável', 
              'gifUrl': exercicio['gifUrl'], 
              'instrucoes': instrucoesJuntas, 
            };
          }).toList();
          _carregandoApi = false;
        });
      } else {
        setState(() => _carregandoApi = false);
      }
    } catch (erro) {
      debugPrint('Erro: $erro');
      setState(() => _carregandoApi = false);
    }
  }

  IconData _obterIcone(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('arms') || cat.contains('biceps')) return Icons.sports_gymnastics;
    if (cat.contains('legs') || cat.contains('quads')) return Icons.directions_walk;
    if (cat.contains('chest') || cat.contains('pectorals')) return Icons.accessibility_new;
    if (cat.contains('abs')) return Icons.airline_seat_flat;
    return Icons.fitness_center;
  }

  List<Map<String, dynamic>> get _treinosFiltrados {
    return _todosOsTreinos.where((treino) {
      final bateNome = treino['nome'].toString().toLowerCase().contains(_textoBusca.toLowerCase());
      final bateFiltro = _filtroAtual == 'Todos' || treino['objetivo'] == _filtroAtual;
      return bateNome && bateFiltro;
    }).toList();
  }

  List<String> get _categoriasDisponiveis {
    final categorias = _todosOsTreinos.map((t) => t['objetivo'].toString()).toSet().toList();
    categorias.insert(0, 'Todos'); 
    return categorias;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (valor) => setState(() => _textoBusca = valor),
            decoration: InputDecoration(
              hintText: 'Buscar exercícios...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),

        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _categoriasDisponiveis.map((filtro) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filtro),
                selected: _filtroAtual == filtro,
                onSelected: (selecionado) {
                  if (selecionado) setState(() => _filtroAtual = filtro);
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            )).toList(),
          ),
        ),
        const Divider(),

        if (_carregandoApi)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_treinosFiltrados.isEmpty)
          const Expanded(child: Center(child: Text('Nenhum exercício encontrado.')))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _treinosFiltrados.length,
              itemBuilder: (context, index) {
                final treino = _treinosFiltrados[index];
                final iconeDinamico = _obterIcone(treino['objetivo']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(iconeDinamico, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    title: Text(treino['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${treino['objetivo']} • ${treino['dificuldade']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 30),
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Traduzindo e salvando...'), duration: Duration(seconds: 1)),
                        );

                        String textoParaTraduzir = "${treino['nome']}. Instructions: ${treino['instrucoes']}";
                        String textoTraduzido = textoParaTraduzir; 

                        try {
                          final urlTradutor = Uri.parse('https://google-translate1.p.rapidapi.com/language/translate/v2');
                          
                          final respostaTraducao = await http.post(urlTradutor, headers: {
                            'X-RapidAPI-Key': 'COLE_A_SUA_CHAVE_AQUI', // ⚠️ SUA CHAVE DA API AQUI DE NOVO
                            'X-RapidAPI-Host': 'google-translate1.p.rapidapi.com',
                            'Content-Type': 'application/x-www-form-urlencoded',
                          }, body: {
                            'q': textoParaTraduzir,
                            'target': 'pt', 
                            'source': 'en', 
                          });

                          if (respostaTraducao.statusCode == 200) {
                            final dados = jsonDecode(respostaTraducao.body);
                            textoTraduzido = dados['data']['translations'][0]['translatedText'];
                          }
                        } catch (e) {
                          debugPrint('Erro na tradução: $e');
                        }

                        List<String> partesTraduzidas = textoTraduzido.split('. Instructions: ');
                        String nomePt = partesTraduzidas[0].toUpperCase();
                        String instrucoesPt = partesTraduzidas.length > 1 ? partesTraduzidas[1] : partesTraduzidas[0];

                        Map<String, String> dicionarioManual = {
                          'abs': 'Abdominais', 'quads': 'Quadríceps', 'chest': 'Peito', 'back': 'Costas', 'shoulders': 'Ombros',
                          'body weight': 'Peso do Corpo', 'dumbbell': 'Halteres', 'barbell': 'Barra', 'cable': 'Cabo', 'cardio': 'Cardio'
                        };
                        String objetivoPt = dicionarioManual[treino['objetivo']] ?? treino['objetivo'];
                        String equipamentoPt = dicionarioManual[treino['dificuldade']] ?? treino['dificuldade'];

                        if(context.mounted) {
                          context.read<TreinoProvider>().adicionarTreino({
                            'nome': nomePt,
                            'objetivo': objetivoPt,
                            'dificuldade': equipamentoPt,
                            'gifUrl': treino['gifUrl'],
                            'instrucoes': instrucoesPt,
                          });

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$nomePt salvo em Português!')));
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}