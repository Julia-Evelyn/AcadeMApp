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

  late final PageController _pageController;
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

    _pageController = PageController(initialPage: _indiceAtual);

    _homeController = HomeController(
      preferencesService: widget.preferencesService,
      alarmAudioService: AudioplayersAlarmAudioService(),
    );

    _perfilController = PerfilController(widget.preferencesService);

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
    _pageController.dispose();
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
          Semantics(
            label: 'Abrir configurações do aplicativo',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Configurações',
              onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (indice) {
          if (indice == 0) {
            _homeController.carregarNomeUsuario();
          }
          setState(() {
            _indiceAtual = indice;
          });
        },
        children: _telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: (indice) {
          _pageController.jumpToPage(indice);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Ir para a página inicial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treinos',
            tooltip: 'Ver meus treinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
            tooltip: 'Explorar novos treinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Corrida',
            tooltip: 'Iniciar monitoramento de corrida',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
            tooltip: 'Ver meu perfil',
          ),
        ],
      ),
    );
  }
}
