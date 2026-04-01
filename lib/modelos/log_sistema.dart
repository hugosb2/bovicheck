import 'package:uuid/uuid.dart';

class LogSistema {
  final String id;
  final String acao;
  final DateTime dataHora;
  final String modulo;
  final String? detalhes;

  LogSistema({
    String? id,
    required this.acao,
    this.modulo = 'Sistema',
    this.detalhes,
    DateTime? dataHora,
  }) : id = id ?? const Uuid().v4(),
       dataHora = dataHora ?? DateTime.now();

  // --- Método do Diagrama de Classes ---

  /// Exporta o log como um Map (representação de backup).
  Map<String, dynamic> exportarBackup() => toMap();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'acao': acao,
      'dataHora': dataHora.toIso8601String(),
      'modulo': modulo,
      'detalhes': detalhes,
    };
  }

  factory LogSistema.fromMap(Map<String, dynamic> map) {
    return LogSistema(
      id: map['id'],
      acao: map['acao'] ?? '',
      dataHora: DateTime.parse(map['dataHora']),
      modulo: map['modulo'] ?? 'Sistema',
      detalhes: map['detalhes'],
    );
  }
}

