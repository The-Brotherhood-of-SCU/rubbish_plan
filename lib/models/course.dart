import 'package:flutter/material.dart';

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const TimeSlot({required this.startTime, required this.endTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: _timeOfDayFromJson(json['startTime'] as Map<String, dynamic>),
      endTime: _timeOfDayFromJson(json['endTime'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'startTime': _timeOfDayToJson(startTime),
    'endTime': _timeOfDayToJson(endTime),
  };

  static TimeOfDay _timeOfDayFromJson(Map<String, dynamic> json) {
    return TimeOfDay(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  static Map<String, dynamic> _timeOfDayToJson(TimeOfDay time) {
    return {'hour': time.hour, 'minute': time.minute};
  }

  TimeSlot copyWith({TimeOfDay? startTime, TimeOfDay? endTime}) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class ScheduleConfig {
  String semesterName;
  DateTime semesterStartDate;
  DateTime semesterEndDate;
  int sectionsPerDay;
  List<TimeSlot> timeSlots;
  double colorOpacity;
  double courseCardFontSize;
  bool showTeacherName;
  bool showLocation;
  bool showWeekend;

  ScheduleConfig({
    this.semesterName = '',
    required this.semesterStartDate,
    required this.semesterEndDate,
    this.sectionsPerDay = 12,
    List<TimeSlot>? timeSlots,
    this.colorOpacity = 0.85,
    this.courseCardFontSize = 11.0,
    this.showTeacherName = true,
    this.showLocation = true,
    this.showWeekend = true,
  }) : timeSlots = timeSlots ?? _defaultTimeSlots(12);

  factory ScheduleConfig.fromJson(Map<String, dynamic> json) {
    return ScheduleConfig(
      semesterName: json['semesterName'] as String? ?? '',
      semesterStartDate: DateTime.parse(json['semesterStartDate'] as String),
      semesterEndDate: DateTime.parse(json['semesterEndDate'] as String),
      sectionsPerDay: json['sectionsPerDay'] as int? ?? 12,
      timeSlots: (json['timeSlots'] as List<dynamic>?)
              ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          _defaultTimeSlots(json['sectionsPerDay'] as int? ?? 12),
      colorOpacity: (json['colorOpacity'] as num?)?.toDouble() ?? 0.85,
      courseCardFontSize: (json['courseCardFontSize'] as num?)?.toDouble() ?? 11.0,
      showTeacherName: json['showTeacherName'] as bool? ?? true,
      showLocation: json['showLocation'] as bool? ?? true,
      showWeekend: json['showWeekend'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'semesterName': semesterName,
    'semesterStartDate':
        '${semesterStartDate.year}-${semesterStartDate.month.toString().padLeft(2, '0')}-${semesterStartDate.day.toString().padLeft(2, '0')}',
    'semesterEndDate':
        '${semesterEndDate.year}-${semesterEndDate.month.toString().padLeft(2, '0')}-${semesterEndDate.day.toString().padLeft(2, '0')}',
    'sectionsPerDay': sectionsPerDay,
    'timeSlots': timeSlots.map((e) => e.toJson()).toList(),
    'colorOpacity': colorOpacity,
    'courseCardFontSize': courseCardFontSize,
    'showTeacherName': showTeacherName,
    'showLocation': showLocation,
    'showWeekend': showWeekend,
  };

  static List<TimeSlot> _defaultTimeSlots(int count) {
    final slots = <TimeSlot>[];
    for (int i = 0; i < count; i++) {
      int startHour;
      int startMin;
      if (i < 4) {
        // Morning: 8:00, 8:55, 9:50, 10:55
        startHour = 8 + i;
        startMin = i < 3 ? 0 : 5;
      } else if (i < 8) {
        // Afternoon: 14:00, 14:55, 15:50, 16:55
        startHour = 14 + (i - 4);
        startMin = i < 7 ? 0 : 5;
      } else {
        // Evening: 19:00, 19:55, 20:50, 21:45
        startHour = 19 + (i - 8);
        startMin = i < 11 ? 0 : (i == 11 ? 5 : 0);
      }
      // Fix evening slots
      if (i >= 8) {
        startHour = 19 + (i - 8);
        startMin = 0;
      }
      final endHour = startHour;
      final endMin = startMin + 45;
      slots.add(TimeSlot(
        startTime: TimeOfDay(hour: startHour, minute: startMin),
        endTime: TimeOfDay(hour: endHour + (endMin >= 60 ? 1 : 0), minute: endMin >= 60 ? endMin - 60 : endMin),
      ));
    }
    return slots;
  }

  int get totalWeeks {
    final days = semesterEndDate.difference(semesterStartDate).inDays;
    return (days / 7).ceil();
  }

  int getCurrentWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(semesterStartDate.year, semesterStartDate.month, semesterStartDate.day);
    if (today.isBefore(start)) return 1;
    final days = today.difference(start).inDays;
    final week = (days / 7).floor() + 1;
    return week.clamp(1, totalWeeks);
  }

  ScheduleConfig copyWith({
    String? semesterName,
    DateTime? semesterStartDate,
    DateTime? semesterEndDate,
    int? sectionsPerDay,
    List<TimeSlot>? timeSlots,
    double? colorOpacity,
    double? courseCardFontSize,
    bool? showTeacherName,
    bool? showLocation,
    bool? showWeekend,
  }) {
    return ScheduleConfig(
      semesterName: semesterName ?? this.semesterName,
      semesterStartDate: semesterStartDate ?? this.semesterStartDate,
      semesterEndDate: semesterEndDate ?? this.semesterEndDate,
      sectionsPerDay: sectionsPerDay ?? this.sectionsPerDay,
      timeSlots: timeSlots ?? this.timeSlots,
      colorOpacity: colorOpacity ?? this.colorOpacity,
      courseCardFontSize: courseCardFontSize ?? this.courseCardFontSize,
      showTeacherName: showTeacherName ?? this.showTeacherName,
      showLocation: showLocation ?? this.showLocation,
      showWeekend: showWeekend ?? this.showWeekend,
    );
  }
}

enum WeekType { every, odd, even }

class Course {
  final String id;
  String name;
  String teacher;
  String location;
  int startWeek;
  int endWeek;
  int dayOfWeek; // 1=Mon ... 7=Sun
  int startSection;
  int endSection;
  int colorValue; // ARGB
  WeekType weekType;

  Course({
    String? id,
    required this.name,
    required this.teacher,
    required this.location,
    required this.startWeek,
    required this.endWeek,
    required this.dayOfWeek,
    required this.startSection,
    required this.endSection,
    required this.colorValue,
    this.weekType = WeekType.every,
  }) : id = id ?? _generateId();

  static String _generateId() {
    final now = DateTime.now();
    return '${now.microsecondsSinceEpoch}';
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      teacher: json['teacher'] as String,
      location: json['location'] as String,
      startWeek: json['startWeek'] as int,
      endWeek: json['endWeek'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      startSection: json['startSection'] as int,
      endSection: json['endSection'] as int,
      colorValue: json['colorValue'] as int,
      weekType: json['weekType'] != null
          ? WeekType.values[json['weekType'] as int]
          : WeekType.every,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'teacher': teacher,
    'location': location,
    'startWeek': startWeek,
    'endWeek': endWeek,
    'dayOfWeek': dayOfWeek,
    'startSection': startSection,
    'endSection': endSection,
    'colorValue': colorValue,
    'weekType': weekType.index,
  };

  Color get color => Color(colorValue);

  set color(Color c) => colorValue = c.toARGB32();

  /// Check if this course is active in the given week
  bool isActiveInWeek(int week) {
    if (week < startWeek || week > endWeek) return false;
    if (weekType == WeekType.odd && week.isEven) return false;
    if (weekType == WeekType.even && week.isOdd) return false;
    return true;
  }

  /// Check if this course conflicts with another course
  bool conflictsWith(Course other, {String? excludeId}) {
    if (excludeId != null && id == excludeId) return false;
    if (dayOfWeek != other.dayOfWeek) return false;
    // Check week overlap considering week types
    for (int w = startWeek; w <= endWeek; w++) {
      if (isActiveInWeek(w) && other.isActiveInWeek(w)) {
        // Same week, check section overlap
        if (!(endSection < other.startSection || startSection > other.endSection)) {
          return true;
        }
      }
    }
    return false;
  }

  Course copyWith({
    String? name,
    String? teacher,
    String? location,
    int? startWeek,
    int? endWeek,
    int? dayOfWeek,
    int? startSection,
    int? endSection,
    int? colorValue,
    WeekType? weekType,
  }) {
    return Course(
      id: id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      colorValue: colorValue ?? this.colorValue,
      weekType: weekType ?? this.weekType,
    );
  }
}
