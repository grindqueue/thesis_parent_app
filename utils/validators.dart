class AppValidators {
  // ── Email ─────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    return null;
  }

  // ── Confirm Password ──────────────────────────────────────────────
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original) return 'Passwords do not match';
      return null;
    };
  }

  // ── Full Name ─────────────────────────────────────────────────────
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 80) return 'Name is too long';
    return null;
  }

  // ── Child Age ─────────────────────────────────────────────────────
  static String? childAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final age = int.tryParse(value.trim());
    if (age == null) return 'Enter a valid number';
    if (age < 1 || age > 17) return 'Age must be between 1 and 17';
    return null;
  }

  // ── Device ID ─────────────────────────────────────────────────────
  static String? deviceId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Device ID is required';
    if (value.trim().length < 4) return 'Invalid device ID';
    return null;
  }

  // ── OTP ───────────────────────────────────────────────────────────
  static String? otp(String value) {
    if (value.length < 6) return 'Enter the complete 6-digit code';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP must be 6 digits';
    return null;
  }

  // ── Required Field (generic) ──────────────────────────────────────
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
