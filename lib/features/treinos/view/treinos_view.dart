import 'treino_ativo_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/treino_provider.dart';


class TreinosView extends StatelessWidget {
  const TreinosView({super.key});

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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TreinoAtivoView(treino: treinoSalvo),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      treinoSalvo['nome'] ?? 'Treino',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${treinoSalvo['objetivo'] ?? 'Geral'} • ${treinoSalvo['dificuldade'] ?? 'Variável'}',
                    ),
                    trailing: Icon(
                      Icons.play_circle_fill,
                      size: 36,
                      color: Theme.of(context).primaryColor,
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