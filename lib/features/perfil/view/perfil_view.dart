import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/perfil_controller.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key, required this.controller});

  final PerfilController controller;

  Future<void> _mostrarOpcoesDeImagem(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Nova Foto'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pegarImagem(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pegarImagem(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvarPerfil(BuildContext context) async {
    await controller.salvarPerfil();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final margemLateral = constraints.maxWidth > 600 ? 100.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: margemLateral,
                vertical: 30,
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        backgroundImage: controller.imagemDoPerfil != null
                            ? FileImage(controller.imagemDoPerfil!)
                            : null,
                        child: controller.imagemDoPerfil == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: controller.estaEditando
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                        child: IconButton(
                          icon: Icon(
                            controller.estaEditando
                                ? Icons.camera_alt
                                : Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (!controller.estaEditando) {
                              controller.iniciarEdicao();
                            } else {
                              _mostrarOpcoesDeImagem(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (controller.estaEditando) ...[
                    TextFormField(
                      controller: controller.nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: controller.sobrenomeController,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.pesoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Peso (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: controller.alturaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Altura (cm)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.height),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _salvarPerfil(context),
                        child: const Text(
                          'Salvar Alteracoes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildCardLeitura(
                      context: context,
                      titulo: 'Nome Completo',
                      valor: controller.nomeCompleto,
                      icone: Icons.badge,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardLeitura(
                            context: context,
                            titulo: 'Peso Atual',
                            valor: controller.pesoFormatado,
                            icone: Icons.monitor_weight,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildCardLeitura(
                            context: context,
                            titulo: 'Altura',
                            valor: controller.alturaFormatada,
                            icone: Icons.height,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardLeitura({
    required BuildContext context,
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    final valorFinal = valor.isEmpty ? 'Nao informado' : valor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(
            context,
          ).primaryColor.withValues(alpha: isDark ? 0.3 : 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icone,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valorFinal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
