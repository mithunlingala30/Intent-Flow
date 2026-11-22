import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../services/task_controller.dart';
import '../theme.dart';

void showToast(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(message)));
}

/// Pushes [page] while re-exposing the task/shell controllers
/// (routes pushed on the root Navigator sit above the Providers).
Future<T?> pushPage<T>(BuildContext context, Widget page) {
  final tasks = context.read<TaskController>();
  final shell = context.read<ShellController>();
  return Navigator.of(context).push<T>(MaterialPageRoute(
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tasks),
        ChangeNotifierProvider.value(value: shell),
      ],
      child: page,
    ),
  ));
}

class NeuCard extends StatelessWidget {
  const NeuCard({super.key, required this.child, this.padding, this.color});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: softShadow(0.9),
        ),
        child: child,
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled || loading ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF7A6CE6), AppColors.purple]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x556558D3), blurRadius: 16, offset: Offset(0, 8))
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled ? onPressed : null,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5)),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child: Text(title,
                  style: Theme.of(context).textTheme.titleMedium)),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(action!),
                const Icon(Icons.chevron_right, size: 18),
              ]),
            ),
        ],
      );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.purple,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3));
}

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.actionLabel,
      this.onAction});
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
        child: Column(children: [
          Icon(icon, size: 38, color: AppColors.purpleLight),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ]),
      );
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.size = 22});
  final double size;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF8F82F0), AppColors.purple]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.bolt_rounded, color: Colors.white, size: size + 2),
          ),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'Intent'),
              TextSpan(
                  text: 'Flow',
                  style: TextStyle(color: AppColors.purple.withOpacity(.85))),
              const TextSpan(
                  text: '.', style: TextStyle(color: AppColors.purpleLight)),
            ]),
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5),
          ),
        ],
      );
}

/// Soft orb illustration used on onboarding / success / empty screens.
class Illustration extends StatelessWidget {
  const Illustration({super.key, this.success = false, this.size = 170});
  final bool success;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDCD7F8))),
          ),
          Container(
            width: size * .78,
            height: size * .78,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE6E2FA))),
          ),
          Container(
            width: size * .52,
            height: size * .52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: success
                      ? const [Color(0xFF7CC3A5), Color(0xFF4FA586)]
                      : const [Color(0xFF9A8EF2), AppColors.purple]),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x446558D3),
                    blurRadius: 22,
                    offset: Offset(0, 12))
              ],
            ),
            child: Icon(success ? Icons.check_rounded : Icons.bolt_rounded,
                color: Colors.white, size: size * .3),
          ),
          Positioned(
              top: size * .08,
              right: size * .16,
              child: const Text('✦',
                  style: TextStyle(color: AppColors.purpleLight, fontSize: 18))),
          Positioned(
              bottom: size * .14,
              left: size * .08,
              child: const Text('✧',
                  style: TextStyle(color: AppColors.purpleLight, fontSize: 16))),
          Positioned(
            left: size * .02,
            top: size * .3,
            child: _tile(Icons.check_rounded),
          ),
          Positioned(
            right: size * .0,
            bottom: size * .26,
            child: _tile(Icons.calendar_month_rounded),
          ),
        ]),
      );

  Widget _tile(IconData i) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: softShadow(.35)),
        child: Icon(i, size: 18, color: AppColors.purple),
      );
}

class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key, required this.category, required this.color});
  final String category;
  final String color;
  @override
  Widget build(BuildContext context) {
    final s = CategoryStyle.of(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(8)),
      child: Text(category,
          style: TextStyle(
              color: s.fg, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.management = false});
  final TaskModel task;
  final bool management;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<TaskController>();
    final style = CategoryStyle.of(task.colorName);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: softShadow(.5),
      ),
      child: Row(children: [
        IconButton(
          tooltip: task.done ? 'Mark pending' : 'Complete',
          onPressed: () => ctrl.toggle(task).catchError(
              (_) => showToast(context, 'Could not update the task.')),
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.done ? AppColors.purple : Colors.transparent,
              border: Border.all(
                  color: task.done ? AppColors.purple : AppColors.purpleLight,
                  width: 2),
            ),
            child: task.done
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        Expanded(
          child: Opacity(
            opacity: task.done ? .55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration:
                            task.done ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Icon(Icons.access_time, size: 13, color: AppColors.muted),
                    Text(task.displayTime,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12.5)),
                    Text(task.category,
                        style: TextStyle(
                            color: style.fg,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                    if (management)
                      Text(task.date.substring(5).replaceFirst('-', '/'),
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12.5)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (management) ...[
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showEditTaskSheet(context, task),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              try {
                await ctrl.remove(task.id);
                if (context.mounted) showToast(context, 'Task deleted');
              } catch (_) {
                if (context.mounted) {
                  showToast(context, 'Could not delete the task.');
                }
              }
            },
          ),
        ] else
          CategoryTag(category: task.category, color: task.colorName),
      ]),
    );
  }
}

/// Bottom sheet to edit title / date / time / category of a task.
Future<void> showEditTaskSheet(BuildContext context, TaskModel task) {
  final ctrl = context.read<TaskController>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _EditTaskSheet(task: task, controller: ctrl),
  );
}

class _EditTaskSheet extends StatefulWidget {
  const _EditTaskSheet({required this.task, required this.controller});
  final TaskModel task;
  final TaskController controller;
  @override
  State<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<_EditTaskSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.task.title);
  late DateTime _date = DateTime.tryParse(widget.task.date) ?? DateTime.now();
  late TimeOfDay _time = TimeOfDay.fromDateTime(widget.task.dateTime);
  late String _category = widget.task.category;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final hh = _time.hour.toString().padLeft(2, '0');
    final mm = _time.minute.toString().padLeft(2, '0');
    try {
      await widget.controller.update(widget.task.copyWith(
        title: _title.text.trim(),
        date: dateKey(_date),
        time: '$hh:$mm',
        category: _category,
      ));
      if (!mounted) return;
      Navigator.pop(context);
      showToast(context, 'Task updated. Back in flow.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, 'Could not save changes. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          22, 20, 22, MediaQuery.of(context).viewInsets.bottom + 22),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text('A little fine-tuning.',
                        style: Theme.of(context).textTheme.titleLarge)),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ]),
              const Text('Make this task work for you.',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Task name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a task name' : null,
              ),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                    onPressed: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100));
                      if (d != null) setState(() => _date = d);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_time.format(context)),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: _time);
                      if (t != null) setState(() => _time = t);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in kCategories)
                    DropdownMenuItem(value: c, child: Text(c))
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                  label: 'Save changes',
                  icon: Icons.check,
                  loading: _saving,
                  onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
