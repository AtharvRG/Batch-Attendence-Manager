import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/features/fees/providers/fee_providers.dart';
// No HiveService needed here

class StudentFeeListItem extends ConsumerWidget {
  final Student student;
  const StudentFeeListItem({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final monthKey = ref.watch(displayedMonthKeyProvider);
    final isPaid = student.monthlyFeeStatus[monthKey] ?? false;
    final statusColor = isPaid ? Colors.green.shade600 : Colors.red.shade600;
    final toggleState = ref.watch(feeStatusToggleProvider);
    final isToggling = toggleState is AsyncLoading;

    return ListTile(
      dense: true,
      leading: Icon( Icons.circle, color: statusColor, size: 18.0,),
      title: Text(student.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale( scale: 0.8, child: Switch( value: isPaid, onChanged: isToggling ? null : (newValue) async { try { await ref.read(feeStatusToggleProvider.notifier).toggleFeeStatus(student, monthKey); } catch (e) { if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Error updating status: $e'), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating,),); } } }, activeColor: Colors.green, inactiveThumbColor: Colors.red.shade400, ),),
          const SizedBox(width: 5),
          if (!isPaid)
            IconButton( icon: Icon(Icons.message_outlined, color: theme.colorScheme.primary), iconSize: 20.0, tooltip: 'Send Fee Reminder for this month', visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, onPressed: () { sendFeeReminder(ref, student).catchError((e) { if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Reminder Error: $e'), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating,),); }}); },)
          else
            const SizedBox(width: 48), // Placeholder for alignment
        ],
      ),
    );
  }
}