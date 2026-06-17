import 'package:academyapp/features/auth/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/perfil_controller.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key, required this.controller});

  final PerfilController controller;

  void _mostrarOpcoesDeImagem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  'Foto de Perfil',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text(
                    'Tirar nova foto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pegarImagem(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.purple,
                    ),
                  ),
                  title: const Text(
                    'Escolher da galeria',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pegarImagem(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final bool isLoggedIn = controller.usuarioAtual != null;

        return Scaffold(
          backgroundColor: isDark
              ? tema.colorScheme.surface
              : const Color(0xFFF4F6F9),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Semantics(
                label: controller.estaEditando
                    ? 'Salvar perfil'
                    : 'Editar perfil',
                button: true,
                child: IconButton(
                  tooltip: controller.estaEditando ? 'Salvar' : 'Editar',
                  icon: Icon(
                    controller.estaEditando ? Icons.check : Icons.edit,
                    color: corDestaque,
                  ),
                  onPressed: () {
                    if (controller.estaEditando) {
                      controller.salvarPerfil();
                    } else {
                      controller.iniciarEdicao();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Semantics(
                        image: true,
                        label: 'Foto de Perfil',
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: corDestaque.withValues(alpha: 0.1),
                            border: Border.all(color: corDestaque, width: 4),
                            image: controller.imagemDoPerfil != null
                                ? DecorationImage(
                                    image: FileImage(
                                      controller.imagemDoPerfil!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.imagemDoPerfil == null
                              ? Icon(Icons.person, size: 70, color: corDestaque)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Semantics(
                          button: true,
                          label: 'Alterar foto de perfil',
                          child: GestureDetector(
                            onTap: () => _mostrarOpcoesDeImagem(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: corDestaque,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? tema.colorScheme.surface
                                      : const Color(0xFFF4F6F9),
                                  width: 4,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (controller.estaEditando) ...[
                  _construirCampoTexto(
                    context,
                    'Nome',
                    controller.nomeController,
                  ),
                  _construirCampoTexto(
                    context,
                    'Sobrenome',
                    controller.sobrenomeController,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _construirCampoTexto(
                          context,
                          'Peso (kg)',
                          controller.pesoController,
                          isNumeric: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _construirCampoTexto(
                          context,
                          'Altura (cm)',
                          controller.alturaController,
                          isNumeric: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: controller.salvarPerfil,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Alterações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corDestaque,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ] else ...[
                  Text(
                    controller.nomeCompleto,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn
                        ? controller.usuarioAtual!.email!
                        : 'Seus dados estão salvos apenas neste aparelho.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (controller.pesoFormatado.isNotEmpty ||
                      controller.alturaFormatada.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (controller.pesoFormatado.isNotEmpty)
                          _construirChipInfo(
                            context,
                            Icons.scale,
                            controller.pesoFormatado,
                            'Peso atual',
                          ),
                        if (controller.alturaFormatada.isNotEmpty)
                          _construirChipInfo(
                            context,
                            Icons.height,
                            controller.alturaFormatada,
                            'Altura atual',
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 40),
                ],

                if (!isLoggedIn && !controller.estaEditando)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          corDestaque,
                          corDestaque.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: corDestaque.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_sync,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sincronize na Nuvem',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Crie uma conta para salvar suas corridas, treinos e não perder o progresso.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: corDestaque,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Entrar / Cadastrar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (isLoggedIn && !controller.estaEditando) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _construirColunaEstatistica('Corridas', '0', isDark),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      _construirColunaEstatistica('Distância', '0 km', isDark),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      _construirColunaEstatistica('Dias', '0', isDark),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],

                if (!controller.estaEditando) ...[
                  _construirOpcaoMenu(
                    context,
                    Icons.history,
                    'Histórico de Corridas',
                    isDark,
                    onTap: () {},
                  ),
                  _construirOpcaoMenu(
                    context,
                    Icons.settings,
                    'Configurações',
                    isDark,
                    onTap: () => Navigator.pushNamed(context, '/configuracoes'),
                  ),
                  if (isLoggedIn)
                    _construirOpcaoMenu(
                      context,
                      Icons.logout,
                      'Sair da Conta',
                      isDark,
                      isDestructive: true,
                      onTap: controller.deslogar,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construirCampoTexto(
    BuildContext context,
    String label,
    TextEditingController textController, {
    bool isNumeric = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Semantics(
        textField: true,
        label: 'Campo de texto para digitar $label',
        child: TextField(
          controller: textController,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.name,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: isDark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirChipInfo(
    BuildContext context,
    IconData icone,
    String valor,
    String labelSemantica,
  ) {
    final corDestaque = Theme.of(context).colorScheme.primary;
    return MergeSemantics(
      child: Semantics(
        label: '$labelSemantica: $valor',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: corDestaque.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 16, color: corDestaque),
              const SizedBox(width: 6),
              Text(
                valor,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: corDestaque,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirColunaEstatistica(String titulo, String valor, bool isDark) {
    return MergeSemantics(
      child: Semantics(
        label: '$valor $titulo',
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              titulo,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirOpcaoMenu(
    BuildContext context,
    IconData icone,
    String titulo,
    bool isDark, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final corItem = isDestructive
        ? Colors.redAccent
        : (isDark ? Colors.white : Colors.black87);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: corItem.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExcludeSemantics(child: Icon(icone, color: corItem, size: 24)),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: corItem,
            fontSize: 16,
          ),
        ),
        trailing: ExcludeSemantics(
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
