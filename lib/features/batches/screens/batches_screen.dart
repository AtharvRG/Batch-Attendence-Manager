import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart';
import 'package:dance_class_tracker/features/batches/widgets/batch_list_item.dart';
import 'package:dance_class_tracker/features/batches/screens/add_edit_batch_screen.dart';
import 'package:dance_class_tracker/core/widgets/empty_placeholder.dart';
import 'package:dance_class_tracker/core/widgets/loading_indicator.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsyncValue = ref.watch(batchListProvider);

    return Scaffold(
      appBar: AppBar( title: const Text('Batches'), actions: [ IconButton( icon: const Icon(Icons.refresh_outlined), tooltip: 'Refresh Batches', onPressed: () => ref.read(batchListProvider.notifier).refresh(),),], ),
      body: batchesAsyncValue.when(
        data: (batchList) {
          if (batchList.isEmpty) {
            // --- FIX Icon Name ---
            return const EmptyPlaceholder(
              icon: Icons.group_work_outlined, // Corrected icon name
              message: 'No batches created yet.\nTap the button below to add your first batch!',
            );
          }
          return RefreshIndicator.adaptive( onRefresh: () => ref.read(batchListProvider.notifier).refresh(), child: ListView.builder( physics: const AlwaysScrollableScrollPhysics(), itemCount: batchList.length, itemBuilder: (context, index) { final batch = batchList[index]; return BatchListItem(key: ValueKey(batch.id), batch: batch); },),);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) { return Center( child: Padding( padding: const EdgeInsets.all(16.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48), const SizedBox(height: 16), Text('Failed to load batches', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), Text('$error', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center), const SizedBox(height: 20), ElevatedButton.icon( icon: const Icon(Icons.refresh), label: const Text('Retry'), onPressed: () => ref.read(batchListProvider.notifier).refresh(),) ],),),); },
      ),
      floatingActionButton: FloatingActionButton.extended( heroTag: 'fab_batches', icon: const Icon(Icons.add), label: const Text('Add Batch'), onPressed: () { ref.read(editingBatchProvider.notifier).state = null; Navigator.push( context, MaterialPageRoute( builder: (context) => const AddEditBatchScreen(isEditMode: false),), ); }, tooltip: 'Add New Batch',),
    );
  }
}