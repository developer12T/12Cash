class Group {
  String groupCode;
  String group;

  Group({
    required this.groupCode,
    required this.group,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        groupCode: json["groupCode"]?.toString() ?? '',
        group: json["group"]?.toString() ?? '',
      );
}
