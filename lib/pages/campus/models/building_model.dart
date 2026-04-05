class BuildingModel {
  final String name;
  final String location;
  final int row;
  final String xqh;

  BuildingModel({
    required this.name,
    required this.location,
    required this.row,
    required this.xqh,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      name: json['name'] as String,
      location: json['location'] as String,
      row: int.parse(json['row'] as String),
      xqh: json['xqh'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'row': row.toString(),
      'xqh': xqh,
    };
  }

  String get campusName {
    switch (xqh) {
      case '01':
        return '望江校区';
      case '02':
        return '华西校区';
      case '03':
        return '江安校区';
      default:
        return '未知校区';
    }
  }
}
