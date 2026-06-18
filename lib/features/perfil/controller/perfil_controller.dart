import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/preferences/app_preferences_service.dart';
import '../model/perfil_data.dart';

class PerfilController extends ChangeNotifier {
  PerfilController(this._preferencesService) {
    carregarPerfil();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      if (user != null) {
        await _preferencesService.forcarSincronizacao(user);
        await carregarPerfil();
      }
    });
  }

  final AppPreferencesService _preferencesService;
  late StreamSubscription<User?> _authSubscription;

  User? get usuarioAtual => FirebaseAuth.instance.currentUser;

  bool estaEditando = false;
  File? imagemDoPerfil;
  String? _caminhoImagemLocal;

  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();

  String get nomeCompleto {
    final nome = nomeController.text.trim();
    final sobrenome = sobrenomeController.text.trim();
    if (nome.isEmpty && sobrenome.isEmpty) return 'Atleta';
    return '$nome $sobrenome'.trim();
  }

  String get pesoFormatado {
    final peso = pesoController.text.trim();
    if (peso.isEmpty) return '';
    return '$peso kg';
  }

  String get alturaFormatada {
    final altura = alturaController.text.trim();
    if (altura.isEmpty) return '';
    return '$altura cm';
  }

  Future<void> carregarPerfil() async {
    final perfil = await _preferencesService.loadPerfilData();

    nomeController.text = perfil.nome;
    sobrenomeController.text = perfil.sobrenome;
    pesoController.text = perfil.peso;
    alturaController.text = perfil.altura;
    _caminhoImagemLocal = perfil.caminhoImagem;

    if (_caminhoImagemLocal != null && _caminhoImagemLocal!.isNotEmpty) {
      final file = File(_caminhoImagemLocal!);
      if (await file.exists()) {
        imagemDoPerfil = file;
      } else {
        imagemDoPerfil = null;
      }
    }
    notifyListeners();
  }

  void iniciarEdicao() {
    estaEditando = true;
    notifyListeners();
  }

  Future<void> salvarPerfil() async {
    estaEditando = false;
    notifyListeners();

    final perfil = PerfilData(
      nome: nomeController.text.trim(),
      sobrenome: sobrenomeController.text.trim(),
      peso: pesoController.text.trim(),
      altura: alturaController.text.trim(),
      caminhoImagem: _caminhoImagemLocal,
    );

    await _preferencesService.savePerfilData(perfil);
    notifyListeners();
  }

  Future<void> pegarImagem(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Copia a imagem da pasta temporária para a pasta de documentos permanente do app
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'foto_perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');

      // Remove a foto antiga se existir para não ocupar espaço desnecessário
      if (_caminhoImagemLocal != null) {
        final oldFile = File(_caminhoImagemLocal!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      imagemDoPerfil = savedImage;
      _caminhoImagemLocal = savedImage.path;

      if (!estaEditando) {
        await salvarPerfil();
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> deslogar() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    nomeController.dispose();
    sobrenomeController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    super.dispose();
  }
}
