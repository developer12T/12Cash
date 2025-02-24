class Cause {
  final String name;
  final String id;

  Cause({required this.name, required this.id});

  // Factory constructor to create Cause instance from JSON
  factory Cause.fromJson(Map<String, dynamic> json) {
    return Cause(
      name: json['name'],
      id: json['_id'],
    );
  }

  // Convert Cause instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      '_id': id,
    };
  }
}
