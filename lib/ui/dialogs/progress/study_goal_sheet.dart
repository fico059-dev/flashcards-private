import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Lets the student set the exam date and targets. Returns the new goal, or
/// null when cancelled.
Future<StudyGoal?> showStudyGoalSheet(
  BuildContext context, {
  required StudyGoal goal,
  required int totalCards,
}) {
  return showModalBottomSheet<StudyGoal>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: bottomSheetShape,
    builder: (context) => KeyboardAwareSheet(
      child: SingleChildScrollView(
        child: _GoalForm(goal: goal, totalCards: totalCards),
      ),
    ),
  );
}

class _GoalForm extends StatefulWidget {
  final StudyGoal goal;
  final int totalCards;

  const _GoalForm({required this.goal, required this.totalCards});

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  late DateTime? _examDate = widget.goal.examDate;
  late final _targetController = TextEditingController(
    text: widget.goal.targetCards?.toString() ?? '',
  );
  late double _osceTarget = widget.goal.targetOsceScore.toDouble();

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? today.add(const Duration(days: 60)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
      helpText: 'Exam date',
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  void _save() {
    final target = int.tryParse(_targetController.text.trim());
    Navigator.of(context).pop(
      StudyGoal(
        examDate: _examDate,
        targetCards: target == null || target <= 0 ? null : target,
        targetOsceScore: _osceTarget.round(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _examDate == null
        ? null
        : startOfDay(_examDate!).difference(startOfDay(DateTime.now())).inDays;

    return Padding(
      padding: bottomSheetPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your study goal', style: context.text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Used to plan how much to study each day. Everything is optional.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: const Text('Exam date'),
            subtitle: Text(
              _examDate == null
                  ? 'Not set'
                  : '${DateFormat('EEE d MMM yyyy').format(_examDate!)}'
                        ' · in $daysLeft days',
            ),
            trailing: _examDate == null
                ? const Icon(Icons.chevron_right)
                : IconButton(
                    tooltip: 'Remove exam date',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _examDate = null),
                  ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.style_outlined),
              labelText: 'Target cards to study',
              helperText:
                  'Leave empty to aim for all ${widget.totalCards} cards '
                  'available to you',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.medical_services_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text('OSCE target score', style: context.text.bodyLarge),
              ),
              Text(
                '${_osceTarget.round()}%',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _osceTarget,
            min: 50,
            max: 100,
            divisions: 10,
            label: '${_osceTarget.round()}%',
            onChanged: (value) => setState(() => _osceTarget = value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save goal'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
