import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricoCorridasView extends StatefulWidget {
  const HistoricoCorridasView({super.key});

  @override
  State<HistoricoCorridasView> createState() => _HistoricoCorridasViewState();
}

class _HistoricoCorridasViewState extends State<HistoricoCorridasView> {
  List<String> _historico = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Pega a lista e inverte para mostrar a mais recente no topo
      _historico = (prefs.getStringList('historico_corridas') ?? []).reversed
          .toList();
      _carregando = false;
    });
  }

  Future<void> _limparHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historico_corridas');
    setState(() {
      _historico = [];
    });
  }

  void _confirmarLimpeza(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Limpar Histórico?'),
        content: const Text(
          'Isso apagará todas as corridas salvas no seu celular. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _limparHistorico();
            },
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corDestaque = tema.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Corridas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_historico.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: 'Limpar Histórico',
              onPressed: () => _confirmarLimpeza(context),
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _historico.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_run,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma corrida registrada.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Suas corridas maiores que 10 metros\naparecerão aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historico.length,
              itemBuilder: (context, index) {
                // Os dados são salvos no formato: "DD/MM/YYYY - X,XX km"
                final corrida = _historico[index];
                final partes = corrida.split(' - ');

                final dataStr = partes.isNotEmpty ? partes[0] : '';
                final distanciaStr = partes.length > 1 ? partes[1] : '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: corDestaque.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.directions_run, color: corDestaque),
                    ),
                    title: Text(
                      distanciaStr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      dataStr,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
