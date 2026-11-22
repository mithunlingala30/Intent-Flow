class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your email address';
    if (!_email.hasMatch(s)) return 'Enter a valid email address';
    return null;
  }

  static String? name(String? v) {
    if ((v?.trim() ?? '').length < 2) return 'Enter your name';
    return null;
  }

  /// Sign-up rule: 8+ chars with at least one letter and one number.
  static String? newPassword(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
      return 'Include at least one letter and one number';
    }
    return null;
  }

  static String? required(String? v, [String msg = 'This field is required']) =>
      (v == null || v.isEmpty) ? msg : null;
}
