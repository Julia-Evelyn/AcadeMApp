import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controller/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.controller});

  final HomeController controller;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _dialogAberto = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_escutarAlertaDeMovimento);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_escutarAlertaDeMovimento);
    super.dispose();
  }

  void _escutarAlertaDeMovimento() {
    if (!mounted || _dialogAberto || !widget.controller.movimentoPendente) {
      return;
    }

    _dialogAberto = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mostrarAlertaDeMovimento();
      _dialogAberto = false;
    });
  }

  Future<void> _mostrarSeletorDeTempo() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Definir Tempo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Concluido'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: Duration(
                      minutes: widget.controller.minutosEscolhidos,
                    ),
                    onTimerDurationChanged: (novaDuracao) {
                      var minutosTotais = novaDuracao.inMinutes;
                      if (minutosTotais == 0) {
                        minutosTotais = 1;
                      }

                      widget.controller.mudarTempo(minutosTotais);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _mostrarAlertaDeMovimento() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.directions_run, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text('Atencao!'),
            ],
          ),
          content: const Text(
            'Esta na hora de se mexer!\nVoce atingiu seu limite de inatividade.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await widget.controller.confirmarAlertaDeMovimento();
              },
              child: const Text('Entendido!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 600 ? 100.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-Vindo, ${widget.controller.nomeUsuario}!',
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
      },
    );
  }

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
        title: const Text('Distancia Percorrida'),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              '0.0 km',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'O rastreamento via GPS sera programado depois...',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInatividade(BuildContext context) {
    final controller = widget.controller;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: controller.estaRodando
              ? Colors.blue.withValues(alpha: 0.5)
              : Colors.transparent,
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
                  onTap: controller.estaRodando ? null : _mostrarSeletorDeTempo,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: controller.estaRodando
                          ? Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          controller.textoDoBotaoTempo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: controller.estaRodando
                                ? Theme.of(context).disabledColor
                                : Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: controller.estaRodando
                              ? Theme.of(context).disabledColor
                              : Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
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
                controller.tempoFormatado,
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
                  onPressed: controller.iniciarOuPausarTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.estaRodando
                        ? Colors.amber
                        : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  icon: Icon(
                    controller.estaRodando ? Icons.pause : Icons.play_arrow,
                  ),
                  label: Text(controller.estaRodando ? 'Pausar' : 'Iniciar'),
                ),
                const SizedBox(width: 15),
                OutlinedButton.icon(
                  onPressed:
                      controller.estaRodando ||
                          controller.tempoRestanteSegundos <
                              (controller.minutosEscolhidos * 60)
                      ? controller.resetarTimer
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
