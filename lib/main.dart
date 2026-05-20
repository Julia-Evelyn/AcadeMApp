import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/configuracoes/view/configuracoes_view.dart';

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
            '/home': (context) => Scaffold(
              appBar: AppBar(title: const Text('Dashboard')),
              body: Center(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/configuracoes'),
                  icon: const Icon(Icons.settings),
                  label: const Text('Ir para Configurações'),
                ),
              ),
            ),

            '/configuracoes': (context) =>
                ConfiguracoesView(themeController: themeController),
          },
        );
      },
    );
  }
}
