import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dance_class_tracker/core/models/batch.dart';
import 'package:dance_class_tracker/core/widgets/loading_indicator.dart';
import 'package:dance_class_tracker/core/widgets/empty_placeholder.dart';
import 'package:dance_class_tracker/features/attendance/providers/attendance_providers.dart';
import 'package:dance_class_tracker/features/attendance/widgets/attendance_list_item.dart';
// Use the new sqflite batch list provider
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final currentSelectedDate = ref.read(selectedAttendanceDateProvider);
    final DateTime? picked = await showDatePicker( context: context, initialDate: currentSelectedDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 30)), );
    if (picked != null && picked != currentSelectedDate) { ref.read(selectedAttendanceDateProvider.notifier).state = picked; }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedAttendanceDateProvider);
    final selectedBatchId = ref.watch(selectedAttendanceBatchIdProvider);
    final formattedDate = DateFormat.yMMMd().format(selectedDate);

    // --- Use batchListProvider (the sqflite version) ---
    final batchesAsyncValue = ref.watch(batchListProvider);

    return Scaffold(
      appBar: AppBar( title: const Text('Take Attendance'), actions: [ TextButton.icon( onPressed: () => _selectDate(context, ref), icon: const Icon(Icons.calendar_today_outlined), label: Text(formattedDate), style: TextButton.styleFrom( foregroundColor: theme.colorScheme.onSurface,),), const SizedBox(width: 8),], ),
      body: Column(
        children: [
          // --- Batch Selector ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: batchesAsyncValue.when(
              data: (batches) {
                // Validation logic (unchanged)
                final validBatchIds = batches.map((b) => b.id).toSet();
                final finalSelectedBatchId = (selectedBatchId != null && validBatchIds.contains(selectedBatchId)) ? selectedBatchId : null;
                if (selectedBatchId != null && !validBatchIds.contains(selectedBatchId)) { WidgetsBinding.instance.addPostFrameCallback((_) { if(context.mounted) { ref.read(selectedAttendanceBatchIdProvider.notifier).state = null; } }); }
                // Dropdown uses validated ID and batches from provider
                return DropdownButtonFormField<String?>( value: finalSelectedBatchId, hint: const Text('Select Batch'), isExpanded: true, decoration: const InputDecoration( labelText: 'Select Batch to take Attendance', border: OutlineInputBorder(), prefixIcon: Icon(Icons.group_work_outlined)), items: batches.map<DropdownMenuItem<String?>>((Batch batch) => DropdownMenuItem<String?>(value: batch.id, child: Text(batch.name))).toList(), onChanged: (String? newValue) { ref.read(selectedAttendanceBatchIdProvider.notifier).state = newValue; }, );
              },
              loading: () => const Row(children: [CircularProgressIndicator(), SizedBox(width: 10), Text('Loading batches...')]),
              error: (err, stack) => Text('Error loading batches: $err'),
            ),
          ),
          const Divider(),
          Expanded( child: _buildAttendanceList(context, ref), ),
        ],
      ),
    );
  }

  // Helper widget _buildAttendanceList (unchanged)
  Widget _buildAttendanceList(BuildContext context, WidgetRef ref) {
    final selectedBatchId = ref.watch(selectedAttendanceBatchIdProvider);
    final attendanceListAsync = ref.watch(attendanceListProvider);
    if (selectedBatchId == null) { return const EmptyPlaceholder( icon: Icons.edit_calendar_outlined, message: 'Please select a date and batch above to take attendance.',); }
    return attendanceListAsync.when(
      data: (attendanceStatusList) {
        if (attendanceStatusList.isEmpty) {
          final batchName = ref.read(batchListProvider).maybeWhen( data: (batches) => batches.firstWhere((b) => b.id == selectedBatchId, orElse: ()=> Batch(name:"Selected")).name, orElse: () => "Selected",) ?? 'Selected';
          return EmptyPlaceholder( icon: Icons.person_off_outlined, message: 'No students found in the "$batchName" batch.', );
        }
        return ListView.builder(
          itemCount: attendanceStatusList.length,
          itemBuilder: (context, index) {
            final status = attendanceStatusList[index];
            return AttendanceListItem( key: ValueKey('${status.student.id}_${ref.read(formattedSelectedDateProvider)}'), status: status,);
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) { final theme = Theme.of(context); return Center(child: Padding( padding: const EdgeInsets.all(16.0), child: Text("Error loading attendance data:\n$error", textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)), )); },
    );
  }
}