class Country {
  final int id;
  final String name;
  final Continent continent;

  Country({
    required this.id,
    required this.name,
    required this.continent,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      continent: Continent.fromJson(json['continentid'] ?? {}),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'continentid': continent.toJson(),
    };
  }
}

class Continent {
  final int id;
  final String continentName;

  Continent({
    required this.id,
    required this.continentName,
  });

  factory Continent.fromJson(Map<String, dynamic> json) {
    return Continent(
      id: json['id'] ?? 0,
      continentName: json['continentname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'continentname': continentName,
    };
  }
}