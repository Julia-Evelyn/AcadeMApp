import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  bool _estaEditando = false;

  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();

  File? _imagemDoPerfil;
  final _picker = ImagePicker();

  static const _chaveNome = 'perfil_nome';
  static const _chaveSobrenome = 'perfil_sobrenome';
  static const _chavePeso = 'perfil_peso';
  static const _chaveAltura = 'perfil_altura';
  static const _chaveCaminhoImagem = 'perfil_imagem_caminho';

  @override
  void initState() {
    super.initState();
    _carregarDadosSalvos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  // Lógica da fotinha de perfil
  Future<void> _pegarImagem(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagemDoPerfil = File(pickedFile.path);
      });
    }
  }

  void _mostrarOpcoesDeImagem() {
    showModalBottomSheet(
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
                  _pegarImagem(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pegarImagem(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Lógica do SharedPreferences (salvar local)
  Future<void> _carregarDadosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    _nomeController.text = prefs.getString(_chaveNome) ?? '';
    _sobrenomeController.text = prefs.getString(_chaveSobrenome) ?? '';
    _pesoController.text = prefs.getString(_chavePeso) ?? '';
    _alturaController.text = prefs.getString(_chaveAltura) ?? '';

    final caminhoImagem = prefs.getString(_chaveCaminhoImagem);
    if (caminhoImagem != null) {
      setState(() {
        _imagemDoPerfil = File(caminhoImagem);
      });
    }
  }

  Future<void> _salvarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveNome, _nomeController.text);
    await prefs.setString(_chaveSobrenome, _sobrenomeController.text);
    await prefs.setString(_chavePeso, _pesoController.text);
    await prefs.setString(_chaveAltura, _alturaController.text);

    if (_imagemDoPerfil != null) {
      await prefs.setString(_chaveCaminhoImagem, _imagemDoPerfil!.path);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );

      setState(() {
        _estaEditando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double margemLateral = constraints.maxWidth > 600 ? 100 : 20;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: margemLateral,
            vertical: 30,
          ),
          child: Column(
            children: [
              // Foto de perfil
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    backgroundImage: _imagemDoPerfil != null
                        ? FileImage(_imagemDoPerfil!)
                        : null,
                    child: _imagemDoPerfil == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _estaEditando
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      icon: Icon(
                        _estaEditando ? Icons.camera_alt : Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (!_estaEditando) {
                          setState(() {
                            _estaEditando = true;
                          });
                        } else {
                          _mostrarOpcoesDeImagem();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Tela de Perfil - Modo leitura e edição
              if (_estaEditando) ...[
                // Modo Edição
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _sobrenomeController,
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
                        controller: _pesoController,
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
                        controller: _alturaController,
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
                    onPressed: _salvarPerfil,
                    child: const Text(
                      'Salvar Alterações',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ] else ...[
                
                // Modo Leitura
                _buildCardLeitura(
                  titulo: 'Nome Completo',
                  // Junta o nome e o sobrenome, se tiver vazio mostra que não foi informado
                  valor: '${_nomeController.text} ${_sobrenomeController.text}'
                      .trim(),
                  icone: Icons.badge,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildCardLeitura(
                        titulo: 'Peso Atual',
                        valor: _pesoController.text.isNotEmpty
                            ? '${_pesoController.text} kg'
                            : '',
                        icone: Icons.monitor_weight,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildCardLeitura(
                        titulo: 'Altura',
                        valor: _alturaController.text.isNotEmpty
                            ? '${_alturaController.text} cm'
                            : '',
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
  }

  // Widget pro modo leitura
  Widget _buildCardLeitura({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    final valorFinal = valor.isEmpty ? 'Não informado' : valor;

    // Descobre se o modo escuro está ativado para ajustar a transparência da borda
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
