import 'package:flutter_test/flutter_test.dart';
import 'package:rubbish_plan/models/course.dart';

void main() {
  group('Course week visibility', () {
    final course = Course(
      name: '高数',
      teacher: '老师',
      location: '教室',
      startWeek: 1,
      endWeek: 16,
      dayOfWeek: 1,
      startSection: 1,
      endSection: 2,
      colorValue: 0xFF2196F3,
      weekType: WeekType.odd,
    );

    test('keeps odd-week ghost card within configured week range', () {
      expect(course.isInWeekRange(2), isTrue);
      expect(course.isActiveInWeek(2), isFalse);
    });

    test('hides course outside configured week range', () {
      expect(course.isInWeekRange(17), isFalse);
      expect(course.isActiveInWeek(17), isFalse);
    });
  });
}
