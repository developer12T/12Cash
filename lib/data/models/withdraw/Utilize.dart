class Utilize {
  final double? freePercentage;
  final double? stockPercentage;
  final double? withdrawPercentage;
  final double? sumPercentage;
  final double? free;
  final double? stock;
  final double? withdraw;
  final double? sum;
  final double? net;
  final double? payload;
  final String? type_name;
  final double? total_weight;
  final double? law_weight;
  final double? height_floor;
  final double? width_floor;
  final double? length_floor;
  final double? front_pressure;
  final double? back_pressure;
  final double? set_speed;
  final double? set_speed_city;

  Utilize({
    this.freePercentage,
    this.stockPercentage,
    this.withdrawPercentage,
    this.sumPercentage,
    this.free,
    this.stock,
    this.withdraw,
    this.sum,
    this.net,
    this.payload,
    this.type_name,
    this.total_weight,
    this.law_weight,
    this.height_floor,
    this.width_floor,
    this.length_floor,
    this.front_pressure,
    this.back_pressure,
    this.set_speed,
    this.set_speed_city,
  });

  factory Utilize.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Utilize(
      freePercentage: parseDouble(json['freePercentage']),
      stockPercentage: parseDouble(json['stocklPercentage']),
      withdrawPercentage: parseDouble(json['withdrawPercentage']),
      sumPercentage: parseDouble(json['sumPercentage']),
      free: parseDouble(json['free']),
      stock: parseDouble(json['stock']),
      withdraw: parseDouble(json['wtihdraw']),
      sum: parseDouble(json['sum']),
      net: parseDouble(json['net']),
      payload: parseDouble(json['payload']),
      type_name: json['type_name'],
      total_weight: parseDouble(json['total_weight']),
      law_weight: parseDouble(json['law_weight']),
      height_floor: parseDouble(json['height_floor']),
      width_floor: parseDouble(json['width_floor']),
      length_floor: parseDouble(json['length_floor']),
      front_pressure: parseDouble(json['front_pressure']),
      back_pressure: parseDouble(json['back_pressure']),
      set_speed: parseDouble(json['set_speed']),
      set_speed_city: parseDouble(json['set_speed_city']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'freePercentage': freePercentage,
      'stocklPercentage': stockPercentage,
      'withdrawPercentage': withdrawPercentage,
      'sumPercentage': sumPercentage,
      'free': free,
      'stock': stock,
      'wtihdraw': withdraw,
      'sum': sum,
      'net': net,
      'payload': payload,
      'type_name': type_name,
      'total_weight': total_weight,
      'law_weight': law_weight,
      'height_floor': height_floor,
      'width_floor': width_floor,
      'length_floor': length_floor,
      'front_pressure': front_pressure,
      'back_pressure': back_pressure,
      'set_speed': set_speed,
      'set_speed_city': set_speed_city,
    };
  }
}
