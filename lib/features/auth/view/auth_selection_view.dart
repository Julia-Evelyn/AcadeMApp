import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academyapp/features/auth/view/login_view.dart';
import 'profile_setup_view.dart';

class AuthSelectionView extends StatelessWidget {
  const AuthSelectionView({super.key});

  Future<void> _limparCacheLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_display_name');
    await prefs.remove('profile_weight');
    await prefs.remove('profile_height');
    await prefs.remove('is_guest_active');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(Icons.fitness_center, size: 80, color: corDestaque),
              const SizedBox(height: 32),
              Text(
                'Bem-vindo ao\nAcadeMApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Acompanhe seus treinos, supere o sedentarismo e atinja seus objetivos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),

            
              ElevatedButton(
                onPressed: () async {
                  await _limparCacheLocal();
                  
                  if (!context.mounted) return;
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: corDestaque,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('ENTRAR OU CADASTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 16),

              // Botão Visitante
              OutlinedButton(
                onPressed: () async {
                  await _limparCacheLocal(); 

                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileSetupView(isGuest: true)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: corDestaque, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('CONTINUAR COMO VISITANTE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: corDestaque)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}