import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/configuracoes/view/configuracoes_view.dart';
import 'features/historico_treinos/view/historico_treinos_view.dart';
import 'core/layout/main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AcadeMApp',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,

          initialRoute: '/home',
          routes: {
            '/home': (context) => const MainLayout(), 
            '/configuracoes': (context) =>
                ConfiguracoesView(themeController: themeController),
            '/historico_treinos': (context) => const HistoricoView(),
          },
        );
      },
    );
  }
}
