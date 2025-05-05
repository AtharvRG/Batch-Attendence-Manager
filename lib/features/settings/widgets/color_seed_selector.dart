// lib/features/settings/widgets/color_seed_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/theme/app_theme.dart'; // Need AppColorSeed enum
import 'package:dance_class_tracker/core/theme/theme_provider.dart'; // Need colorSeedProvider

class ColorSeedSelector extends ConsumerWidget {
  const ColorSeedSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(colorSeedProvider);
    final availableSeeds = AppColorSeed.values; // Get all enum values

    return Wrap( // Use Wrap for horizontal layout that wraps
      spacing: 8.0, // Horizontal space between chips
      runSpacing: 4.0, // Vertical space if wraps
      alignment: WrapAlignment.start, // Align chips to the start
      children: availableSeeds.map((seed) {
        final bool isSelected = currentColor.value == seed.color.value;

        return ChoiceChip(
          label: Text(seed.name[0].toUpperCase() + seed.name.substring(1)), // Capitalize name
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(colorSeedProvider.notifier).setColorSeed(seed.color);
            }
          },
          avatar: CircleAvatar( // Show color swatch
            backgroundColor: seed.color,
            radius: 8, // Small avatar
          ),
          selectedColor: seed.color.withOpacity(0.3), // Indicate selection
          labelStyle: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? seed.color : Theme.of(context).colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1.0,
              )
          ),
        );
      }).toList(),
    );
  }
}