import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/view/login_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  User? _usuarioAtual;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _usuarioAtual = user;
        });
      }
    });
  }

  Future<void> _deslogar() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;

    final bool isLoggedIn = _usuarioAtual != null;

    return Scaffold(
      backgroundColor: isDark
          ? tema.colorScheme.surface
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Meu Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: corDestaque.withValues(alpha: 0.1),
                      border: Border.all(color: corDestaque, width: 4),
                    ),
                    child: Icon(Icons.person, size: 70, color: corDestaque),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abrindo câmera... 📸')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: corDestaque,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? tema.colorScheme.surface
                                : const Color(0xFFF4F6F9),
                            width: 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isLoggedIn ? 'Atleta PRO' : 'Visitante',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isLoggedIn
                  ? _usuarioAtual!.email!
                  : 'Seus dados estão salvos apenas neste aparelho.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 40),

            if (!isLoggedIn)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [corDestaque, corDestaque.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: corDestaque.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_sync, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Sincronize na Nuvem',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Crie uma conta para salvar suas corridas, treinos e não perder o progresso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: corDestaque,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Entrar / Cadastrar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (isLoggedIn)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _construirColunaEstatistica('Corridas', '0', isDark),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  _construirColunaEstatistica('Distância', '0 km', isDark),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  _construirColunaEstatistica('Dias', '0', isDark),
                ],
              ),

            const SizedBox(height: 30),

            _construirOpcaoMenu(
              context,
              Icons.history,
              'Histórico de Corridas',
              isDark,
              onTap: () {},
            ),
            _construirOpcaoMenu(
              context,
              Icons.settings,
              'Configurações',
              isDark,
              onTap: () {},
            ),
            if (isLoggedIn)
              _construirOpcaoMenu(
                context,
                Icons.logout,
                'Sair da Conta',
                isDark,
                isDestructive: true,
                onTap: _deslogar,
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirColunaEstatistica(String titulo, String valor, bool isDark) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(titulo, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _construirOpcaoMenu(
    BuildContext context,
    IconData icone,
    String titulo,
    bool isDark, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final corItem = isDestructive
        ? Colors.redAccent
        : (isDark ? Colors.white : Colors.black87);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: corItem.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icone, color: corItem, size: 24),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: corItem,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
