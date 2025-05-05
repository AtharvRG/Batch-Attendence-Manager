// Utility class for common form input validation logic
class Validators {

  // Validates names (student, parent, etc.)
  // Ensures value is not empty and meets minimum length requirement.
  static String? name(String? value, String fieldName) {
    final trimmedValue = value?.trim() ?? ''; // Trim whitespace or default to empty
    if (trimmedValue.isEmpty) {
      return 'Please enter the $fieldName'; // Error if empty
    }
    if (trimmedValue.length < 2) {
      // Example: Require at least 2 characters for a name
      return '$fieldName should be at least 2 characters long';
    }
    // Optional: Add more complex validation like regex for allowed characters if needed
    // final nameRegExp = RegExp(r"^[a-zA-Z\s'-]+$"); // Example regex
    // if (!nameRegExp.hasMatch(trimmedValue)) {
    //   return 'Please enter a valid $fieldName';
    // }
    return null; // Return null signifies valid input
  }

  // Validates mobile phone numbers
  // Checks if compulsory and matches a basic pattern (allows optional '+', requires digits).
  static String? mobileNumber(String? value, {bool isCompulsory = true}) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      // Return error only if the field is marked as compulsory
      return isCompulsory ? 'Please enter a mobile number' : null;
    }

    // Basic pattern: Optional '+' at start, followed by digits.
    // Removes spaces/hyphens for validation check. Adjust length requirement if needed.
    final digitOnlyValue = trimmedValue.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    // Example: Basic check for at least 7 digits (adjust as needed for local formats)
    if (digitOnlyValue.length < 7) {
      return 'Please enter a valid mobile number (at least 7 digits)';
    }

    // More robust regex for international numbers (optional):
    // final phoneRegExp = RegExp(r'^\+?[1-9]\d{1,14}$'); // E.164 basic pattern
    // if (!phoneRegExp.hasMatch(trimmedValue.replaceAll(RegExp(r'\s+|-'), ''))) {
    //    return 'Please enter a valid international mobile number format';
    // }

    return null; // Valid
  }

  // Convenience validator for optional mobile numbers
  static String? optionalMobileNumber(String? value) {
    // If the value is present, validate it; otherwise, it's valid (null)
    if (value != null && value.trim().isNotEmpty) {
      return mobileNumber(value, isCompulsory: false);
    }
    return null; // Empty optional field is valid
  }

// Add other common validators as needed (e.g., email, password complexity)
/*
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }
    // Basic email regex (consider using a package like `email_validator` for robustness)
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  */
}