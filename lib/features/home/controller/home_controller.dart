import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/audio/alarm_audio_service.dart';
import '../../../core/services/preferences/app_preferences_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required AppPreferencesService preferencesService,
    required AlarmAudioService alarmAudioService,
  }) : _preferencesService = preferencesService,
       _alarmAudioService = alarmAudioService {
    carregarDadosIniciais();
  }

  final AppPreferencesService _preferencesService;
  final AlarmAudioService _alarmAudioService;

  String nomeUsuario = 'Atleta';
  Timer? _timer;
  int minutosEscolhidos = AppPreferencesService.defaultAlertMinutes;
  int tempoRestanteSegundos = AppPreferencesService.defaultAlertMinutes * 60;
  bool estaRodando = false;
  bool movimentoPendente = false;

  Future<void> carregarDadosIniciais() async {
    await carregarNomeUsuario();
    minutosEscolhidos = await _preferencesService.loadAlertMinutes();
    tempoRestanteSegundos = minutosEscolhidos * 60;
    notifyListeners();
  }

  Future<void> carregarNomeUsuario() async {
    nomeUsuario = await _preferencesService.loadProfileDisplayName();
    notifyListeners();
  }

  String get tempoFormatado {
    final minutos = tempoRestanteSegundos ~/ 60;
    final segundos = tempoRestanteSegundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  String get textoDoBotaoTempo {
    final horasEscolhidas = minutosEscolhidos ~/ 60;
    final minutosRestantes = minutosEscolhidos % 60;

    return horasEscolhidas > 0
        ? '${horasEscolhidas}h ${minutosRestantes}min'
        : '$minutosRestantes min';
  }

  void iniciarOuPausarTimer() {
    if (estaRodando) {
      _timer?.cancel();
      estaRodando = false;
      notifyListeners();
      return;
    }

    estaRodando = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (tempoRestanteSegundos > 0) {
        tempoRestanteSegundos--;
        notifyListeners();
        return;
      }

      _timer?.cancel();
      estaRodando = false;
      tempoRestanteSegundos = minutosEscolhidos * 60;
      movimentoPendente = true;
      notifyListeners();
      unawaited(_alarmAudioService.playLoop('audio/alarme.mp3'));
    });
  }

  Future<void> resetarTimer() async {
    _timer?.cancel();
    await _alarmAudioService.stop();
    estaRodando = false;
    tempoRestanteSegundos = minutosEscolhidos * 60;
    movimentoPendente = false;
    notifyListeners();
  }

  Future<void> mudarTempo(int novosMinutos) async {
    _timer?.cancel();
    minutosEscolhidos = novosMinutos;
    tempoRestanteSegundos = minutosEscolhidos * 60;
    estaRodando = false;
    await _preferencesService.saveAlertMinutes(novosMinutos);
    notifyListeners();
  }

  Future<void> confirmarAlertaDeMovimento() async {
    await _alarmAudioService.stop();
    movimentoPendente = false;
    notifyListeners();
    iniciarOuPausarTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_alarmAudioService.dispose());
    super.dispose();
  }
}
