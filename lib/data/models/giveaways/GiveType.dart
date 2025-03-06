class GiveType {
  final String name;
  final String giveId;
  // final String id;

  GiveType({required this.name, required this.giveId});

  // Factory constructor to create GiveType instance from JSON
  factory GiveType.fromJson(Map<String, dynamic> json) {
    return GiveType(
      name: json['name'],
      giveId: json['giveId'],
      // id: json['_id'],
    );
  }

  // Convert GiveType instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'giveId': giveId,
      // '_id': id,
    };
  }
}
