import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/media/profile_image_picker_service.dart';
import '../../../core/services/preferences/app_preferences_service.dart';
import '../model/perfil_data.dart';

class PerfilController extends ChangeNotifier {
  PerfilController({
    required AppPreferencesService preferencesService,
    required ProfileImagePickerService imagePickerService,
  }) : _preferencesService = preferencesService,
       _imagePickerService = imagePickerService {
    carregarDadosSalvos();
  }

  final AppPreferencesService _preferencesService;
  final ProfileImagePickerService _imagePickerService;

  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();

  bool estaEditando = false;
  File? imagemDoPerfil;

  Future<void> carregarDadosSalvos() async {
    final perfil = await _preferencesService.loadPerfilData();
    nomeController.text = perfil.nome;
    sobrenomeController.text = perfil.sobrenome;
    pesoController.text = perfil.peso;
    alturaController.text = perfil.altura;

    if (perfil.caminhoImagem != null && perfil.caminhoImagem!.isNotEmpty) {
      imagemDoPerfil = File(perfil.caminhoImagem!);
    }

    notifyListeners();
  }

  void iniciarEdicao() {
    estaEditando = true;
    notifyListeners();
  }

  Future<void> pegarImagem(ImageSource source) async {
    final imagem = await _imagePickerService.pickImage(source);
    if (imagem == null) {
      return;
    }

    imagemDoPerfil = imagem;
    notifyListeners();
  }

  Future<void> salvarPerfil() async {
    await _preferencesService.savePerfilData(
      PerfilData(
        nome: nomeController.text,
        sobrenome: sobrenomeController.text,
        peso: pesoController.text,
        altura: alturaController.text,
        caminhoImagem: imagemDoPerfil?.path,
      ),
    );

    estaEditando = false;
    notifyListeners();
  }

  String get nomeCompleto {
    return '${nomeController.text} ${sobrenomeController.text}'.trim();
  }

  String get pesoFormatado {
    return pesoController.text.isNotEmpty ? '${pesoController.text} kg' : '';
  }

  String get alturaFormatada {
    return alturaController.text.isNotEmpty
        ? '${alturaController.text} cm'
        : '';
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    super.dispose();
  }
}
