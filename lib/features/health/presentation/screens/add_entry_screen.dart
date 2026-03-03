import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';
import 'package:mission_victus/features/health/domain/usecases/add_health_entry_usecase.dart';
import 'package:mission_victus/features/health/presentation/providers/health_entries_notifier.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({super.key});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Mood _selectedMood = Mood.good;
  final DateTime _date = DateTime.now();

  @override
  void dispose() {
    _sleepController.dispose();
    _waterController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await ref.read(addEntryProvider.notifier).addEntry(
          AddHealthEntryInput(
            date: _date,
            mood: _selectedMood,
            sleepHours: double.parse(_sleepController.text.trim()),
            waterIntake: double.parse(_waterController.text.trim()),
            note: _noteController.text,
          ),
        );

    if (!mounted) return;

    switch (result.status) {
      case AddHealthEntryStatus.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health entry saved successfully.')),
        );
        Navigator.of(context).pop();
      case AddHealthEntryStatus.duplicate:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry for this day already exists.')),
        );
      case AddHealthEntryStatus.invalid:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Invalid entry.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(addEntryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(_date),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Mood',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Mood.values
                  .map(
                    (mood) => ChoiceChip(
                      label: Text('${_emoji(mood)} ${mood.label}'),
                      selected: _selectedMood == mood,
                      onSelected: (_) {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sleepController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Sleep hours'),
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) return 'Sleep hours is required.';
                final parsed = double.tryParse(raw);
                if (parsed == null) return 'Enter a valid number.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _waterController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Water intake (L)'),
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) return 'Water intake is required.';
                final parsed = double.tryParse(raw);
                if (parsed == null) return 'Enter a valid number.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: addState.isSaving ? null : _save,
              icon: addState.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(addState.isSaving ? 'Saving...' : 'Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  String _emoji(Mood mood) {
    switch (mood) {
      case Mood.good:
        return '😊';
      case Mood.okay:
        return '😌';
      case Mood.bad:
        return '😔';
    }
  }
}
