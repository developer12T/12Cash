class SendmoneyTable {
  final String date;
  final double sendmoney;
  final double summary;
  final double diff;
  final String status;
  final double change;
  final double good;
  final double damaged;

  SendmoneyTable({
    required this.date,
    required this.sendmoney,
    required this.summary,
    required this.diff,
    required this.status,
    required this.change,
    required this.good,
    required this.damaged,
  });

  // Factory constructor for JSON
  factory SendmoneyTable.fromJson(Map<String, dynamic> json) {
    return SendmoneyTable(
      date: json['date'] ?? '',
      sendmoney: (json['sendmoney'] as num?)?.toDouble() ?? 0.0,
      summary: (json['summary'] as num?)?.toDouble() ?? 0.0,
      diff: (json['diff'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
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
      'diff': diff,
      'sendmoney': sendmoney,
      'status': status,
      'change': change,
      'good': good,
      'damaged': damaged,
    };
  }
}
