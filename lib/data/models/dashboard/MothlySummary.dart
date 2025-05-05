class MonthlySummary {
  final double month;
  final double summary;

  MonthlySummary({
    required this.month,
    required this.summary,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      month: json['month'],
      summary: (json['summary'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'summary': summary,
    };
  }
}
