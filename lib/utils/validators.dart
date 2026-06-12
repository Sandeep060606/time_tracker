class Validators {
  const Validators._();

  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  static bool isValidQr(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && trimmed.length >= 3;
  }
}
