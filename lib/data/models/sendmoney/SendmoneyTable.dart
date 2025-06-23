class SendmoneyTable {
  final String date;
  final double summary;
  final String status;
  final double good;
  final double damaged;

  SendmoneyTable({
    required this.date,
    required this.summary,
    required this.status,
    required this.good,
    required this.damaged,
  });

  // Factory constructor for JSON
  factory SendmoneyTable.fromJson(Map<String, dynamic> json) {
    return SendmoneyTable(
      date: json['date'] ?? '',
      summary: (json['summary'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      good: (json['good'] as num?)?.toDouble() ?? 0.0,
      damaged: (json['damaged'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'summary': summary,
      'status': status,
      'good': good,
      'damaged': damaged,
    };
  }
}
