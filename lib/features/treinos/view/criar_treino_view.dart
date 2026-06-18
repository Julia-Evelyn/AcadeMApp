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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final tema = Theme.of(context);
            final isDark = tema.brightness == Brightness.dark;
            final corDestaque = tema.colorScheme.primary;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? tema.colorScheme.surface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      indexEditando != null ? 'Editar Bloco' : 'Novo Bloco',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text(
                              'Exercício',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            selected: !isDescanso,
                            onSelected: (val) =>
                                setStateModal(() => isDescanso = false),
                            selectedColor: corDestaque.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
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
                            selectedColor: Colors.blueGrey.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _construirCampoTextoModerno(
                      context,
                      isDescanso ? 'Descrição (opcional)' : 'Nome do Exercício',
                      descricaoController,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    if (!isDescanso)
                      Row(
                        children: [
                          Expanded(
                            child: _construirCampoTextoModerno(
                              context,
                              'Séries',
                              seriesController,
                              isDark,
                              isNumeric: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _construirCampoTextoModerno(
                              context,
                              'Repetições',
                              repsController,
                              isDark,
                              isNumeric: true,
                            ),
                          ),
                        ],
                      ),
                    if (!isDescanso) const SizedBox(height: 24),
                    Text(
                      isDescanso ? 'Tempo de Descanso:' : 'Duração Estimada:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? tema.colorScheme.surfaceContainerHighest 
                            : const Color(0xFFF4F6F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        initialTimerDuration: Duration(seconds: tempoEscolhido),
                        onTimerDurationChanged: (Duration novaDuracao) {
                          tempoEscolhido = novaDuracao.inSeconds;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corDestaque,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          indexEditando != null ? 'Atualizar Bloco' : 'Adicionar Bloco',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  // Método auxiliar para os inputs modernos do modal
  Widget _construirCampoTextoModerno(
    BuildContext context, 
    String label, 
    TextEditingController controller, 
    bool isDark, 
    {bool isNumeric = false}
  ) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : const Color(0xFFF4F6F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Future<void> _salvarTreino() async {
    if (_nomeTreinoController.text.isEmpty || _blocos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dê um nome ao treino e adicione pelo menos um bloco.'),
          backgroundColor: Colors.orange,
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
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? tema.colorScheme.surface : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.treinoParaEditar != null ? 'Editar Treino' : 'Montar Rotina',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? tema.colorScheme.surfaceContainerHighest : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _nomeTreinoController,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Ex: Treino de Perna Monstro',
                  hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
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
                return Container(
                  key: ValueKey(bloco.id),
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? tema.colorScheme.surfaceContainerHighest : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: bloco.isDescanso
                          ? Colors.blueGrey.withValues(alpha: 0.3)
                          : corDestaque.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    onTap: () => _mostrarModalAdicionarBloco(indexEditando: index),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bloco.isDescanso
                            ? Colors.blueGrey.withValues(alpha: 0.1)
                            : corDestaque.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        bloco.isDescanso ? Icons.timer : Icons.fitness_center,
                        color: bloco.isDescanso ? Colors.blueGrey : corDestaque,
                      ),
                    ),
                    title: Text(
                      bloco.descricao.isEmpty
                          ? (bloco.isDescanso ? 'Descanso' : 'Exercício')
                          : bloco.descricao,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        bloco.isDescanso
                            ? 'Tempo: ${_formatarTempo(bloco.duracaoSegundos)}'
                            : '${bloco.series}x${bloco.repeticoes} • ${_formatarTempo(bloco.duracaoSegundos)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() => _blocos.removeAt(index));
                          },
                        ),
                        const Icon(Icons.drag_indicator, color: Colors.grey),
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
        backgroundColor: corDestaque,
        foregroundColor: Colors.white,
        onPressed: () => _mostrarModalAdicionarBloco(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Bloco',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black87,
              foregroundColor: isDark ? Colors.black87 : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
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
                        ? 'SALVAR EDIÇÃO'
                        : 'FINALIZAR TREINO',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}