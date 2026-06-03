import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/layout/main_layout.dart';
import 'core/services/firebase/firebase_bootstrap_service.dart';
import 'core/services/firebase_database_service.dart';
import 'core/services/media/profile_image_picker_service.dart';
import 'core/services/preferences/app_preferences_service.dart';
import 'core/services/preferences/key_value_store.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/configuracoes/view/configuracoes_view.dart';
import 'features/historico_treinos/view/historico_treinos_view.dart';
import 'features/treinos/controller/treino_provider.dart';  
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesStore = await SharedPreferencesStore.create();
  final preferencesService = AppPreferencesService(preferencesStore);

  await FirebaseBootstrapService().initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeController = ThemeController(
    preferencesService: preferencesService,
    initialThemeMode: await preferencesService.loadThemeMode(),
    initialAccentColor: Color(await preferencesService.loadAccentColorValue()),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TreinoProvider(FirebaseDatabaseService()),
        ),
      ],
      child: MyApp(
        themeController: themeController,
        preferencesService: preferencesService,
        profileImagePickerService: DeviceProfileImagePickerService(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeController,
    required this.preferencesService,
    required this.profileImagePickerService,
  });

  final ThemeController themeController;
  final AppPreferencesService preferencesService;
  final ProfileImagePickerService profileImagePickerService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AcadeMApp',
          theme: AppTheme.getLightTheme(themeController.corDestaque),
          darkTheme: AppTheme.getDarkTheme(themeController.corDestaque),
          themeMode: themeController.themeMode,
          initialRoute: '/home',
          routes: {
            '/home': (context) => MainLayout(
                  preferencesService: preferencesService,
                  profileImagePickerService: profileImagePickerService,
                ),
            '/configuracoes': (context) =>
                ConfiguracoesView(themeController: themeController),
            '/historico_treinos': (context) => const HistoricoView(),
          },
        );
      },
    );
  }
}