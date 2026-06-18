import 'dart:async';
import 'package:flutter/material.dart';

import '../controller/home_controller.dart';
import 'camera_motion_detector.dart';

class SensorMovimentoView extends StatefulWidget {
  final HomeController controller;

  const SensorMovimentoView({super.key, required this.controller});

  @override
  State<SensorMovimentoView> createState() => _SensorMovimentoViewState();
}

class _SensorMovimentoViewState extends State<SensorMovimentoView> {
  int _tempoRestante = 60;
  bool _isMoving = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarCronometro();
  }

  void _iniciarCronometro() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isMoving && _tempoRestante > 0) {
        setState(() {
          _tempoRestante--;
        });

        if (_tempoRestante <= 0) {
          _timer?.cancel();
          _mostrarSucesso();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _mostrarSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 50),
              SizedBox(height: 12),
              Text('Parabéns!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Você se movimentou por 1 minuto e derrotou a inatividade!',
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
                  Navigator.pop(context, true); 
                },
                child: const Text('Voltar à Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
        
          CameraMotionDetector(
            controller: widget.controller,
            isFullscreen: true, 
            onMotionChanged: (estaSeMovendo) {
              if (mounted) {
                setState(() {
                  _isMoving = estaSeMovendo;
                });
              }
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Hora de se Mexer!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Cronômetro
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CircularProgressIndicator(
                        value: _tempoRestante / 60,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        color: _isMoving ? Colors.greenAccent.shade400 : Colors.orangeAccent,
                      ),
                    ),
                    Text(
                      '$_tempoRestante',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: _isMoving ? Colors.greenAccent.shade400 : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status do movimento
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isMoving ? 'Continue assim!' : 'Aguardando movimento...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _isMoving ? Colors.greenAccent.shade400 : Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}