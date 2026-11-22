import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/notification_service.dart';
import '../services/task_controller.dart';
import '../theme.dart';

void showNotifications(BuildContext context) {
  final next = context.read<TaskController>().upcoming;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.bg,
    constraints: const BoxConstraints(maxWidth: 520),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your notifications',
                  style: Theme.of(ctx).textTheme.titleLarge),
              TextButton.icon(
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('Test alert'),
                onPressed: () async {
                  await NotificationService.instance.showInstantNotification(
                    title: 'IntentFlow Alert ⚡',
                    body:
                        'Notifications are active! You will receive timely alerts for your tasks.',
                  );
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Test notification sent! Check your notification bar.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (next.isEmpty)
            const Text("You're all set. Nothing coming up.")
          else ...[
            const Text("You're all set for now. Next up:"),
            const SizedBox(height: 8),
            for (final t in next)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.purple),
                title: Text(t.title),
                subtitle: Text(
                    '${DateFormat('MMM d').format(t.dateTime)} · ${t.displayTime}'),
              ),
          ],
        ],
      ),
    ),
  );
}
