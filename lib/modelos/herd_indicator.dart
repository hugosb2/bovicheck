class IndicadorRebanho {
  final String id;
  final String chaveIndicador; // birthRate, averageCalvingInterval, etc
  final String tituloIndicador; // Taxa de Natalidade, etc
  final String unidadeIndicador; // %, dias, etc
  final bool aplicarAoLote;
  final bool aplicarNaPropriedade;
  final DateTime criadoEm;

  IndicadorRebanho({
    required this.id,
    required this.chaveIndicador,
    required this.tituloIndicador,
    required this.unidadeIndicador,
    this.aplicarAoLote = false,
    this.aplicarNaPropriedade = false,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'indicatorKey': chaveIndicador,
        'indicatorTitle': tituloIndicador,
        'indicatorUnit': unidadeIndicador,
        'applyToLote': aplicarAoLote ? 1 : 0,
        'applyToProperty': aplicarNaPropriedade ? 1 : 0,
        'createdAt': criadoEm.toIso8601String(),
      };

  factory IndicadorRebanho.fromMap(Map<String, dynamic> map) =>
      IndicadorRebanho(
        id: map['id'],
        chaveIndicador: map['indicatorKey'],
        tituloIndicador: map['indicatorTitle'],
        unidadeIndicador: map['indicatorUnit'],
        aplicarAoLote:
            (map['applyToLote'] ?? map['applyToPastureArea'] ?? 0) == 1,
        aplicarNaPropriedade: map['applyToProperty'] == 1,
        criadoEm: DateTime.parse(map['createdAt']),
      );

  Map<String, dynamic> toJson() => toMap();

  factory IndicadorRebanho.fromJson(Map<String, dynamic> json) =>
      IndicadorRebanho.fromMap(json);

  // Compatibilidade com nomes antigos
  String get indicatorKey => chaveIndicador;
  String get indicatorTitle => tituloIndicador;
  String get indicatorUnit => unidadeIndicador;
  bool get applyToLote => aplicarAoLote;
  bool get applyToProperty => aplicarNaPropriedade;
  DateTime get createdAt => criadoEm;
}

class HerdIndicator extends IndicadorRebanho {
  HerdIndicator(
      {required super.id,
      required String indicatorKey,
      required String indicatorTitle,
      required String indicatorUnit,
      bool applyToLote = false,
      bool applyToProperty = false,
      required DateTime createdAt})
      : super(
            chaveIndicador: indicatorKey,
            tituloIndicador: indicatorTitle,
            unidadeIndicador: indicatorUnit,
            aplicarAoLote: applyToLote,
            aplicarNaPropriedade: applyToProperty,
            criadoEm: createdAt);
  // Compatibilidade: factories
  factory HerdIndicator.fromMap(Map<String, dynamic> map) {
    final i = IndicadorRebanho.fromMap(map);
    return HerdIndicator(
      id: i.id,
      indicatorKey: i.chaveIndicador,
      indicatorTitle: i.tituloIndicador,
      indicatorUnit: i.unidadeIndicador,
      applyToLote: i.aplicarAoLote,
      applyToProperty: i.aplicarNaPropriedade,
      createdAt: i.criadoEm,
    );
  }

  factory HerdIndicator.fromJson(Map<String, dynamic> json) {
    return HerdIndicator.fromMap(json);
  }
}
