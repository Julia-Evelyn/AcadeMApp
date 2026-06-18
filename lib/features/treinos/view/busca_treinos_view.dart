import 'dart:convert';
import 'dart:math';
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

  final Map<String, String> _dicionarioPT = {
    'abs': 'Abdominais',
    'quads': 'Quadríceps',
    'chest': 'Peito',
    'back': 'Costas',
    'shoulders': 'Ombros',
    'arms': 'Braços',
    'legs': 'Pernas',
    'cardio': 'Cardio',
    'body weight': 'Peso do Corpo',
    'dumbbell': 'Halteres',
    'barbell': 'Barra',
    'cable': 'Cabo',
    'band': 'Faixa Elástica',
    'kettlebell': 'Kettlebell',
  };

  @override
  void initState() {
    super.initState();
    _buscarETraduzirTreinos();
  }

  Future<void> _buscarETraduzirTreinos() async {
    try {
      final url = Uri.parse('https://exercisedb.p.rapidapi.com/exercises?limit=15');
      final resposta = await http.get(url, headers: {
        'X-RapidAPI-Key': 'e6174e33d9msh3136e0f08d03576p10121bjsn05177eff2666',
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      });

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        final List resultados = jsonDecode(resposta.body);
        
        String textoParaTraduzir = resultados.map((ex) {
          final inst = (ex['instructions'] as List?)?.join(' ') ?? 'Sem instruções.';
          return '${ex['name']} @@@ $inst';
        }).join(' ||| ');

        String textoTraduzido = textoParaTraduzir;
        
        try {
          final uriTradutor = Uri.parse(
            'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=pt&dt=t&q=${Uri.encodeQueryComponent(textoParaTraduzir)}'
          );
          
          final resTraducao = await http.get(uriTradutor);

          if (resTraducao.statusCode == 200) {
            final jsonTraducao = jsonDecode(resTraducao.body);
            textoTraduzido = '';
            for (var pedaco in jsonTraducao[0]) {
              textoTraduzido += pedaco[0];
            }
          }
        } catch (e) {
          debugPrint('Erro no tradutor gratuito: $e');
        }


        List<String> blocosTraduzidos = textoTraduzido.split(RegExp(r'\s*\|\|\|\s*'));
        final random = Random();

        setState(() {
          _todosOsTreinos = resultados.asMap().entries.map((entry) {
            int idx = entry.key;
            var exercicioOriginal = entry.value;

            String nomePt = exercicioOriginal['name'];
            String instrucaoPt = 'Sem instruções.';
            
            if (idx < blocosTraduzidos.length) {
              List<String> partes = blocosTraduzidos[idx].split(RegExp(r'\s*@@@\s*'));
              nomePt = partes.isNotEmpty ? partes[0] : nomePt;
              instrucaoPt = partes.length > 1 ? partes[1] : instrucaoPt;
            }

            String objRaw = exercicioOriginal['target'] ?? 'Geral';
            String equipRaw = exercicioOriginal['equipment'] ?? 'Variável';
            String objPt = _dicionarioPT[objRaw.toLowerCase()] ?? objRaw;
            String equipPt = _dicionarioPT[equipRaw.toLowerCase()] ?? equipRaw;

            int tempoExercicio = (random.nextInt(4) + 2) * 10; 
            int series = random.nextInt(2) + 3; 

            return {
              'nome': nomePt.toUpperCase(),
              'objetivo': objPt,
              'dificuldade': equipPt,
              'gifUrl': exercicioOriginal['gifUrl']?.toString().replaceAll('http://', 'https://'),
              'instrucoes': instrucaoPt,
              'duracao': tempoExercicio,
              'descanso': (tempoExercicio / 2).round(),
              'series': series,
            };
          }).toList();
          _carregandoApi = false;
        });
      } else {
        setState(() => _carregandoApi = false);
      }
    } catch (erro) {
      debugPrint('Erro: $erro');
      if (mounted) setState(() => _carregandoApi = false);
    }
  }

  IconData _obterIcone(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('braços') || cat.contains('ombros')) return Icons.sports_gymnastics;
    if (cat.contains('pernas') || cat.contains('quadríceps')) return Icons.directions_walk;
    if (cat.contains('peito') || cat.contains('costas')) return Icons.accessibility_new;
    if (cat.contains('abdominais')) return Icons.airline_seat_flat;
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
          const Expanded(child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Baixando e traduzindo treinos...', style: TextStyle(color: Colors.grey)),
              ],
            )
          ))
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
                    title: Text(
                      treino['nome'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${treino['objetivo']} • ${treino['dificuldade']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 30),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        // Como a lista JÁ está traduzida e com tempo, basta salvar!
                        context.read<TreinoProvider>().adicionarTreino(treino);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${treino['nome']} salvo na sua rotina!'),
                            backgroundColor: Colors.green,
                          ),
                        );
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