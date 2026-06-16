import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CorridaView extends StatefulWidget {
  const CorridaView({super.key});

  @override
  State<CorridaView> createState() => _CorridaViewState();
}

class _CorridaViewState extends State<CorridaView> {
  bool _estaCorrendo = false;
  double _distanciaTotalMetros = 0.0;

  int _segundosDecorridos = 0;
  Timer? _cronometro;

  StreamSubscription<Position>? _positionStream;
  final MapController _mapController = MapController();

  LatLng _posicaoAtual = const LatLng(-15.799, -47.860);
  final List<LatLng> _rotaPercorrida = [];
  bool _buscandoSatelite = true;

  @override
  void initState() {
    super.initState();
    _iniciarMapaRapido();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _cronometro?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _iniciarMapaRapido() async {
    try {
      var status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() => _buscandoSatelite = false);
        return;
      }

      bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        setState(() => _buscandoSatelite = false);
        _mostrarAvisoGpsDesligado();
        return;
      }

      Position? ultimaPosicao = await Geolocator.getLastKnownPosition();
      if (ultimaPosicao != null && mounted) {
        setState(() {
          _posicaoAtual = LatLng(
            ultimaPosicao.latitude,
            ultimaPosicao.longitude,
          );
        });
        _mapController.move(_posicaoAtual, 16.0);
      }

      Position posExata = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _posicaoAtual = LatLng(posExata.latitude, posExata.longitude);
          _buscandoSatelite = false;
        });
        _mapController.move(_posicaoAtual, 17.0);
      }
    } catch (e) {
      if (mounted) setState(() => _buscandoSatelite = false);
      debugPrint("Aviso do GPS: $e");
    }
  }

  void _mostrarAvisoGpsDesligado() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ative a Localização (GPS) do celular.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _iniciarCorrida() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      openAppSettings();
      return;
    }

    setState(() {
      _estaCorrendo = true;
      _distanciaTotalMetros = 0.0;
      _segundosDecorridos = 0;
      _rotaPercorrida.clear();
      _rotaPercorrida.add(_posicaoAtual);
    });

    _cronometro = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _segundosDecorridos++);
    });

    const LocationSettings config = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: config)
        .listen((Position novaPos) {
          LatLng novaLatLng = LatLng(novaPos.latitude, novaPos.longitude);

          double distanciaPercorrida = Geolocator.distanceBetween(
            _posicaoAtual.latitude,
            _posicaoAtual.longitude,
            novaPos.latitude,
            novaPos.longitude,
          );

          setState(() {
            _distanciaTotalMetros += distanciaPercorrida;
            _posicaoAtual = novaLatLng;
            _rotaPercorrida.add(novaLatLng);
          });

          _mapController.move(novaLatLng, 17.0);
        });
  }

  Future<void> _pararESalvarCorrida() async {
    _positionStream?.cancel();
    _cronometro?.cancel();
    setState(() => _estaCorrendo = false);

    if (_distanciaTotalMetros > 10) {
      final prefs = await SharedPreferences.getInstance();
      List<String> historico = prefs.getStringList('historico_corridas') ?? [];

      String dataAtual =
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      historico.add("$dataAtual - $_distanciaFormatada km");
      await prefs.setStringList('historico_corridas', historico);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Corrida guardada no histórico! 🏃‍♂️'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String get _distanciaFormatada =>
      (_distanciaTotalMetros / 1000).toStringAsFixed(2).replaceAll('.', ',');
  String get _tempoFormatado {
    int minutos = _segundosDecorridos ~/ 60;
    int segundos = _segundosDecorridos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  String get _caloriasQueimadas =>
      ((_distanciaTotalMetros / 1000) * 65).toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    // === CAPTURA AS CORES OFICIAIS DO APLICATIVO ===
    final Color corDestaque = Theme.of(context).colorScheme.primary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // O painel inferior usa a cor de destaque no tema claro e cor de superfície no tema escuro
    final Color corFundoPainel = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : corDestaque;

    final Color corTextoPainel = isDark
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;

    return Scaffold(
      body: Column(
        children: [
          // MAPA
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _posicaoAtual,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.academapp.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        if (_rotaPercorrida.isNotEmpty)
                          Polyline(
                            points: _rotaPercorrida,
                            color: corDestaque,
                            strokeWidth: 6.0,
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _posicaoAtual,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: corDestaque, 
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (_buscandoSatelite)
                  Positioned(
                    top: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Procurando satélite...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Painel inferior
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: corFundoPainel),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _distanciaFormatada,
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: corTextoPainel,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 15.0,
                            left: 5.0,
                          ),
                          child: Text(
                            'km',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: corTextoPainel,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              _tempoFormatado,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: corTextoPainel,
                              ),
                            ),
                            Text(
                              'MINUTOS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: corTextoPainel.withValues(alpha: 0.7),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? Colors.grey[700]! : Colors.white30,
                        ),
                        Column(
                          children: [
                            Text(
                              _caloriasQueimadas,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: corTextoPainel,
                              ),
                            ),
                            Text(
                              'CALORIAS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: corTextoPainel.withValues(alpha: 0.7),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: _estaCorrendo
                          ? _pararESalvarCorrida
                          : _iniciarCorrida,
                      child: Container(
                        width: 120,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? corDestaque : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _estaCorrendo ? 20 : 25,
                            height: _estaCorrendo ? 20 : 25,
                            decoration: BoxDecoration(
                              color: isDark ? corTextoPainel : Colors.red,
                              borderRadius: BorderRadius.circular(
                                _estaCorrendo ? 5 : 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
