import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/treino_provider.dart';
import 'treino_ativo_view.dart';
import 'criar_treino_view.dart';
import 'detalhes_treino_personalizado_view.dart';
import 'package:academyapp/core/widgets/card_treino.dart';

class TreinosView extends StatelessWidget {
  const TreinosView({super.key});

  Future<bool?> _mostrarConfirmacaoExclusao(BuildContext context) {
    return showDialog<bool>(
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
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

              return Dismissible(
                key: Key(treinoId ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
                ),
                confirmDismiss: (direction) async {
                  return await _mostrarConfirmacaoExclusao(context);
                },
                onDismissed: (direction) {
                  if (treinoId != null) {
                    treinoProvider.removerTreino(treinoId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Treino removido da sua rotina.'),
                        backgroundColor: Colors.grey,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: CardTreino(
                  titulo: treinoSalvo['nome'] ?? 'Treino',
                  duracao: treinoSalvo['objetivo'] ?? 'Geral',
                  dificuldade: treinoSalvo['dificuldade'] ?? 'Variável',
                  isApi: treinoSalvo['objetivo'] != 'Personalizado', 
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