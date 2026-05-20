import 'package:flutter/material.dart';

import '../../../core/theme/theme_controller.dart';

class ConfiguracoesView extends StatelessWidget {
  final ThemeController themeController;

  const ConfiguracoesView({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double margemLateral = constraints.maxWidth > 600 ? 100 : 20;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: margemLateral,
              vertical: 20,
            ),
            children: [
              const Text(
                'Aparencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioGroup<ThemeMode>(
                  groupValue: themeController.themeMode,
                  onChanged: (ThemeMode? valor) {
                    if (valor != null) {
                      themeController.mudarTema(valor);
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text('Seguir o Sistema'),
                        value: ThemeMode.system,
                      ),
                      Divider(height: 1),
                      RadioListTile<ThemeMode>(
                        title: Text('Modo Claro'),
                        value: ThemeMode.light,
                      ),
                      Divider(height: 1),
                      RadioListTile<ThemeMode>(
                        title: Text('Modo Escuro'),
                        value: ThemeMode.dark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
