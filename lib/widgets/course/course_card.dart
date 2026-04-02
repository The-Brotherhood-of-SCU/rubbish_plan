import 'package:flutter/material.dart';
import 'package:rubbish_plan/injection/injector.dart';
import 'package:rubbish_plan/l10n/app_localizations.dart';
import 'package:rubbish_plan/models/course.dart';
import 'package:rubbish_plan/providers/app_config_provider.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final ScheduleConfig config;
  final int displayWeek;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CourseCard({
    super.key,
    required this.course,
    required this.config,
    required this.displayWeek,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final appConfig = getIt<AppConfigProvider>();
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([
        appConfig.colorOpacity,
        appConfig.courseCardFontSize,
      ]),
      builder: (context, _) {
        final isActive = course.isActiveInWeek(displayWeek);
        final color = course.color.withValues(
          alpha: isActive
              ? appConfig.colorOpacity.value
              : appConfig.colorOpacity.value * 0.2,
        );
        const textColor = Colors.white;
        final fontSize = appConfig.courseCardFontSize.value;
        final smallFontSize = fontSize - 1;

        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: isActive
                  ? null
                  : Border.all(color: textColor.withAlpha(50), width: 0.5),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isActive ? course.name : '${l10n.notThisWeek} ${course.name}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                if (config.showLocation && course.location.isNotEmpty)
                  _buildIconText(
                    Icons.location_on_outlined,
                    course.location,
                    smallFontSize,
                    textColor,
                  ),
                if (config.showTeacherName && course.teacher.isNotEmpty)
                  _buildIconText(
                    Icons.person_outline,
                    course.teacher,
                    smallFontSize,
                    textColor,
                  ),
                _buildIconText(
                  Icons.calendar_today_outlined,
                  '${course.startWeek}-${course.endWeek}${l10n.week}',
                  smallFontSize,
                  textColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconText(
    IconData icon,
    String text,
    double fontSize,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize, color: color.withAlpha(200)),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: color.withAlpha(230),
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
