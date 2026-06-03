import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool isLogin = true;
  bool senhaOculta = true;
  bool carregando = false;

  void alternarModo() {
    isLogin = !isLogin;
    notifyListeners();
  }

  void alternarVisibilidadeSenha() {
    senhaOculta = !senhaOculta;
    notifyListeners();
  }

  // Mostra mensagem de erro
  Future<String?> autenticar() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      return 'Por favor, preencha o email e a senha.';
    }

    carregando = true;
    notifyListeners(); // Mostra a rodinha de carregamento

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: senha);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: senha);
      }
      
      carregando = false;
      notifyListeners();
      return null; 
      
    } on FirebaseAuthException catch (e) {
      carregando = false;
      notifyListeners();
      
      // Traduz os erros do Firebase para português
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Email ou senha incorretos.';
      } else if (e.code == 'email-already-in-use') {
        return 'Este email já está cadastrado.';
      } else if (e.code == 'weak-password') {
        return 'A senha é muito fraca (mínimo de 6 caracteres).';
      }
      return 'Erro Firebase (${e.code}): ${e.message}';
    } catch (e) {
      carregando = false;
      notifyListeners();
      return 'Erro inesperado: $e';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}