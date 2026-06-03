import '../../../core/services/preferences/app_preferences_service.dart';

class ConfiguracoesController {
  ConfiguracoesController({required AppPreferencesService preferencesService})
    : _preferencesService = preferencesService;

  final AppPreferencesService _preferencesService;

  Future<void> salvarTempoAlerta(int minutos) async {
    await _preferencesService.saveAlertMinutes(minutos);
  }

  Future<int> lerTempoAlerta() async {
    return _preferencesService.loadAlertMinutes();
  }
}
