class Cause {
  final String name;
  final String value;
  final String id;

  Cause({
    required this.name,
    required this.id,
    required this.value,
  });

  // Factory constructor to create Cause instance from JSON
  factory Cause.fromJson(Map<String, dynamic> json) {
    return Cause(
      name: json['name'],
      value: json['value'],
      id: json['_id'],
    );
  }

  // Convert Cause instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      '_id': id,
    };
  }
}
