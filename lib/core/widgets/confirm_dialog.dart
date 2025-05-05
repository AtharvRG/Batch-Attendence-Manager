import 'package:flutter/material.dart';

/// Shows a platform-adaptive confirmation dialog.
///
/// Returns `true` if the user confirms (presses [confirmText]),
/// `false` otherwise (presses [cancelText] or dismisses the dialog).
Future<bool> showConfirmDialog(
    BuildContext context, {
      required String title, // The title of the dialog
      required String content, // The main message/content of the dialog
      String confirmText = 'Confirm', // Text for the confirmation button
      String cancelText = 'Cancel', // Text for the cancellation button
      bool isDestructiveAction = false, // If true, makes confirm button look destructive (e.g., red text on iOS)
    }) async {
  // Use showDialog which adapts based on platform (Material vs Cupertino)
  final result = await showDialog<bool>(
    context: context,
    // barrierDismissible: false, // Uncomment to prevent dismissing by tapping outside
    builder: (BuildContext dialogContext) {
      // Build the AlertDialog content
      return AlertDialog.adaptive( // Use adaptive constructor
        title: Text(title),
        content: SingleChildScrollView( // Ensure content scrolls if too long
          child: Text(content),
        ),
        actions: <Widget>[
          // Cancellation Button (typically TextButton)
          TextButton(
            child: Text(cancelText),
            onPressed: () {
              Navigator.of(dialogContext).pop(false); // Return false when cancelled
            },
          ),
          // Confirmation Button (can be TextButton or FilledButton)
          TextButton(
            // Apply destructive styling if needed
            style: TextButton.styleFrom(
              foregroundColor: isDestructiveAction
                  ? Theme.of(dialogContext).colorScheme.error // Use error color for destructive actions
                  : null, // Use default color otherwise
            ),
            child: Text(confirmText),
            onPressed: () {
              Navigator.of(dialogContext).pop(true); // Return true when confirmed
            },
          ),
          // Alternative using FilledButton for primary confirm action:
          // FilledButton(
          //   style: isDestructiveAction ? FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.errorContainer, foregroundColor: Theme.of(dialogContext).colorScheme.onErrorContainer) : null,
          //   child: Text(confirmText),
          //   onPressed: () {
          //      Navigator.of(dialogContext).pop(true);
          //   },
          // )
        ],
      );
    },
  );
  // showDialog returns null if dismissed by tapping outside the barrier.
  // Treat null as false (user didn't explicitly confirm).
  return result ?? false;
}