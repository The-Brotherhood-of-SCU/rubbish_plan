import 'package:flutter/material.dart';
import 'package:rubbish_plan/injection/injector.dart';
import 'package:rubbish_plan/l10n/app_localizations.dart';
import 'package:rubbish_plan/models/course.dart';
import 'package:rubbish_plan/providers/course_provider.dart';
import 'package:rubbish_plan/widgets/dialog/dialog.dart';
import 'package:rubbish_plan/widgets/route/router_utils.dart';

class ScheduleManagementPage extends StatelessWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final courseProvider = getIt<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scheduleManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final controller = TextEditingController();
              final newName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.semesterName),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.semesterName,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.pop(context, text);
                        } else {
                          // Could optionally show a small snackbar/hint here
                          Navigator.pop(context);
                        }
                      },
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              );

              if (newName != null && newName.isNotEmpty) {
                final newConfig = ScheduleConfig(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  semesterName: newName,
                  semesterStartDate: DateTime.now(),
                );
                await courseProvider.addSchedule(newConfig);
              }
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          courseProvider.allSchedules,
          courseProvider.scheduleConfig,
        ]),
        builder: (context, _) {
          final allSchedules = courseProvider.allSchedules.value;
          final currentId = courseProvider.scheduleConfig.value.id;

          return ListView.builder(
            itemCount: allSchedules.length,
            itemBuilder: (context, index) {
              final schedule = allSchedules[index];
              final isCurrent = schedule.id == currentId;
              return ListTile(
                leading: Icon(
                  isCurrent ? Icons.check_circle : Icons.circle_outlined,
                  color: isCurrent ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                title: Text(schedule.semesterName.isEmpty ? '默认课表' : schedule.semesterName),
                subtitle: Text('共 ${schedule.totalWeeks} 周'),
                onTap: () {
                  courseProvider.switchSchedule(schedule.id);
                  Navigator.pop(logicRootContext);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final controller = TextEditingController(text: schedule.semesterName);
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.semesterName),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: l10n.semesterName,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, controller.text.trim()),
                                child: Text(l10n.save),
                              ),
                            ],
                          ),
                        );

                        if (newName != null && newName.isNotEmpty) {
                          final updatedConfig = schedule.copyWith(semesterName: newName);
                          await courseProvider.updateScheduleConfig(updatedConfig);
                        }
                      },
                    ),
                    if (allSchedules.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showYesNoDialog(
                            title: l10n.delete,
                            content: '确定要删除课表 "${schedule.semesterName}" 吗？',
                          );
                          if (confirm == true) {
                            await courseProvider.deleteSchedule(schedule.id);
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}