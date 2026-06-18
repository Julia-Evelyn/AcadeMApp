import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    _realizarVerificacaoDeFluxo();
  }

  Future<void> _realizarVerificacaoDeFluxo() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (!mounted) return; 

    final usuarioLogado = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final eVisitanteAtivo = prefs.getBool('is_guest_active') ?? false;

    if (!mounted) return;

    if (usuarioLogado != null || eVisitanteAtivo) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth_selection');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final corDestaque = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: corDestaque.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.directions_run_rounded, size: 100, color: corDestaque),
              ),
              const SizedBox(height: 24),
              Text(
                'AcadeMApp',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text('O seu parceiro de treino', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}