import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CorridaView extends StatefulWidget {
  const CorridaView({super.key});

  @override
  State<CorridaView> createState() => _CorridaViewState();
}

class _CorridaViewState extends State<CorridaView> {
  bool _estaCorrendo = false;
  double _distanciaTotalMetros = 0.0;
  Position? _posicaoAnterior;
  StreamSubscription<Position>? _positionStream;

  @override
  void dispose() {
    // Cancela o rastreio quando o usuário sair da tela (temporário)
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _iniciarCorrida() async {
    var statusPermissao = await Permission.location.request();

    if (statusPermissao.isGranted) {
      // Pega o ponto inicial antes de começar a contagem
      _posicaoAnterior = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _estaCorrendo = true;
        _distanciaTotalMetros = 0.0; // Zera o contador
      });

      // GPS atualiza só quando se move a mais de 2 metros (pra n bugar a distância)
      const LocationSettings configuracaoGPS = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, 
      );

      _positionStream = Geolocator.getPositionStream(locationSettings: configuracaoGPS)
          .listen((Position novaPosicao) {
            
        if (_posicaoAnterior != null) {
          // Calcula a distância do último ponto até o atual
          double distanciaPercorrida = Geolocator.distanceBetween(
            _posicaoAnterior!.latitude,
            _posicaoAnterior!.longitude,
            novaPosicao.latitude,
            novaPosicao.longitude,
          );

          setState(() {
            _distanciaTotalMetros += distanciaPercorrida;
            _posicaoAnterior = novaPosicao;
          });
        }
      });
    } else {
      if (statusPermissao.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  void _pararCorrida() {
    _positionStream?.cancel();
    setState(() => _estaCorrendo = false);
  }

  // Mostra metros até 999m e depois é formatado em km
  String get _distanciaFormatada {
    if (_distanciaTotalMetros < 1000) {
      return '${_distanciaTotalMetros.toStringAsFixed(0)} m';
    } else {
      return '${(_distanciaTotalMetros / 1000).toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _estaCorrendo ? Icons.directions_run : Icons.nature_people, 
                size: 80, 
                color: _estaCorrendo ? Colors.teal : Theme.of(context).primaryColor
              ),
              const SizedBox(height: 20),
              Text(
                _estaCorrendo ? 'Rastreando...' : 'Pronto para correr?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              // Mostrador de distância
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor, width: 4),
                ),
                child: Column(
                  children: [
                    Text(
                      _distanciaFormatada,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const Text('Percorridos', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Botão de Start / Stop
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _estaCorrendo ? _pararCorrida : _iniciarCorrida,
                  icon: Icon(_estaCorrendo ? Icons.stop : Icons.play_arrow, size: 28),
                  label: Text(
                    _estaCorrendo ? 'Parar Corrida' : 'Iniciar Corrida', 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _estaCorrendo ? Colors.redAccent : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}