import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TreinoPersonalizadoAtivoView extends StatefulWidget {
  final Map<String, dynamic> treino;
  const TreinoPersonalizadoAtivoView({super.key, required this.treino});

  @override
  State<TreinoPersonalizadoAtivoView> createState() =>
      _TreinoPersonalizadoAtivoViewState();
}

class _TreinoPersonalizadoAtivoViewState
    extends State<TreinoPersonalizadoAtivoView> {
  late List<dynamic> _exercicios;
  int _currentIndex = 0;
  int _tempoRestante = 0;
  bool _rodando = false;
  Timer? _timer;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _exercicios = widget.treino['exercicios'] ?? [];
    if (_exercicios.isNotEmpty) {
      _tempoRestante = _exercicios[_currentIndex]['duracao'] ?? 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _tocarApito() async {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    try {
      await _audioPlayer.play(AssetSource('audio/alarme.mp3'));
      Future.delayed(const Duration(seconds: 2), () => _audioPlayer.stop());
    } catch (e) {
      debugPrint('Áudio não encontrado ou erro ao tocar: $e');
    }
  }

  void _iniciarPausarTimer() {
    if (_rodando) {
      _timer?.cancel();
      setState(() => _rodando = false);
    } else {
      setState(() => _rodando = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_tempoRestante > 0) {
          setState(() => _tempoRestante--);
        } else {
          _iniciarPausarTimer();
          _tocarApito(); // Toca o apito padronizado ao fim do tempo
          _avancar();
        }
      });
    }
  }

  void _avancar() {
    if (_currentIndex < _exercicios.length - 1) {
      setState(() {
        _currentIndex++;
        _tempoRestante = _exercicios[_currentIndex]['duracao'] ?? 0;
        _rodando = false;
      });
      _timer?.cancel();
    } else {
      _mostrarFimTreino();
    }
  }

  void _voltar() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _tempoRestante = _exercicios[_currentIndex]['duracao'] ?? 0;
        _rodando = false;
      });
      _timer?.cancel();
    }
  }

  void _mostrarFimTreino() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text('🎉 Parabéns!')),
        content: const Text(
          'Você concluiu todo o seu treino personalizado com sucesso!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Finalizar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundosTotais) {
    final minutos = segundosTotais ~/ 60;
    final segundos = segundosTotais % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_exercicios.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Treino Vazio')));
    }

    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;

    final exercicioAtual = _exercicios[_currentIndex];
    final bool isDescanso = exercicioAtual['isDescanso'] ?? false;
    final corFase = isDescanso ? Colors.teal : corDestaque;

    return Scaffold(
      backgroundColor: isDark ? tema.colorScheme.surfaceContainerHighest : Colors.white,
      appBar: AppBar(
        title: Text(widget.treino['nome'] ?? 'Treino Ativo', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. ÁREA SUPERIOR (MÍDIA / ÍCONE GIGANTE)
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: corFase.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDescanso ? Icons.timer : Icons.fitness_center,
                      size: 80,
                      color: corFase,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. PAINEL INFERIOR (CONTROLES E TIMER) - IDÊNTICO À API
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: tema.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: corFase.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Etapa ${_currentIndex + 1} de ${_exercicios.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: corFase,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _formatarTempo(_tempoRestante),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: _tempoRestante == 0 ? Colors.redAccent : tema.textTheme.bodyLarge?.color,
                      letterSpacing: 2,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            exercicioAtual['nome'] ?? (isDescanso ? 'Descanso' : 'Exercício'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (!isDescanso) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${exercicioAtual['series']} Séries x ${exercicioAtual['repeticoes']} Repetições',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _currentIndex > 0 ? _voltar : null,
                        icon: const Icon(Icons.skip_previous, size: 36),
                        color: _currentIndex > 0 ? Colors.grey : Colors.grey.withValues(alpha: 0.3),
                      ),
                      GestureDetector(
                        onTap: _iniciarPausarTimer,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: corFase,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: corFase.withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            _rodando ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _avancar,
                        icon: const Icon(Icons.skip_next, size: 36),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}