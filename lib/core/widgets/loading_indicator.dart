import 'package:flutter/material.dart';

// A simple, centered CircularProgressIndicator.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Center the progress indicator on the screen
    return const Center(
      // Use the platform-adaptive circular progress indicator
      child: CircularProgressIndicator.adaptive(),
    );
  }
}