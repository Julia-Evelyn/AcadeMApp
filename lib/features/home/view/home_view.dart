import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Fitness'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double horizontalPadding =
              constraints.maxWidth > 600 ? 100 : 20;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-Vindo, Atleta!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildStatusCard(
                  context,
                  title: 'Progresso Diario',
                  value: '5.2 km',
                  icon: Icons.directions_run,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                _buildStatusCard(
                  context,
                  title: 'Alerta de Inatividade',
                  value: 'A cada 45 min',
                  icon: Icons.timer,
                  color: Colors.blue,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/historico_treinos',
                        ),
                        icon: const Icon(Icons.history),
                        label: const Text('Ver Historico'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/configuracoes',
                        ),
                        icon: const Icon(Icons.settings),
                        label: const Text('Configurar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
