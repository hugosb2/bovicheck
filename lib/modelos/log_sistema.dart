import 'package:uuid/uuid.dart';

class LogSistema {
  final String id;
  final String acao; // Ex: 'Criou Animal', 'Exportou PDF'
  final String? detalhe;
  final DateTime dataHora;

  LogSistema({String? id, required this.acao, this.detalhe, DateTime? dataHora})
    : id = id ?? const Uuid().v4(),
      dataHora = dataHora ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'acao': acao,
      'detalhe': detalhe,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory LogSistema.fromMap(Map<String, dynamic> map) {
    return LogSistema(
      id: map['id'],
      acao: map['acao'] ?? '',
      detalhe: map['detalhe'],
      dataHora: DateTime.parse(map['dataHora']),
    );
  }
}
