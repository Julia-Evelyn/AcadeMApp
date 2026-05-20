import 'package:flutter/material.dart';
import '../../../core/theme/theme_controller.dart';

class ConfiguracoesView extends StatelessWidget {
  final ThemeController themeController;

  const ConfiguracoesView({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),

      body: LayoutBuilder(
        builder: (context, constraints) {
          double margemLateral = constraints.maxWidth > 600 ? 100 : 20;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: margemLateral,
              vertical: 20,
            ),
            children: [
              const Text(
                'Aparência',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Seguir o Sistema'),
                      value: ThemeMode.system,
                      groupValue: themeController.themeMode,
                      onChanged: (ThemeMode? valor) {
                        if (valor != null) themeController.mudarTema(valor);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Modo Claro'),
                      value: ThemeMode.light,
                      groupValue: themeController.themeMode,
                      onChanged: (ThemeMode? valor) {
                        if (valor != null) themeController.mudarTema(valor);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Modo Escuro'),
                      value: ThemeMode.dark,
                      groupValue: themeController.themeMode,
                      onChanged: (ThemeMode? valor) {
                        if (valor != null) themeController.mudarTema(valor);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
