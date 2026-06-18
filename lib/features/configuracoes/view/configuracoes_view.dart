// ignore_for_file: deprecated_member_use

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
          final double margemLateral = constraints.maxWidth > 600 ? 100 : 20;

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: margemLateral, vertical: 20),
            children: [
              // --- SEÇÃO DE ACESSIBILIDADE ---
              const Text('Acessibilidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text('Fonte para Dislexia'),
                  subtitle: const Text('Altera as letras do app para facilitar a leitura.'),
                  activeThumbColor: themeController.corDestaque,
                  value: themeController.usarFonteDislexia,
                  onChanged: (bool valor) {
                    themeController.alternarFonteDislexia(valor);
                  },
                ),
              ),
              const SizedBox(height: 30),

              const Text('Tema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 30),

              const Text('Cor de Destaque', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personalize a cor principal do aplicativo:'),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: ThemeController.coresDisponiveis.length,
                          separatorBuilder: (context, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final cor = ThemeController.coresDisponiveis[index];
                            final selecionada = cor.toARGB32() == themeController.corDestaque.toARGB32();

                            return GestureDetector(
                              onTap: () => themeController.mudarCor(cor),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: cor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selecionada ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                                    width: selecionada ? 3 : 0,
                                  ),
                                  boxShadow: [
                                    if (selecionada) BoxShadow(color: cor.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2),
                                  ],
                                ),
                                child: selecionada ? const Icon(Icons.check, color: Colors.white) : null,
                              ),
                            );
                          },
                        ),
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