class Propriedade {
  final String id;
  String nome;
  String proprietario;
  String latitude;
  String longitude;
  String cidade;
  String estado;

  Propriedade({
    required this.id,
    required this.nome,
    required this.proprietario,
    required this.latitude,
    required this.longitude,
    required this.cidade,
    required this.estado,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'proprietario': proprietario,
        'latitude': latitude,
        'longitude': longitude,
        'cidade': cidade,
        'estado': estado,
      };

  factory Propriedade.fromMap(Map<String, dynamic> map) => Propriedade(
        id: map['id'],
        nome: map['nome'],
        proprietario: map['proprietario'],
        latitude: map['latitude'],
        longitude: map['longitude'],
        cidade: map['cidade'],
        estado: map['estado'],
      );

  Map<String, dynamic> toJson() => toMap();
  factory Propriedade.fromJson(Map<String, dynamic> json) =>
      Propriedade.fromMap(json);
}
