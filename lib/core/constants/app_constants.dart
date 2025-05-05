// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';

// --- General App Info ---
const String appTitle = 'Dance Class Tracker';

// --- UI Constants ---
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kListItemVerticalPadding = 5.0;
const double kListItemHorizontalPadding = 12.0;
const double kCardElevation = 1.5; // Consistent card elevation
const double kCardBorderRadius = 12.0; // Consistent corner radius

// --- Durations ---
const Duration kSnackBarDuration = Duration(seconds: 3);
const Duration kShortSnackBarDuration = Duration(seconds: 2);

// --- Default Messages ---
const String kErrorLoadingData = 'Failed to load data. Please try again.';
const String kGenericError = 'An unexpected error occurred.';

// --- Formatting ---
// Moved date formats to date_formatter.dart

// Example other constants if needed:
// const int kMaxStudentsPerBatch = 20;
// const String kDefaultBatchName = 'New Batch';