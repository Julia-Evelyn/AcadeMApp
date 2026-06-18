import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final historico = prefs.getStringList('historico_corridas') ?? [];

    List<double> semana = List.filled(7, 0.0);
    final agora = DateTime.now();

    final inicioDaSemana = agora.subtract(Duration(days: agora.weekday % 7));
    final inicioDaSemanaLimpo = DateTime(
      inicioDaSemana.year,
      inicioDaSemana.month,
      inicioDaSemana.day,
    );

    for (String corrida in historico) {
      try {
        final partes = corrida.split(' - ');
        if (partes.length < 2) continue;

        final dataStr = partes[0].trim();
        
        final distanciaStr = partes[1].replaceAll(' km', '').replaceAll(',', '.').trim();
        final distancia = double.tryParse(distanciaStr) ?? 0.0;

        final dataPartes = dataStr.split('/');
        if (dataPartes.length == 3) {
          final dia = int.parse(dataPartes[0]);
          final mes = int.parse(dataPartes[1]);
          final ano = int.parse(dataPartes[2].length == 2 ? '20${dataPartes[2]}' : dataPartes[2]);
          
          final dataFormatada = DateTime(ano, mes, dia);

          if (dataFormatada.isAfter(inicioDaSemanaLimpo) ||
              dataFormatada.isAtSameMomentAs(inicioDaSemanaLimpo)) {
            int diaIndex = dataFormatada.weekday % 7;
            semana[diaIndex] += distancia;
          }
        }
      } catch (e) {
        debugPrint('Erro ao ler corrida do SharedPreferences pro gráfico: $e');
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
    } else {
      estaRodando = true;
      _timer?.cancel();
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (tempoRestanteSegundos > 0) {
          tempoRestanteSegundos--;
        } else {
          _timer?.cancel();
          estaRodando = false;
          movimentoPendente = true;
          tocarAlarmeInatividade();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void resetarTimer() {
    _timer?.cancel();
    estaRodando = false;
    tempoRestanteSegundos = minutosEscolhidos * 60;
    movimentoPendente = false;
    notifyListeners();
  }


  void tocarAlarmeInatividade() {
    try {
      _alarmAudioService.playLoop('audio/alarme.mp3');
    } catch (e) {
      debugPrint('Erro ao disparar áudio de inatividade: $e');
    }
  }

  Future<void> confirmarAlertaDeMovimento() async {
    try {
      await _alarmAudioService.stop();
    } catch (e) {
      debugPrint('Erro ao parar áudio: $e');
    }
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

  void atualizarMovimentoCamera(bool movendo) {
    if (estaMovendo == movendo) {
      return;
    }

    estaMovendo = movendo;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _timer?.cancel();
    _alarmAudioService.dispose().ignore();
    super.dispose();
  }
}