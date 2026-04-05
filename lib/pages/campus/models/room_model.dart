class ClassUseInfo {
  final String courseName;
  final String teacherName;
  final bool isInUse;
  final bool isBorrowed;
  final String reseat;

  ClassUseInfo({
    required this.courseName,
    required this.teacherName,
    required this.isInUse,
    required this.isBorrowed,
    required this.reseat,
  });

  factory ClassUseInfo.fromJson(Map<String, dynamic> json) {
    final use = json['use']?.toString() ?? '0';
    final reseat = json['reseat']?.toString() ?? '-1';
    return ClassUseInfo(
      courseName: json['kcm']?.toString() ?? '',
      teacherName: json['jsm']?.toString() ?? '',
      isInUse: use == '1',
      isBorrowed: reseat != '-1',
      reseat: reseat,
    );
  }
}

class RoomData {
  final String roomName;
  final int seatCount;
  final List<ClassUseInfo> classUses;

  RoomData({
    required this.roomName,
    required this.seatCount,
    required this.classUses,
  });

  factory RoomData.fromJson(Map<String, dynamic> json) {
    final classUsesJson = json['classUse'] as List? ?? [];
    return RoomData(
      roomName: json['roomName'] as String,
      seatCount: int.tryParse(json['roomZws']?.toString() ?? '0') ?? 0,
      classUses: classUsesJson
          .map((e) => ClassUseInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WeekInfo {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;

  WeekInfo({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
  });

  factory WeekInfo.fromJson(Map<String, dynamic> json) {
    final ksr = json['ksr']?.toString() ?? '';
    final jsr = json['jsr']?.toString() ?? '';
    return WeekInfo(
      weekNumber: int.tryParse(json['zc']?.toString() ?? '0') ?? 0,
      startDate: DateTime.tryParse(ksr) ?? DateTime.now(),
      endDate: DateTime.tryParse(jsr) ?? DateTime.now(),
    );
  }
}

class RoomQueryResult {
  final List<RoomData> rooms;
  final List<WeekInfo> weeks;
  final int serverTime;

  RoomQueryResult({
    required this.rooms,
    required this.weeks,
    required this.serverTime,
  });

  factory RoomQueryResult.fromJson(Map<String, dynamic> json) {
    final roomDataJson = json['roomdata'] as List? ?? [];
    final xldataJson = json['xldata'] as List? ?? [];
    return RoomQueryResult(
      rooms: roomDataJson
          .map((e) => RoomData.fromJson(e as Map<String, dynamic>))
          .toList(),
      weeks: xldataJson
          .map((e) => WeekInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      serverTime: json['servertime'] ?? 0,
    );
  }

  int getCurrentWeekNumber() {
    final now = DateTime.now();
    for (final week in weeks) {
      if (now.isAfter(week.startDate) && now.isBefore(week.endDate)) {
        return week.weekNumber;
      }
    }
    return 0;
  }
}
