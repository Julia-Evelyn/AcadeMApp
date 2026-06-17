import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/treino_provider.dart';

class BlocoTreino {
  String id;
  bool isDescanso;
  int duracaoSegundos;
  String descricao;
  int series;
  int repeticoes;

  BlocoTreino({
    String? id,
    required this.isDescanso,
    required this.duracaoSegundos,
    this.descricao = '',
    this.series = 1,
    this.repeticoes = 1,
  }) : id = id ?? UniqueKey().toString();
}

class CriarTreinoView extends StatefulWidget {
  final Map<String, dynamic>? treinoParaEditar;

  const CriarTreinoView({super.key, this.treinoParaEditar});

  @override
  State<CriarTreinoView> createState() => _CriarTreinoViewState();
}

class _CriarTreinoViewState extends State<CriarTreinoView> {
  final _nomeTreinoController = TextEditingController();
  final List<BlocoTreino> _blocos = [];
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.treinoParaEditar != null) {
      _nomeTreinoController.text = widget.treinoParaEditar!['nome'] ?? '';
      final exercicios =
          widget.treinoParaEditar!['exercicios'] as List<dynamic>? ?? [];
      for (var ex in exercicios) {
        _blocos.add(
          BlocoTreino(
            isDescanso: ex['isDescanso'] ?? false,
            duracaoSegundos: ex['duracao'] ?? 0,
            descricao: ex['nome'] ?? '',
            series: ex['series'] ?? 1,
            repeticoes: ex['repeticoes'] ?? 1,
          ),
        );
      }
    }
  }

  String _formatarTempo(int segundosTotais) {
    final minutos = segundosTotais ~/ 60;
    final segundos = segundosTotais % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  Future<void> _mostrarModalAdicionarBloco({int? indexEditando}) async {
    bool isDescanso = false;
    int tempoEscolhido = 60;
    final descricaoController = TextEditingController();
    final seriesController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '15');

    if (indexEditando != null) {
      final blocoAtual = _blocos[indexEditando];
      isDescanso = blocoAtual.isDescanso;
      tempoEscolhido = blocoAtual.duracaoSegundos;
      descricaoController.text =
          blocoAtual.descricao == 'Descanso' ||
              blocoAtual.descricao == 'Exercício'
          ? ''
          : blocoAtual.descricao;
      seriesController.text = blocoAtual.series.toString();
      repsController.text = blocoAtual.repeticoes.toString();
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final corDestaque = Theme.of(context).colorScheme.primary;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      indexEditando != null
                          ? 'Editar Série'
                          : 'Adicionar Série',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text(
                              'Treino',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            selected: !isDescanso,
                            onSelected: (val) =>
                                setStateModal(() => isDescanso = false),
                            selectedColor: corDestaque.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text(
                              'Descanso',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            selected: isDescanso,
                            onSelected: (val) =>
                                setStateModal(() => isDescanso = true),
                            selectedColor: Colors.blueGrey.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: descricaoController,
                      decoration: InputDecoration(
                        labelText: isDescanso
                            ? 'Descrição (opcional)'
                            : 'Nome do Exercício',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!isDescanso)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: seriesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Séries',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: repsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Repetições',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (!isDescanso) const SizedBox(height: 20),
                    const Text(
                      'Duração / Descanso:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 150,
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        initialTimerDuration: Duration(seconds: tempoEscolhido),
                        onTimerDurationChanged: (Duration novaDuracao) {
                          tempoEscolhido = novaDuracao.inSeconds;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          indexEditando != null ? 'Atualizar' : 'Adicionar',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (descricaoController.text.isNotEmpty || isDescanso) {
      setState(() {
        final novoBloco = BlocoTreino(
          id: indexEditando != null ? _blocos[indexEditando].id : null,
          isDescanso: isDescanso,
          duracaoSegundos: tempoEscolhido,
          descricao: descricaoController.text.trim(),
          series: int.tryParse(seriesController.text) ?? 1,
          repeticoes: int.tryParse(repsController.text) ?? 1,
        );

        if (indexEditando != null) {
          _blocos[indexEditando] = novoBloco;
        } else {
          _blocos.add(novoBloco);
        }
      });
    }
  }

  Future<void> _salvarTreino() async {
    if (_nomeTreinoController.text.isEmpty || _blocos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dê um nome ao treino e adicione pelo menos uma série.',
          ),
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final id = widget.treinoParaEditar != null
        ? widget.treinoParaEditar!['id']
        : DateTime.now().millisecondsSinceEpoch.toString();

    final novoTreinoPersonalizado = {
      'id': id,
      'nome': _nomeTreinoController.text.trim(),
      'objetivo': 'Personalizado',
      'dificuldade': 'Personalizada',
      'exercicios': _blocos
          .map(
            (bloco) => {
              'nome': bloco.descricao.isEmpty
                  ? (bloco.isDescanso ? 'Descanso' : 'Exercício')
                  : bloco.descricao,
              'duracao': bloco.duracaoSegundos,
              'isDescanso': bloco.isDescanso,
              'series': bloco.series,
              'repeticoes': bloco.repeticoes,
            },
          )
          .toList(),
    };

    if (widget.treinoParaEditar != null) {
      await context.read<TreinoProvider>().atualizarTreinoPersonalizado(
        id,
        novoTreinoPersonalizado,
      );
    } else {
      await context.read<TreinoProvider>().adicionarTreino(
        novoTreinoPersonalizado,
      );
    }

    if (!mounted) return;

    setState(() => _salvando = false);
    Navigator.pop(context);

    if (widget.treinoParaEditar != null) {
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.treinoParaEditar != null
              ? 'Treino atualizado!'
              : 'Treino salvo com sucesso!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final corDestaque = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.treinoParaEditar != null ? 'Editar Treino' : 'Novo Treino',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nomeTreinoController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Nome do Treino',
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _blocos.length,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _blocos.removeAt(oldIndex);
                  _blocos.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final bloco = _blocos[index];
                return Card(
                  key: ValueKey(bloco.id),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: bloco.isDescanso
                          ? Colors.blueGrey.withValues(alpha: 0.3)
                          : corDestaque.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () =>
                        _mostrarModalAdicionarBloco(indexEditando: index),
                    leading: CircleAvatar(
                      backgroundColor: bloco.isDescanso
                          ? Colors.blueGrey.withValues(alpha: 0.1)
                          : corDestaque.withValues(alpha: 0.1),
                      child: Icon(
                        bloco.isDescanso ? Icons.timer : Icons.fitness_center,
                        color: bloco.isDescanso ? Colors.blueGrey : corDestaque,
                      ),
                    ),
                    title: Text(
                      bloco.descricao.isEmpty
                          ? (bloco.isDescanso ? 'Descanso' : 'Exercício')
                          : bloco.descricao,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      bloco.isDescanso
                          ? 'Tempo: ${_formatarTempo(bloco.duracaoSegundos)}'
                          : '${bloco.series}x${bloco.repeticoes} • ${_formatarTempo(bloco.duracaoSegundos)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () =>
                              _mostrarModalAdicionarBloco(indexEditando: index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() => _blocos.removeAt(index));
                          },
                        ),
                        const Icon(Icons.drag_handle, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarModalAdicionarBloco(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar Série',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            onPressed: _salvando ? null : _salvarTreino,
            child: _salvando
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    widget.treinoParaEditar != null
                        ? 'ATUALIZAR TREINO'
                        : 'SALVAR TREINO',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
