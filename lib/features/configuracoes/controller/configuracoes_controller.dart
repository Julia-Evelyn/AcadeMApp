import 'package:shared_preferences/shared_preferences.dart';

    class ConfiguracoesController {
      // Salva o tempo no celular
      Future<void> salvarTempoAlerta(int minutos) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('tempo_alerta', minutos);
      }

      // Lê o tempo salvo (ou retorna 45 min como padrão)
      Future<int> lerTempoAlerta() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getInt('tempo_alerta') ?? 45; 
      }
    }