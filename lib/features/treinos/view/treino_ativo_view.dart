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
  final int _tempoExercicio = 30;
  final int _tempoDescanso = 15;
  final int _totalSeries = 3;

  int _serieAtual = 1;
  bool _estaDescansando = false;
  late int _tempoRestante;
  bool _estaRodando = false;
  Timer? _timer;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
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
    // Tenta tocar o áudio. Se não tiver o arquivo MP3 na pasta assets/audio, ele ignora silenciosamente.
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
              onPressed: () {
                Navigator.pop(context); // Fecha o Dialog
                Navigator.pop(context); // Volta pra tela de listagem
              },
              child: const Text('Concluir'),
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

  @override
  Widget build(BuildContext context) {
    final corFase = _estaDescansando
        ? Colors.teal
        : Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: Text(widget.treino['nome'] ?? 'Exercício')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.white,
            child: Builder(
              builder: (context) {
                final url = widget.treino['gifUrl']?.toString() ?? '';

                // Se o banco de dados não tiver a URL, já desenhamos o placeholder direto
                if (url.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sem demonstração',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Image.network(
                  url.replaceAll('http://', 'https://'),
                  fit: BoxFit.contain,
                  headers: const {
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                    'Accept':
                        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Erro ao carregar GIF',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: corFase.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _estaDescansando
                          ? 'Modo Descanso'
                          : 'Série $_serieAtual de $_totalSeries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corFase,
                      ),
                    ),
                  ),
                  Text(
                    _tempoFormatado,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        widget.treino['instrucoes'] ??
                            'Mantenha a postura correta...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _avancarFase,
                        icon: const Icon(Icons.skip_next, size: 40),
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
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            _estaRodando = false;
                            _tempoRestante = _estaDescansando
                                ? _tempoDescanso
                                : _tempoExercicio;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 40),
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
