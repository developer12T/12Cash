class OptionWithdraw {
  final String value;
  final String name;

  OptionWithdraw({
    required this.value,
    required this.name,
  });

  // Factory constructor to create Type instance from JSON
  factory OptionWithdraw.fromJson(Map<String, dynamic> json) {
    return OptionWithdraw(
      value: json['value'],
      name: json['name'],
    );
  }

  // Convert Type instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
    };
  }
}
