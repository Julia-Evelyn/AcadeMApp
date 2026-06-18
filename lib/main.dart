import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

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
import 'features/auth/view/splash_view.dart';
import 'features/auth/view/auth_selection_view.dart';
import 'features/auth/view/profile_setup_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final preferencesStore = await SharedPreferencesStore.create();

    await FirebaseBootstrapService().initialize(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Firebase.initializeApp();
  
    final dbService = FirebaseDatabaseService();
    final preferencesService = AppPreferencesService(
      preferencesStore,
      dbService,
    );

    final bool usaFonteDislexia = await preferencesService.loadUsarFonteDislexia();

    final themeController = ThemeController(
      preferencesService: preferencesService,
      initialThemeMode: await preferencesService.loadThemeMode(),
      initialAccentColor: Color(await preferencesService.loadAccentColorValue()),
      initialUsarFonteDislexia: usaFonteDislexia, // INJETANDO NO CONTROLLER
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => TreinoProvider(dbService),
          ),
        ],
        child: MyApp(
          themeController: themeController,
          preferencesService: preferencesService,
          profileImagePickerService: DeviceProfileImagePickerService(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Erro fatal: $e')))));
    debugPrint('ERRO FATAL DETECTADO: $e');
    debugPrint('$stackTrace');
  }
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
          
          theme: AppTheme.getLightTheme(
            themeController.corDestaque, 
            usarFonteDislexia: themeController.usarFonteDislexia,
          ),
          darkTheme: AppTheme.getDarkTheme(
            themeController.corDestaque, 
            usarFonteDislexia: themeController.usarFonteDislexia,
          ),
          themeMode: themeController.themeMode,
          
          home: const SplashView(),
          
          routes: {
            '/auth_selection': (context) => const AuthSelectionView(),
            '/profile_setup': (context) => const ProfileSetupView(isGuest: true),
            '/home': (context) => MainLayout(
                  preferencesService: preferencesService,
                  profileImagePickerService: profileImagePickerService,
                ),
            '/configuracoes': (context) => ConfiguracoesView(themeController: themeController),
            '/historico_treinos': (context) => const HistoricoView(),
          },
        );
      },
    );
  }
}