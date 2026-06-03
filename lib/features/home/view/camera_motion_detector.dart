import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/home_controller.dart';

class CameraMotionDetector extends StatefulWidget {
  const CameraMotionDetector({super.key, required this.controller});

  final HomeController controller;

  @override
  State<CameraMotionDetector> createState() => _CameraMotionDetectorState();
}

class _CameraMotionDetectorState extends State<CameraMotionDetector> {
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _permissionDenied = false;
  bool _cameraAvailable = false;
  bool _isMoving = false;
  double? _previousLuminosity; // <- Double agora para maior precisão
  int _movingFrameCount = 0;
  int _stillFrameCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Na web, permission_handler não funciona — câmera pede permissão automaticamente
    if (!kIsWeb) {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        setState(() {
          _permissionDenied = true;
          _isInitializing = false;
        });
        return;
      }
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraAvailable = false;
          _isInitializing = false;
        });
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
        // NÃO especificar imageFormatGroup na web — deixa o padrão da plataforma
        imageFormatGroup: kIsWeb ? null : ImageFormatGroup.yuv420,
      );

      await _cameraController?.initialize();
      await _cameraController?.startImageStream(_processCameraImage);

      setState(() {
        _cameraAvailable = true;
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint('Erro ao inicializar câmera: $e');
      setState(() {
        _cameraAvailable = false;
        _isInitializing = false;
      });
    }
  }

  Future<void> _stopCamera() async {
    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}
    await _cameraController?.dispose();
    _cameraController = null;
  }

  void _processCameraImage(CameraImage image) {
    double currentAvg;

    try {
      // yuv420 / nv21 (Android/iOS): plano Y é luminância pura
      // bgra8888 (Web/iOS fallback): precisa calcular luminância dos canais RGB
      if (image.format.group == ImageFormatGroup.yuv420 ||
          image.format.group == ImageFormatGroup.nv21) {
        currentAvg = _calcularLuminanciaYUV(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        currentAvg = _calcularLuminanciaBGRA(image);
      } else {
        // Formato desconhecido: tenta usar o primeiro plano mesmo assim
        currentAvg = _calcularLuminanciaGenerico(image.planes.first.bytes);
      }
    } catch (e) {
      debugPrint('Erro ao processar frame: $e');
      return;
    }

    if (_previousLuminosity == null) {
      _previousLuminosity = currentAvg;
      return;
    }

    final prev = _previousLuminosity!;
    final diff = (currentAvg - prev).abs();
    final diffPercent = prev > 0 ? (diff / prev) * 100.0 : 0.0;
    _previousLuminosity = currentAvg;

    const thresholdPercent = 6.0;
    const requiredFrames = 2;

    if (diffPercent >= thresholdPercent) {
      _movingFrameCount++;
      _stillFrameCount = 0;
    } else {
      _stillFrameCount++;
      _movingFrameCount = 0;
    }

    var moving = _isMoving;
    if (!_isMoving && _movingFrameCount >= requiredFrames) {
      moving = true;
    } else if (_isMoving && _stillFrameCount >= requiredFrames) {
      moving = false;
    }

    if (moving != _isMoving) {
      _isMoving = moving;
      widget.controller.atualizarMovimentoCamera(moving);
      if (mounted) setState(() {});
    }
  }

  // Plano Y do YUV420 — luminância direta, muito eficiente
  double _calcularLuminanciaYUV(CameraImage image) {
    final bytes = image.planes[0].bytes;
    return _calcularLuminanciaGenerico(bytes);
  }

  // BGRA8888 — cada pixel tem 4 bytes: B, G, R, A
  // Luminância perceptual: 0.114*B + 0.587*G + 0.299*R
  double _calcularLuminanciaBGRA(CameraImage image) {
    final bytes = image.planes[0].bytes;
    if (bytes.isEmpty) return 0;

    final sampleStep = max(1, (bytes.length ~/ 4) ~/ 300); // ~300 pixels amostrados
    double total = 0;
    int samples = 0;

    for (var i = 0; i < bytes.length - 3; i += 4 * sampleStep) {
      final b = bytes[i];
      final g = bytes[i + 1];
      final r = bytes[i + 2];
      // Ignora alpha (bytes[i + 3])
      total += 0.114 * b + 0.587 * g + 0.299 * r;
      samples++;
    }

    return samples > 0 ? total / samples : 0;
  }

  // Fallback genérico — amostragem simples do primeiro plano
  double _calcularLuminanciaGenerico(Uint8List bytes) {
    if (bytes.isEmpty) return 0;
    final sampleStep = max(1, bytes.length ~/ 1200);
    int total = 0;
    int samples = 0;
    for (var i = 0; i < bytes.length; i += sampleStep) {
      total += bytes[i];
      samples++;
    }
    return samples > 0 ? total / samples : 0;
  }

  Widget _buildPreview() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionDenied) {
      return _buildPermissionMessage();
    }

    if (!_cameraAvailable ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Center(
        child: Icon(Icons.videocam_off, size: 56, color: Colors.white70),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildPermissionMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.camera_alt, size: 40, color: Colors.white70),
        const SizedBox(height: 12),
        const Text(
          'Permita o acesso à câmera para monitorar movimento.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: kIsWeb ? null : () => openAppSettings(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
          child: const Text('Abrir configurações'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // (build idêntico ao original — sem alterações)
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: _buildPreview(),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Icon(
                  _isMoving
                      ? Icons.motion_photos_on
                      : Icons.motion_photos_paused,
                  color: _isMoving
                      ? Colors.greenAccent.shade700
                      : Colors.orangeAccent.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _permissionDenied
                        ? 'Câmera não autorizada'
                        : _isMoving
                            ? 'Movimento detectado'
                            : 'Nenhum movimento detectado',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
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