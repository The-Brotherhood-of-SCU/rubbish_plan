import 'package:flutter/material.dart';
import 'package:rubbish_plan/injection/injector.dart';
import 'package:rubbish_plan/l10n/app_localizations.dart';
import 'package:rubbish_plan/models/course.dart';
import 'package:rubbish_plan/pages/course_edit_page.dart';
import 'package:rubbish_plan/providers/course_provider.dart';
import 'package:rubbish_plan/widgets/common/text.dart';
import 'package:rubbish_plan/widgets/course/course_grid.dart';
import 'package:rubbish_plan/widgets/dialog/dialog.dart';
import 'package:rubbish_plan/widgets/route/router_utils.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final courseProvider = getIt<CourseProvider>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([
        courseProvider.courses,
        courseProvider.scheduleConfig,
        courseProvider.currentWeek,
        courseProvider.isLoading,
      ]),
      builder: (context, _) {
        if (courseProvider.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final config = courseProvider.scheduleConfig.value;
        final week = courseProvider.currentWeek.value;
        final totalWeeks = config.totalWeeks;
        final allCourses = courseProvider.courses.value;

        return Column(
          children: [
            // Top bar: date, week switcher, action buttons
            _buildTopBar(context, l10n, week, totalWeeks),
            const SizedBox(height: 8),
            // Course grid
            Expanded(
              child: allCourses.isEmpty
                  ? Center(child: Text(l10n.noCourseThisWeek))
                  : CourseGrid(
                      courses: allCourses,
                      config: config,
                      displayWeek: week,
                      totalWeeks: totalWeeks,
                      onCourseTap: _onCourseTap,
                      onCourseLongPress: _onCourseLongPress,
                      onEmptyTap: _onEmptyTap,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n, int week, int totalWeeks) {
    return Row(
      spacing: 8,
      children: [
        const SizedBox(width: 8),
        // Week navigation
        IconButton(
          onPressed: week > 1 ? () => _changeWeek(week - 1) : null,
          icon: const Icon(Icons.chevron_left, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        GestureDetector(
          onTap: () => _goToCurrentWeek(),
          child: TitleText(l10n.currentWeek(week)),
        ),
        IconButton(
          onPressed: week < totalWeeks ? () => _changeWeek(week + 1) : null,
          icon: const Icon(Icons.chevron_right, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const Expanded(child: SizedBox()),
        IconButton(
          onPressed: _onAddCourse,
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {}, // Placeholder: download/import
          icon: const Icon(Icons.download),
        ),
        IconButton(
          onPressed: () {}, // Placeholder: send/export
          icon: const Icon(Icons.send),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _changeWeek(int newWeek) {
    courseProvider.updateCurrentWeek(newWeek);
  }

  void _goToCurrentWeek() {
    final currentWeek = courseProvider.scheduleConfig.value.getCurrentWeek();
    courseProvider.updateCurrentWeek(currentWeek);
  }

  void _onAddCourse() {
    popupOrNavigate(context, const CourseEditPage());
  }

  void _onCourseTap(Course course) {
    popupOrNavigate(context, CourseEditPage(course: course));
  }

  void _onCourseLongPress(Course course) {
    final l10n = AppLocalizations.of(context)!;
    showYesNoDialog(
      title: l10n.deleteCourse,
      content: l10n.deleteCourseConfirm,
    ).then((confirm) async {
      if (confirm == true) {
        await courseProvider.deleteCourse(course.id);
      }
    });
  }

  void _onEmptyTap(int dayOfWeek, int section) {
    popupOrNavigate(
      context,
      CourseEditPage(
        prefillDayOfWeek: dayOfWeek,
        prefillSection: section,
      ),
    );
  }
}
