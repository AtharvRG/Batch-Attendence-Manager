import 'package:flutter/material.dart';

// A reusable widget to display when a list or view is empty.
class EmptyPlaceholder extends StatelessWidget {
  final String message; // The text message to display
  final IconData icon;   // The icon to display above the message

  const EmptyPlaceholder({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme data

    return Center( // Center the content vertically and horizontally
      child: Padding(
        padding: const EdgeInsets.all(32.0), // Add padding around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically in the Column
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: [
            // Display the icon
            Icon(
              icon,
              size: 80, // Adjust icon size as needed
              // Use a less prominent theme color for the icon
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 20), // Spacing between icon and message
            // Display the message
            Text(
              message,
              textAlign: TextAlign.center, // Center align the text message
              // Use a slightly subdued text style
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                height: 1.4, // Adjust line height for readability if multi-line
              ),
            ),
          ],
        ),
      ),
    );
  }
}