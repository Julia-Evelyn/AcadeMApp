import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TreinoAtivoView extends StatefulWidget {
  final Map<String, dynamic> treino;

  const TreinoAtivoView({super.key, required this.treino});

  @override
  State<TreinoAtivoView> createState() => _TreinoAtivoViewState();
}

class _TreinoAtivoViewState extends State<TreinoAtivoView> {
  late int _tempoExercicio;
  late int _tempoDescanso;
  late int _totalSeries;

  int _serieAtual = 1;
  bool _estaDescansando = false;
  late int _tempoRestante;
  bool _estaRodando = false;
  Timer? _timer;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tempoExercicio = widget.treino['duracao'] ?? 30;
    _tempoDescanso = widget.treino['descanso'] ?? 15;
    _totalSeries = widget.treino['series'] ?? 3;

    _tempoRestante = _tempoExercicio;
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

  void _iniciarOuPausarTimer() {
    if (_estaRodando) {
      _timer?.cancel();
      setState(() => _estaRodando = false);
    } else {
      setState(() => _estaRodando = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_tempoRestante > 0) {
            _tempoRestante--;
          } else {
            _tocarApito();
            _avancarFase();
          }
        });
      });
    }
  }

  void _avancarFase() {
    if (!_estaDescansando) {
      setState(() {
        _estaDescansando = true;
        _tempoRestante = _tempoDescanso;
      });
    } else {
      if (_serieAtual < _totalSeries) {
        setState(() {
          _estaDescansando = false;
          _serieAtual++;
          _tempoRestante = _tempoExercicio;
        });
      } else {
        _timer?.cancel();
        _mostrarFimDeTreino();
      }
    }
  }

  void _mostrarFimDeTreino() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text('🎉 Parabéns!')),
        content: const Text(
          'Você concluiu todas as séries deste exercício com sucesso!',
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
              child: const Text(
                'Concluir',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _tempoFormatado {
    int minutos = _tempoRestante ~/ 60;
    int segundos = _tempoRestante % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  IconData _obterIconeDinamico(String objetivo) {
    if (_estaDescansando) return Icons.timer;

    final obj = objetivo.toLowerCase();
    if (obj.contains('braços') || obj.contains('ombros')) {
      return Icons.sports_gymnastics;
    }
    if (obj.contains('pernas') || obj.contains('quadríceps')) {
      return Icons.directions_walk;
    }
    if (obj.contains('peito') || obj.contains('costas')) {
      return Icons.accessibility_new;
    }
    if (obj.contains('abdominais')) return Icons.airline_seat_flat;
    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;
    final corFase = _estaDescansando ? Colors.teal : corDestaque;

    final String objetivoTreino = widget.treino['objetivo'] ?? '';
    final IconData iconeTreino = _obterIconeDinamico(objetivoTreino);

    return Scaffold(
      backgroundColor: isDark
          ? tema.colorScheme.surfaceContainerHighest
          : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.treino['nome'] ?? 'Exercício',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: corFase.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconeTreino, size: 80, color: corFase),
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: tema.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: corFase.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _estaDescansando
                          ? 'Modo Descanso'
                          : 'Série $_serieAtual de $_totalSeries',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: corFase,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _tempoFormatado,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: _tempoRestante == 0
                          ? Colors.redAccent
                          : tema.textTheme.bodyLarge?.color,
                      letterSpacing: 2,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        widget.treino['instrucoes'] ??
                            'Mantenha a postura correta e respire de forma controlada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            _estaRodando = false;
                            _tempoRestante = _estaDescansando
                                ? _tempoDescanso
                                : _tempoExercicio;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 36),
                        color: Colors.grey,
                      ),
                      GestureDetector(
                        onTap: _iniciarOuPausarTimer,
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
                            _estaRodando ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _avancarFase,
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
