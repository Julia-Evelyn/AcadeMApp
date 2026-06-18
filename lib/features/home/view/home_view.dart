import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../controller/home_controller.dart';
import 'sensor_movimento_view.dart';

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
    if (!mounted) {
      return;
    }

    if (_dialogAberto && !widget.controller.movimentoPendente) {
      _dialogAberto = false;
      Navigator.of(context, rootNavigator: true).maybePop();
      return;
    }

    if (_dialogAberto || !widget.controller.movimentoPendente) {
      return;
    }

    _dialogAberto = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mostrarAlertaDeMovimento();
      _dialogAberto = false;
    });
  }

  String get _saudacao {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Future<void> _mostrarSeletorDeTempo() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 350,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 5,
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
                  horizontal: 24,
                  vertical: 12,
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
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Concluído',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
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
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.directions_run, color: Colors.orange, size: 32),
              SizedBox(width: 12),
              Text('Atenção!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Está na hora de se mexer!\nVocê atingiu seu limite de inatividade. Deseja iniciar uma atividade agora?',
            style: TextStyle(fontSize: 16, height: 1.3),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await widget.controller.confirmarAlertaDeMovimento();

                widget.controller.resetarTimer();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await widget.controller.confirmarAlertaDeMovimento();

                widget.controller.resetarTimer();

                if (context.mounted) {
                  final sucesso = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SensorMovimentoView(controller: widget.controller),
                    ),
                  );

                  widget.controller.resetarTimer();

                  if (sucesso == true) {
                    widget.controller.iniciarOuPausarTimer();
                  }
                }
              },
              child: const Text(
                'Ok',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGraficoSemanal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corDestaque = Theme.of(context).colorScheme.primary;
    final dadosSemana = widget.controller.distanciasSemana;

    double maiorDistancia = dadosSemana.isNotEmpty
        ? dadosSemana.reduce(max)
        : 0.0;
    double tetoGrafico = maiorDistancia > 4.0 ? maiorDistancia + 2.0 : 6.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso Semanal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Icon(Icons.directions_run, color: corDestaque),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Quilômetros percorridos nesta semana',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(
            height: 35,
          ), // Aumentei o espaçamento para caber os textos
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: tetoGrafico,
                barTouchData: BarTouchData(
                  enabled:
                      false, // Desativa o toque para mostrar os tooltips permanentemente
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        Colors.transparent, // Fundo transparente
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 8, // Margem entre a barra e o texto
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      // Se for 0.0, não mostra o texto para não poluir
                      if (rod.toY == 0) return null;
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(
                          1,
                        ), // Exibe o valor com 1 casa decimal (ex: 5.2)
                        TextStyle(
                          color: corDestaque, // Cor do texto igual a da barra
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30, // 👈 ADICIONE ESTA LINHA AQUI
                      getTitlesWidget: (value, meta) {
                        const dias = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
                        bool isHoje =
                            (DateTime.now().weekday % 7) == value.toInt();

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dias[value.toInt()],
                            style: TextStyle(
                              color: isHoje ? corDestaque : Colors.grey,
                              fontWeight: isHoje
                                  ? FontWeight.w900
                                  : FontWeight.bold,
                              fontSize: isHoje ? 14 : 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    // ESTA É A LINHA MÁGICA: Força o tooltip a ficar sempre visível se a distância > 0
                    showingTooltipIndicators: dadosSemana[index] > 0 ? [0] : [],
                    barRods: [
                      BarChartRodData(
                        toY: dadosSemana[index],
                        color: corDestaque,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: tetoGrafico,
                          color: corDestaque.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: isDark
              ? tema.colorScheme.surface
              : const Color(0xFFF4F6F9),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MergeSemantics(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_saudacao,',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.controller.nomeUsuario}!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ExcludeSemantics(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: corDestaque.withValues(alpha: 0.15),
                              border: Border.all(color: corDestaque, width: 2),
                              image: widget.controller.imagemDoPerfil != null
                                  ? DecorationImage(
                                      image: FileImage(
                                        widget.controller.imagemDoPerfil!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: widget.controller.imagemDoPerfil == null
                                ? Icon(
                                    Icons.person,
                                    size: 30,
                                    color: corDestaque,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pronto para combater o sedentarismo hoje?',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 35),

                  Text(
                    'Controle de Atividade',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.controller.estaRodando
                            ? [corDestaque, corDestaque.withValues(alpha: 0.75)]
                            : [
                                const Color(0xFF6C63FF),
                                const Color(0xFF8A84FF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: widget.controller.estaRodando
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (widget.controller.estaRodando
                                      ? corDestaque
                                      : const Color(0xFF6C63FF))
                                  .withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Alerta de Inatividade',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Semantics(
                              button: true,
                              label: 'Editar tempo de inatividade',
                              child: GestureDetector(
                                onTap: widget.controller.estaRodando
                                    ? null
                                    : _mostrarSeletorDeTempo,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.controller.estaRodando
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.controller.textoDoBotaoTempo,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: widget.controller.estaRodando
                                              ? Colors.white60
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: widget.controller.estaRodando
                                            ? Colors.white30
                                            : Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.controller.tempoFormatado,
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                label: widget.controller.estaRodando
                                    ? 'Pausar monitoramento'
                                    : 'Iniciar monitoramento',
                                child: ElevatedButton.icon(
                                  onPressed:
                                      widget.controller.iniciarOuPausarTimer,
                                  icon: Icon(
                                    widget.controller.estaRodando
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: widget.controller.estaRodando
                                        ? Colors.black87
                                        : Colors.white,
                                  ),
                                  label: Text(
                                    widget.controller.estaRodando
                                        ? 'Pausar'
                                        : 'Iniciar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.controller.estaRodando
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget.controller.estaRodando
                                        ? Colors.amber
                                        : Colors.white.withValues(alpha: 0.25),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Semantics(
                              label: 'Zerar cronômetro',
                              child: OutlinedButton(
                                onPressed:
                                    widget.controller.estaRodando ||
                                        widget
                                                .controller
                                                .tempoRestanteSegundos <
                                            (widget
                                                    .controller
                                                    .minutosEscolhidos *
                                                60)
                                    ? widget.controller.resetarTimer
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.white30,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  _buildGraficoSemanal(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
