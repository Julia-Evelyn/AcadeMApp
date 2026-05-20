class AtividadeModel {
  final int? id;
  final double distanciaKm;
  final DateTime dataHora;

  AtividadeModel({this.id, required this.distanciaKm, required this.dataHora});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'distancia_km': distanciaKm,
      'data_hora': dataHora.toIso8601String(),
    };
  }

  factory AtividadeModel.fromMap(Map<String, dynamic> map) {
    return AtividadeModel(
      id: map['id'],
      distanciaKm: map['distancia_km'],
      dataHora: DateTime.parse(map['data_hora']),
    );
  }
}
