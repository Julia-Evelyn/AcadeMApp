import 'package:academyapp/features/treinos/view/busca_treinos_view.dart';
import 'package:flutter/material.dart';

import '../../features/corrida/view/corrida_view.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/home/view/home_view.dart';
import '../../features/perfil/controller/perfil_controller.dart';
import '../../features/perfil/view/perfil_view.dart';
import '../../features/treinos/view/treinos_view.dart';

import '../services/audio/alarm_audio_service.dart';
import '../services/media/profile_image_picker_service.dart';
import '../services/preferences/app_preferences_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.preferencesService,
    required this.profileImagePickerService,
  });

  final AppPreferencesService preferencesService;
  final ProfileImagePickerService profileImagePickerService;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _indiceAtual = 0;
  late final HomeController _homeController;
  late final PerfilController _perfilController;

  late final List<Widget> _telas;

  final List<String> _titulos = [
    'Home',
    'Meus Treinos',
    'Explorar Treinos', 
    'Corrida',
    'Meu Perfil',
  ];

  @override
  void initState() {
    super.initState();
    _homeController = HomeController(
      preferencesService: widget.preferencesService,
      alarmAudioService: AudioplayersAlarmAudioService(),
    );
    _perfilController = PerfilController(
      preferencesService: widget.preferencesService,
      imagePickerService: widget.profileImagePickerService,
    );
    
    _telas = [
      HomeView(controller: _homeController),
      const TreinosView(),
      const BuscaTreinosView(), 
      const CorridaView(),
      PerfilView(controller: _perfilController),
    ];
  }

  @override
  void dispose() {
    _homeController.dispose();
    _perfilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indiceAtual]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
          ),
        ],
      ),
      body: IndexedStack(index: _indiceAtual, children: _telas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: (indice) {
          if (indice == 0) {
            _homeController.carregarNomeUsuario();
          }

          setState(() {
            _indiceAtual = indice;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Corrida',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}