import 'dart:async';
import 'dart:io';
import 'package:academyapp/core/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/audio/alarm_audio_service.dart';
import '../../../core/services/preferences/app_preferences_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required AppPreferencesService preferencesService,
    required AlarmAudioService alarmAudioService,
  }) : _preferencesService = preferencesService,
       _alarmAudioService = alarmAudioService {
    carregarDadosIniciais();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      if (user != null) {
        await _preferencesService.forcarSincronizacao(user);
        await carregarDadosIniciais();
      }
    });
  }

  final AppPreferencesService _preferencesService;
  final AlarmAudioService _alarmAudioService;
  late StreamSubscription<User?> _authSubscription;

  String nomeUsuario = 'Atleta';
  File? imagemDoPerfil;

  List<double> distanciasSemana = List.filled(7, 0.0);

  Timer? _timer;
  int minutosEscolhidos = AppPreferencesService.defaultAlertMinutes;
  int tempoRestanteSegundos = AppPreferencesService.defaultAlertMinutes * 60;
  bool estaRodando = false;
  bool movimentoPendente = false;
  bool estaMovendo = false;

  Future<void> carregarDadosIniciais() async {
    await carregarNomeUsuario();
    await carregarFotoPerfil();
    await carregarProgressoSemanal();
    minutosEscolhidos = await _preferencesService.loadAlertMinutes();
    tempoRestanteSegundos = minutosEscolhidos * 60;
    notifyListeners();
  }

  Future<void> carregarNomeUsuario() async {
    nomeUsuario = await _preferencesService.loadProfileDisplayName();
    notifyListeners();
  }

  Future<void> carregarFotoPerfil() async {
    final perfil = await _preferencesService.loadPerfilData();
    if (perfil.caminhoImagem != null && perfil.caminhoImagem!.isNotEmpty) {
      final file = File(perfil.caminhoImagem!);
      if (file.existsSync()) {
        imagemDoPerfil = file;
      } else {
        imagemDoPerfil = null;
      }
      notifyListeners();
    } else {
      imagemDoPerfil = null;
      notifyListeners();
    }
  }

  Future<void> carregarProgressoSemanal() async {
    final dbHelper = DatabaseHelper();
    final atividades = await dbHelper.buscarTodasAtividades();

    List<double> semana = List.filled(7, 0.0);
    final agora = DateTime.now();

    final inicioDaSemana = agora.subtract(Duration(days: agora.weekday % 7));
    final inicioDaSemanaLimpo = DateTime(
      inicioDaSemana.year,
      inicioDaSemana.month,
      inicioDaSemana.day,
    );

    for (var item in atividades) {
      final dataStr = item['data_hora'] as String;
      final distancia = (item['distancia_km'] as num).toDouble();

      try {
        final dataFormatada = DateTime.parse(dataStr);

        if (dataFormatada.isAfter(inicioDaSemanaLimpo) ||
            dataFormatada.isAtSameMomentAs(inicioDaSemanaLimpo)) {
          int diaIndex = dataFormatada.weekday % 7;
          semana[diaIndex] += distancia;
        }
      } catch (e) {
        debugPrint('Erro ao ler data da atividade: $e');
      }
    }

    distanciasSemana = semana;
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
    await _finalizarAlertaEReiniciarTimer();
  }

  Future<void> _finalizarAlertaEReiniciarTimer() async {
    await _alarmAudioService.stop();
    movimentoPendente = false;

    if (!estaRodando) {
      iniciarOuPausarTimer();
    } else {
      notifyListeners();
    }
  }

  void atualizarMovimentoCamera(bool movendo) {
    if (estaMovendo == movendo) {
      return;
    }

    estaMovendo = movendo;
    notifyListeners();

    if (movendo && movimentoPendente) {
      unawaited(_finalizarAlertaEReiniciarTimer());
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _timer?.cancel();
    unawaited(_alarmAudioService.dispose());
    super.dispose();
  }
}
