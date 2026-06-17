import 'treino_ativo_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/treino_provider.dart';

class TreinosView extends StatelessWidget {
  const TreinosView({super.key});

  // Função para evitar que o usuário apague um treino sem querer!
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
                'Nenhum treino salvo.\nVá na aba Buscar para adicionar!',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TreinoAtivoView(treino: treinoSalvo),
                      ),
                    );
                  },
                  // ACESSIBILIDADE: Agrupa as informações para o TalkBack narrar de uma vez só
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
                          // BOTÃO DE EXCLUIR O TREINO
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
                                        'Erro: Não foi possível identificar o treino para exclusão.',
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
    );
  }
}
