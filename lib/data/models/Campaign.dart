class CampaignModel {
  final String id;
  final String mongoId;
  final String title;
  final String des;
  final DateTime createdAt;
  final String link;
  final List<String> image;
  final List<String> file;
  final DateTime updatedAt;
  final int v;

  CampaignModel({
    required this.id,
    required this.mongoId,
    required this.title,
    required this.des,
    required this.createdAt,
    required this.link,
    required this.image,
    required this.file,
    required this.updatedAt,
    required this.v,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] ?? '',
      mongoId: json['_id'] ?? '',
      title: json['title'] ?? '',
      des: json['des'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      link: json['link'] ?? '',
      image: List<String>.from(json['image'] ?? []),
      file: List<String>.from(json['file'] ?? []),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': mongoId,
      'title': title,
      'des': des,
      'createdAt': createdAt.toIso8601String(),
      'link': link,
      'image': image,
      'file': file,
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
