import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/treino_provider.dart';
import 'treino_ativo_view.dart';
import 'criar_treino_view.dart';
import 'detalhes_treino_personalizado_view.dart';

class TreinosView extends StatelessWidget {
  const TreinosView({super.key});

  void _mostrarConfirmacaoExclusao(
    BuildContext context,
    TreinoProvider provider,
    String idTreino,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Remover Treino'),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja remover este treino da sua rotina?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              provider.removerTreino(idTreino);
              Navigator.pop(context);
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TreinoProvider>(
        builder: (context, treinoProvider, child) {
          if (treinoProvider.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (treinoProvider.meusTreinos.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum treino salvo.\nClique no botão + abaixo ou vá na aba Buscar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: treinoProvider.meusTreinos.length,
            itemBuilder: (context, index) {
              final treinoSalvo = treinoProvider.meusTreinos[index];
              final String? treinoId = treinoSalvo['id'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (treinoSalvo['objetivo'] == 'Personalizado') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesTreinoPersonalizadoView(
                            treino: treinoSalvo,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TreinoAtivoView(treino: treinoSalvo),
                        ),
                      );
                    }
                  },
                  child: MergeSemantics(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: ExcludeSemantics(
                          child: Icon(
                            Icons.fitness_center,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        treinoSalvo['nome'] ?? 'Treino',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${treinoSalvo['objetivo'] ?? 'Geral'} • ${treinoSalvo['dificuldade'] ?? 'Variável'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            label: 'Remover treino',
                            button: true,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                if (treinoId != null) {
                                  _mostrarConfirmacaoExclusao(
                                    context,
                                    treinoProvider,
                                    treinoId,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Erro: Não foi possível identificar o treino.',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          ExcludeSemantics(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 36,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CriarTreinoView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
