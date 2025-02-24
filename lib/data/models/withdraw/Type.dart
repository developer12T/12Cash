class TypeDistribute {
  final String type;
  final String typeNameTH;
  final String typeNameEN;

  TypeDistribute({
    required this.type,
    required this.typeNameTH,
    required this.typeNameEN,
  });

  // Factory constructor to create Type instance from JSON
  factory TypeDistribute.fromJson(Map<String, dynamic> json) {
    return TypeDistribute(
      type: json['type'],
      typeNameTH: json['typeNameTH'],
      typeNameEN: json['typeNameEN'],
    );
  }

  // Convert Type instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'typeNameTH': typeNameTH,
      'typeNameEN': typeNameEN,
    };
  }
}
