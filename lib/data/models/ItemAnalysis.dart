class ItemSummarize {
  final String itemNo;
  final double january;
  final double february;
  final double march;
  final double april;
  final double may;
  final double june;
  final double july;
  final double august;
  final double september;
  final double october;
  final double november;
  final double december;
  final double max;
  final double avg;
  final double sum;

  ItemSummarize({
    required this.itemNo,
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
    required this.max,
    required this.avg,
    required this.sum,
  });

  factory ItemSummarize.fromJson(Map<String, dynamic> json) {
    return ItemSummarize(
      itemNo: json['itemNo'],
      january: json['January']?.toDouble() ?? 0.0,
      february: json['February']?.toDouble() ?? 0.0,
      march: json['March']?.toDouble() ?? 0.0,
      april: json['April']?.toDouble() ?? 0.0,
      may: json['May']?.toDouble() ?? 0.0,
      june: json['June']?.toDouble() ?? 0.0,
      july: json['July']?.toDouble() ?? 0.0,
      august: json['August']?.toDouble() ?? 0.0,
      september: json['September']?.toDouble() ?? 0.0,
      october: json['October']?.toDouble() ?? 0.0,
      november: json['November']?.toDouble() ?? 0.0,
      december: json['December']?.toDouble() ?? 0.0,
      max: json['MAX']?.toDouble() ?? 0.0,
      avg: json['AVG']?.toDouble() ?? 0.0,
      sum: json['SUM']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemNo': itemNo,
      'January': january,
      'February': february,
      'March': march,
      'April': april,
      'May': may,
      'June': june,
      'July': july,
      'August': august,
      'September': september,
      'October': october,
      'November': november,
      'December': december,
      'MAX': max,
      'AVG': avg,
      'SUM': sum,
    };
  }
}
