import 'dart:async';
import 'package:flutter/material.dart';

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
    super.dispose();
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
        title: const Text(
          'Parabéns!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Você concluiu todo o seu treino personalizado.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
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

    final exercicioAtual = _exercicios[_currentIndex];
    final bool isDescanso = exercicioAtual['isDescanso'] ?? false;
    final corDestaque = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.treino['nome'] ?? 'Treino Ativo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Etapa ${_currentIndex + 1} de ${_exercicios.length}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Icon(
              isDescanso ? Icons.timer : Icons.fitness_center,
              size: 100,
              color: isDescanso ? Colors.blueGrey : corDestaque,
            ),
            const SizedBox(height: 30),
            Text(
              exercicioAtual['nome'] ?? '',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (!isDescanso)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: corDestaque.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${exercicioAtual['series']} Séries x ${exercicioAtual['repeticoes']} Repetições',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: corDestaque,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              _formatarTempo(_tempoRestante),
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: _tempoRestante == 0
                    ? Colors.red
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 40,
                  color: Colors.grey,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _currentIndex > 0 ? _voltar : null,
                ),
                FloatingActionButton.large(
                  backgroundColor: corDestaque,
                  foregroundColor: Colors.white,
                  onPressed: _iniciarPausarTimer,
                  elevation: _rodando ? 2 : 6,
                  child: Icon(
                    _rodando ? Icons.pause : Icons.play_arrow,
                    size: 48,
                  ),
                ),
                IconButton(
                  iconSize: 40,
                  color: Colors.grey,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _avancar,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
