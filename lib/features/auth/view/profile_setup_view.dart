import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupView extends StatefulWidget {
  final bool isGuest;

  const ProfileSetupView({super.key, this.isGuest = false});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final _nomeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();

  Future<void> _finalizarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.isGuest) {
      await prefs.setBool('is_guest_active', true);
      // Se não digitar nada, salva como "Visitante"
      final nomeSalvo = _nomeController.text.isNotEmpty
          ? _nomeController.text
          : 'Visitante';
      await prefs.setString('profile_display_name', nomeSalvo);
    }

    if (_pesoController.text.isNotEmpty) {
      await prefs.setString('profile_weight', _pesoController.text);
    } else {
      await prefs.remove('profile_weight');
    }

    if (_alturaController.text.isNotEmpty) {
      await prefs.setString('profile_height', _alturaController.text);
    } else {
      await prefs.remove('profile_height');
    }

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corDestaque = tema.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: tema.textTheme.bodyLarge?.color),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Só mais um\npouco...',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: tema.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Precisamos de algumas informações para personalizar sua experiência.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              if (widget.isGuest) ...[
                _buildCustomTextField(
                  controller: _nomeController,
                  label: 'Nome Completo',
                  icon: Icons.person_outline,
                  context: context,
                ),
                const SizedBox(height: 24),
              ],

              Row(
                children: [
                  Expanded(
                    child: _buildCustomTextField(
                      controller: _pesoController,
                      label: 'Peso (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCustomTextField(
                      controller: _alturaController,
                      label: 'Altura (cm)',
                      icon: Icons.height,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      context: context,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finalizarConfiguracao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corDestaque,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'COMEÇAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required BuildContext context,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
