import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Illustration(success: true),
              const SizedBox(height: 16),
              const Eyebrow('CONSIDER IT DONE'),
              const SizedBox(height: 8),
              Text('Your task has been scheduled!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              const Text('One less thing on your mind. We\'ve got it from here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              NeuCard(
                child: Column(children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppColors.purple, size: 30),
                  const SizedBox(height: 8),
                  Text(task.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                      '${DateFormat('EEEE, MMMM d').format(task.dateTime)} · ${task.displayTime}',
                      style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 10),
                  Chip(
                    avatar: const Icon(Icons.check, size: 14),
                    label: Text(
                        'Saved to your account${task.repeat != 'None' ? ' · Repeats ${task.repeat.toLowerCase()}' : ''}'),
                  ),
                ]),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'View all tasks',
                icon: Icons.arrow_forward,
                onPressed: () {
                  context.read<ShellController>().go(1);
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit task'),
                onPressed: () => showEditTaskSheet(context, task),
              ),
              TextButton(
                onPressed: () {
                  context.read<ShellController>().go(0);
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: const Text('Back to your day'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
