import 'package:email_validator/email_validator.dart';

/// Shared, composable `TextFormField` validators.
///
/// Every screen that has a form (sign in, sign up, add expense) mixes this
/// in instead of re-writing the same "is it empty" / "is it a valid email"
/// checks inline, keeping the validation rules consistent app-wide.
mixin FormValidationMixin {
  String? validateRequired(
    String? value, {
    String fieldLabel = 'This field',
    int minLength = 1,
    int? maxLength,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < minLength) {
      return '$fieldLabel must be at least $minLength character(s).';
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldLabel must be $maxLength characters or fewer.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || !EmailValidator.validate(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String? value, {int minLength = 7}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < minLength) {
      return 'Password must be at least $minLength characters.';
    }
    return null;
  }

  String? validatePositiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an amount.';
    }
    final parsed = num.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid amount greater than zero.';
    }
    return null;
  }
}
