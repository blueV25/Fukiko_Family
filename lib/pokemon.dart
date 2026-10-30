class Pokemon {
  final int id;
  final String name;
  final int baseExperience;
  final int height;
  final int weight;
  final List<String> abilities;
  final List<String> types;
  final List<String> moves;
  final String? frontImage;

  Pokemon({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.types,
    required this.moves,
    this.frontImage,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['sprites'] != null) {
      var sprites = json['sprites'];
      if (sprites['other'] != null && sprites['other']['home'] != null) {
        imageUrl = sprites['other']['home']['front_default'];
      }
      imageUrl ??= sprites['front_default'];
    }

    List<String> abilityList = [];
    if (json['abilities'] != null) {
      var rawAbilities = json['abilities'] as List;
      for (var item in rawAbilities) {
        var abilityName = item['ability']['name'];
        abilityList.add(abilityName.toString());
      }
    }

    List<String> typeList = [];
    if (json['types'] != null) {
      var rawTypes = json['types'] as List;
      for (var item in rawTypes) {
        var typeName = item['type']['name'];
        typeList.add(typeName.toString());
      }
    }

    List<String> moveList = [];
    if (json['moves'] != null) {
      var rawMoves = json['moves'] as List;
      for (var item in rawMoves) {
        var moveName = item['move']['name'];
        moveList.add(moveName.toString());
      }
    }

    return Pokemon(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      baseExperience: json['base_experience'] ?? 0,
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      abilities: abilityList,
      types: typeList,
      moves: moveList,
      frontImage: imageUrl,
    );
  }
}
