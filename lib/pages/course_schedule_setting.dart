import 'package:flutter/material.dart';
import 'package:rubbish_plan/injection/injector.dart';
import 'package:rubbish_plan/l10n/app_localizations.dart';
import 'package:rubbish_plan/models/course.dart';
import 'package:rubbish_plan/providers/course_provider.dart';
import 'package:rubbish_plan/widgets/common/styled_card.dart';

class CourseScheduleSetting extends StatefulWidget {
  const CourseScheduleSetting({super.key});

  @override
  State<CourseScheduleSetting> createState() => _CourseScheduleSettingState();
}

class _CourseScheduleSettingState extends State<CourseScheduleSetting> {
  final courseProvider = getIt<CourseProvider>();

  late TextEditingController _semesterNameController;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _sectionsPerDay;
  late List<TimeSlot> _timeSlots;
  late double _colorOpacity;
  late double _fontSize;
  late bool _showTeacher;
  late bool _showLocation;
  late bool _showWeekend;

  @override
  void initState() {
    super.initState();
    final config = courseProvider.scheduleConfig.value;
    _semesterNameController = TextEditingController(text: config.semesterName);
    _startDate = config.semesterStartDate;
    _endDate = config.semesterEndDate;
    _sectionsPerDay = config.sectionsPerDay;
    _timeSlots = List.from(config.timeSlots);
    _colorOpacity = config.colorOpacity;
    _fontSize = config.courseCardFontSize;
    _showTeacher = config.showTeacherName;
    _showLocation = config.showLocation;
    _showWeekend = config.showWeekend;
  }

  @override
  void dispose() {
    _semesterNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scheduleSetting),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            // Semester config section
            _SectionTitle(l10n.semesterConfig),
            TextFormField(
              controller: _semesterNameController,
              decoration: InputDecoration(
                labelText: l10n.semesterName,
                border: const OutlineInputBorder(),
              ),
            ),
            _DatePickerField(
              label: l10n.semesterStartDate,
              date: _startDate,
              onTap: () => _pickDate(context, true),
            ),
            _DatePickerField(
              label: l10n.semesterEndDate,
              date: _endDate,
              onTap: () => _pickDate(context, false),
            ),
            const Divider(),
            // Section count
            _SectionTitle(l10n.sectionCount),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _sectionsPerDay > 1
                      ? () => setState(() {
                            _sectionsPerDay--;
                            _adjustTimeSlots();
                          })
                      : null,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_sectionsPerDay',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _sectionsPerDay < 20
                      ? () => setState(() {
                            _sectionsPerDay++;
                            _adjustTimeSlots();
                          })
                      : null,
                ),
              ],
            ),
            const Divider(),
            // Time slots
            _SectionTitle(l10n.timeSlot),
            ...List.generate(_timeSlots.length, (i) {
              return _TimeSlotEditor(
                index: i,
                slot: _timeSlots[i],
                onChanged: (slot) {
                  setState(() => _timeSlots[i] = slot);
                },
              );
            }),
            const Divider(),
            // Display settings
            _SectionTitle(l10n.displaySetting),
            // Color opacity
            Row(
              children: [
                Expanded(child: Text(l10n.colorOpacity)),
                Text('${(_colorOpacity * 100).round()}%'),
              ],
            ),
            Slider(
              value: _colorOpacity,
              min: 0.3,
              max: 1.0,
              divisions: 14,
              onChanged: (v) => setState(() => _colorOpacity = v),
            ),
            // Font size
            Row(
              children: [
                Expanded(child: Text(l10n.fontSize)),
                Text('${_fontSize.round()}'),
              ],
            ),
            Slider(
              value: _fontSize,
              min: 8,
              max: 16,
              divisions: 16,
              onChanged: (v) => setState(() => _fontSize = v),
            ),
            // Show teacher
            SwitchListTile(
              title: Text(l10n.showTeacher),
              value: _showTeacher,
              onChanged: (v) => setState(() => _showTeacher = v),
              contentPadding: EdgeInsets.zero,
            ),
            // Show location
            SwitchListTile(
              title: Text(l10n.showLocation),
              value: _showLocation,
              onChanged: (v) => setState(() => _showLocation = v),
              contentPadding: EdgeInsets.zero,
            ),
            // Show weekend
            SwitchListTile(
              title: Text(l10n.showWeekend),
              value: _showWeekend,
              onChanged: (v) => setState(() => _showWeekend = v),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _adjustTimeSlots() {
    while (_timeSlots.length < _sectionsPerDay) {
      final hour = 8 + _timeSlots.length;
      _timeSlots.add(TimeSlot(
        startTime: TimeOfDay(hour: hour, minute: 0),
        endTime: TimeOfDay(hour: hour, minute: 45),
      ));
    }
    if (_timeSlots.length > _sectionsPerDay) {
      _timeSlots = _timeSlots.sublist(0, _sectionsPerDay);
    }
  }

  Future<void> _save() async {
    final config = ScheduleConfig(
      semesterName: _semesterNameController.text.trim(),
      semesterStartDate: _startDate,
      semesterEndDate: _endDate,
      sectionsPerDay: _sectionsPerDay,
      timeSlots: _timeSlots,
      colorOpacity: _colorOpacity,
      courseCardFontSize: _fontSize,
      showTeacherName: _showTeacher,
      showLocation: _showLocation,
      showWeekend: _showWeekend,
    );
    await courseProvider.updateScheduleConfig(config);
    if (mounted) Navigator.pop(context);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotEditor extends StatelessWidget {
  final int index;
  final TimeSlot slot;
  final void Function(TimeSlot) onChanged;

  const _TimeSlotEditor({
    required this.index,
    required this.slot,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = _formatTime(slot.startTime);
    final endStr = _formatTime(slot.endTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 16), // Added left padding
          SizedBox(
            width: 48,
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _pickTime(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(startStr),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-'),
                ),
                GestureDetector(
                  onTap: () => _pickTime(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(endStr),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 64), // Adjusted right spacer (48 + 16) to keep time centered
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? slot.startTime : slot.endTime,
    );
    if (picked != null) {
      onChanged(slot.copyWith(
        startTime: isStart ? picked : null,
        endTime: isStart ? null : picked,
      ));
    }
  }
}
