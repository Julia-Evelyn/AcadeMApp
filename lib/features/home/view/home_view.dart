import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _nomeUsuario = 'Atleta';

  // Variáveis do temporizador
  Timer? _timer;
  int _minutosEscolhidos = 45;
  int _tempoRestanteSegundos = 45 * 60;
  bool _estaRodando = false;

  // Controla o áudio
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _carregarNomeUsuario();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Libera a memória do áudio quando fecha a tela
    super.dispose();
  }

  Future<void> _carregarNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeUsuario = prefs.getString('perfil_nome') ?? 'Atleta';
      if (_nomeUsuario.isEmpty) _nomeUsuario = 'Atleta';
    });
  }

  // Lógica do áudio
  Future<void> _tocarAlarme() async {
    // Configura para tocar em looping até o usuário desligar o alarme
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // Busca o arquivo na pasta assets
    await _audioPlayer.play(AssetSource('audio/alarme.mp3'));
  }

  Future<void> _pararAlarme() async {
    await _audioPlayer.stop();
  }

  // Lógica do alerta
  void _iniciarOuPausarTimer() {
    if (_estaRodando) {
      _timer?.cancel();
      setState(() => _estaRodando = false);
    } else {
      setState(() => _estaRodando = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_tempoRestanteSegundos > 0) {
            _tempoRestanteSegundos--;
          } else {
            // caso o tempo acabe
            _timer?.cancel();
            _estaRodando = false;
            _tempoRestanteSegundos = _minutosEscolhidos * 60; // Reseta o texto
            _tocarAlarme(); 
            _mostrarAlertaDeMovimento(); 
          }
        });
      });
    }
  }

  void _resetarTimer() {
    _timer?.cancel();
    _pararAlarme(); // Faz com que o alarme pare se o usuário zerar o coiso
    setState(() {
      _estaRodando = false;
      _tempoRestanteSegundos = _minutosEscolhidos * 60;
    });
  }

  void _mudarTempo(int novosMinutos) {
    _timer?.cancel();
    setState(() {
      _minutosEscolhidos = novosMinutos;
      _tempoRestanteSegundos = _minutosEscolhidos * 60;
      _estaRodando = false;
    });
  }

  // Popup do scroll do tempo do alerta
  void _mostrarSeletorDeTempo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (BuildContext context) {
        return Container(
          height: 350,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Cabeçalho
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Definir Tempo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Concluído'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              // A Roleta do IOS
              Expanded(
                child: CupertinoTheme(
                  // Faz o texto do scroll seguir as cores do tema
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 22),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: Duration(minutes: _minutosEscolhidos),
                    onTimerDurationChanged: (Duration novaDuracao) {
                      int minutosTotais = novaDuracao.inMinutes;
                      if (minutosTotais == 0) minutosTotais = 1; 
                      _mudarTempo(minutosTotais);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20), // Respiro visual no final
            ],
          ),
        );
      },
    );
  }

  // Alerta que para o som
  void _mostrarAlertaDeMovimento() {
    showDialog(
      context: context,
      barrierDismissible: false, // Block o clique fora do popup
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.directions_run, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text('Atenção!'),
            ],
          ),
          content: const Text(
            'Está na hora de se mexer!\nVocê atingiu seu limite de inatividade.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _pararAlarme(); // Desliga o som do alarme
                Navigator.pop(context);
                _iniciarOuPausarTimer(); // Reinicia a contagem 
              },
              child: const Text('Entendido!'),
            ),
          ],
        );
      },
    );
  }

  String get _tempoFormatado {
    int minutos = _tempoRestanteSegundos ~/ 60;
    int segundos = _tempoRestanteSegundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding = constraints.maxWidth > 600 ? 100 : 20;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-Vindo, $_nomeUsuario!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              const Text('Pronto para combater o sedentarismo hoje?'),
              const SizedBox(height: 30),

              _buildCardGPS(context),
              const SizedBox(height: 20),
              _buildCardInatividade(context),
            ],
          ),
        );
      },
    );
  }

  // Cardezinho do GPS (vai ser ajustado no futuro)
  Widget _buildCardGPS(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          child: const Icon(Icons.location_on, color: Colors.orange),
        ),
        title: const Text('Distância Percorrida'),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              '0.0 km',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text('O rastreamento via GPS será programado depois...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Cardezinho do alerta de inatividade
  Widget _buildCardInatividade(BuildContext context) {
    int horasEscolhidas = _minutosEscolhidos ~/ 60;
    int minEscolhidos = _minutosEscolhidos % 60;
    String textoDoBotao = horasEscolhidas > 0 
        ? '${horasEscolhidas}h ${minEscolhidos}min' 
        : '$minEscolhidos min';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: _estaRodando ? Colors.blue.withValues(alpha: 0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  child: const Icon(Icons.timer, color: Colors.blue),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    'Alerta de Inatividade',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                
                InkWell(
                  onTap: _estaRodando ? null : _mostrarSeletorDeTempo,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _estaRodando 
                          ? Colors.grey.withValues(alpha: 0.1) 
                          : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          textoDoBotao,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _estaRodando ? Colors.grey : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit, 
                          size: 16, 
                          color: _estaRodando ? Colors.grey : Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _tempoFormatado,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _iniciarOuPausarTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _estaRodando ? Colors.amber : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: Icon(_estaRodando ? Icons.pause : Icons.play_arrow),
                  label: Text(_estaRodando ? 'Pausar' : 'Iniciar'),
                ),
                const SizedBox(width: 15),
                OutlinedButton.icon(
                  onPressed: _estaRodando || _tempoRestanteSegundos < (_minutosEscolhidos * 60) 
                      ? _resetarTimer 
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.stop),
                  label: const Text('Zerar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}