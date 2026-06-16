import 'package:flutter/material.dart';
import '../controller/login_controller.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Instancia o controller puro
  final LoginController _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose(); // Limpa a memória quando sair da tela
    super.dispose();
  }

  // Função que faz a ponte entre o botão e o Controller
  Future<void> _lidarComAutenticacao() async {
    final erro = await _controller.autenticar();

    if (!mounted) return;

    if (erro != null) {
      // Deu erro: mostra o alerta vermelho
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.redAccent),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final corDestaque = tema.colorScheme.primary;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: isDark ? tema.colorScheme.surface : const Color(0xFFF4F6F9),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.fitness_center, size: 80, color: corDestaque),
                    const SizedBox(height: 24),
                    
                    Text(
                      _controller.isLogin ? 'Bem-vindo de volta!' : 'Comece sua jornada',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87, letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.isLogin ? 'Entre para continuar seu treino' : 'Crie uma conta para salvar seu progresso',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 48),

                    // CAMPO EMAIL
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? tema.colorScheme.surfaceContainerHighest : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: TextField(
                        controller: _controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: corDestaque),
                          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CAMPO SENHA
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? tema.colorScheme.surfaceContainerHighest : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: TextField(
                        controller: _controller.senhaController,
                        obscureText: _controller.senhaOculta,
                        decoration: InputDecoration(
                          hintText: 'Senha', prefixIcon: Icon(Icons.lock_outline, color: corDestaque),
                          suffixIcon: IconButton(
                            icon: Icon(_controller.senhaOculta ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: _controller.alternarVisibilidadeSenha,
                          ),
                          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_controller.isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {}, child: Text('Esqueceu a senha?', style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold))),
                      ),
                    
                    SizedBox(height: _controller.isLogin ? 24 : 40),

                    // Botão de login
                    ElevatedButton(
                      onPressed: _controller.carregando ? null : _lidarComAutenticacao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corDestaque, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5, shadowColor: corDestaque.withValues(alpha: 0.5),
                      ),
                      child: _controller.carregando 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _controller.isLogin ? 'ENTRAR' : 'CRIAR CONTA',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_controller.isLogin ? 'Não tem uma conta?' : 'Já tem uma conta?', style: TextStyle(color: Colors.grey[600])),
                        TextButton(
                          onPressed: _controller.carregando ? null : _controller.alternarModo,
                          child: Text(_controller.isLogin ? 'Cadastre-se' : 'Faça login', style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}