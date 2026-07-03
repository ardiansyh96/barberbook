/// Form validation utilities for all input fields in BarberBook.
///
/// Returns null if valid, or an error message string if invalid.
/// This pattern is compatible with Flutter's FormField validator parameter.
class Validators {
  Validators._();

  /// Validates that a field is not empty
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email format using a comprehensive regex
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password meets minimum requirements
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validates that confirmation matches the original password
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != originalPassword) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Validates Indonesian phone number format
  /// Accepts formats: 08xxx, +62xxx, 62xxx
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates a name field (min 2 characters, letters only)
  static String? name(String? value, [String fieldName = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  /// Compose multiple validators - runs them in order, returns first error
  static String? compose(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
