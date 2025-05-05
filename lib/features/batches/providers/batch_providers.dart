import 'dart:async';
import 'package:flutter/material.dart'; // For TextEditingController
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/database/database_service.dart'; // Import sqflite service
import 'package:dance_class_tracker/core/models/batch.dart'; // Import Batch model

// State Notifier managing the asynchronous list of Batches
class BatchListNotifier extends StateNotifier<AsyncValue<List<Batch>>> {
  final DatabaseService _dbService; // Injected database service instance

  // Constructor: Initializes with a loading state and immediately fetches data.
  BatchListNotifier(this._dbService) : super(const AsyncValue.loading()) {
    print("--- BatchListNotifier: Initializing and fetching initial batches...");
    _fetchBatches(); // Load initial data when the notifier is first created
  }

  // Private helper method to fetch all batches from the database.
  // It updates the notifier's state with either data, loading, or error.
  Future<void> _fetchBatches() async {
    // Set loading state only if the current state isn't already loading,
    // to prevent unnecessary screen flashes during rapid refreshes.
    if (state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }
    try {
      // Await the database call to get all batches.
      final batches = await _dbService.getAllBatches();

      // Sort batches alphabetically by name (case-insensitive) for consistent display.
      batches.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      // Check if the notifier is still mounted (i.e., the provider is still active)
      // before attempting to update the state. This prevents errors if the
      // widget listening to this provider is disposed before the async operation completes.
      if (mounted) {
        // Update the state with the fetched and sorted data, wrapped in AsyncValue.data.
        state = AsyncValue.data(batches);
        print("--- BatchListNotifier: Fetched and updated state with ${batches.length} batches.");
      } else {
        print("--- BatchListNotifier: Notifier unmounted after fetch, state not updated.");
      }
    } catch (e, s) { // Catch any potential errors during database interaction.
      print("--- BatchListNotifier: CRITICAL Error fetching batches: $e\n$s");
      // Update the state with the error information if still mounted.
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  // Public method to add a new batch to the database.
  // After insertion, it refreshes the list state.
  Future<void> addBatch(Batch batch) async {
    // Indicate potential start of operation (optional, as fetch sets loading)
    // state = const AsyncValue.loading();
    try {
      print("--- BatchListNotifier: Attempting to add batch ID: ${batch.id}, Name: ${batch.name}");
      // Call the database service to insert the new batch.
      await _dbService.insertBatch(batch);
      // Refresh the entire list from the database to reflect the addition.
      await _fetchBatches();
      print("--- BatchListNotifier: Successfully added batch and refreshed list.");
    } catch (e) {
      print("--- BatchListNotifier: Error adding batch ID: ${batch.id}: $e");
      // Let the calling UI handle the error feedback by rethrowing.
      rethrow;
    }
  }

  // Public method to update an existing batch in the database.
  // After update, it refreshes the list state.
  Future<void> updateBatch(Batch batch) async {
    // Indicate potential start of operation (optional)
    // state = const AsyncValue.loading();
    try {
      print("--- BatchListNotifier: Attempting to update batch ID: ${batch.id}, Name: ${batch.name}");
      // Call the database service to update the batch.
      await _dbService.updateBatch(batch);
      // Refresh the list to show the updated batch information.
      await _fetchBatches();
      print("--- BatchListNotifier: Successfully updated batch and refreshed list.");
    } catch (e) {
      print("--- BatchListNotifier: Error updating batch ID: ${batch.id}: $e");
      rethrow; // Propagate error
    }
  }

  // Public method to delete a batch from the database by its ID.
  // After deletion, it refreshes the list state.
  Future<void> deleteBatch(String batchId) async {
    // Indicate potential start of operation (optional)
    // state = const AsyncValue.loading();
    try {
      print("--- BatchListNotifier: Attempting to delete batch ID: $batchId");
      // Call the database service to delete the batch.
      await _dbService.deleteBatch(batchId);
      // Refresh the list to remove the deleted item.
      await _fetchBatches();
      print("--- BatchListNotifier: Successfully deleted batch and refreshed list.");
    } catch (e) {
      print("--- BatchListNotifier: Error deleting batch ID: $batchId: $e");
      rethrow; // Propagate error
    }
  }

  // Public method to allow UI elements (like a refresh indicator or button)
  // to manually trigger a refetch of the batch list.
  Future<void> refresh() async {
    print("--- BatchListNotifier: Manual refresh requested via refresh().");
    // Re-run the fetch logic.
    await _fetchBatches();
  }
}

// The StateNotifierProvider definition.
// This creates the BatchListNotifier instance when first read
// and provides it to the application.
final batchListProvider = StateNotifierProvider<BatchListNotifier, AsyncValue<List<Batch>>>((ref) {
  print("--- Creating BatchListNotifier instance via provider.");
  // Pass the singleton DatabaseService instance to the notifier.
  return BatchListNotifier(DatabaseService());
});


// --- Providers for managing the state of the Add/Edit Batch Form ---

// StateProvider to hold the specific Batch object being edited.
// It's null when the user is adding a *new* batch.
final editingBatchProvider = StateProvider<Batch?>((ref) {
  // Initial state is null (no batch being edited by default).
  return null;
});

// Provider for the TextEditingController used in the batch name input field.
// `autoDispose` ensures the controller resources are automatically cleaned up
// when the provider is no longer listened to (e.g., when the Add/Edit screen is closed).
final batchNameControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  // Watch the `editingBatchProvider` to get the batch being edited, if any.
  final editingBatch = ref.watch(editingBatchProvider);
  // Initialize the controller with the name of the batch being edited, or empty if adding new.
  final controller = TextEditingController(text: editingBatch?.name ?? '');

  // Register a disposal function using `ref.onDispose`.
  // This ensures the controller's resources are released when the provider is disposed.
  ref.onDispose(() {
    print("--- Disposing batchNameControllerProvider's TextEditingController.");
    controller.dispose();
  });

  // Return the created controller instance.
  return controller;
});